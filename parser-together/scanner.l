%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
%}

%%

[0-9]+         { yylval.intValue = atoi(yytext); return NUM; }
"+"            { return PLUS; }
"-"            { return MINUS; }
"*"            { return TIMES; }
"/"            { return DIVIDE; }
"("            { return LPAREN; }
")"            { return RPAREN; }

[\t\n ]+       { /* ignora espaços e quebras de linha */ }

.              { printf("Caractere não reconhecido: %s\n", yytext); }

%%

int yywrap(void) {
    return 1;
}
