#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>

/* Tipos de nós da AST */
typedef enum {
    NODE_PROGRAM,
    NODE_STMT_LIST,
    NODE_IF,
    NODE_IF_ELSE,
    NODE_WHILE,
    NODE_FOR,
    NODE_FUNCTION,
    NODE_FUNCTION_CALL,
    NODE_ASSIGN,
    NODE_BINARY_OP,
    NODE_UNARY_OP,
    NODE_IDENTIFIER,
    NODE_INTEGER,
    NODE_FLOAT,
    NODE_STRING,
    NODE_BOOLEAN,
    NODE_NONE,
    NODE_PASS,
    NODE_BREAK,
    NODE_CONTINUE,
    NODE_RETURN,
    NODE_EXPR_LIST,
    NODE_PARAM_LIST,
    NODE_LIST
} NodeType;

/* Estrutura do nó da AST */
typedef struct ASTNode {
    NodeType type;
    char* value;
    struct ASTNode** children;
    int num_children;
    int capacity;
} ASTNode;

typedef enum {
    FLOW_NONE,
    FLOW_BREAK,
    FLOW_CONTINUE,
    FLOW_RETURN
} FlowControl;

/* Funções para manipulação da AST */
ASTNode* create_node(NodeType type, const char* value);
void add_child(ASTNode* parent, ASTNode* child);
void print_ast(ASTNode* node, int depth);
void free_ast(ASTNode* node);

/* Interpretador */
FlowControl interpret(ASTNode* node);
int evaluate_expression(ASTNode* node);

FlowControl interpret_stmt_list(ASTNode* node);
FlowControl interpret_assign(ASTNode* node);
FlowControl interpret_if(ASTNode* node);
FlowControl interpret_while(ASTNode* node);
FlowControl interpret_for(ASTNode* node);
FlowControl interpret_function_def(ASTNode* node);
FlowControl interpret_function_call(ASTNode* node);

/* Tabela de símbolos simples */
typedef struct Symbol {
    char* name;
    int* list;     // lista de inteiros (simples)
    int size;      // tamanho da lista
    int value;     // valor inteiro (fallback)
    struct Symbol* next;
} Symbol;



extern Symbol* symbol_table;
void set_variable(const char* name, int value);
int get_variable(const char* name);

#endif