%option noyywrap
%option yylineno
%option caseless
%option never-interactive
%option nounput
%option noinput

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"
#include "parser.tab.h"

void echo_text(const char *s);
void echo_flush_line(void);
static void lex_fatal(const char *what);
static void lex_fatal_plain(const char *what);

#define YY_USER_ACTION                          \
    do {                                        \
        echo_text(yytext);                      \
        yylloc.first_line   = yylineno;         \
        yylloc.last_line    = yylineno;         \
        yylloc.first_column = 1;                \
        yylloc.last_column  = 1;                \
    } while (0);
%}

DIGIT       [0-9]
LETTER      [A-Za-z]
ID          ({LETTER}|_)({LETTER}|{DIGIT}|_)*
INTEGER     -?{DIGIT}+
REAL        -?{DIGIT}+"."{DIGIT}+
STRING      '[^'\n]*'
WS          [ \t\r]+

%x COMMENT

%%

"--"[^\n]*          { }
"/*"                { BEGIN(COMMENT); }
<COMMENT>"*/"       { BEGIN(INITIAL); }
<COMMENT>\n         { }
<COMMENT>.          { }
<COMMENT><<EOF>>    { lex_fatal_plain("unterminated multi-line comment (closing */ is missing)"); }

{WS}                { }
\n                  { }

"select"            { return KW_SELECT;  }
"from"              { return KW_FROM;    }
"where"             { return KW_WHERE;   }
"limit"             { return KW_LIMIT;   }
"group"             { return KW_GROUP;   }
"order"             { return KW_ORDER;   }
"by"                { return KW_BY;      }
"in"                { return KW_IN;      }
"and"               { return KW_AND;     }
"or"                { return KW_OR;      }
"not"               { return KW_NOT;     }
"create"            { return KW_CREATE;  }
"table"             { return KW_TABLE;   }
"int"               { return KW_INT;     }
"float"             { return KW_FLOAT;   }
"varchar"           { return KW_VARCHAR; }
"join"              { return KW_JOIN;    }
"on"                { return KW_ON;      }
"as"                { return KW_AS;      }

"!="                { return OP_NE; }
">="                { return OP_GE; }
"<="                { return OP_LE; }
"="                 { return '='; }
">"                 { return '>'; }
"<"                 { return '<'; }

"("                 { return '('; }
")"                 { return ')'; }
","                 { return ','; }
";"                 { return ';'; }
"."                 { return '.'; }
"*"                 { return '*'; }

{REAL}              { yylval.str = strdup(yytext); return FLOAT_LIT; }
{INTEGER}           { yylval.str = strdup(yytext); return INT_LIT;   }
{STRING}            { yylval.str = strdup(yytext); return STR_LIT;  }
{ID}                { yylval.str = strdup(yytext); return IDENT;     }

'[^'\n]*            { lex_fatal("unterminated string literal"); }
.                   { lex_fatal("illegal character"); }

%%

static int echo_at_line_start = 1;
static int echo_lineno        = 1;

void echo_text(const char *s)
{
    for (; *s; ++s) {
        if (echo_at_line_start) {
            printf("%4d| ", echo_lineno);
            echo_at_line_start = 0;
        }
        putchar(*s);
        if (*s == '\n') {
            echo_lineno++;
            echo_at_line_start = 1;
        }
    }
}

void echo_flush_line(void)
{
    if (!echo_at_line_start) {
        putchar('\n');
        echo_at_line_start = 1;
    }
    fflush(stdout);
}

static void lex_fatal_plain(const char *what)
{
    echo_flush_line();
    printf("\n*** Lexical error (line %d): %s\n", yylineno, what);
    printf("*** Analysis stopped at line %d.\n", yylineno);
    printf("\n==================== ANALYSIS RESULT ====================\n");
    printf("FAILURE: the program contains a lexical error at line %d.\n",
           yylineno);
    fflush(stdout);
    exit(2);
}

static void lex_fatal(const char *what)
{
    echo_flush_line();
    printf("\n*** Lexical error (line %d): %s: \"%s\"\n",
           yylineno, what, yytext);
    printf("*** Analysis stopped at line %d.\n", yylineno);
    printf("\n==================== ANALYSIS RESULT ====================\n");
    printf("FAILURE: the program contains a lexical error at line %d.\n",
           yylineno);
    fflush(stdout);
    exit(2);
}
