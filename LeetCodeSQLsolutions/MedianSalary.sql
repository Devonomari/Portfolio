/* Ex table
+-----+------------+--------+
|Id   | Company    | Salary |
+-----+------------+--------+
|1    | A          | 2341   |
|2    | A          | 341    |
|3    | A          | 15     |
|4    | A          | 15314  |
|5    | A          | 451    |
|6    | A          | 513    |
|7    | B          | 15     |
|8    | B          | 13     |
|9    | B          | 1154   |
|10   | B          | 1345   |
|11   | B          | 1221   |
|12   | B          | 234    |
|13   | C          | 2345   |
|14   | C          | 2645   |
|15   | C          | 2645   |
|16   | C          | 2652   |
|17   | C          | 65     |
+-----+------------+--------+

Write a SQL query to find the median salary of each company. Bonus points if you can solve it without using any built-in SQL functions.
*/
---Solution
SELECT Id, Company, Salary
FROM
(
SELECT *, rank() OVER(Partition by Company ORDER BY Salary, ID) as ranking,
COUNT(*) OVER(Partition by Company) total_salaries
FROM Employee
) a

WHERE (CASE WHEN mod(total_salaries,2) = 1 THEN ranking = ROUND(total_salaries/2)
    ELSE ranking = ROUND(total_salaries/2) OR ranking = ROUND(total_salaries/2)+1 END)