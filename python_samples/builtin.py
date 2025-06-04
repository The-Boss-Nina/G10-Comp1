# Teste de funções built-in

# print - já testamos muito
print("Teste de print")

# len - tamanho
lista = [1, 2, 3, 4, 5]
tamanho = len(lista)
print(tamanho)

nome = "Python"
tamanho_nome = len(nome)
print(tamanho_nome)

# Conversões de tipo
numero_str = "42"
numero_int = int(numero_str)
print(numero_int)

valor_int = 10
valor_str = str(valor_int)
print(valor_str)

valor_float = float(numero_str)
print(valor_float)

# range para loops
for i in range(5):
    print(i)

for i in range(2, 8):
    print(i)