%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int linha = 1;
int coluna = 1;
int nivel_indentacao = 0;
int ultimo_nivel_indentacao = 0;

void atualiza_localizacao() {
    coluna += yyleng;
}

void nova_linha() {
    linha++;
    coluna = 1;
}

void conta_indentacao() {
    int espacos = 0;
    char *texto = yytext;
    while (*texto != '\0') {
        if (*texto == ' ') {
            espacos++;
        } else if (*texto == '\t') {
            espacos += 4; // convenção comum em Python (1 tab = 4 espaços)
        }
        texto++;
    }
    
    ultimo_nivel_indentacao = nivel_indentacao;
    nivel_indentacao = espacos / 4; // assumindo 4 espaços por nível
    
    if (nivel_indentacao > ultimo_nivel_indentacao) {
        printf("INDENT\n");
    } else if (nivel_indentacao < ultimo_nivel_indentacao) {
        int diferenca = ultimo_nivel_indentacao - nivel_indentacao;
        for (int i = 0; i < diferenca; i++) {
            printf("DEDENT\n");
        }
    }
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

"if"        { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"elif"      { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"else"      { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"while"     { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"for"       { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"in"        { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"def"       { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"return"    { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"class"     { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"import"    { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"from"      { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"as"        { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"try"       { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"except"    { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"finally"   { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"with"      { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"break"     { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"continue"  { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"pass"      { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"None"      { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"True"      { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"False"     { atualiza_localizacao(); printf("PALAVRA_CHAVE: %s\n", yytext); }
"and"       { atualiza_localizacao(); printf("OPERADOR_LOGICO: %s\n", yytext); }
"or"        { atualiza_localizacao(); printf("OPERADOR_LOGICO: %s\n", yytext); }
"not"       { atualiza_localizacao(); printf("OPERADOR_LOGICO: %s\n", yytext); }

"+"         { atualiza_localizacao(); printf("OPERADOR_ARITMETICO: %s\n", yytext); }
"-"         { atualiza_localizacao(); printf("OPERADOR_ARITMETICO: %s\n", yytext); }
"*"         { atualiza_localizacao(); printf("OPERADOR_ARITMETICO: %s\n", yytext); }
"/"         { atualiza_localizacao(); printf("OPERADOR_ARITMETICO: %s\n", yytext); }
"%"         { atualiza_localizacao(); printf("OPERADOR_ARITMETICO: %s\n", yytext); }
"**"        { atualiza_localizacao(); printf("OPERADOR_ARITMETICO: %s\n", yytext); }
"//"        { atualiza_localizacao(); printf("OPERADOR_ARITMETICO: %s\n", yytext); }

"="         { atualiza_localizacao(); printf("OPERADOR_ATRIBUICAO: %s\n", yytext); }
"+="        { atualiza_localizacao(); printf("OPERADOR_ATRIBUICAO: %s\n", yytext); }
"-="        { atualiza_localizacao(); printf("OPERADOR_ATRIBUICAO: %s\n", yytext); }
"*="        { atualiza_localizacao(); printf("OPERADOR_ATRIBUICAO: %s\n", yytext); }
"/="        { atualiza_localizacao(); printf("OPERADOR_ATRIBUICAO: %s\n", yytext); }
"%="        { atualiza_localizacao(); printf("OPERADOR_ATRIBUICAO: %s\n", yytext); }

"=="        { atualiza_localizacao(); printf("OPERADOR_COMPARACAO: %s\n", yytext); }
"!="        { atualiza_localizacao(); printf("OPERADOR_COMPARACAO: %s\n", yytext); }
"<"         { atualiza_localizacao(); printf("OPERADOR_COMPARACAO: %s\n", yytext); }
">"         { atualiza_localizacao(); printf("OPERADOR_COMPARACAO: %s\n", yytext); }
"<="        { atualiza_localizacao(); printf("OPERADOR_COMPARACAO: %s\n", yytext); }
">="        { atualiza_localizacao(); printf("OPERADOR_COMPARACAO: %s\n", yytext); }

"("         { atualiza_localizacao(); printf("DELIMITADOR: %s\n", yytext); }
")"         { atualiza_localizacao(); printf("DELIMITADOR: %s\n", yytext); }
"["         { atualiza_localizacao(); printf("DELIMITADOR: %s\n", yytext); }
"]"         { atualiza_localizacao(); printf("DELIMITADOR: %s\n", yytext); }
"{"         { atualiza_localizacao(); printf("DELIMITADOR: %s\n", yytext); }
"}"         { atualiza_localizacao(); printf("DELIMITADOR: %s\n", yytext); }
":"         { atualiza_localizacao(); printf("DELIMITADOR: %s\n", yytext); }
","         { atualiza_localizacao(); printf("DELIMITADOR: %s\n", yytext); }
"."         { atualiza_localizacao(); printf("DELIMITADOR: %s\n", yytext); }

{ID}        { atualiza_localizacao(); printf("IDENTIFICADOR: %s\n", yytext); }
{NUM_INT}   { atualiza_localizacao(); printf("NUMERO_INTEIRO: %s\n", yytext); }
{NUM_FLOAT} { atualiza_localizacao(); printf("NUMERO_FLOAT: %s\n", yytext); }
{STRING}    { atualiza_localizacao(); printf("STRING: %s\n", yytext); }

{INDENTACAO} { 
    if (coluna == 1) {
        conta_indentacao();
    }
    coluna += yyleng;
}

{NOVA_LINHA} { 
    nova_linha();
    printf("NOVA_LINHA\n");
}

{ESPACO}    { atualiza_localizacao(); /* Ignora espaços que não estão no início da linha */ }

"#".*       { atualiza_localizacao(); printf("COMENTARIO: %s\n", yytext); }

.           { 
    atualiza_localizacao(); 
    printf("ERRO: Caractere não reconhecido '%s' na linha %d, coluna %d\n", yytext, linha, coluna-1); 
}

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *arquivo = fopen(argv[1], "r");
        if (!arquivo) {
            printf("Erro ao abrir o arquivo %s\n", argv[1]);
            return 1;
        }
        yyin = arquivo;
    }
    
    yylex();
    
    // Emite DEDENT restantes no final do arquivo
    for (int i = 0; i < nivel_indentacao; i++) {
        printf("DEDENT\n");
    }
    
    if (argc > 1) {
        fclose(yyin);
    }
    
    return 0;
}