%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "ast.h"
#include "mapping.h"

extern int yylex();
extern void yyerror(const char *s);
extern int linha, coluna;

ASTNode* raiz_ast = NULL;
%}

%union {
    int integer;
    double real;
    char* string;
    ASTNode* node;
}

/* Tokens terminais */
%token <integer> INTEGER
%token <real> FLOAT
%token <string> IDENTIFIER STRING_LITERAL

/* Palavras-chave */
%token IF ELIF ELSE WHILE FOR IN DEF RETURN CLASS IMPORT FROM AS
%token TRY EXCEPT FINALLY WITH BREAK CONTINUE PASS
%token NONE TRUE FALSE

/* Operadores */
%token AND OR NOT
%token PLUS MINUS MULTIPLY DIVIDE MODULO POWER FLOOR_DIV
%token ASSIGN PLUS_ASSIGN MINUS_ASSIGN MULTIPLY_ASSIGN DIVIDE_ASSIGN MODULO_ASSIGN
%token EQUAL NOT_EQUAL LESS GREATER LESS_EQUAL GREATER_EQUAL

/* Delimitadores */
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token COLON COMMA DOT NEWLINE INDENT DEDENT

/* Tipos não-terminais */
%type <node> programa stmt_list stmt simple_stmt compound_stmt small_stmt
%type <node> if_stmt while_stmt for_stmt def_stmt
%type <node> expr_stmt assign_stmt
%type <node> expr or_expr and_expr not_expr comparison_expr
%type <node> arith_expr term factor atom
%type <node> suite
%type <node> expr_list identifier_list

/* Precedência e associatividade */
%right ASSIGN PLUS_ASSIGN MINUS_ASSIGN MULTIPLY_ASSIGN DIVIDE_ASSIGN MODULO_ASSIGN
%left OR
%left AND
%left NOT
%left EQUAL NOT_EQUAL LESS GREATER LESS_EQUAL GREATER_EQUAL
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO FLOOR_DIV
%right POWER
%left LPAREN RPAREN LBRACKET RBRACKET

%%

programa:
    stmt_list { 
        raiz_ast = $1; 
        printf("AST construída com sucesso!\n");
    }
    ;

stmt_list:
    /* vazio */ { $$ = create_node(NODE_STMT_LIST, NULL); }
    | stmt_list stmt { 
        $$ = $1; 
        if ($2) add_child($$, $2); 
    }
    | stmt_list NEWLINE { $$ = $1; } /* Ignora linhas vazias extras */
    ;

stmt:
    simple_stmt NEWLINE { $$ = $1; }
    | simple_stmt { $$ = $1; } /* Permite statements sem NEWLINE */
    | compound_stmt { $$ = $1; }
    | NEWLINE { $$ = NULL; } /* Linha vazia */
    | error NEWLINE { $$ = NULL; yyerrok; }
    ;

simple_stmt:
    small_stmt { $$ = $1; }
    ;

small_stmt:
    expr_stmt { $$ = $1; }
    | assign_stmt { $$ = $1; }
    | PASS { $$ = create_node(NODE_PASS, "passar"); }
    | BREAK { $$ = create_node(NODE_BREAK, "parar"); }
    | CONTINUE { $$ = create_node(NODE_CONTINUE, "continuar"); }
    | RETURN { $$ = create_node(NODE_RETURN, "retornar"); }
    | RETURN expr { 
        $$ = create_node(NODE_RETURN, "retornar"); 
        add_child($$, $2);
    }
    | IDENTIFIER LPAREN RPAREN { 
        char* translated = translate_builtin($1);
        $$ = create_node(NODE_FUNCTION_CALL, translated); 
    }
    | IDENTIFIER LPAREN expr_list RPAREN { 
        char* translated = translate_builtin($1);
        $$ = create_node(NODE_FUNCTION_CALL, translated); 
        add_child($$, $3);
    }
    ;

compound_stmt:
    if_stmt { $$ = $1; }
    | while_stmt { $$ = $1; }
    | for_stmt { $$ = $1; }
    | def_stmt { $$ = $1; }
    ;

