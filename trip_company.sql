create schema trip_company;
use trip_company;

create table trip
(
	t_id int not null primary key,
    num_of_days int default 0,
    price float default 0,
    t_area varchar(50)
)engine = InnoDB;

create table equipment
(
	e_id int not null primary key,
    t_id int not null,
    e_type varchar(35),
    foreign key (t_id) references trip(t_id)
)engine = InnoDB;

create table locations
(
	l_id int not null primary key,
    t_id int not null,
    l_name varchar(35),
    address varchar(255),
    foreign key (t_id) references trip(t_id)
)engine = InnoDB;

create table attraction
(
	a_id int not null primary key,
    l_id int not null,
    a_type varchar(35),
    a_name varchar(255),
    foreign key (l_id) references locations(l_id)
)engine = InnoDB;

create table restaurants
(
	r_id int not null primary key,
    l_id int not null,
    a_type varchar(35),
    a_name varchar(255),
    foreign key (l_id) references locations(l_id)
)engine = InnoDB;

create table meals
(
	m_id int not null primary key,
    r_id int not null,
    kosher boolean,
    foreign key (r_id) references restaurants(r_id)
)engine = InnoDB;

create table guide
(
	g_id int not null primary key,
    g_name varchar(25),
    gender varchar(5),
    dob date
)engine = InnoDB;

create table actual_trip
(
	at_id int not null primary key,
    t_id int not null,
    g_id int not null,
    start_date date,
    end_date date,
    at_language varchar(5),
    foreign key (t_id) references trip(t_id),
    foreign key (g_id) references guide(g_id)
)engine = InnoDB;

create table actual_trip_has_locations
(
	at_id int not null,
    l_id int not null,
    start_point varchar(255),
    end_point varchar(255),
    primary key (at_id,l_id),
    foreign key (at_id) references actual_trip(at_id),
    foreign key (l_id) references locations(l_id)
)engine = InnoDB;

create table participants
(
	p_id int not null primary key,
    first_name varchar(25),
    last_name varchar(25),
    gender varchar(5),
    dob date
)engine = InnoDB;

create table actual_trip_has_participants
(
	at_id int not null,
	p_id int not null,
    primary key (at_id,p_id),
    foreign key (at_id) references actual_trip(at_id),
    foreign key (p_id) references participants(p_id)
)engine = InnoDB;

create table bus
(
    plate_number varchar(25) not null primary key,
    num_of_seats int default 0,
    model varchar(25)
)engine = InnoDB;

create table actual_trip_has_buses
(
	at_id int not null,
	plate_number varchar(25) not null,
    primary key (at_id,plate_number),
    foreign key (at_id) references actual_trip(at_id),
    foreign key (plate_number) references bus(plate_number)
)engine = InnoDB;

INSERT INTO trip (t_id, num_of_days, price, t_area) VALUES
(1, 10, 1000, 'Center'),
(2, 7, 750, 'Golan'),
(3, 14, 1500,'South'),
(4, 5, 500,'Center'),
(5, 21, 2000,'Jerusalem');

INSERT INTO equipment (e_id, t_id, e_type) VALUES
(1, 1, 'Backpack'),
(2, 1, 'Tent'),
(3, 3, 'Sleeping Bag'),
(4, 2, 'Climbing Gear'),
(5, 4, 'Fishing Rod');

INSERT INTO locations (l_id, t_id, l_name, address) VALUES
(1, 1, 'Lona Park', '61240 Rokach street, Tel-Aviv'),
(2, 1, 'Zinabeberay Beach', 'Kineret, Tiberias'),
(3, 2, 'Hermon Mount', 'Mt Hermon'),
(4, 3, 'Ashdod Marina', 'Onyon St 1, Ashdod'),
(5, 4, 'Safari', 'Sderat Hatsvi 1, Ramat Gan'),
(6, 5, 'Machne Yuda', 'Machne Yuda, Jerusalem');

