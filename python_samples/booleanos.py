# Teste de valores booleanos e None

# Valores booleanos
verdadeiro = True
falso = False
nulo = None

print(verdadeiro)
print(falso)
print(nulo)

# Comparações que geram booleanos
idade = 25
eh_adulto = idade >= 18
eh_crianca = idade < 13

print(eh_adulto)
print(eh_crianca)

# Operações com None
valor = None
if valor == None:
    print("Valor é None")

# Conversões booleanas implícitas
if 1:
    print("1 é verdadeiro")

if 0:
    print("0 é verdadeiro")
else:
    print("0 é falso")