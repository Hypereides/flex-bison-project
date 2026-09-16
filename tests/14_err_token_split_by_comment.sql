-- Question 1 : a comment is not allowed to break a token
CREATE TABLE T1 ( a int );

Se/* this comment breaks the keyword */lect a FROM T1;
