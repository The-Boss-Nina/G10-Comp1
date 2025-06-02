%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* Forward declaration para evitar dependências circulares */
typedef struct ASTNode ASTNode;

/* Definir YYSTYPE antes de incluir parser.tab.h */
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
int nivel_indentacao = 0;
int stack_indentacao[100];
int topo_stack = 0;
int inicio_linha = 1;

void atualiza_localizacao() {
    coluna += yyleng;
}

void nova_linha() {
    linha++;
    coluna = 1;
    inicio_linha = 1;
}

int processa_indentacao() {
    int espacos = 0;
    char *texto = yytext;
    
    // Conta espaços e tabs
    while (*texto != '\0') {
        if (*texto == ' ') {
            espacos++;
        } else if (*texto == '\t') {
            espacos += 4; // 1 tab = 4 espaços
        }
        texto++;
    }
    
    int novo_nivel = espacos / 4;
    
    if (novo_nivel > nivel_indentacao) {
        // Aumentou indentação
        stack_indentacao[topo_stack++] = nivel_indentacao;
        nivel_indentacao = novo_nivel;
        return INDENT;
    } else if (novo_nivel < nivel_indentacao) {
        // Diminuiu indentação - pode precisar de múltiplos DEDENTs
        // Por enquanto, retorna apenas um DEDENT
        if (topo_stack > 0) {
            nivel_indentacao = stack_indentacao[--topo_stack];
        } else {
            nivel_indentacao = novo_nivel;
        }
        return DEDENT;
    }
    
    return 0; // Mesmo nível de indentação
}

%}

%option noyywrap

/* Definições */
DIGITO      [0-9]
LETRA       [a-zA-Z]
ID          [a-zA-Z_][a-zA-Z0-9_]*
NUM_INT     {DIGITO}+
NUM_FLOAT   {DIGITO}+\.{DIGITO}+
STRING      \"[^\"]*\"|\'[^\']*\'
ESPACO      [ \t]+
NOVA_LINHA  \n
INDENTACAO  ^[ \t]+

%%

    /* Tratamento de indentação */
{INDENTACAO} { 
    if (inicio_linha) {
        coluna += yyleng;
        inicio_linha = 0;
        int token = processa_indentacao();
        if (token) return token;
    } else {
        coluna += yyleng;
    }
}

    /* Palavras-chave */
"if"        { atualiza_localizacao(); inicio_linha = 0; return IF; }
"elif"      { atualiza_localizacao(); inicio_linha = 0; return ELIF; }
"else"      { atualiza_localizacao(); inicio_linha = 0; return ELSE; }
"while"     { atualiza_localizacao(); inicio_linha = 0; return WHILE; }
"for"       { atualiza_localizacao(); inicio_linha = 0; return FOR; }
"in"        { atualiza_localizacao(); inicio_linha = 0; return IN; }
"def"       { atualiza_localizacao(); inicio_linha = 0; return DEF; }
"return"    { atualiza_localizacao(); inicio_linha = 0; return RETURN; }
"class"     { atualiza_localizacao(); inicio_linha = 0; return CLASS; }
"import"    { atualiza_localizacao(); inicio_linha = 0; return IMPORT; }
"from"      { atualiza_localizacao(); inicio_linha = 0; return FROM; }
"as"        { atualiza_localizacao(); inicio_linha = 0; return AS; }
"try"       { atualiza_localizacao(); inicio_linha = 0; return TRY; }
"except"    { atualiza_localizacao(); inicio_linha = 0; return EXCEPT; }
"finally"   { atualiza_localizacao(); inicio_linha = 0; return FINALLY; }
"with"      { atualiza_localizacao(); inicio_linha = 0; return WITH; }
"break"     { atualiza_localizacao(); inicio_linha = 0; return BREAK; }
"continue"  { atualiza_localizacao(); inicio_linha = 0; return CONTINUE; }
"pass"      { atualiza_localizacao(); inicio_linha = 0; return PASS; }
"None"      { atualiza_localizacao(); inicio_linha = 0; return NONE; }
"True"      { atualiza_localizacao(); inicio_linha = 0; return TRUE; }
"False"     { atualiza_localizacao(); inicio_linha = 0; return FALSE; }

    /* Operadores lógicos */
