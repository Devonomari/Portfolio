--Preview of dataset
SELECT *
FROM annualriderdata
LIMIT 20

/* Data Cleaning/Processing 

	The data set used for the analysis is for July 2021 to June 2020, which includes over 4 million rides.

	There were no Nulls or data integrity issues with ride_id, rideable_type, member_casual columns

	The following query creates a ride/rent time column. Looking at abnormally short rent times revealed a few data issues:
		1.) There exist many rides where the bike was checked out and immediately checked back in to the same station.
		2.) Many rides were rented for absurd amounts of time and will also be removed.
		3.) A few negative rent_times exist and should be removed.
		4.) Many Nulls exist for both return and start locations. These should be removed as well. */

--A query to inspect the data being removed to verify invalidity
SELECT (ended_at - started_at) as rent_time, *
FROM annualriderdata
WHERE (ended_at - started_at) < '00:00:30'
AND (ended_at - started_at) > '03:00:00'
AND (start_station_id IS NULL OR end_station_id IS NULL)
ORDER BY 1 desc

--Data Preparing
-- Filtering out of station Nulls, immediate rent cancelations, and negative time intervals. Delete intentionally not used
-- incase original data needs to be revisted.
SELECT *
FROM annualriderdata
WHERE (ended_at - started_at) > '00:00:30'
AND (ended_at - started_at) < '02:00:00'
AND (start_station_id IS NOT NULL AND end_station_id IS NOT NULL)

-- Next a clean and processed view to fully analyze the data
/*
    Various additional columns were added for easier analysis:
 			
			DISTANCE is being calculated as a resultant vector of the change in latitude and 
            longitude from start station to end station which was converted into miles. This is not a perfect estimation 
            as straight lines do not take into consideration true routes, but may still offer useful insight.
			
				 With pythagorean formula and a google search for the ratio of degrees longitude/latitude to miles I used:
			     -> sqrt(start_lat - end_lat)*69)^2 + ((start_lng-end_lng)*54.6)^2) to get this column 
			
			The timestamps for "started_at" and "ended_at" are being broken down into various columns:
				- MINUTES_RENTED <- interval of time rented = (ended_at-started_at) converted into a numeric type.
				- START_DATE & END_DATE <- Calandar portion of timestamps converted into 'date' data type
				- START_HOUR & END_HOUR <- Hour portion of the timestamps using date_part()
				- WEEKDAY <- used the postgres EXTRACT(DOW FROM ...) function combined with case statement to create a day 
				  of the week column.{The extract function returns an integer 0-6 which is why the case statement is used
			
*/
CREATE VIEW RiderDataCln AS

SELECT ride_id, rideable_type, start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng, member_casual,
    ROUND((EXTRACT(EPOCH FROM (ended_at - started_at))/60)::numeric,1) AS minutes_rented,
	ROUND(sqrt(((start_lat - end_lat)*69)^2 + ((start_lng-end_lng)*54.6)^2), 4) AS distance,
	date_part('hour', started_at) AS start_hour, date_part('hour', ended_at) AS end_hour,
	started_at::date AS start_date, ended_at::date AS end_date,
	(CASE WHEN EXTRACT(DOW FROM started_at) = 0 THEN 'Sunday' 
	 	WHEN EXTRACT(DOW FROM started_at) = 1 THEN 'Monday'
		WHEN EXTRACT(DOW FROM started_at) = 2 THEN 'Tuesday'
		WHEN EXTRACT(DOW FROM started_at) = 3 THEN 'Wednesday'
	 	WHEN EXTRACT(DOW FROM started_at) = 4 THEN 'Thursday'
	 	WHEN EXTRACT(DOW FROM started_at) = 5 THEN 'Friday'
	 	WHEN EXTRACT(DOW FROM started_at) = 6 THEN 'Saturday'	 
	 END) AS weekday
	
FROM annualriderdata
WHERE (ended_at - started_at) > '00:01:00'
AND (ended_at - started_at) < '02:00:00'
AND (start_station_id IS NOT NULL AND end_station_id IS NOT NULL)


--Some additional analysis...

-- What is the average rent time and average distance for member vs casual?
SELECT member_casual, rideable_type, AVG(minutes_rented) as avg_rent_time, ROUND(AVG(distance),3) as avg_dist
FROM RiderDataCln
GROUP BY member_casual, rideable_type

--What is the ride count for members vs casual for weekends vs workweek?
WITH weekendstats AS (
	SELECT member_casual,
	(CASE WHEN weekday = 'Saturday' OR weekday = 'Sunday' THEN 'weekend' ELSE 'weekday' END Weekend_weekday)
	FROM RiderDataCln
	
SELECT member_casual, weekend_weekday, COUNT(*)
FROM weekendstats
GROUP BY member_casual, weekend_weekday
ORDER BY 2

--
SELECT *, sum(d.cnt) OVER(partition by member_casual) as agg FROM(
SELECT COUNT(*) cnt, start_station_name, end_station_name,member_casual, AVG(minutes_rented)
FROM RiderDataCln
GROUP BY rideable_type,start_station_name,end_station_name,member_casual
ORDER BY count(*) DESC
LIMIT 100
) d

SELECT member_casual, COUNT(*)
FROM riderdatacln 
WHERE distance = 0
GROUP BY member_casual
