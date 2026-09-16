#!/bin/sh
set -e
bison -d -o parser.tab.c parser.y
flex  -o lex.yy.c lexer.l
gcc -Wall -Wextra -O2 -o myParser.exe parser.tab.c lex.yy.c symtab.c
echo "Built myParser.exe"
