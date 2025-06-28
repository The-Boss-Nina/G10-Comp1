# Interpretador Python para Linguagem Abstrata em Português

Este projeto implementa um compilador que traduz código Python para uma linguagem em português, incluindo análise léxica, sintática e geração de AST (Árvore Sintática Abstrata). Foi desenvolvido como parte da disciplina de Compiladores 1 (FGA0003).

## Estrutura do Projeto

O projeto é composto pelos seguintes componentes:

1. **scanner.l**: Analisador léxico escrito em Flex que identifica tokens de código Python.
2. **parser.y**: Analisador sintático em Bison que constrói a AST
4. **ast.h/ast.c**: Implementação da Árvore Sintática Abstrata
3. **mapeamento.h**: Tradução de tokens e funções built-in para português
5. **Makefile**: Script para facilitar a compilação e execução do projeto.

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


### Funções Built-in
- print() → escrever()
- len() → tamanho()
- input() → ler()
- e outras...


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
- Bison (versão 3.0 ou superior)

### Compilação
```bash

# Limpar arquivos gerados
make clean

# Compilar o projeto
make
```

### Execução
```bash
# Analisar um arquivo Python e traduzir para português
make executar ARQUIVO=python_samples/NOME_ARQUIVO.py

ou

./interpretador python_samples/NOME_ARQUIVO.py
```

O resultado será gerado no Terminal/Console.

## Exemplo

Para o código Python:
```python
x = 10
y = 20
z = x + y
print(z)
```

A saída será semelhante a:
```
=== Executando python_samples/teste_basico.py ===
Iniciando análise sintática...
AST construída com sucesso!
Análise sintática concluída com sucesso!

=== AST em Português ===
LISTA_COMANDOS
  ATRIBUICAO: recebe
    IDENTIFICADOR: x
    INTEIRO: 10
  ATRIBUICAO: recebe
    IDENTIFICADOR: y
    INTEIRO: 20
  ATRIBUICAO: recebe
    IDENTIFICADOR: z
    OP_BINARIO: mais
      IDENTIFICADOR: x
      IDENTIFICADOR: y
  CHAMADA_FUNCAO: escrever
    LISTA_EXPR
      IDENTIFICADOR: z

=== Interpretação ===
EXECUTANDO: x recebe 10
EXECUTANDO: y recebe 20
EXECUTANDO: z recebe 30
EXECUTANDO: chamada de função escrever
SAÍDA: 30 
```
