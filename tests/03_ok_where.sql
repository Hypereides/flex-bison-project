-- Question 2e : type compatible conditions, IN / NOT IN, AND / OR / NOT.

CREATE TABLE Persons (
    id        int,
    name      varchar(100),
    age       int,
    weight    float
);

SELECT id, name
FROM Persons
WHERE id IN (1, 2, 3);

SELECT id
FROM Persons
WHERE name NOT IN ('id1', 'id2', 'id3');

SELECT *
FROM Persons
WHERE age >= 18 AND weight <= 90.5;

/* a FLOAT column accepts both integer and real literals */
SELECT *
FROM Persons
WHERE weight > 70 OR weight != -0.5;

SELECT *
FROM Persons
WHERE NOT (age < 10 OR age > 65) AND name = 'this is my text';

SELECT *
FROM Persons
WHERE age = weight;          -- INT and FLOAT are both numeric
