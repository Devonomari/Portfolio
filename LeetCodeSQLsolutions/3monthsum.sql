/*
PROBLEM:
Table: Employee

+-------------+------+
| Column Name | Type |
+-------------+------+
| Id          | int  |
| Month       | int  |
| Salary      | int  |
+-------------+------+
(Id, Month) is the primary key for this table.
Each row in the table indicates the salary of an employee in one month during the year 2020.
 

Write an SQL query to calculate the cumulative salary summary for every employee in a single unified table.

The cumulative salary summary for an employee can be calculated as follows:

For each month that the employee worked, sum up the salaries in that month and the previous two months. This is their 3-month sum for that month. If an employee did not work for the company in previous months, their effective salary for those months is 0.
Do not include the 3-month sum for the most recent month that the employee worked for in the summary.
Do not include the 3-month sum for any month the employee did not work.
Return the result table ordered by Id in ascending order. In case of a tie, order it by Month in descending order.

The query result format is in the following example:

 

Employee table:
+----+-------+--------+
| Id | Month | Salary |
+----+-------+--------+
| 1  | 1     | 20     |
| 2  | 1     | 20     |
| 1  | 2     | 30     |
| 2  | 2     | 30     |
| 3  | 2     | 40     |
| 1  | 3     | 40     |
| 3  | 3     | 60     |
| 1  | 4     | 60     |
| 3  | 4     | 70     |
| 1  | 7     | 90     |
| 1  | 8     | 90     |
+----+-------+--------+

Result table:
+----+-------+--------+
| id | month | Salary |
+----+-------+--------+
| 1  | 4     | 130    |
| 1  | 3     | 90     |
| 1  | 2     | 50     |
| 1  | 1     | 20     |
| 2  | 1     | 20     |
| 3  | 3     | 100    |
| 3  | 2     | 40     |
+----+-------+--------+
*/

--SOLUTION
-- Usually a simple 3 row sliding window function would work, but here we have skipped months 
-- Hence a multijoin and subquery had to be used
SELECT Id, Month, Salary FROM (
    
    SELECT e.Id AS Id, e.Month AS Month, (e.salary + IFNULL(e1.salary,0) + IFNULL(e2.salary,0)) AS Salary, 
        MAX(e.Month) OVER(Partition By e.id) as recentmonth
    FROM Employee e
    --Left Self Joining the table with the two previous months. 
        LEFT JOIN Employee e1
            ON (e1.Month + 1) = e.Month AND e1.id = e.id
        LEFT JOIN Employee e2
            ON (e2.Month + 2) = e.Month AND e2.id = e.id
    ORDER BY e.id, e.Month DESC

) alias

WHERE Month < recentmonth