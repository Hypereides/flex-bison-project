#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "symtab.h"

static char *xstrdup(const char *s)
{
    char *p;
    if (!s) return NULL;
    p = (char *)malloc(strlen(s) + 1);
    if (!p) { fprintf(stderr, "out of memory\n"); exit(9); }
    strcpy(p, s);
    return p;
}

static void *xmalloc(size_t n)
{
    void *p = malloc(n);
    if (!p) { fprintf(stderr, "out of memory\n"); exit(9); }
    return p;
}

const char *type_name(DataType t)
{
    switch (t) {
        case TY_INT:     return "INT";
        case TY_FLOAT:   return "FLOAT";
        case TY_VARCHAR: return "VARCHAR";
        default:         return "?";
    }
}

static const char *lit_name(DataType t)
{
    switch (t) {
        case TY_INT:     return "integer";
        case TY_FLOAT:   return "real";
        case TY_VARCHAR: return "string";
        default:         return "?";
    }
}

static const char *lit_art(DataType t) { return t == TY_INT ? "an" : "a"; }

typedef struct Diag {
    int          line;
    char        *text;
    struct Diag *next;
} Diag;

static Diag *diag_head = NULL;
static int   sem_error_count = 0;

int sem_errors(void) { return sem_error_count; }

void sem_error(int line, const char *fmt, ...)
{
    va_list  ap;
    char     buf[1024];
    Diag    *d, **pp;

    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);

    sem_error_count++;

    d = (Diag *)xmalloc(sizeof(Diag));
    d->line = line;
    d->text = xstrdup(buf);
    d->next = NULL;

    pp = &diag_head;
    while (*pp && (*pp)->line <= line)
        pp = &(*pp)->next;
    d->next = *pp;
    *pp = d;
}

void sem_flush_messages(void)
{
    Diag *d;
    for (d = diag_head; d; d = d->next)
        printf("*** Semantic error (line %d): %s\n", d->line, d->text);
    fflush(stdout);
}

typedef struct Column {
    char           *name;
    DataType        type;
    int             len;
    int             line;
    struct Column  *next;
} Column;

typedef struct Table {
    char          *name;
    int            line;
    Column        *cols;
    Column        *cols_tail;
    struct Table  *next;
} Table;

static Table *db_head = NULL;
static Table *db_tail = NULL;

static Table *db_find(const char *name)
{
    Table *t;
    for (t = db_head; t; t = t->next)
        if (strcmp(t->name, name) == 0)
            return t;
    return NULL;
}

static Column *table_find_col(Table *t, const char *name)
{
    Column *c;
    if (!t) return NULL;
    for (c = t->cols; c; c = c->next)
        if (strcmp(c->name, name) == 0)
            return c;
    return NULL;
}

TypeSpec *typespec_new(DataType t, int len)
{
    TypeSpec *ts = (TypeSpec *)xmalloc(sizeof(TypeSpec));
    ts->type = t;
    ts->len  = len;
    return ts;
}

LitNode *lit_new(DataType t, const char *text, int line)
{
    LitNode *n = (LitNode *)xmalloc(sizeof(LitNode));
    n->type = t;
    n->text = xstrdup(text);
    n->line = line;
    n->next = NULL;
    return n;
}

LitList *litlist_new(LitNode *n)
{
    LitList *l = (LitList *)xmalloc(sizeof(LitList));
    l->head = l->tail = n;
    return l;
}

LitList *litlist_add(LitList *l, LitNode *n)
{
    l->tail->next = n;
    l->tail = n;
    return l;
}

ColRef *colref_new(const char *qual, const char *name, int line)
{
    ColRef *c = (ColRef *)xmalloc(sizeof(ColRef));
    c->qual = qual ? xstrdup(qual) : NULL;
    c->name = xstrdup(name);
    c->line = line;
    return c;
}

