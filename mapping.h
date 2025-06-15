#ifndef MAPPING_H
#define MAPPING_H

#include <string.h>

/* Mapeamento de funções built-in Python para Português */
struct builtin_mapping {
    char *python;
    char *portugues;
};

static struct builtin_mapping funcoes_builtin[] = {
    {"print", "escrever"},
    {"input", "ler"},
    {"len", "tamanho"},
    {"str", "texto"},
    {"int", "inteiro"},
    {"float", "real"},
    {"list", "lista"},
    {"dict", "dicionario"},
    {"range", "intervalo"},
    {"sum", "somar"},
    {"max", "maximo"},
    {"min", "minimo"},
    {"abs", "absoluto"},
    {"round", "arredondar"},

    /* Novas funções adicionadas */
    {"type", "tipo"},
    {"bool", "booleano"},
    {"enumerate", "enumerar"},
    {"zip", "emparelhar"},
    {"reversed", "reverter"},
    {"sorted", "ordenar"},
    {"map", "mapear"},
    {"filter", "filtrar"},
    {"all", "todos"},
    {"any", "algum"},
    {"open", "abrir"},
    {"chr", "caractere"},
    {"ord", "codigo"},
    {"bin", "binario"},
    {"hex", "hexadecimal"},
    {"oct", "octal"},
    {"pow", "potencia"},
    {"divmod", "dividir_modulo"},
    {"isinstance", "e_instancia"},
    {"issubclass", "e_subclasse"},
    {"help", "ajuda"},
    {"id", "identificador"},

    {NULL, NULL}
};

/* Função para traduzir funções built-in */
static inline char* translate_builtin(char* python_name) {
    int i = 0;
    while (funcoes_builtin[i].python != NULL) {
        if (strcmp(funcoes_builtin[i].python, python_name) == 0) {
            return funcoes_builtin[i].portugues;
        }
        i++;
    }
    return python_name; // Retorna o nome original se não encontrar tradução
}

#endif