if_stmt:
    IF expr COLON suite { 
        $$ = create_node(NODE_IF, "se"); 
        add_child($$, $2);
        add_child($$, $4);
    }
    | IF expr COLON suite ELSE COLON suite { 
        $$ = create_node(NODE_IF_ELSE, "se_senao"); 
        add_child($$, $2);
        add_child($$, $4);
        add_child($$, $7);
    }
    ;

while_stmt:
    WHILE expr COLON suite { 
        $$ = create_node(NODE_WHILE, "enquanto"); 
        add_child($$, $2);
        add_child($$, $4);
    }
    ;

for_stmt:
    FOR IDENTIFIER IN expr COLON suite { 
        $$ = create_node(NODE_FOR, "para"); 
        ASTNode* var = create_node(NODE_IDENTIFIER, $2);
        add_child($$, var);
        add_child($$, $4);
        add_child($$, $6);
    }
    ;

def_stmt:
    DEF IDENTIFIER LPAREN RPAREN COLON suite { 
        $$ = create_node(NODE_FUNCTION, "funcao"); 
        ASTNode* name = create_node(NODE_IDENTIFIER, $2);
        add_child($$, name);
        add_child($$, $6);
    }
    | DEF IDENTIFIER LPAREN identifier_list RPAREN COLON suite { 
        $$ = create_node(NODE_FUNCTION, "funcao"); 
        ASTNode* name = create_node(NODE_IDENTIFIER, $2);
        add_child($$, name);
        add_child($$, $4);
        add_child($$, $7);
    }
    ;

suite:
    NEWLINE INDENT stmt_list DEDENT { $$ = $3; }
    ;

expr_stmt:
    expr { $$ = $1; }
    ;

assign_stmt:
    IDENTIFIER ASSIGN expr { 
        $$ = create_node(NODE_ASSIGN, "recebe"); 
        ASTNode* var = create_node(NODE_IDENTIFIER, $1);
        add_child($$, var);
        add_child($$, $3);
    }
    | IDENTIFIER PLUS_ASSIGN expr { 
        $$ = create_node(NODE_ASSIGN, "incrementa"); 
        ASTNode* var = create_node(NODE_IDENTIFIER, $1);
        add_child($$, var);
        add_child($$, $3);
    }
    | IDENTIFIER MINUS_ASSIGN expr { 
        $$ = create_node(NODE_ASSIGN, "decrementa"); 
        ASTNode* var = create_node(NODE_IDENTIFIER, $1);
        add_child($$, var);
        add_child($$, $3);
    }
    ;

expr:
    or_expr { $$ = $1; }
    ;

