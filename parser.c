#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mapping.h"

/* Funções para buscar traduções */
char* traduzir_palavra_chave(char* python_token) {
    int i = 0;
    while (palavras_chave[i].python != NULL) {
        if (strcmp(palavras_chave[i].python, python_token) == 0) {
            return palavras_chave[i].portugues;
        }
        i++;
    }
    return python_token; // Retorna o token original se não encontrar tradução
}

char* traduzir_operador_logico(char* python_token) {
    int i = 0;
    while (operadores_logicos[i].python != NULL) {
        if (strcmp(operadores_logicos[i].python, python_token) == 0) {
            return operadores_logicos[i].portugues;
        }
        i++;
    }
    return python_token;
}

char* traduzir_operador_aritmetico(char* python_token) {
    int i = 0;
    while (operadores_aritmeticos[i].python != NULL) {
        if (strcmp(operadores_aritmeticos[i].python, python_token) == 0) {
            return operadores_aritmeticos[i].portugues;
        }
        i++;
    }
    return python_token;
}

char* traduzir_operador_atribuicao(char* python_token) {
    int i = 0;
    while (operadores_atribuicao[i].python != NULL) {
        if (strcmp(operadores_atribuicao[i].python, python_token) == 0) {
            return operadores_atribuicao[i].portugues;
        }
        i++;
    }
    return python_token;
}

char* traduzir_operador_comparacao(char* python_token) {
    int i = 0;
    while (operadores_comparacao[i].python != NULL) {
        if (strcmp(operadores_comparacao[i].python, python_token) == 0) {
            return operadores_comparacao[i].portugues;
        }
        i++;
    }
    return python_token;
}

char* traduzir_funcao_builtin(char* python_token) {
    int i = 0;
    while (funcoes_builtin[i].python != NULL) {
        if (strcmp(funcoes_builtin[i].python, python_token) == 0) {
            return funcoes_builtin[i].portugues;
        }
        i++;
    }
    return python_token;
}

/* Função principal para traduzir tokens */
void traduzir_token(char* tipo_token, char* valor_token) {
    if (strcmp(tipo_token, "PALAVRA_CHAVE") == 0) {
        printf("%s: %s\n", tipo_token, traduzir_palavra_chave(valor_token));
    } 
    else if (strcmp(tipo_token, "OPERADOR_LOGICO") == 0) {
        printf("%s: %s\n", tipo_token, traduzir_operador_logico(valor_token));
    }
    else if (strcmp(tipo_token, "OPERADOR_ARITMETICO") == 0) {
        printf("%s: %s\n", tipo_token, traduzir_operador_aritmetico(valor_token));
    }
    else if (strcmp(tipo_token, "OPERADOR_ATRIBUICAO") == 0) {
        printf("%s: %s\n", tipo_token, traduzir_operador_atribuicao(valor_token));
    }
    else if (strcmp(tipo_token, "OPERADOR_COMPARACAO") == 0) {
        printf("%s: %s\n", tipo_token, traduzir_operador_comparacao(valor_token));
    }
    else if (strcmp(tipo_token, "IDENTIFICADOR") == 0) {
        // Verificar se é uma função built-in
        char* traducao = traduzir_funcao_builtin(valor_token);
        printf("%s: %s\n", tipo_token, traducao);
    }
    else {
        // Para outros tipos de token, manter o valor original
        printf("%s: %s\n", tipo_token, valor_token);
    }
}

/* Função para processar a saída do scanner e traduzir */
void processar_saida_scanner(FILE* entrada) {
    char linha[256];
    char tipo_token[50];
    char valor_token[200];
    
    while (fgets(linha, sizeof(linha), entrada)) {
        // Remove a quebra de linha
        linha[strcspn(linha, "\n")] = '\0';
        
        // Tokens especiais que não precisam de tradução
        if (strcmp(linha, "INDENT") == 0 || 
            strcmp(linha, "DEDENT") == 0 || 
            strcmp(linha, "NOVA_LINHA") == 0) {
            printf("%s\n", linha);
            continue;
        }
        
        // Para tokens no formato "TIPO: VALOR"
        if (sscanf(linha, "%[^:]: %[^\n]", tipo_token, valor_token) == 2) {
            traduzir_token(tipo_token, valor_token);
        } else {
            // Se não conseguir extrair tipo e valor, apenas imprime a linha
            printf("%s\n", linha);
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <arquivo_tokens>\n", argv[0]);
        return 1;
    }
    
    FILE* arquivo = fopen(argv[1], "r");
    if (!arquivo) {
        fprintf(stderr, "Erro ao abrir o arquivo %s\n", argv[1]);
        return 1;
    }
    
    processar_saida_scanner(arquivo);
    
    fclose(arquivo);
    return 0;
}