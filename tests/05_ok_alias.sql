-- Question 3b : aliases (AS) in FROM and in JOIN.

CREATE TABLE Persons ( PersonID int, LastName varchar(255), City varchar(50) );
CREATE TABLE Orders  ( OrderID  int, PersonID int, total float );

-- alias on the FROM table only
SELECT p.LastName, Orders.total
FROM Persons AS p
JOIN Orders ON p.PersonID = Orders.PersonID
WHERE p.City = 'Patras';

-- alias on the JOIN table only
SELECT Persons.LastName, o.total
FROM Persons
JOIN Orders AS o ON Persons.PersonID = o.PersonID
GROUP BY Persons.City
ORDER BY o.total
LIMIT 5;

-- alias on both tables
SELECT p.LastName, o.total
FROM Persons AS p
JOIN Orders AS o ON p.PersonID = o.PersonID
WHERE o.total >= 10 AND p.LastName IN ('Papas', 'Nikou')
ORDER BY o.total;

-- no alias at all and a single table : unqualified columns are allowed
SELECT LastName FROM Persons WHERE City = 'Athens';
