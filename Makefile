FLEX   = flex
BISON  = bison
CC     = gcc
CFLAGS = -Wall -Wextra -O2

TARGET = myParser.exe

all: $(TARGET)

parser.tab.c parser.tab.h: parser.y
	$(BISON) -d -o parser.tab.c parser.y

lex.yy.c: lexer.l parser.tab.h
	$(FLEX) -o lex.yy.c lexer.l

$(TARGET): parser.tab.c lex.yy.c symtab.c symtab.h
	$(CC) $(CFLAGS) -o $(TARGET) parser.tab.c lex.yy.c symtab.c

test: $(TARGET)
	@for f in tests/*.sql; do \
	    echo "############################################################"; \
	    echo "### $$f"; \
	    echo "############################################################"; \
	    ./$(TARGET) $$f; \
	    echo ""; \
	done

clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h lex.yy.c parser.output

.PHONY: all test clean