"and"       { atualiza_localizacao(); inicio_linha = 0; return AND; }
"or"        { atualiza_localizacao(); inicio_linha = 0; return OR; }
"not"       { atualiza_localizacao(); inicio_linha = 0; return NOT; }

    /* Operadores aritméticos - ordem importante! */
"**"        { atualiza_localizacao(); inicio_linha = 0; return POWER; }
"//"        { atualiza_localizacao(); inicio_linha = 0; return FLOOR_DIV; }
"+"         { atualiza_localizacao(); inicio_linha = 0; return PLUS; }
"-"         { atualiza_localizacao(); inicio_linha = 0; return MINUS; }
"*"         { atualiza_localizacao(); inicio_linha = 0; return MULTIPLY; }
"/"         { atualiza_localizacao(); inicio_linha = 0; return DIVIDE; }
"%"         { atualiza_localizacao(); inicio_linha = 0; return MODULO; }

    /* Operadores de atribuição - ordem importante! */
"+="        { atualiza_localizacao(); inicio_linha = 0; return PLUS_ASSIGN; }
"-="        { atualiza_localizacao(); inicio_linha = 0; return MINUS_ASSIGN; }
"*="        { atualiza_localizacao(); inicio_linha = 0; return MULTIPLY_ASSIGN; }
"/="        { atualiza_localizacao(); inicio_linha = 0; return DIVIDE_ASSIGN; }
"%="        { atualiza_localizacao(); inicio_linha = 0; return MODULO_ASSIGN; }
"="         { atualiza_localizacao(); inicio_linha = 0; return ASSIGN; }

    /* Operadores de comparação - ordem importante! */
"=="        { atualiza_localizacao(); inicio_linha = 0; return EQUAL; }
"!="        { atualiza_localizacao(); inicio_linha = 0; return NOT_EQUAL; }
"<="        { atualiza_localizacao(); inicio_linha = 0; return LESS_EQUAL; }
">="        { atualiza_localizacao(); inicio_linha = 0; return GREATER_EQUAL; }
"<"         { atualiza_localizacao(); inicio_linha = 0; return LESS; }
">"         { atualiza_localizacao(); inicio_linha = 0; return GREATER; }

    /* Delimitadores */
"("         { atualiza_localizacao(); inicio_linha = 0; return LPAREN; }
")"         { atualiza_localizacao(); inicio_linha = 0; return RPAREN; }
"["         { atualiza_localizacao(); inicio_linha = 0; return LBRACKET; }
"]"         { atualiza_localizacao(); inicio_linha = 0; return RBRACKET; }
"{"         { atualiza_localizacao(); inicio_linha = 0; return LBRACE; }
"}"         { atualiza_localizacao(); inicio_linha = 0; return RBRACE; }
":"         { atualiza_localizacao(); inicio_linha = 0; return COLON; }
","         { atualiza_localizacao(); inicio_linha = 0; return COMMA; }
"."         { atualiza_localizacao(); inicio_linha = 0; return DOT; }

    /* Tokens literais */
{ID}        { 
    atualiza_localizacao(); 
    inicio_linha = 0; 
    yylval.string = strdup(yytext); 
    return IDENTIFIER; 
}
{NUM_INT}   { 
    atualiza_localizacao(); 
    inicio_linha = 0; 
    yylval.integer = atoi(yytext); 
    return INTEGER; 
}
{NUM_FLOAT} { 
    atualiza_localizacao(); 
    inicio_linha = 0; 
    yylval.real = atof(yytext); 
    return FLOAT; 
}
{STRING}    { 
    atualiza_localizacao(); 
    inicio_linha = 0; 
    yylval.string = strdup(yytext); 
    return STRING_LITERAL; 
}

    /* Nova linha */
{NOVA_LINHA} { 
    nova_linha();
    return NEWLINE;
}

    /* Espaços (ignorados exceto no início da linha) */
{ESPACO}    { 
    if (!inicio_linha) {
        atualiza_localizacao(); 
    }
}

    /* Comentários */
"#".*       { atualiza_localizacao(); inicio_linha = 0; /* ignora comentários */ }

    /* Caracteres não reconhecidos */
.           { 
    atualiza_localizacao(); 
    printf("ERRO: Caractere não reconhecido '%s' na linha %d, coluna %d\n", yytext, linha, coluna-1); 
    inicio_linha = 0;
}

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro na linha %d, coluna %d: %s\n", linha, coluna, s);
}