#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "ast.h"

/* Tabela de símbolos global */
Symbol* symbol_table = NULL;

/* Criar um novo nó da AST */
ASTNode* create_node(NodeType type, const char* value) {
    ASTNode* node = malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Erro: falha na alocação de memória\n");
        exit(1);
    }
    
    node->type = type;
    node->value = value ? strdup(value) : NULL;
    node->children = NULL;
    node->num_children = 0;
    node->capacity = 0;
    
    return node;
}

/* Adicionar um filho ao nó */
void add_child(ASTNode* parent, ASTNode* child) {
    if (!parent || !child) return;
    
    if (parent->num_children >= parent->capacity) {
        parent->capacity = parent->capacity == 0 ? 2 : parent->capacity * 2;
        parent->children = realloc(parent->children, 
                                 parent->capacity * sizeof(ASTNode*));
        if (!parent->children) {
            fprintf(stderr, "Erro: falha na realocação de memória\n");
            exit(1);
        }
    }
    
    parent->children[parent->num_children++] = child;
}

/* Imprimir a AST */
void print_ast(ASTNode* node, int depth) {
    if (!node) return;
    
    for (int i = 0; i < depth; i++) {
        printf("  ");
    }
    
    const char* type_names[] = {
        "PROGRAMA", "LISTA_COMANDOS", "SE", "SE_SENAO", "ENQUANTO", "PARA",
        "FUNCAO", "CHAMADA_FUNCAO", "ATRIBUICAO", "OP_BINARIO", "OP_UNARIO",
        "IDENTIFICADOR", "INTEIRO", "REAL", "TEXTO", "BOOLEANO", "NENHUM",
        "PASSAR", "PARAR", "CONTINUAR", "RETORNAR", "LISTA_EXPR", "LISTA_PARAM",
        "LISTA"
    };
    
    printf("%s", type_names[node->type]);
    if (node->value) {
        printf(": %s", node->value);
    }
    printf("\n");
    
    for (int i = 0; i < node->num_children; i++) {
        print_ast(node->children[i], depth + 1);
    }
}

/* Liberar memória da AST */
void free_ast(ASTNode* node) {
    if (!node) return;
    
    for (int i = 0; i < node->num_children; i++) {
        free_ast(node->children[i]);
    }
    
    if (node->children) {
        free(node->children);
    }
    if (node->value) {
        free(node->value);
    }
    free(node);
}

/* Funções da tabela de símbolos */
void set_variable(const char* name, int value) {
    Symbol* sym = symbol_table;
    
    // Procura se a variável já existe
    while (sym) {
        if (strcmp(sym->name, name) == 0) {
            sym->value = value;
            return;
        }
        sym = sym->next;
    }
    
    // Cria nova variável
    sym = malloc(sizeof(Symbol));
    sym->name = strdup(name);
    sym->value = value;
    sym->next = symbol_table;
    symbol_table = sym;
}

int get_variable(const char* name) {
    Symbol* sym = symbol_table;
    while (sym) {
        if (strcmp(sym->name, name) == 0) {
            return sym->value;
        }
        sym = sym->next;
    }
    
    printf("Erro: variável '%s' não foi declarada\n", name);
    return 0;
}

/* Interpretador */
void interpret(ASTNode* node) {
    if (!node) return;
    
    switch (node->type) {
        case NODE_STMT_LIST:
            interpret_stmt_list(node);
            break;
        case NODE_ASSIGN:
            interpret_assign(node);
            break;
        case NODE_IF:
        case NODE_IF_ELSE:
            interpret_if(node);
            break;
        case NODE_WHILE:
            interpret_while(node);
            break;
        case NODE_FOR:
            interpret_for(node);
            break;
        case NODE_FUNCTION:
            interpret_function_def(node);
            break;
        case NODE_FUNCTION_CALL:
            interpret_function_call(node);
            break;
        case NODE_PASS:
            printf("EXECUTANDO: passar\n");
            break;
        case NODE_BREAK:
            printf("EXECUTANDO: parar\n");
            break;
        case NODE_CONTINUE:
            printf("EXECUTANDO: continuar\n");
            break;
        case NODE_RETURN:
            printf("EXECUTANDO: retornar");
            if (node->num_children > 0) {
                printf(" %d", evaluate_expression(node->children[0]));
            }
            printf("\n");
            break;
        default:
            // Para outros tipos, apenas avalia como expressão
            evaluate_expression(node);
            break;
    }
}

