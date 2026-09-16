-- Question 2a : table names must be unique
CREATE TABLE Persons ( id int, name varchar(30) );
CREATE TABLE Persons ( id int, city varchar(30) );

SELECT id FROM Persons;
