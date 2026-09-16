/* Comments may appear between the tokens of any statement,
   they may span several lines,
   and they are simply ignored by the lexical analyser. */
CREATE /* here */ TABLE /* and here */ T1 ( a int, b varchar(10) ); -- and here too

SELECT -- a comment right after the keyword
       a,
       b   /* another one */
FROM   T1
WHERE  a = 3          -- integer literal against an INT column
   AND b = 'text'     /* string literal against a VARCHAR column */
LIMIT  100;
