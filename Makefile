CC = gcc
CFLAGS = -Wall -g -std=c99 -D_GNU_SOURCE
FLEX = flex
BISON = bison

# Arquivos fonte
LEXER = scanner.l
PARSER = parser.y
AST_SRC = ast.c
HEADERS = ast.h mapping.h

# Arquivos gerados
LEXER_C = lex.yy.c
PARSER_C = parser.tab.c
PARSER_H = parser.tab.h

# Executável final
TARGET = interpretador

# Regra principal
all: $(TARGET)

# Gerar o analisador sintático com Bison
$(PARSER_C) $(PARSER_H): $(PARSER)
	$(BISON) -d $(PARSER)

# Gerar o analisador léxico com Flex
$(LEXER_C): $(LEXER) $(PARSER_H)
	$(FLEX) $(LEXER)

# Compilar o interpretador
$(TARGET): $(LEXER_C) $(PARSER_C) $(AST_SRC) $(HEADERS)
	$(CC) $(CFLAGS) -o $(TARGET) $(LEXER_C) $(PARSER_C) $(AST_SRC) -lfl -lm

# Regra para executar um arquivo específico
executar: $(TARGET)
	@if [ -z "$(ARQUIVO)" ]; then \
		echo "Uso: make executar ARQUIVO=nome_do_arquivo.py"; \
	else \
		echo "=== Executando $(ARQUIVO) ==="; \
		./$(TARGET) $(ARQUIVO); \
	fi

# Debug específico de arquivo
debug-file: $(TARGET)
	@if [ -z "$(ARQUIVO)" ]; then \
		echo "Uso: make debug-file ARQUIVO=nome_do_arquivo.py"; \
	else \
		echo "=== Debug de $(ARQUIVO) ==="; \
		cp scanner.l scanner_backup.l; \
		cp scanner_debug.l scanner.l; \
		$(BISON) -t -d parser.y \
		$(FLEX) scanner.l; \
		$(CC) $(CFLAGS) -o $(TARGET) lex.yy.c parser.tab.c ast.c -lfl; \
		echo "=== TOKENS GERADOS ==="; \
		./$(TARGET) $(ARQUIVO); \
		echo "=== Restaurando Scanner ==="; \
		cp scanner_backup.l scanner.l; \
		$(BISON) -d parser.y; \
		$(FLEX) scanner.l; \
		$(CC) $(CFLAGS) -o $(TARGET) lex.yy.c parser.tab.c ast.c -lfl; \
	fi

# Regra para executar de forma interativa (entrada padrão)
interativo: $(TARGET)
	@echo "=== Modo Interativo ==="; \
	echo "Digite o código Python (Ctrl+D para finalizar):"; \
	./$(TARGET)

# Verificar se as ferramentas estão instaladas
check-tools:
	@echo "Verificando ferramentas necessárias..."
	@which $(CC) > /dev/null || (echo "ERRO: $(CC) não encontrado" && exit 1)
	@which $(FLEX) > /dev/null || (echo "ERRO: $(FLEX) não encontrado" && exit 1)
	@which $(BISON) > /dev/null || (echo "ERRO: $(BISON) não encontrado" && exit 1)
	@echo "Todas as ferramentas estão disponíveis!"

# Informações sobre o projeto
info:
	@echo "=== Interpretador Python para Português ==="
	@echo "Comandos disponíveis:"
	@echo "  make              : Compilar o projeto"
	@echo "  make executar ARQUIVO=nome.py : Executar arquivo específico"
	@echo "  make clean        : Limpar arquivos gerados"

# Limpeza de arquivos gerados
clean:
	rm -f $(TARGET) $(LEXER_C) $(PARSER_C) $(PARSER_H)
	rm -f *.o *.output parser_backup.y scanner_backup.l
	@echo "Arquivos gerados removidos"

# Instalar dependências (Ubuntu/Debian)
install-deps:
	@echo "Instalando dependências para Ubuntu/Debian..."
	sudo apt-get update
	sudo apt-get install gcc flex bison

# Regras que não geram arquivos
.PHONY: all teste executar interativo exemplo teste-exemplo check-tools info clean clean-all install-deps debug-file parser-minimal debug-tokens teste-basico

# Evitar remoção de arquivos intermediários
.PRECIOUS: $(PARSER_C) $(PARSER_H) $(LEXER_C)