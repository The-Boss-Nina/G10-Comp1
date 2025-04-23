# Parser Leticia - Comp1

Parser feito com Flex e Bison para expressões matemáticas.

## Como compilar

```bash
bison -d parser.y
flex scanner.l
gcc -o parser parser.tab.c lex.yy.c -lfl
```

## Como rodar

```bash
./parser
```

Digite a expressão e finalize com:
- Ctrl+D (Linux/macOS)
- Ctrl+Z + Enter (Windows)