void interpret_function_def(ASTNode* node) {
    if (node->num_children >= 1) {
        ASTNode* name = node->children[0];
        printf("EXECUTANDO: definição de função %s\n", name->value);
        // Implementação simplificada - apenas reporta a definição
    }
}

void interpret_stmt_list(ASTNode* node) {
    for (int i = 0; i < node->num_children; i++) {
        interpret(node->children[i]);
    }
}

void interpret_assign(ASTNode* node) {
    if (node->num_children >= 2) {
        ASTNode* var = node->children[0];
        ASTNode* expr = node->children[1];
        
        int value = evaluate_expression(expr);
        set_variable(var->value, value);
        
        printf("EXECUTANDO: %s %s %d\n", var->value, node->value, value);
    }
}

void interpret_if(ASTNode* node) {
    if (node->num_children >= 2) {
        int condition = evaluate_expression(node->children[0]);
        printf("EXECUTANDO: se (condição: %d)\n", condition);
        
        if (condition) {
            interpret(node->children[1]);
        } else if (node->type == NODE_IF_ELSE && node->num_children >= 3) {
            printf("EXECUTANDO: senao\n");
            interpret(node->children[2]);
        }
    }
}

void interpret_while(ASTNode* node) {
    if (node->num_children >= 2) {
        printf("EXECUTANDO: enquanto\n");
        while (evaluate_expression(node->children[0])) {
            interpret(node->children[1]);
        }
    }
}

void interpret_for(ASTNode* node) {
    if (node->num_children >= 3) {
        ASTNode* var = node->children[0];
        printf("EXECUTANDO: para %s em (lista)\n", var->value);
        // Implementação simplificada
        interpret(node->children[2]);
    }
}

void interpret_function_call(ASTNode* node) {
    printf("EXECUTANDO: chamada de função %s\n", node->value);
    
    // Tratamento especial para print/escrever
    if (strcmp(node->value, "escrever") == 0 || strcmp(node->value, "print") == 0) {
        printf("SAÍDA: ");
        if (node->num_children > 0) {
            ASTNode* args = node->children[0];
            for (int i = 0; i < args->num_children; i++) {
                if (args->children[i]->type == NODE_STRING) {
                    printf("%s ", args->children[i]->value);
                } else {
                    printf("%d ", evaluate_expression(args->children[i]));
                }
            }
        }
        printf("\n");
    }
}

int evaluate_expression(ASTNode* node) {
    if (!node) return 0;
    
    switch (node->type) {
        case NODE_INTEGER:
            return atoi(node->value);
        case NODE_FLOAT:
            return (int)atof(node->value);
        case NODE_IDENTIFIER:
            return get_variable(node->value);
        case NODE_BOOLEAN:
            return strcmp(node->value, "Verdadeiro") == 0 ? 1 : 0;
        case NODE_NONE:
            return 0;
        case NODE_BINARY_OP:
            if (node->num_children >= 2) {
                int left = evaluate_expression(node->children[0]);
                int right = evaluate_expression(node->children[1]);
                
                if (strcmp(node->value, "mais") == 0) return left + right;
                if (strcmp(node->value, "menos") == 0) return left - right;
                if (strcmp(node->value, "vezes") == 0) return left * right;
                if (strcmp(node->value, "dividido_por") == 0) return right != 0 ? left / right : 0;
                if (strcmp(node->value, "modulo") == 0) return right != 0 ? left % right : 0;
                if (strcmp(node->value, "igual_a") == 0) return left == right;
                if (strcmp(node->value, "diferente_de") == 0) return left != right;
                if (strcmp(node->value, "menor_que") == 0) return left < right;
                if (strcmp(node->value, "maior_que") == 0) return left > right;
                if (strcmp(node->value, "menor_ou_igual_a") == 0) return left <= right;
                if (strcmp(node->value, "maior_ou_igual_a") == 0) return left >= right;
                if (strcmp(node->value, "e") == 0) return left && right;
                if (strcmp(node->value, "ou") == 0) return left || right;
            }
            break;
        case NODE_UNARY_OP:
            if (node->num_children >= 1) {
                int operand = evaluate_expression(node->children[0]);
                if (strcmp(node->value, "nao") == 0) return !operand;
                if (strcmp(node->value, "negativo") == 0) return -operand;
                if (strcmp(node->value, "positivo") == 0) return operand;
            }
            break;
        default:
            break;
    }
    
    return 0;
}