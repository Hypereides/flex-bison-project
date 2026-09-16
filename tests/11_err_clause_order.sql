-- Question 1 : the order of the clauses of SELECT is strict
-- select -> from -> where -> group by -> order by -> limit
CREATE TABLE T1 ( a int, b varchar(10) );

SELECT a, b
FROM T1
ORDER BY a
WHERE a = 1;