static char *colref_text(ColRef *c)
{
    char *s;
    if (c->qual) {
        s = (char *)xmalloc(strlen(c->qual) + strlen(c->name) + 2);
        sprintf(s, "%s.%s", c->qual, c->name);
    } else {
        s = xstrdup(c->name);
    }
    return s;
}

static Table *cur_table   = NULL;
static int    cur_ignored = 0;

void sem_create_begin(const char *tname, int line)
{
    Table *old = db_find(tname);
    cur_ignored = 0;

    if (old) {
        sem_error(line,
                  "table '%s' is already defined (first definition at line %d); "
                  "table names must be unique", tname, old->line);
        cur_ignored = 1;
    }
    cur_table = (Table *)xmalloc(sizeof(Table));
    cur_table->name      = xstrdup(tname);
    cur_table->line      = line;
    cur_table->cols      = NULL;
    cur_table->cols_tail = NULL;
    cur_table->next      = NULL;
}

int sem_varchar_len(const char *text, int line)
{
    long n = strtol(text, NULL, 10);
    if (n <= 0) {
        sem_error(line, "VARCHAR length must be a strictly positive integer "
                        "(found %s)", text);
        return 1;
    }
    return (int)n;
}

void sem_create_column(const char *cname, TypeSpec *ts, int line)
{
    Column *old, *c;

    if (!cur_table) return;

    old = table_find_col(cur_table, cname);
    if (old) {
        sem_error(line,
                  "column '%s' is declared more than once in table '%s' "
                  "(first declaration at line %d)",
                  cname, cur_table->name, old->line);
        return;
    }
    c = (Column *)xmalloc(sizeof(Column));
    c->name = xstrdup(cname);
    c->type = ts->type;
    c->len  = ts->len;
    c->line = line;
    c->next = NULL;
    if (cur_table->cols_tail) cur_table->cols_tail->next = c;
    else                      cur_table->cols            = c;
    cur_table->cols_tail = c;
}

void sem_create_end(void)
{
    if (!cur_table) return;
    if (!cur_ignored) {
        if (db_tail) db_tail->next = cur_table;
        else         db_head       = cur_table;
        db_tail = cur_table;
    }
    cur_table   = NULL;
    cur_ignored = 0;
}

typedef struct TRef {
    Table       *table;
    char        *tname;
    char        *alias;
    int          line;
    struct TRef *next;
} TRef;

static TRef *scope_head = NULL;
static TRef *scope_tail = NULL;

typedef struct PendCol {
    ColRef         *ref;
    struct PendCol *next;
} PendCol;

static PendCol *pend_head = NULL;
static PendCol *pend_tail = NULL;

static const char *tref_visible_name(TRef *r)
{
    return r->alias ? r->alias : r->tname;
}

static void scope_clear(void)
{
    TRef *r = scope_head, *n;
    while (r) { n = r->next; free(r->tname); free(r->alias); free(r); r = n; }
    scope_head = scope_tail = NULL;
}

static void pend_clear(void)
{
    PendCol *p = pend_head, *n;
    while (p) { n = p->next; free(p); p = n; }
    pend_head = pend_tail = NULL;
}

void sem_select_begin(void)
{
    scope_clear();
    pend_clear();
}

void sem_add_table_ref(const char *tname, const char *alias, int line)
{
    TRef       *r;
    TRef       *it;
    Table      *t   = db_find(tname);
    const char *vis = alias ? alias : tname;

    if (!t)
        sem_error(line, "table '%s' is used but has never been created "
                        "with a CREATE TABLE statement", tname);

    for (it = scope_head; it; it = it->next) {
        if (strcmp(tref_visible_name(it), vis) == 0) {
            sem_error(line, "'%s' is already used in this statement to refer "
                            "to a table (line %d); use a different alias",
                            vis, it->line);
            break;
        }
    }

    r = (TRef *)xmalloc(sizeof(TRef));
    r->table = t;
    r->tname = xstrdup(tname);
    r->alias = alias ? xstrdup(alias) : NULL;
    r->line  = line;
    r->next  = NULL;
    if (scope_tail) scope_tail->next = r;
    else            scope_head       = r;
    scope_tail = r;
}

