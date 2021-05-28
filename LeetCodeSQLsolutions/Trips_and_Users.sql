/*+-------------+----------+
| Column Name | Type     |
+-------------+----------+
| Id          | int      |
| Client_Id   | int      |
| Driver_Id   | int      |
| City_Id     | int      |
| Status      | enum     |
| Request_at  | date     |     
+-------------+----------+
Id is the primary key for this table.
The table holds all taxi trips. Each trip has a unique Id, while Client_Id and Driver_Id are foreign keys to the Users_Id at the Users table.
Status is an ENUM type of (‘completed’, ‘cancelled_by_driver’, ‘cancelled_by_client’).

+-------------+----------+
| Column Name | Type     |
+-------------+----------+
| Users_Id    | int      |
| Banned      | enum     |
| Role        | enum     |
+-------------+----------+
Users_Id is the primary key for this table.
The table holds all users. Each user has a unique Users_Id, and Role is an ENUM type of (‘client’, ‘driver’, ‘partner’).
Status is an ENUM type of (‘Yes’, ‘No’).

TASK:
Write a SQL query to find the cancellation rate of requests with unbanned users (both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03".

The cancellation rate is computed by dividing the number of canceled (by client or driver) requests with unbanned users by the total number of requests with unbanned users on that day.

Return the result table in any order. Round Cancellation Rate to two decimal points.*/

--SOLUTION
WITH q2 AS (

SELECT Request_at as Day, sum(completed_bool) OVER(partition by Request_at) completed_today, count(completed_bool) OVER(partition by Request_at) requested_today   
FROM 
    (SELECT 
      (CASE 
        WHEN trips.Status = 'completed' AND u1.Banned = 'No' AND u2.Banned = 'No' 
            THEN 1
        WHEN trips.Status != 'completed' AND u1.Banned = 'No' AND u2.Banned = 'No'
            THEN 0
        ELSE NULL END) completed_bool, Request_at
     FROM Trips   
     JOIN Users u1
        ON u1.users_id = trips.client_id
     JOIN Users u2
        ON u2.users_id = trips.driver_id             

    ) as q1
)

SELECT Day, ROUND(1-(completed_today/requested_today),2) as "Cancellation Rate"
FROM q2 
WHERE Day IN ('2013-10-01', '2013-10-03','2013-10-02')
GROUP BY Day, "Cancellation Rate"