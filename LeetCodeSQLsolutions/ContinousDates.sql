--PROBLEM

/*Table: Failed

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| fail_date    | date    |
+--------------+---------+
Primary key for this table is fail_date.
Failed table contains the days of failed tasks.

Table: Succeeded

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| success_date | date    |
+--------------+---------+
Primary key for this table is success_date.
Succeeded table contains the days of succeeded tasks.

A system is running one task every day. Every task is independent of the previous tasks. The tasks can fail or succeed.

Write an SQL query to generate a report of period_state for each continuous interval of days in the period from 2019-01-01 to 2019-12-31.

period_state is 'failed' if tasks in this interval failed or 'succeeded' if tasks in this interval succeeded. Interval of days are retrieved as start_date and end_date.

Order result by start_date.

The query result format is in the following example:

Failed table:
+-------------------+
| fail_date         |
+-------------------+
| 2018-12-28        |
| 2018-12-29        |
| 2019-01-04        |
| 2019-01-05        |
+-------------------+

Succeeded table:
+-------------------+
| success_date      |
+-------------------+
| 2018-12-30        |
| 2018-12-31        |
| 2019-01-01        |
| 2019-01-02        |
| 2019-01-03        |
| 2019-01-06        |
+-------------------+


Result table:
+--------------+--------------+--------------+
| period_state | start_date   | end_date     |
+--------------+--------------+--------------+
| succeeded    | 2019-01-01   | 2019-01-03   |
| failed       | 2019-01-04   | 2019-01-05   |
| succeeded    | 2019-01-06   | 2019-01-06   |
+--------------+--------------+--------------+

The report ignored the system state in 2018 as we care about the system in the period 2019-01-01 to 2019-12-31.
From 2019-01-01 to 2019-01-03 all tasks succeeded and the system state was "succeeded".
From 2019-01-04 to 2019-01-05 all tasks failed and system state was "failed".
From 2019-01-06 to 2019-01-06 all tasks succeeded and system state was "succeeded".
*/

--SOLUTION
/*
Strategy: 
I know once I can create a column with a unique numeric identifier for each date range that I then will be able to use a 
group by with the min and max aggreagate functions on the dates of each range group
for the output table. A combination of window functions and case statements should allow me to create one.

*/
WITH 
-- Combine both tables and add a success/fail column. Order by date.
combined_tables AS (
SELECT fail_date as dates, 'failed' as state 
FROM Failed
    
UNION ALL
    
SELECT success_date as dates, 'succeeded' as state 
FROM Succeeded ),
-- Created a column where a value of 1 is assigned if a state change has occured from previous day and 0 otherwise.  
boolean_mask AS(
SELECT *, (CASE WHEN lag(state) OVER(ORDER BY DATES) = state THEN 0 ELSE 1 END) as bool
FROM combined_tables
WHERE dates >= '2019-01-01' AND dates <= '2019-12-31'
ORDER BY dates),
-- Sum over previous boolean column to create +1 value each time state changes
periods_identified AS (
SELECT *, Sum(bool) OVER(order by dates) as identifier
FROM boolean_mask)
-- Group by state and the above column. Use min/max for start and end dates of each range
SELECT state as period_state, min(dates) as start_date, max(dates) as end_date
FROM periods_identified
GROUP BY state, identifier