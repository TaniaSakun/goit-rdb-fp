-- Task 1: Load Data and Normalize
CREATE SCHEMA pandemic;
USE pandemic;

-- Task 2: Normalize to 3NF
CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_name VARCHAR(255) UNIQUE NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL
);
SELECT * FROM entities;

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
SELECT * FROM infectious_cases_normalized LIMIT 10;

-- Task 3: Analyze Data
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

-- Task 4: Build a Year Difference Column
SELECT 
    year,
    DATE(CONCAT(year, '-01-01')) AS first_january,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(YEAR, DATE(CONCAT(year, '-01-01')), CURDATE()) AS year_difference
FROM infectious_cases_normalized;

-- Task 5: Create a Custom Function
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