-- Question 3a : one and several JOIN clauses.

CREATE TABLE Persons ( PersonID int, LastName varchar(255), City varchar(50) );
CREATE TABLE Orders  ( OrderID  int, PersonID int, total float );
CREATE TABLE Items   ( ItemID   int, OrderID  int, descr varchar(80) );

SELECT Persons.LastName, Orders.total
FROM Persons
JOIN Orders ON Persons.PersonID = Orders.PersonID
WHERE Orders.total > 100.0
ORDER BY Persons.LastName;

SELECT Persons.LastName, Items.descr
FROM Persons
JOIN Orders ON Persons.PersonID = Orders.PersonID
JOIN Items  ON Orders.OrderID   = Items.OrderID
WHERE Items.descr != 'unknown'
GROUP BY Persons.LastName, Items.descr
ORDER BY Persons.LastName
LIMIT 25;
