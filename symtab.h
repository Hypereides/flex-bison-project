#ifndef SYMTAB_H
#define SYMTAB_H

typedef enum {
    TY_INT = 0,
    TY_FLOAT,
    TY_VARCHAR,
    TY_UNKNOWN
} DataType;

const char *type_name(DataType t);

typedef struct {
    DataType type;
    int      len;
} TypeSpec;

TypeSpec *typespec_new(DataType t, int len);

typedef struct LitNode {
    DataType         type;
    char            *text;
    int              line;
    struct LitNode  *next;
} LitNode;

typedef struct {
    LitNode *head;
    LitNode *tail;
} LitList;

LitNode *lit_new(DataType t, const char *text, int line);
LitList *litlist_new(LitNode *n);
LitList *litlist_add(LitList *l, LitNode *n);

typedef struct {
    char *qual;
    char *name;
    int   line;
} ColRef;

ColRef *colref_new(const char *qual, const char *name, int line);

typedef struct {
    int       is_column;
    DataType  type;
    char     *desc;
    int       line;
} Expr;

Expr *expr_from_column(ColRef *c);
Expr *expr_from_literal(LitNode *l);

void sem_error(int line, const char *fmt, ...);
int  sem_errors(void);
void sem_flush_messages(void);

void sem_create_begin(const char *tname, int line);
void sem_create_column(const char *cname, TypeSpec *ts, int line);
void sem_create_end(void);
int  sem_varchar_len(const char *text, int line);

void sem_select_begin(void);
void sem_select_end(void);
void sem_add_table_ref(const char *tname, const char *alias, int line);
void sem_select_star(void);
void sem_select_defer(ColRef *c);
void sem_use_column(ColRef *c);
void sem_check_on(ColRef *l, ColRef *r, int line);
void sem_check_cmp(Expr *l, Expr *r, const char *op, int line);
void sem_check_in(ColRef *c, LitList *l, int negated, int line);
void sem_check_limit(const char *text, int line);

#endif
