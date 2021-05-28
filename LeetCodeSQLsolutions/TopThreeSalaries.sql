/*
Employee Table
+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| Id           | int     |
| Name         | varchar |
| Salary       | int     |
| DepartmentId | int     |
+--------------+---------+
Id is the primary key for this table.
Each row contains the ID, name, salary, and department of one employee.

Department Table
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| Id          | int     |
| Name        | varchar |
+-------------+---------+
Id is the primary key for this table.
Each row contains the ID and the name of one department.

TASK: 
A company's executives are interested in seeing who earns the most money in each of the company's departments. 
A high earner in a department is an employee who has a salary in the top three unique salaries for that department.
Write an SQL query to find the employees who are high earners in each of the departments.

Return the result table in any order.*/

--SOLUTION
With highest_earners as(
SELECT d.Name as Department, e.Name as Employee, e.Salary as Salary, dense_rank() OVER(partition by Departmentid order by Salary desc) ranking
FROM employee e 
JOIN department d
ON e.departmentid = d.id
)
SELECT Department, Employee, Salary
FROM highest_earners
WHERE ranking <= 3