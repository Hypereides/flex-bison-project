# mySQLq parser

Lexical and syntax analyser for mySQLq, a small SQL-like query language,
written with Flex and Bison. Lab assignment for Programming Languages &
Compilers, CEID, University of Patras.

## Build

    make

Needs flex, bison and gcc. The generated C files are committed, so if flex
or bison are not installed you can still build with gcc alone:

    gcc -Wall -Wextra -O2 -o myParser.exe parser.tab.c lex.yy.c symtab.c

`make clean` removes the generated files and the executable.

## Run

    ./myParser.exe tests/02_ok_select_basic.sql

Prints the source with line numbers, then the diagnostics if there are any,
then the verdict.

Exit codes: 0 correct, 1 cannot open the file, 2 lexical or syntax error,
3 semantic error.

## Tests

    ./run_tests.sh              run all of them
    ./run_tests.sh 24           only the ones matching "24"
    ./run_tests.sh -v           print the full output too

Tests named `_ok_` must be accepted, tests named `_err_` must be rejected.
The runner compares the exit code against what the filename implies.

## Files

    lexer.l      token patterns, program listing, lexical errors
    parser.y     the grammar, plus main() and yyerror()
    symtab.c     symbol table and the semantic checks
    symtab.h     types and function declarations
    tests/       test inputs
    screenshots/ screenshots for the report
