use trip_company;

# Manager
# Retrieve the count of participants per actual trip.
SELECT at_id, COUNT(p_id) AS participant_count
FROM actual_trip_has_participants
GROUP BY at_id;

# Manager
# Retrieve the names of attractions and the corresponding locations for actual trips that have more than 2 participants.
SELECT a.a_name, l.l_name, COUNT(atp.p_id) as num_of_participants
FROM attraction a
JOIN locations l ON a.l_id = l.l_id
JOIN actual_trip_has_locations atl ON l.l_id = atl.l_id
JOIN actual_trip_has_participants atp ON atl.at_id = atp.at_id
GROUP BY l.l_name , a.a_name
HAVING COUNT(atp.p_id) > 2;

#Manager
# Query to retrieve the names of participants who have been on multiple trips
SELECT p.first_name, p.last_name
FROM participants p
INNER JOIN actual_trip_has_participants atp ON p.p_id = atp.p_id
GROUP BY p.p_id, p.first_name, p.last_name
HAVING COUNT(atp.at_id) > 1;

#Manager
#Query to retrieve the trips where all participants are of the same gender
SELECT at.at_id,l.l_name , t.num_of_days, t.price
FROM actual_trip at
INNER JOIN trip t ON at.t_id = t.t_id
INNER JOIN actual_trip_has_participants atp ON at.at_id = atp.at_id
INNER JOIN participants p ON atp.p_id = p.p_id
INNER JOIN locations l on l.t_id = t.t_id
GROUP BY at.at_id, t.num_of_days, t.price, l.l_name
HAVING COUNT(DISTINCT p.gender) = 1;

#Manager
#Query to retrieve the guide who has the most trips and the total duration of their trips
SELECT g.g_id, g.g_name, COUNT(at.at_id) AS num_trips, SUM(t.num_of_days) AS total_duration
FROM guide g
INNER JOIN actual_trip at ON g.g_id = at.g_id
INNER JOIN trip t ON at.t_id = t.t_id
GROUP BY g.g_id, g.g_name
HAVING COUNT(at.at_id) = (
    SELECT MAX(trip_count)
    FROM (
        SELECT g_id, COUNT(at_id) AS trip_count
        FROM actual_trip
        GROUP BY g_id
    ) AS subquery
);

# Manager
# Retrive all actual trips that the date difference is greater than 5 days and there is at least one male participant.
SELECT at.at_id, at.start_date, at.end_date, t.num_of_days, t.price, g.g_name, g.gender, g.dob
FROM actual_trip at
JOIN trip t ON at.t_id = t.t_id
JOIN guide g ON at.g_id = g.g_id
WHERE DATEDIFF(at.end_date, at.start_date) > 5
  AND CheckMaleParticipants(at.at_id) = TRUE;

# Participants
#Retrieve the trip details (trip ID, number of days, price) 
#along with the corresponding guide names (guide ID, guide name) for all actual trips.
SELECT at.at_id, t.num_of_days, t.price, g.g_id, g.g_name
FROM actual_trip at
JOIN trip t ON at.t_id = t.t_id
JOIN guide g ON at.g_id = g.g_id;

#Participants
# Retrieve the buses of every actual trip
SELECT at.at_id, GROUP_CONCAT(b.plate_number) AS bus_plate_numbers
FROM actual_trip at
INNER JOIN actual_trip_has_buses atb ON at.at_id = atb.at_id
INNER JOIN bus b ON atb.plate_number = b.plate_number
GROUP BY at.at_id;

# Participants
# Retrieve the actual trips that have at least 1 kosher meal
SELECT DISTINCT at.*
FROM actual_trip at
INNER JOIN actual_trip_has_locations atl ON at.at_id = atl.at_id
INNER JOIN locations l ON atl.l_id = l.l_id
INNER JOIN restaurants r ON l.l_id = r.l_id
INNER JOIN meals m ON r.r_id = m.r_id
WHERE m.kosher = true;

# Participants
# Retrieve all trips that the duration is above 3 days and taking place in Mount Kilimanjaro and having
# climbing equipment
SELECT distinct t.*
FROM trip t
INNER JOIN actual_trip a_trip ON t.t_id = a_trip.t_id
INNER JOIN actual_trip_has_locations a_loc ON a_trip.at_id = a_loc.at_id
INNER JOIN locations loc ON a_loc.l_id = loc.l_id
INNER JOIN equipment equip ON t.t_id = equip.t_id
WHERE t.num_of_days > 3
AND loc.l_name = 'Hermon Mount'
AND equip.e_type = 'Climbing Gear';

# Participants
# Retrieve all trips with their associated guides, participants, and the number of attractions available at each location
SELECT t.*, g.g_name, p.first_name, p.last_name, COUNT(a.a_id) AS num_of_attractions
FROM trip t
INNER JOIN actual_trip a_trip ON t.t_id = a_trip.t_id
INNER JOIN guide g ON a_trip.g_id = g.g_id
INNER JOIN actual_trip_has_participants a_part ON a_trip.at_id = a_part.at_id
INNER JOIN participants p ON a_part.p_id = p.p_id
INNER JOIN actual_trip_has_locations a_loc ON a_trip.at_id = a_loc.at_id
LEFT JOIN attraction a ON a_loc.l_id = a.l_id
GROUP BY t.t_id, g.g_id, p.p_id;



