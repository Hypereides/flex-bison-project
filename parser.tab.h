/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    KW_SELECT = 258,               /* KW_SELECT  */
    KW_FROM = 259,                 /* KW_FROM  */
    KW_WHERE = 260,                /* KW_WHERE  */
    KW_LIMIT = 261,                /* KW_LIMIT  */
    KW_GROUP = 262,                /* KW_GROUP  */
    KW_ORDER = 263,                /* KW_ORDER  */
    KW_BY = 264,                   /* KW_BY  */
    KW_IN = 265,                   /* KW_IN  */
    KW_AND = 266,                  /* KW_AND  */
    KW_OR = 267,                   /* KW_OR  */
    KW_NOT = 268,                  /* KW_NOT  */
    KW_CREATE = 269,               /* KW_CREATE  */
    KW_TABLE = 270,                /* KW_TABLE  */
    KW_INT = 271,                  /* KW_INT  */
    KW_FLOAT = 272,                /* KW_FLOAT  */
    KW_VARCHAR = 273,              /* KW_VARCHAR  */
    KW_JOIN = 274,                 /* KW_JOIN  */
    KW_ON = 275,                   /* KW_ON  */
    KW_AS = 276,                   /* KW_AS  */
    IDENT = 277,                   /* IDENT  */
    INT_LIT = 278,                 /* INT_LIT  */
    FLOAT_LIT = 279,               /* FLOAT_LIT  */
    STR_LIT = 280,                 /* STR_LIT  */
    OP_NE = 281,                   /* OP_NE  */
    OP_GE = 282,                   /* OP_GE  */
    OP_LE = 283                    /* OP_LE  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 21 "parser.y"

    char     *str;
    TypeSpec *tspec;
    ColRef   *col;
    Expr     *expr;
    LitNode  *lit;
    LitList  *lits;
    int       flag;

#line 102 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif

/* Location type.  */
#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE YYLTYPE;
struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
};
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


extern YYSTYPE yylval;
extern YYLTYPE yylloc;

int yyparse (void);


#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
