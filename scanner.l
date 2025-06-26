%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef struct ASTNode ASTNode;

typedef union {
    int integer;
    double real;
    char* string;
    ASTNode* node;
} YYSTYPE;

#define YYSTYPE_IS_DECLARED 1
extern YYSTYPE yylval;

#include "parser.tab.h"

int linha = 1;
int coluna = 1;

#define MAX_INDENT_STACK 100
static int indent_stack[MAX_INDENT_STACK];
static int indent_sp = 0;
static int current_indent_level = 0;
static int dedents_to_emit = 0;

void init_indentation_stack() {
    indent_stack[0] = 0;
    indent_sp = 1;
    current_indent_level = 0;
    dedents_to_emit = 0;
}

void atualiza_localizacao() {
    coluna += yyleng;
}

void nova_linha() {
    linha++;
    coluna = 1;
}

static int emit_dedents_if_needed() {
    if (dedents_to_emit > 0) {
        dedents_to_emit--;
        current_indent_level = indent_stack[indent_sp - 1];
        return DEDENT;
    }
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro na linha %d, coluna %d: %s\n", linha, coluna, s);
}

void __attribute__((constructor)) init_lexer_on_load() {
    init_indentation_stack();
}
%}

%option noyywrap
%x INDENT_STATE

DIGITO        [0-9]
LETRA         [a-zA-Z]
ID            {LETRA}[a-zA-Z0-9_]*
NUM_INT       {DIGITO}+
NUM_FLOAT     {DIGITO}+\.{DIGITO}+
STRING        \"[^\"]*\"|\'[^\']*\'
ESPACO        [ \t]+
COMENTARIO    \#.*
NOVA_LINHA    \n
%%

<INITIAL>{NOVA_LINHA} {
    nova_linha();
    BEGIN INDENT_STATE;

    int token_dedent = emit_dedents_if_needed();
    if (token_dedent) {
        return token_dedent;
    }

    return NEWLINE;
}

<INDENT_STATE>{ESPACO} {
    current_indent_level = yyleng;
}

<INDENT_STATE>{COMENTARIO} {
    current_indent_level = 0;
    nova_linha();
    BEGIN INDENT_STATE;
}

<INDENT_STATE>{NOVA_LINHA} {
    current_indent_level = 0;
    nova_linha();
    BEGIN INDENT_STATE;
    return NEWLINE;
}

<INDENT_STATE>[^\n \t\#] {
    unput(yytext[0]);

    if (current_indent_level > indent_stack[indent_sp - 1]) {
        if (indent_sp >= MAX_INDENT_STACK) {
            yyerror("Erro: Limite de indentacao excedido!");
            exit(1);
        }
        indent_stack[indent_sp++] = current_indent_level;
        BEGIN INITIAL;
        return INDENT;
    } else if (current_indent_level < indent_stack[indent_sp - 1]) {
        while (indent_sp > 1 && current_indent_level < indent_stack[indent_sp - 1]) {
            indent_sp--;
            dedents_to_emit++;
        }
        if (current_indent_level != indent_stack[indent_sp - 1]) {
            yyerror("Erro: Indentacao inconsistente");
            exit(1);
        }
        BEGIN INITIAL;
        dedents_to_emit--;
        return DEDENT;
    } else {
        BEGIN INITIAL;
    }
}

