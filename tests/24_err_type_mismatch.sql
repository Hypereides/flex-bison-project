-- Question 2e-i / 2e-ii : type compatibility inside WHERE
CREATE TABLE Persons ( id int, name varchar(30), weight float );

SELECT id FROM Persons WHERE id = 3.5;          -- INT vs real literal
SELECT id FROM Persons WHERE id = 'three';      -- INT vs string literal
SELECT id FROM Persons WHERE name >= 10;        -- VARCHAR vs integer literal
SELECT id FROM Persons WHERE weight = 'heavy';  -- FLOAT vs string literal
SELECT id FROM Persons WHERE name = weight;     -- VARCHAR column vs FLOAT column