static DataType resolve_column(ColRef *c)
{
    TRef   *r;
    Column *col;

    if (!scope_head) return TY_UNKNOWN;

    if (c->qual) {
        for (r = scope_head; r; r = r->next)
            if (strcmp(tref_visible_name(r), c->qual) == 0)
                break;

        if (!r) {

            for (r = scope_head; r; r = r->next)
                if (r->alias && strcmp(r->tname, c->qual) == 0) {
                    sem_error(c->line,
                        "table '%s' is referenced through the alias '%s'; "
                        "write '%s.%s' instead of '%s.%s'",
                        r->tname, r->alias, r->alias, c->name,
                        c->qual, c->name);
                    return TY_UNKNOWN;
                }
            sem_error(c->line,
                "'%s' is not a table or an alias of this statement "
                "(in the reference '%s.%s')", c->qual, c->qual, c->name);
            return TY_UNKNOWN;
        }
        if (!r->table) return TY_UNKNOWN;

        col = table_find_col(r->table, c->name);
        if (!col) {
            sem_error(c->line, "column '%s' does not exist in table '%s'",
                      c->name, r->table->name);
            return TY_UNKNOWN;
        }
        return col->type;
    }

    {
        Column *found       = NULL;
        TRef   *needs_alias = NULL;
        int     matches     = 0;
        int     unknown_table = 0;

        for (r = scope_head; r; r = r->next) {
            if (!r->table) { unknown_table = 1; continue; }
            col = table_find_col(r->table, c->name);
            if (!col) continue;
            if (r->alias) {
                if (!needs_alias) needs_alias = r;
                continue;
            }
            matches++;
            found = col;
        }

        if (matches == 1) return found->type;

        if (matches > 1) {
            sem_error(c->line, "column '%s' is ambiguous: it exists in more "
                               "than one table of this statement; qualify it "
                               "with a table name or an alias", c->name);
            return TY_UNKNOWN;
        }
        if (needs_alias) {
            sem_error(c->line,
                "table '%s' is referenced through the alias '%s'; column '%s' "
                "must be written as '%s.%s'",
                needs_alias->tname, needs_alias->alias, c->name,
                needs_alias->alias, c->name);
            return TY_UNKNOWN;
        }
        if (unknown_table) return TY_UNKNOWN;

        if (!scope_head->next)
            sem_error(c->line, "column 'Flex inp%s' does not exist in table '%s'",
                      c->name, scope_head->tname);
        else
            sem_error(c->line, "column '%s' does not exist in any of the "
                               "tables of this statement", c->name);
        return TY_UNKNOWN;
    }
}

void sem_select_star(void) {  }

void sem_select_defer(ColRef *c)
{
    PendCol *p = (PendCol *)xmalloc(sizeof(PendCol));
    p->ref  = c;
    p->next = NULL;
    if (pend_tail) pend_tail->next = p;
    else           pend_head       = p;
    pend_tail = p;
}

void sem_use_column(ColRef *c)
{
    (void)resolve_column(c);
}

void sem_select_end(void)
{
    PendCol *p;
    for (p = pend_head; p; p = p->next)
        (void)resolve_column(p->ref);
    pend_clear();
    scope_clear();
}

Expr *expr_from_column(ColRef *c)
{
    Expr *e = (Expr *)xmalloc(sizeof(Expr));
    e->is_column = 1;
    e->type      = resolve_column(c);
    e->desc      = colref_text(c);
    e->line      = c->line;
    return e;
}

Expr *expr_from_literal(LitNode *l)
{
    Expr *e = (Expr *)xmalloc(sizeof(Expr));
    e->is_column = 0;
    e->type      = l->type;
    e->desc      = xstrdup(l->text);
    e->line      = l->line;
    return e;
}