<INITIAL>{
    "**"        { atualiza_localizacao(); return POWER; }
    "//"        { atualiza_localizacao(); return FLOOR_DIV; }
    "+="        { atualiza_localizacao(); return PLUS_ASSIGN; }
    "-="        { atualiza_localizacao(); return MINUS_ASSIGN; }
    "*="        { atualiza_localizacao(); return MULTIPLY_ASSIGN; }
    "/="        { atualiza_localizacao(); return DIVIDE_ASSIGN; }
    "%="        { atualiza_localizacao(); return MODULO_ASSIGN; }
    "=="        { atualiza_localizacao(); return EQUAL; }
    "!="        { atualiza_localizacao(); return NOT_EQUAL; }
    "<="        { atualiza_localizacao(); return LESS_EQUAL; }
    ">="        { atualiza_localizacao(); return GREATER_EQUAL; }

    "if"        { atualiza_localizacao(); return IF; }
    "elif"      { atualiza_localizacao(); return ELIF; }
    "else"      { atualiza_localizacao(); return ELSE; }
    "while"     { atualiza_localizacao(); return WHILE; }
    "for"       { atualiza_localizacao(); return FOR; }
    "in"        { atualiza_localizacao(); return IN; }
    "def"       { atualiza_localizacao(); return DEF; }
    "return"    { atualiza_localizacao(); return RETURN; }
    "class"     { atualiza_localizacao(); return CLASS; }
    "import"    { atualiza_localizacao(); return IMPORT; }
    "from"      { atualiza_localizacao(); return FROM; }
    "as"        { atualiza_localizacao(); return AS; }
    "try"       { atualiza_localizacao(); return TRY; }
    "except"    { atualiza_localizacao(); return EXCEPT; }
    "finally"   { atualiza_localizacao(); return FINALLY; }
    "with"      { atualiza_localizacao(); return WITH; }
    "break"     { atualiza_localizacao(); return BREAK; }
    "continue"  { atualiza_localizacao(); return CONTINUE; }
    "pass"      { atualiza_localizacao(); return PASS; }
    "None"      { atualiza_localizacao(); return NONE; }
    "True"      { atualiza_localizacao(); return TRUE; }
    "False"     { atualiza_localizacao(); return FALSE; }

    "and"       { atualiza_localizacao(); return AND; }
    "or"        { atualiza_localizacao(); return OR; }
    "not"       { atualiza_localizacao(); return NOT; }

    "+"         { atualiza_localizacao(); return PLUS; }
    "-"         { atualiza_localizacao(); return MINUS; }
    "*"         { atualiza_localizacao(); return MULTIPLY; }
    "/"         { atualiza_localizacao(); return DIVIDE; }
    "%"         { atualiza_localizacao(); return MODULO; }

    "="         { atualiza_localizacao(); return ASSIGN; }
    "<"         { atualiza_localizacao(); return LESS; }
    ">"         { atualiza_localizacao(); return GREATER; }

    "("         { atualiza_localizacao(); return LPAREN; }
    ")"         { atualiza_localizacao(); return RPAREN; }
    "["         { atualiza_localizacao(); return LBRACKET; }
    "]"         { atualiza_localizacao(); return RBRACKET; }
    "{"         { atualiza_localizacao(); return LBRACE; }
    "}"         { atualiza_localizacao(); return RBRACE; }
    ":"         { atualiza_localizacao(); return COLON; }
    ","         { atualiza_localizacao(); return COMMA; }
    "."         { atualiza_localizacao(); return DOT; }

    {ID}        {
        atualiza_localizacao();
        yylval.string = strdup(yytext);
        return IDENTIFIER;
    }
    {NUM_FLOAT} {
        atualiza_localizacao();
        yylval.real = atof(yytext);
        return FLOAT;
    }
    {NUM_INT}   {
        atualiza_localizacao();
        yylval.integer = atoi(yytext);
        return INTEGER;
    }
    {STRING}    {
        atualiza_localizacao();
        yylval.string = strdup(yytext);
        return STRING_LITERAL;
    }

    {ESPACO}    { atualiza_localizacao(); }
    {COMENTARIO} { atualiza_localizacao(); }

    . {
        atualiza_localizacao();
        fprintf(stderr, "ERRO: Caractere nao reconhecido '%s' na linha %d, coluna %d\n", yytext, linha, coluna - yyleng);
    }
}

<<EOF>> {
    while (indent_sp > 1) {
        indent_sp--;
        return DEDENT;
    }
    return 0;
}

%%