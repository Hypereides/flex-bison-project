-- varchar(n) and LIMIT n require a strictly positive integer
CREATE TABLE T1 ( a int, b varchar(-3), c varchar(0) );

SELECT a FROM T1 LIMIT 0;
SELECT a FROM T1 LIMIT -5;
