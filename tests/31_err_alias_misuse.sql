-- Question 3b : when an alias is defined it must be used everywhere
CREATE TABLE Persons ( PersonID int, LastName varchar(255), City varchar(50) );
CREATE TABLE Orders  ( OrderID int, PersonID int, total float );

-- 'Persons' is aliased to 'p' : 'Persons.LastName' and 'City' are not allowed
SELECT Persons.LastName, City
FROM Persons AS p
JOIN Orders AS o ON p.PersonID = o.PersonID
WHERE o.total > 10;

-- unknown alias 'x'
SELECT p.LastName
FROM Persons AS p
ORDER BY x.LastName;

-- the same visible name is used twice in the same statement
SELECT p.LastName
FROM Persons AS p
JOIN Orders AS p ON p.PersonID = p.PersonID;