INSERT INTO attraction (a_id, l_id, a_type, a_name) VALUES
(1, 1, 'Spare time', 'Amusement Park'),
(2, 2, 'Camping', 'Camping'),
(3, 2, 'BBQ', 'Lunch'),
(4, 3, 'Climbing', 'Hermon'),
(5, 5, 'Amusement', 'Zoo');

INSERT INTO restaurants (r_id, l_id, a_type, a_name) VALUES
(1, 1, 'Fast Food', 'Burger Park'),
(2, 2, 'Mexican', 'El Tovar'),
(3, 3, 'Italian', 'Yellowstone Pizza Co.'),
(4, 4, 'Seafood', 'Benny The Fishman'),
(5, 5, 'African', 'Sunnyside Restaurant');

INSERT INTO meals (m_id, r_id, kosher) VALUES
(1, 1, false),
(2, 1, true),
(3, 2, true),
(4, 4, false),
(5, 5, true);

INSERT INTO guide (g_id, g_name, gender, dob) VALUES
(1, 'John Smith', 'M', '1980-01-01'),
(2, 'Sarah Johnson', 'F', '1985-05-15'),
(3, 'David Lee', 'M', '1990-12-31'),
(4, 'Emma Rodriguez', 'F', '1995-07-10'),
(5, 'Michael Kim', 'M', '1988-03-22');

-- Insert into actual_trip
INSERT INTO actual_trip (at_id, t_id, g_id, start_date, end_date, at_language) 
VALUES 
(1, 1, 1, '2023-06-01', '2023-06-10', 'EN'),
(2, 2, 2, '2023-07-01', '2023-07-08', 'FR'),
(3, 1, 3, '2023-08-01', '2023-08-15', 'ES'),
(4, 3, 4, '2023-09-01', '2023-09-10', 'DE'),
(5, 2, 4, '2023-10-01', '2023-10-07', 'IT');


-- Insert into actual_trip_has_locations
INSERT INTO actual_trip_has_locations (at_id, l_id, start_point, end_point)
VALUES 
(1, 1, 'Airport', 'Hotel'),
(1, 2, 'Hotel', 'Beach'),
(2, 3, 'Airport', 'City Center'),
(3, 1, 'Airport', 'Hotel'),
(3, 2, 'Hotel', 'Museum'),
(4, 4, 'Airport', 'Hotel'),
(4, 5, 'Hotel', 'Mountain Top'),
(5, 3, 'Airport', 'City Center'),
(5, 4, 'City Center', 'Hotel');

-- Insert into participants
INSERT INTO participants (p_id, first_name, last_name, gender, dob) 
VALUES 
(123, 'John', 'Doe', 'M', '1990-01-01'),
(234, 'Jane', 'Doe', 'F', '1995-05-05'),
(345, 'David', 'Smith', 'M', '1985-03-15'),
(456, 'Emily', 'Johnson', 'F', '1989-07-20'),
(567, 'Michael', 'Williams', 'M', '1998-11-10');

-- Insert into actual_trip_has_participants
INSERT INTO actual_trip_has_participants (at_id, p_id) 
VALUES 
(1, 123),
(1, 234),
(2, 234),
(2, 345),
(3, 456),
(3, 567),
(4, 234),
(4, 456);

-- Insert into bus
INSERT INTO bus (plate_number, num_of_seats, model) 
VALUES 
('ABC-123', 50, 'Mercedes-Benz'),
('DEF-456', 45, 'Volvo'),
('GHI-789', 60, 'Scania'),
('JKL-012', 55, 'MAN'),
('MNO-345', 40, 'Iveco');

-- Insert into actual_trip_has_buses
INSERT INTO actual_trip_has_buses (at_id, plate_number) 
VALUES 
(1, 'ABC-123'),
(1, 'DEF-456'),
(2, 'GHI-789'),
(3, 'JKL-012'),
(4, 'MNO-345');

