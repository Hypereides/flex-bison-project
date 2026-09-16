-- Question 1 : every optional clause of SELECT, in the mandatory order.

CREATE TABLE Persons (
    PersonID  int,
    LastName  varchar(255),
    City      varchar(50),
    age       int,
    weight    float
);

SELECT * FROM Persons;

SELECT LastName, City FROM Persons;

SELECT City, age
FROM Persons
WHERE age >= 18
GROUP BY City, age
ORDER BY City
LIMIT 10;

SeLeCt LastName fRoM Persons LiMiT 1;
