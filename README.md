# Interpretador Python para Linguagem Abstrata em Português

Este projeto implementa um interpretador que traduz código Python para uma linguagem abstrata em português. Ele foi desenvolvido como parte da disciplina de Compiladores 1 (FGA0003).

## Estrutura do Projeto

O projeto é composto pelos seguintes componentes:

1. **scanner.l**: Analisador léxico escrito em Flex que identifica tokens de código Python.
2. **mapeamento.h**: Contém o mapeamento de tokens Python para seus equivalentes em português.
3. **tradutor.c**: Converte os tokens Python identificados pelo scanner para a linguagem abstrata em português.
4. **Makefile**: Script para facilitar a compilação e execução do projeto.

## Tokens Implementados

O interpretador reconhece os seguintes tipos de tokens:

### Palavras-chave
- `if` → `se`
- `elif` → `senao_se`
- `else` → `senao`
- `while` → `enquanto`
- `for` → `para`
- `in` → `em`
- `def` → `funcao`
- `return` → `retornar`
- e outras...

### Operadores
- Aritméticos: `+`, `-`, `*`, `/`, `%`, `**`, `//`
- Lógicos: `and`, `or`, `not`
- Comparação: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Atribuição: `=`, `+=`, `-=`, `*=`, `/=`, `%=`

### Outros Elementos
- Identificadores (nomes de variáveis e funções)
- Números (inteiros e de ponto flutuante)
- Strings (entre aspas simples ou duplas)
- Delimitadores: `(`, `)`, `[`, `]`, `{`, `}`, `:`, `,`, `.`
- Indentação (INDENT e DEDENT)
- Comentários (iniciados com `#`)

## Como Usar

### Requisitos
- GCC (GNU Compiler Collection)
- Flex (Fast Lexical Analyzer Generator)

### Compilação
```bash
# Compilar o projeto
make

# Limpar arquivos gerados
make clean
```

### Execução
```bash
# Analisar um arquivo Python e traduzir para português
make compilar ARQUIVO=exemplo.py
```

O resultado será gerado no arquivo `tokens_portugues.txt`.

### Executando Manualmente
Também é possível executar cada etapa separadamente:

```bash
# Executar apenas o scanner
./scanner exemplo.py > tokens_python.txt

# Executar apenas o tradutor
./tradutor tokens_python.txt > tokens_portugues.txt
```
## Exemplo

Para o código Python:
```python
def calcular_media(valores):
    total = 0
    for valor in valores:
        total += valor
    return total / len(valores)
```

A saída será semelhante a:
```
PALAVRA_CHAVE: funcao
IDENTIFICADOR: calcular_media
DELIMITADOR: (
IDENTIFICADOR: valores
DELIMITADOR: )
DELIMITADOR: :
NOVA_LINHA
INDENT
IDENTIFICADOR: total
OPERADOR_ATRIBUICAO: recebe
NUMERO_INTEIRO: 0
NOVA_LINHA
PALAVRA_CHAVE: para
IDENTIFICADOR: valor
PALAVRA_CHAVE: em
IDENTIFICADOR: valores
DELIMITADOR: :
NOVA_LINHA
INDENT
IDENTIFICADOR: total
OPERADOR_ATRIBUICAO: incrementa
IDENTIFICADOR: valor
NOVA_LINHA
DEDENT
PALAVRA_CHAVE: retornar
IDENTIFICADOR: total
OPERADOR_ARITMETICO: dividido_por
IDENTIFICADOR: tamanho
DELIMITADOR: (
IDENTIFICADOR: valores
DELIMITADOR: )
NOVA_LINHA
DEDENT
```
