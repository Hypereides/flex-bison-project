-- Question 1 : illegal character
CREATE TABLE T1 ( a int );

SELECT a FROM T1 WHERE a # 5;
