-- Question 1 / 2 : CREATE TABLE statements, all the data types.
-- Keywords are case insensitive, identifiers are not.

CREATE TABLE Persons (
    PersonID   int,
    LastName  varchar(255),
    FirstName  varchar(255),
    Address    varchar(255),
    City       varchar(50),
    age        int,
    weight     float
);

/* The table below has the same column names as the one above.
   This is allowed: column names must be unique inside ONE table only. */
create table Orders (
    OrderID    INT,
    PersonID   int,
    total      Float,
    City       varchar(50)
);

CREATE TABLE askisi ( id int, code varchar(10) );
CREATE TABLE Askisi ( id int, code varchar(10) );   -- different table (case sensitive)
