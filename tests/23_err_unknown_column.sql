-- Question 2d : columns of SELECT / WHERE / GROUP BY / ORDER BY must exist
CREATE TABLE Persons ( id int, name varchar(30), age int );

SELECT id, salary          -- 'salary' does not exist
FROM Persons
WHERE height > 10          -- 'height' does not exist
GROUP BY town              -- 'town' does not exist
ORDER BY age;
