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
	$(CC) $(CFLAGS) -o $(TARGET) $(LEXER_C) $(PARSER_C) $(AST_SRC) -lfl

# Regra para testar com o arquivo de exemplo
teste: $(TARGET)
	@echo "=== Testando o Interpretador ==="
	@echo "Analisando arquivo: python_samples/ex_completo.py"
	@echo ""
	./$(TARGET) python_samples/ex_completo.py
	@echo ""
	@echo "=== Teste Concluído ==="

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
		$(BISON) -d parser.y; \
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

# Parser minimal para debug
parser-minimal: 
	@echo "=== Parser Minimal ==="
	cp parser.y parser_backup.y
	cp parser_minimal.y parser.y
	$(BISON) -d parser.y
	$(FLEX) $(LEXER)
	$(CC) $(CFLAGS) -o $(TARGET) $(LEXER_C) $(PARSER_C) $(AST_SRC) -lfl
	@echo "=== Teste if_minimal.py ==="
	./$(TARGET) python_samples/if_minimal.py
	@echo "=== Restaurando Parser ==="
	cp parser_backup.y parser.y

# Debug de tokens
debug-tokens:
	@echo "=== Debug de Tokens ==="
	cp scanner.l scanner_backup.l
	cp scanner_debug.l scanner.l
	$(BISON) -d parser.y
	$(FLEX) scanner.l
	$(CC) $(CFLAGS) -o $(TARGET) lex.yy.c parser.tab.c ast.c -lfl
	@echo "=== Tokens de python_samples/if_minimal.py ==="
	./$(TARGET) python_samples/if_minimal.py
	@echo "=== Restaurando Scanner ==="
	cp scanner_backup.l scanner.l

# Teste básico
teste-basico: $(TARGET)
	@echo "=== Teste Básico ==="
	@echo "x = 10" > python_samples/teste_basico.py
	@echo "y = 20" >> python_samples/teste_basico.py  
	@echo "z = x + y" >> python_samples/teste_basico.py
	@echo "print(z)" >> python_samples/teste_basico.py
	@echo "Testando arquivo básico..."
	./$(TARGET) python_samples/teste_basico.py
	@echo "=== Teste Básico Concluído ==="

# Regra para executar de forma interativa (entrada padrão)
interativo: $(TARGET)
	@echo "=== Modo Interativo ==="; \
	echo "Digite o código Python (Ctrl+D para finalizar):"; \
	./$(TARGET)

# Criar arquivo de exemplo simples para teste
exemplo:
	@echo "Criando arquivo de exemplo..."
	@mkdir -p python_samples
	@echo "x = 10" > python_samples/ex_completo.py
	@echo "y = 20" >> python_samples/ex_completo.py
	@echo "z = x + y" >> python_samples/ex_completo.py
	@echo "print(z)" >> python_samples/ex_completo.py
	@echo "" >> python_samples/ex_completo.py
	@echo "if x > 5:" >> python_samples/ex_completo.py
	@echo "    print(\"x é maior que 5\")" >> python_samples/ex_completo.py
	@echo "" >> python_samples/ex_completo.py
	@echo "def somar(a, b):" >> python_samples/ex_completo.py
	@echo "    return a + b" >> python_samples/ex_completo.py
	@echo "Arquivo criado: python_samples/ex_completo.py"

# Regra para testar com o exemplo criado
teste-exemplo: exemplo $(TARGET)
	@echo "=== Testando com exemplo criado ==="
	./$(TARGET) python_samples/ex_completo.py

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
	@echo "  make teste        : Testar com exemplo padrão"
	@echo "  make exemplo      : Criar arquivo de exemplo"
	@echo "  make teste-exemplo: Testar com exemplo criado"
	@echo "  make executar ARQUIVO=nome.py : Executar arquivo específico"
	@echo "  make debug-file ARQUIVO=nome.py : Debug detalhado"
	@echo "  make parser-minimal : Testar parser simplificado"
	@echo "  make debug-tokens : Ver tokens gerados"
	@echo "  make teste-basico : Teste muito simples"
	@echo "  make interativo   : Modo interativo"
	@echo "  make check-tools  : Verificar ferramentas"
	@echo "  make clean        : Limpar arquivos gerados"

# Limpeza de arquivos gerados
clean:
	rm -f $(TARGET) $(LEXER_C) $(PARSER_C) $(PARSER_H)
	rm -f *.o *.output parser_backup.y scanner_backup.l
	@echo "Arquivos gerados removidos"

# Limpeza completa (inclui arquivos de exemplo)
clean-all: clean
	rm -rf python_samples/teste_basico.py python_samples/ex_completo.py
	@echo "Limpeza completa realizada"

# Instalar dependências (Ubuntu/Debian)
install-deps:
	@echo "Instalando dependências para Ubuntu/Debian..."
	sudo apt-get update
	sudo apt-get install gcc flex bison

# Regras que não geram arquivos
.PHONY: all teste executar interativo exemplo teste-exemplo check-tools info clean clean-all install-deps debug-file parser-minimal debug-tokens teste-basico

# Evitar remoção de arquivos intermediários
.PRECIOUS: $(PARSER_C) $(PARSER_H) $(LEXER_C)