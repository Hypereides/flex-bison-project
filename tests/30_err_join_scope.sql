-- Question 3a : tables and columns of a JOIN must exist and be in scope
CREATE TABLE Persons ( PersonID int, LastName varchar(255) );
CREATE TABLE Orders  ( OrderID int, PersonID int );

-- Customers has never been created
SELECT Persons.LastName
FROM Persons
JOIN Customers ON Persons.PersonID = Customers.PersonID;

-- Items is used in the ON clause but is not in the scope of the statement
SELECT Persons.LastName
FROM Persons
JOIN Orders ON Items.OrderID = Orders.OrderID;

-- the column does not exist in the joined table
SELECT Persons.LastName
FROM Persons
JOIN Orders ON Persons.PersonID = Orders.CustomerID;
