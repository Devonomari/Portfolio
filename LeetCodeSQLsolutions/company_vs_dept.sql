/*Given two tables as below, write a query to display the comparison result (higher/lower/same) of the 
  average salary of employees in a department for the month to the company's average salary for the month.

  Table: salary
| id | employee_id | amount | pay_date   |
|----|-------------|--------|------------|
| 1  | 1           | 9000   | 2017-03-31 |
| 2  | 2           | 6000   | 2017-03-31 |
| 3  | 3           | 10000  | 2017-03-31 |
| 4  | 1           | 7000   | 2017-02-28 |
| 5  | 2           | 6000   | 2017-02-28 |
| 6  | 3           | 8000   | 2017-02-28 |

| employee_id | department_id |
|-------------|---------------|
| 1           | 1             |
| 2           | 2             |
| 3           | 2             |

So for the sample data above, the result is:

| pay_month | department_id | comparison  |
|-----------|---------------|-------------|
| 2017-03   | 1             | higher      |
| 2017-03   | 2             | lower       |
| 2017-02   | 1             | same        |
| 2017-02   | 2             | same        |
*/


--SOLUTION:
WITH monthly_average AS (

    SELECT   DATE_FORMAT(s.pay_date,'%Y-%m') month, AVG(amount) company_average
    FROM     salary s
    GROUP BY DATE_FORMAT(s.pay_date,'%Y-%m') 

),

average_compare AS (
    
SELECT   e.department_id AS department_id, DATE_FORMAT(s.pay_date,'%Y-%m')  pay_month,                    AVG(s.amount) AS dept_avg, monthly_average.company_average month_avg
FROM     salary s
JOIN     employee e
      ON s.employee_id = e.employee_id
JOIN     monthly_average
      ON monthly_average.month = DATE_FORMAT(s.pay_date,'%Y-%m') 
GROUP BY e.department_id, monthly_average.company_average,  DATE_FORMAT(s.pay_date,'%Y-%m') 

)

SELECT pay_month, department_id, 
    (CASE 
        WHEN dept_avg > month_avg THEN 'higher'
        WHEN dept_avg < month_avg THEN 'lower'
        ELSE 'same' END) as comparison
FROM average_compare
