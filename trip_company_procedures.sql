use trip_company;

# This procedure deletes participants who are not assigned to any trip
DELIMITER $
CREATE PROCEDURE DeleteUnassignedParticipants()
BEGIN
    -- Create a temporary table to store the IDs of participants assigned to a trip
    CREATE TEMPORARY TABLE temp_unassigned_participants
		SELECT p_id
		FROM participants
		WHERE p_id NOT IN (SELECT p_id FROM actual_trip_has_participants);

    -- Delete participants who are not assigned to any trip
    DELETE FROM participants
    WHERE p_id = (SELECT p_id From temp_unassigned_participants ) ;

    -- Drop the temporary table
    DROP TABLE IF EXISTS temp_unassigned_participants;
END $
DELIMITER ;

#2 This procedure adds a new participant to a specific trip based on their details.
DELIMITER $$
CREATE PROCEDURE AddParticipant(IN tripId INT, IN participantId INT, IN firstName VARCHAR(25), IN lastName VARCHAR(25), 
								IN gender VARCHAR(5), IN dob DATE)
BEGIN
    INSERT INTO participants (p_id, first_name, last_name, gender, dob) VALUES (participantId, firstName, lastName, gender, dob);
    INSERT INTO actual_trip_has_participants (at_id, p_id) VALUES (tripId, participantId);
END$$
DELIMITER ;

#3 This procedure calculate the avg age of all the participants.
DELIMITER $$
CREATE PROCEDURE avgPatricipantsAge(OUT average_age DECIMAL(10, 2))
BEGIN
	SELECT AVG(DATEDIFF(CURDATE(), dob) / 365)
		INTO average_age
        FROM participants;
END $$
DELIMITER ;

# This procedure updates the price of a trip by applying a discount percentage
DELIMITER $
CREATE PROCEDURE UpdateTripPriceWithDiscount(IN tripID INT, IN discountPercentage FLOAT)
BEGIN
    DECLARE originalPrice FLOAT;
    DECLARE discountedPrice FLOAT;

    SELECT price INTO originalPrice FROM trip WHERE t_id = tripID;

    SET discountedPrice = originalPrice - (originalPrice * discountPercentage / 100);

    UPDATE trip SET price = discountedPrice WHERE t_id = tripID;
END $
DELIMITER ;

#This procedure retrieves the participants for a specific trip based on the trip ID and an age range
DELIMITER $
CREATE PROCEDURE GetParticipantsByAgeRange(IN tripID INT, IN minAge INT, IN maxAge INT)
BEGIN
	SELECT p.* FROM participants p
    INNER JOIN actual_trip_has_participants ap ON p.p_id = ap.p_id
    INNER JOIN actual_trip at ON ap.at_id = at.at_id
    WHERE at.t_id = tripID AND YEAR(CURDATE()) - YEAR(p.dob) BETWEEN minAge AND maxAge;
END $
DELIMITER ;

#This procedure recommends trips based on the provided area and price range. 
#It considers trips with a similar area and price range, and also takes into account the number of available participants
DELIMITER $
CREATE PROCEDURE GetTripRecommendations(IN area VARCHAR(50), IN minPrice FLOAT, IN maxPrice FLOAT)
BEGIN
	SELECT t.* FROM trip t
    LEFT JOIN (
        SELECT at.t_id, COUNT(ap.p_id) AS participantCount
        FROM actual_trip at
        LEFT JOIN actual_trip_has_participants ap ON at.at_id = ap.at_id
        GROUP BY at.t_id
    ) AS participantStats ON t.t_id = participantStats.t_id
    WHERE t.t_area = area AND t.price BETWEEN minPrice AND maxPrice
    ORDER BY participantStats.participantCount DESC, t.num_of_days ASC;
END $
DELIMITER ;

# This procedure generates a detailed report for a specific trip based on the provided trip ID. 
#The report includes trip details, location information, participants, and assigned guide.
DELIMITER $
CREATE PROCEDURE GenerateTripReport(IN tripID INT)
BEGIN
    DECLARE tripName VARCHAR(50);
    DECLARE tripArea VARCHAR(50);
    DECLARE guideName VARCHAR(25);

    SELECT t_area INTO tripArea FROM trip WHERE t_id = tripID;

    SELECT g_name INTO guideName
    FROM guide
    WHERE g_id = (SELECT g_id FROM actual_trip WHERE at_id = tripID);

    SELECT CONCAT(first_name, ' ', last_name) AS participantName
    FROM participants p
    INNER JOIN actual_trip_has_participants ap ON p.p_id = ap.p_id
    WHERE ap.at_id = tripID;

    SELECT l_name, address
    FROM locations
    INNER JOIN actual_trip_has_locations al ON locations.l_id = al.l_id
    WHERE al.at_id = tripID;

    SELECT CONCAT('Trip Report - Trip ID: ', tripID, ', Area: ', tripArea) AS reportTitle;
    SELECT CONCAT('Assigned Guide: ', guideName) AS guideInfo;
    
    
END $
DELIMITER ;

call GenerateTripReport(2);

# procedure that takes an input parameter representing the number of people and returns 
# all relevant actual trips that have enough available seats for the assigned participants
DELIMITER $

CREATE PROCEDURE FindAvailableTrips(IN numPeople INT)
BEGIN
    SELECT at.at_id, at.t_id, at.start_date, at.end_date
    FROM actual_trip at
    JOIN (
        SELECT atp.at_id, COUNT(atp.p_id) AS assigned_participants
        FROM actual_trip_has_participants atp
        GROUP BY atp.at_id
    ) AS assigned ON at.at_id = assigned.at_id
    JOIN (
        SELECT atb.at_id, SUM(b.num_of_seats) AS total_seats
        FROM actual_trip_has_buses atb
        JOIN bus b ON atb.plate_number = b.plate_number
        GROUP BY atb.at_id
    ) AS seats ON at.at_id = seats.at_id
    WHERE seats.total_seats >= numPeople + assigned.assigned_participants;
END $

DELIMITER ;


# A function that will return true if we have at least one male participant.
DELIMITER $
CREATE FUNCTION CheckMaleParticipants(actualTripId INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE maleParticipantsCount INT;
    
    SELECT COUNT(*) INTO maleParticipantsCount
    FROM actual_trip_has_participants atp
    JOIN participants p ON atp.p_id = p.p_id
    WHERE atp.at_id = actualTripId
      AND p.gender = 'M';
    
    IF maleParticipantsCount > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END $
DELIMITER ;

# A procedure that takes inputs for creating a new attraction and equipment, and associates them with a specified location ID
DELIMITER $
CREATE PROCEDURE CreateAttractionWithEquipment(
    IN locationID INT,
    IN attractionId INT,
    IN attractionType VARCHAR(35),
    IN attractionName VARCHAR(255),
    IN equipmentType VARCHAR(35),
    IN equipmentID INT
)
BEGIN
    -- Insert new attraction
	declare tripID int;
        
    INSERT INTO attraction (a_id ,l_id, a_type, a_name)
    VALUES (attractionId ,locationID, attractionType, attractionName);
    
    select l.t_id into tripID
    from locations l
    where l.t_id = locationID;
    
    -- Insert new equipment
    INSERT INTO equipment (e_id, t_id, e_type)
    VALUES (equipmentID, tripID, equipmentType);
END $
DELIMITER ;