or_expr:
    and_expr { $$ = $1; }
    | or_expr OR and_expr { 
        $$ = create_node(NODE_BINARY_OP, "ou"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    ;

and_expr:
    not_expr { $$ = $1; }
    | and_expr AND not_expr { 
        $$ = create_node(NODE_BINARY_OP, "e"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    ;

not_expr:
    comparison_expr { $$ = $1; }
    | NOT not_expr { 
        $$ = create_node(NODE_UNARY_OP, "nao"); 
        add_child($$, $2);
    }
    ;

comparison_expr:
    arith_expr { $$ = $1; }
    | comparison_expr EQUAL arith_expr { 
        $$ = create_node(NODE_BINARY_OP, "igual_a"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    | comparison_expr NOT_EQUAL arith_expr { 
        $$ = create_node(NODE_BINARY_OP, "diferente_de"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    | comparison_expr LESS arith_expr { 
        $$ = create_node(NODE_BINARY_OP, "menor_que"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    | comparison_expr GREATER arith_expr { 
        $$ = create_node(NODE_BINARY_OP, "maior_que"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    | comparison_expr LESS_EQUAL arith_expr { 
        $$ = create_node(NODE_BINARY_OP, "menor_ou_igual_a"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    | comparison_expr GREATER_EQUAL arith_expr { 
        $$ = create_node(NODE_BINARY_OP, "maior_ou_igual_a"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    ;

arith_expr:
    term { $$ = $1; }
    | arith_expr PLUS term { 
        $$ = create_node(NODE_BINARY_OP, "mais"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    | arith_expr MINUS term { 
        $$ = create_node(NODE_BINARY_OP, "menos"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    ;

term:
    factor { $$ = $1; }
    | term MULTIPLY factor { 
        $$ = create_node(NODE_BINARY_OP, "vezes"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    | term DIVIDE factor { 
        $$ = create_node(NODE_BINARY_OP, "dividido_por"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    | term MODULO factor { 
        $$ = create_node(NODE_BINARY_OP, "modulo"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    | term FLOOR_DIV factor { 
        $$ = create_node(NODE_BINARY_OP, "divisao_inteira"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    ;

factor:
    atom { $$ = $1; }
    | PLUS factor { 
        $$ = create_node(NODE_UNARY_OP, "positivo"); 
        add_child($$, $2);
    }
    | MINUS factor { 
        $$ = create_node(NODE_UNARY_OP, "negativo"); 
        add_child($$, $2);
    }
    | factor POWER atom { 
        $$ = create_node(NODE_BINARY_OP, "elevado_a"); 
        add_child($$, $1);
        add_child($$, $3);
    }
    ;

atom:
    IDENTIFIER { 
        char* translated = translate_builtin($1);
        $$ = create_node(NODE_IDENTIFIER, translated); 
    }
    | INTEGER { 
        char buffer[32];
        sprintf(buffer, "%d", $1);
        $$ = create_node(NODE_INTEGER, buffer); 
    }
    | FLOAT { 
        char buffer[32];
        sprintf(buffer, "%.2f", $1);
        $$ = create_node(NODE_FLOAT, buffer); 
    }
    | STRING_LITERAL { $$ = create_node(NODE_STRING, $1); }
    | TRUE { $$ = create_node(NODE_BOOLEAN, "Verdadeiro"); }
    | FALSE { $$ = create_node(NODE_BOOLEAN, "Falso"); }
    | NONE { $$ = create_node(NODE_NONE, "Nenhum"); }
    | LPAREN expr RPAREN { $$ = $2; }
    | IDENTIFIER LPAREN RPAREN { 
        char* translated = translate_builtin($1);
        $$ = create_node(NODE_FUNCTION_CALL, translated); 
    }
    | IDENTIFIER LPAREN expr_list RPAREN { 
        char* translated = translate_builtin($1);
        $$ = create_node(NODE_FUNCTION_CALL, translated); 
        add_child($$, $3);
    }
    | LBRACKET expr_list RBRACKET {
        $$ = create_node(NODE_LIST, "lista");
        add_child($$, $2);
    }
    | LBRACKET RBRACKET {
        $$ = create_node(NODE_LIST, "lista_vazia");
    }
    ;

expr_list:
    expr { 
        $$ = create_node(NODE_EXPR_LIST, NULL); 
        add_child($$, $1);
    }
    | expr_list COMMA expr { 
        $$ = $1; 
        add_child($$, $3); 
    }
    ;

identifier_list:
    IDENTIFIER { 
        $$ = create_node(NODE_PARAM_LIST, NULL); 
        ASTNode* param = create_node(NODE_IDENTIFIER, $1);
        add_child($$, param);
    }
    | identifier_list COMMA IDENTIFIER { 
        $$ = $1; 
        ASTNode* param = create_node(NODE_IDENTIFIER, $3);
        add_child($$, param); 
    }
    ;

%%

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *arquivo = fopen(argv[1], "r");
        if (!arquivo) {
            printf("Erro ao abrir o arquivo %s\n", argv[1]);
            return 1;
        }
        extern FILE* yyin;
        yyin = arquivo;
    }
    
    printf("Iniciando análise sintática...\n");
    
    if (yyparse() == 0) {
        printf("Análise sintática concluída com sucesso!\n");
        
        if (raiz_ast) {
            printf("\n=== AST em Português ===\n");
            print_ast(raiz_ast, 0);
            
            printf("\n=== Interpretação ===\n");
            interpret(raiz_ast);
        }
    } else {
        printf("Erro na análise sintática!\n");
        return 1;
    }
    
    if (argc > 1) {
        extern FILE* yyin;
        fclose(yyin);
    }
    
    return 0;
}