static int compatible_col_lit(DataType col, DataType lit)
{
    switch (col) {
        case TY_INT:     return lit == TY_INT;
        case TY_FLOAT:   return lit == TY_INT || lit == TY_FLOAT;
        case TY_VARCHAR: return lit == TY_VARCHAR;
        default:         return 1;
    }
}

static int numeric(DataType t) { return t == TY_INT || t == TY_FLOAT; }

void sem_check_cmp(Expr *l, Expr *r, const char *op, int line)
{
    if (!l || !r) return;
    if (l->type == TY_UNKNOWN || r->type == TY_UNKNOWN) return;

    if (l->is_column && !r->is_column) {
        if (!compatible_col_lit(l->type, r->type))
            sem_error(line, "incompatible comparison '%s %s %s': column '%s' "
                            "is of type %s and cannot be compared with %s %s "
                            "literal",
                      l->desc, op, r->desc, l->desc,
                      type_name(l->type), lit_art(r->type), lit_name(r->type));
        return;
    }
    if (!l->is_column && r->is_column) {
        if (!compatible_col_lit(r->type, l->type))
            sem_error(line, "incompatible comparison '%s %s %s': column '%s' "
                            "is of type %s and cannot be compared with %s %s "
                            "literal",
                      l->desc, op, r->desc, r->desc,
                      type_name(r->type), lit_art(l->type), lit_name(l->type));
        return;
    }
    if (l->is_column && r->is_column) {
        if (!((numeric(l->type) && numeric(r->type)) ||
              (l->type == TY_VARCHAR && r->type == TY_VARCHAR)))
            sem_error(line, "incompatible comparison '%s %s %s': column types "
                            "%s and %s are not compatible",
                      l->desc, op, r->desc,
                      type_name(l->type), type_name(r->type));
        return;
    }

    if (!((numeric(l->type) && numeric(r->type)) ||
          (l->type == TY_VARCHAR && r->type == TY_VARCHAR)))
        sem_error(line, "incompatible comparison '%s %s %s': %s %s literal "
                        "cannot be compared with %s %s literal",
                  l->desc, op, r->desc,
                  lit_art(l->type), lit_name(l->type),
                  lit_art(r->type), lit_name(r->type));
}

void sem_check_in(ColRef *c, LitList *list, int negated, int line)
{
    DataType ct = resolve_column(c);
    LitNode *n;
    char    *txt;

    (void)line;
    if (ct == TY_UNKNOWN || !list) return;

    txt = colref_text(c);
    for (n = list->head; n; n = n->next) {
        if (!compatible_col_lit(ct, n->type)) {
            sem_error(n->line,
                "incompatible operand in '%s %sIN (...)': column '%s' is of "
                "type %s and cannot be compared with the %s literal %s",
                txt, negated ? "NOT " : "", txt, type_name(ct),
                lit_name(n->type), n->text);
        }
    }
    free(txt);
}

void sem_check_on(ColRef *l, ColRef *r, int line)
{
    DataType lt = resolve_column(l);
    DataType rt = resolve_column(r);

    if (lt == TY_UNKNOWN || rt == TY_UNKNOWN) return;

    if (!((numeric(lt) && numeric(rt)) ||
          (lt == TY_VARCHAR && rt == TY_VARCHAR))) {
        char *a = colref_text(l);
        char *b = colref_text(r);
        sem_error(line, "JOIN condition '%s = %s' compares incompatible types "
                        "(%s and %s)", a, b, type_name(lt), type_name(rt));
        free(a);
        free(b);
    }
}

void sem_check_limit(const char *text, int line)
{
    long n = strtol(text, NULL, 10);
    if (n <= 0)
        sem_error(line, "the argument of LIMIT must be a strictly positive "
                        "integer (found %s)", text);
}
