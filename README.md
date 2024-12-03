# goit-rdb-fp
The repository for the Final Project GoItNeo Relational Databases

Project Description

### Task 1
**Load the data:**
- Create the pandemic schema in the database using SQL.
- Select it as the default schema using SQL.
- Import the data using the Import wizard as you did in topic 3.
- Review the data for context.

```
CREATE SCHEMA pandemic;
USE pandemic;
```
<img width="223" alt="p1" src="https://github.com/user-attachments/assets/391ac9a4-381e-46f5-8b78-9e125e6ab211">

### Task 2 
Normalize the infectious_cases table to the 3rd normal form. Save two tables with the normalized data in the same schema.

```
CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_name VARCHAR(255) UNIQUE NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL
);
SELECT * FROM entities;
```
<img width="548" alt="p2_1" src="https://github.com/user-attachments/assets/390c4f0f-1b1d-4c1b-8c2b-55ec7f5937a7">

```
INSERT INTO entities (entity_name, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

CREATE TABLE infectious_cases_normalized (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    year INT NOT NULL,
    number_rabies FLOAT,
    FOREIGN KEY (entity_id) REFERENCES entities(id)
);

INSERT INTO infectious_cases_normalized (entity_id, year, number_rabies)
SELECT 
    e.id,
    ic.Year,
    CASE WHEN ic.Number_rabies = '' THEN NULL ELSE ic.Number_rabies END
FROM infectious_cases ic
INNER JOIN entities e ON ic.Entity = e.entity_name AND ic.Code = e.code;
SELECT * FROM infectious_cases_normalized LIMIT 50;
```
<img width="770" alt="p2_2" src="https://github.com/user-attachments/assets/0e28f74e-05e2-45a8-b0b0-25c302b29393">

### Task 3
**Analyze the data:**
- For each unique combination of Entity and Code or their id, calculate the average, minimum, maximum, and sum for the Number_rabies attribute.
- Sort the result by the calculated average in descending order.
- Select only 10 rows to display.

```
SELECT 
    e.entity_name,
    e.code,
    AVG(icn.number_rabies) AS avg_rabies,
    MIN(icn.number_rabies) AS min_rabies,
    MAX(icn.number_rabies) AS max_rabies,
    SUM(icn.number_rabies) AS sum_rabies
FROM infectious_cases_normalized icn
INNER JOIN entities e ON icn.entity_id = e.id
WHERE icn.number_rabies IS NOT NULL
GROUP BY e.entity_name, e.code
ORDER BY avg_rabies DESC
LIMIT 10;
```
<img width="548" alt="p3" src="https://github.com/user-attachments/assets/40a4650d-540e-4f4d-b82f-b82fa9c03f28">

### Task 4
Create a difference in the "years" column.
For the original or normalized table for the Year column, build using built-in SQL functions:
an attribute that creates the date of January 1 of the corresponding year,

```
SELECT 
    year,
    DATE(CONCAT(year, '-01-01')) AS first_january,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(YEAR, DATE(CONCAT(year, '-01-01')), CURDATE()) AS year_difference
FROM infectious_cases_normalized;
```
<img width="737" alt="p4" src="https://github.com/user-attachments/assets/d479f0b3-5914-4a12-bb00-5ab52bb00557">

### Task 5
Build your function.
Create and use a function that builds the same attribute as in the previous task: the function should take the year value as input and return the difference in years between the current date and the date created from the year attribute (1996 → ‘1996-01-01’).

```
DELIMITER $$

CREATE FUNCTION calculate_year_difference(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE year_diff INT;
    SET year_diff = TIMESTAMPDIFF(YEAR, DATE(CONCAT(input_year, '-01-01')), CURDATE());
    RETURN year_diff;
END $$

DELIMITER ;

SELECT 
    year,
    calculate_year_difference(year) AS year_difference
FROM infectious_cases_normalized;
```
<img width="777" alt="p5" src="https://github.com/user-attachments/assets/178b8da5-d48c-4dff-9780-cbae7c0af421">
