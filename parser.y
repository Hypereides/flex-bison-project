%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

extern int   yylex(void);
extern int   yylineno;
extern FILE *yyin;
extern void  echo_flush_line(void);

void yyerror(const char *msg);

static int  syntax_error_line = 0;
static char syntax_error_msg[512];
%}

%locations
%define parse.error verbose

%union {
    char     *str;
    TypeSpec *tspec;
    ColRef   *col;
    Expr     *expr;
    LitNode  *lit;
    LitList  *lits;
    int       flag;
}

%token KW_SELECT KW_FROM KW_WHERE KW_LIMIT KW_GROUP KW_ORDER KW_BY
%token KW_IN KW_AND KW_OR KW_NOT
%token KW_CREATE KW_TABLE KW_INT KW_FLOAT KW_VARCHAR
%token KW_JOIN KW_ON KW_AS

%token <str> IDENT INT_LIT FLOAT_LIT STR_LIT

%token OP_NE OP_GE OP_LE

%type <tspec> data_type
%type <col>   column_ref
%type <expr>  operand
%type <lit>   literal
%type <lits>  literal_list
%type <str>   relop opt_alias
%type <flag>  in_op

%left  KW_OR
%left  KW_AND
%right KW_NOT

%start program

%%

program
    : statement_list
    ;

statement_list
    : statement
    | statement_list statement
    ;

statement
    : create_stmt ';'
    | select_stmt ';'
    ;

create_stmt
    : KW_CREATE KW_TABLE IDENT       { sem_create_begin($3, @3.first_line); }
      '(' column_def_list ')'        { sem_create_end(); }
    ;

column_def_list
    : column_def
    | column_def_list ',' column_def
    ;

column_def
    : IDENT data_type                { sem_create_column($1, $2, @1.first_line); }
    ;

data_type
    : KW_INT                         { $$ = typespec_new(TY_INT, 0); }
    | KW_FLOAT                       { $$ = typespec_new(TY_FLOAT, 0); }
    | KW_VARCHAR '(' INT_LIT ')'
          { $$ = typespec_new(TY_VARCHAR, sem_varchar_len($3, @3.first_line)); }
    ;

select_stmt
    : KW_SELECT                      { sem_select_begin(); }
      select_list
      KW_FROM table_ref
      join_list
      opt_where
      opt_group_by
      opt_order_by
      opt_limit                      { sem_select_end(); }
    ;

select_list
    : '*'                            { sem_select_star(); }
    | select_column_list
    ;

select_column_list
    : column_ref                     { sem_select_defer($1); }
    | select_column_list ',' column_ref
                                     { sem_select_defer($3); }
    ;

table_ref
    : IDENT opt_alias                { sem_add_table_ref($1, $2, @1.first_line); }
    ;

opt_alias
    :                                { $$ = NULL; }
    | KW_AS IDENT                    { $$ = $2; }
    ;

join_list
    :
    | join_list join_clause
    ;

join_clause
    : KW_JOIN table_ref KW_ON column_ref '=' column_ref
                                     { sem_check_on($4, $6, @3.first_line); }
    ;

opt_where
    :
    | KW_WHERE condition
    ;

condition
    : condition KW_OR  condition
    | condition KW_AND condition
    | KW_NOT condition
    | '(' condition ')'
    | predicate
    ;

predicate
    : operand relop operand
                                     { sem_check_cmp($1, $3, $2, @2.first_line); }
    | column_ref in_op '(' literal_list ')'
                                     { sem_check_in($1, $4, $2, @2.first_line); }
    ;

in_op
    : KW_IN                          { $$ = 0; }
    | KW_NOT KW_IN                   { $$ = 1; }
    ;

relop
    : '='                            { $$ = "="; }
    | OP_NE                          { $$ = "!="; }
    | '>'                            { $$ = ">"; }
    | '<'                            { $$ = "<"; }
    | OP_GE                          { $$ = ">="; }
    | OP_LE                          { $$ = "<="; }
    ;

operand
    : column_ref                     { $$ = expr_from_column($1); }
    | literal                        { $$ = expr_from_literal($1); }
    ;

literal_list
    : literal                        { $$ = litlist_new($1); }
    | literal_list ',' literal       { $$ = litlist_add($1, $3); }
    ;

literal
    : INT_LIT                        { $$ = lit_new(TY_INT,     $1, @1.first_line); }
    | FLOAT_LIT                      { $$ = lit_new(TY_FLOAT,   $1, @1.first_line); }
    | STR_LIT                        { $$ = lit_new(TY_VARCHAR, $1, @1.first_line); }
    ;

opt_group_by
    :
    | KW_GROUP KW_BY column_use_list
    ;

opt_order_by
    :
    | KW_ORDER KW_BY column_use_list
    ;

column_use_list
    : column_ref                     { sem_use_column($1); }
    | column_use_list ',' column_ref { sem_use_column($3); }
    ;

opt_limit
    :
    | KW_LIMIT INT_LIT               { sem_check_limit($2, @2.first_line); }
    ;

column_ref
    : IDENT                          { $$ = colref_new(NULL, $1, @1.first_line); }
    | IDENT '.' IDENT                { $$ = colref_new($1,   $3, @1.first_line); }
    ;

%%

void yyerror(const char *msg)
{
    syntax_error_line = yylloc.first_line ? yylloc.first_line : yylineno;
    snprintf(syntax_error_msg, sizeof(syntax_error_msg),
             "*** Syntax error (line %d): %s\n"
             "*** The analysis and the listing of the program stop at line %d.\n",
             syntax_error_line, msg, syntax_error_line);
}

int main(int argc, char **argv)
{
    int rc;

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <file_name>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "myParser: cannot open file '%s'\n", argv[1]);
        return 1;
    }

    printf("==================== mySQLq source: %s ====================\n",
           argv[1]);
    fflush(stdout);

    rc = yyparse();

    echo_flush_line();

    if (sem_errors() > 0 || rc != 0 || syntax_error_line) {
        printf("\n==================== DIAGNOSTICS ====================\n");
        sem_flush_messages();
        if (syntax_error_line)
            printf("%s", syntax_error_msg);
    }

    printf("\n==================== ANALYSIS RESULT ====================\n");

    if (rc != 0 || syntax_error_line) {
        printf("FAILURE: the program is NOT syntactically correct "
               "(syntax error at line %d).\n", syntax_error_line);
        fclose(yyin);
        return 2;
    }
    if (sem_errors() > 0) {
        printf("FAILURE: the program is syntactically correct but contains "
               "%d semantic error(s).\n", sem_errors());
        fclose(yyin);
        return 3;
    }
    printf("SUCCESS: the program is syntactically and semantically correct.\n");
    fclose(yyin);
    return 0;
}
