%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);

int resultado;  // variável global para guardar o resultado
%}

%union {
    int intValue;
}

%token <intValue> NUM
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN

%type <intValue> expr input

%%

input:
    expr { resultado = $1; }
;

expr:
    expr PLUS expr     { $$ = $1 + $3; }
  | expr MINUS expr    { $$ = $1 - $3; }
  | expr TIMES expr    { $$ = $1 * $3; }
  | expr DIVIDE expr   { $$ = $1 / $3; }
  | LPAREN expr RPAREN { $$ = $2; }
  | NUM                { $$ = $1; }
;

%%

int main(void) {
    printf("Digite uma expressão matemática:\n");
    yyparse();
    printf("Resultado final: %d\n", resultado);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}
