CC = gcc
CFLAGS = -Wall

all: scanner tradutor

scanner: scanner.l
	flex scanner.l
	$(CC) $(CFLAGS) -o scanner lex.yy.c

tradutor: parser.c mapping.h
	$(CC) $(CFLAGS) -o tradutor tradutor.c

# Regra para executar o compilador completo
compilar: scanner tradutor
	@echo "Compilando arquivo Python para Português Abstrato..."
	./scanner $(ARQUIVO) > tokens_python.txt
	./tradutor tokens_python.txt > tokens_portugues.txt
	@echo "Compilação concluída. Resultado em tokens_portugues.txt"

clean:
	rm -f scanner tradutor lex.yy.c tokens_python.txt tokens_portugues.txt

