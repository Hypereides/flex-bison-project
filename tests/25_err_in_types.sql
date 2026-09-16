-- Question 2e-iii : every literal of an IN list must be compatible
CREATE TABLE Persons ( id int, name varchar(30) );

SELECT id FROM Persons WHERE id IN (1, 2, 'three', 4.5);
SELECT id FROM Persons WHERE name NOT IN ('a', 7, 'c');
