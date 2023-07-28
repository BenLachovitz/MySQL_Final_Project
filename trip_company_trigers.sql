#A log table for the next trigger
create table avg_age_log
(
	log_id int auto_increment primary key, 
	avg_age double,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)engine = InnoDB;

# Trigger to calculate the average age of participants when a new participant is added
delimiter $
CREATE TRIGGER calculate_average_age AFTER INSERT ON participants
FOR EACH ROW
BEGIN
    CALL avgPatricipantsAge(@M);
    INSERT INTO avg_age_log (avg_age) value (@M);
END $
delimiter ;

# Trigger to prevent deleting a guide who is currently assigned to an actual trip
delimiter $
CREATE TRIGGER prevent_guide_deletion BEFORE DELETE ON guide
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM actual_trip WHERE g_id = OLD.g_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete a guide who is currently assigned to an actual trip.';
    END IF;
END $
delimiter ;

select * from guide;

select* from actual_trip;

delete from guide where g_id = 4;

#A log table for the next trigger
CREATE TABLE trip_price_logs (
    log_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    t_id INT NOT NULL,
    old_price FLOAT,
    new_price FLOAT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

#A trigger that allow us to follow the price updates of a trip
DELIMITER $
CREATE TRIGGER update_trip_price
AFTER UPDATE ON trip
FOR EACH ROW
BEGIN
    IF NEW.price <> OLD.price THEN
        INSERT INTO trip_price_logs (t_id, old_price, new_price)
        VALUES (OLD.t_id, OLD.price, NEW.price);
    END IF;
END $
DELIMITER ;

# A trigger before updating a start or end date of an actual trip.
# we will check if the duration is matched to the trip it self before the update.
DELIMITER $
CREATE TRIGGER trip_date_change_trigger
BEFORE UPDATE ON actual_trip
FOR EACH ROW
BEGIN
		declare trip_duration int;
    IF OLD.start_date <> NEW.start_date OR OLD.end_date <> NEW.end_date THEN
        SET trip_duration = DATEDIFF(NEW.end_date, NEW.start_date) + 1;
        IF trip_duration != (SELECT t.num_of_days from trip t where t.t_id = NEW.t_id) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The dates you entered doesnt match the number of trip days.';
        END IF;
	END IF;
END $
DELIMITER ;

select * from trips;

#Log table for the next trigger
CREATE TABLE bus_count_logs (
    log_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    added_bus_plate_number VARCHAR(25),
    bus_count INT,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
#A trigger to count how many buses there are to the company after a new bus is added
DELIMITER $
CREATE TRIGGER bus_count_trigger
AFTER INSERT ON bus
FOR EACH ROW
BEGIN
	DECLARE bus_count int;
    SET bus_count = 0;
    
    SELECT COUNT(*) INTO bus_count FROM bus;
    
    INSERT INTO bus_count_logs (added_bus_plate_number, bus_count)
    VALUES (NEW.plate_number, bus_count);
END $
DELIMITER ; 

#When restaurant is deleted we wish to delete the relevant meal before
DELIMITER $
CREATE TRIGGER delete_meal_trigger
BEFORE DELETE ON restaurants
FOR EACH ROW
BEGIN
    DELETE FROM meals WHERE r_id = OLD.r_id;
END $
DELIMITER ;

#Automatically assign a guide to an actual trip when it is created.
DELIMITER $
CREATE TRIGGER assign_guide
BEFORE INSERT ON actual_trip
FOR EACH ROW
BEGIN
    SET NEW.g_id = (
        SELECT g_id
        FROM guide
        ORDER BY RAND()
        LIMIT 1
    );
END $
DELIMITER ;


#Generate a unique ID for each new equipment record.
DELIMITER $
CREATE TRIGGER generate_equipment_id
BEFORE INSERT ON equipment
FOR EACH ROW
BEGIN
    SET NEW.e_id = (
        SELECT IFNULL(MAX(e_id), 0) + 1
        FROM equipment
    );
END $
DELIMITER ;

# Prevent a duplicated license plate
DELIMITER $
CREATE TRIGGER prevent_duplicate_plate_number
BEFORE INSERT ON bus
FOR EACH ROW
BEGIN
    DECLARE plate_count INT;

    SET plate_count = (
        SELECT COUNT(*)
        FROM bus
        WHERE plate_number = NEW.plate_number
    );

    IF plate_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot insert bus. Plate number already exists.';
    END IF;
END $
DELIMITER ;


#After a restaurant is added, we will generate a random meal for that restaurant.
DELIMITER $
CREATE TRIGGER insert_meal_after_restaurant
AFTER INSERT ON restaurants
FOR EACH ROW
BEGIN
    DECLARE rnd INT;
    DECLARE m INT;
    SET rnd = FLOOR(RAND() * 2); -- Generate random number between 0 and 1
    SET m = (SELECT IFNULL(MAX(m_id), 0) + 1
        FROM meals);
    INSERT INTO meals (m_id, r_id, kosher)
    VALUES (m ,NEW.r_id, rnd);
END$
DELIMITER ;







