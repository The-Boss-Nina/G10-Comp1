/* Mapeamento de tokens Python para linguagem abstrata em Português */

struct mapeamento {
  char *python;
  char *portugues;
};

struct mapeamento palavras_chave[] = {
  {"if", "se"},
  {"elif", "senao_se"},
  {"else", "senao"},
  {"while", "enquanto"},
  {"for", "para"},
  {"in", "em"},
  {"def", "funcao"},
  {"return", "retornar"},
  {"class", "classe"},
  {"import", "importar"},
  {"from", "de"},
  {"as", "como"},
  {"try", "tentar"},
  {"except", "exceto"},
  {"finally", "finalmente"},
  {"with", "com"},
  {"break", "parar"},
  {"continue", "continuar"},
  {"pass", "passar"},
  {"None", "Nenhum"},
  {"True", "Verdadeiro"},
  {"False", "Falso"},
  {NULL, NULL}
};

struct mapeamento operadores_logicos[] = {
  {"and", "e"},
  {"or", "ou"},
  {"not", "nao"},
  {NULL, NULL}
};

struct mapeamento operadores_aritmeticos[] = {
  {"+", "mais"},
  {"-", "menos"},
  {"*", "vezes"},
  {"/", "dividido_por"},
  {"%", "modulo"},
  {"**", "elevado_a"},
  {"//", "divisao_inteira"},
  {NULL, NULL}
};

struct mapeamento operadores_atribuicao[] = {
  {"=", "recebe"},
  {"+=", "incrementa"},
  {"-=", "decrementa"},
  {"*=", "multiplica_por"},
  {"/=", "divide_por"},
  {"%=", "modulo_por"},
  {NULL, NULL}
};

struct mapeamento operadores_comparacao[] = {
  {"==", "igual_a"},
  {"!=", "diferente_de"},
  {"<", "menor_que"},
  {">", "maior_que"},
  {"<=", "menor_ou_igual_a"},
  {">=", "maior_ou_igual_a"},
  {NULL, NULL}
};

struct mapeamento funcoes_builtin[] = {
  {"print", "escrever"},
  {"input", "ler"},
  {"len", "tamanho"},
  {"str", "texto"},
  {"int", "inteiro"},
  {"float", "real"},
  {"list", "lista"},
  {"dict", "dicionario"},
  {"range", "intervalo"},
  {NULL, NULL}
};