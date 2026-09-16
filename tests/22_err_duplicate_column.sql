-- Question 2c : the column names of a table must be different
CREATE TABLE Persons (
    id    int,
    name  varchar(30),
    id    float
);

SELECT id FROM Persons;
