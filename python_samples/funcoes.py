# Teste de funções

# Função simples sem parâmetros
def saudacao():
    print("Olá mundo!")

# Função com parâmetros
def somar(a, b):
    return a + b

# Função com múltiplos parâmetros
def calcular_area(largura, altura, profundidade):
    volume = largura * altura * profundidade
    return volume

# Função que chama outra função
def dobrar_soma(x, y):
    resultado = somar(x, y)
    return resultado * 2

# Chamadas de função
saudacao()
resultado1 = somar(5, 3)
print(resultado1)

volume = calcular_area(2, 3, 4)
print(volume)

dobrado = dobrar_soma(10, 20)
print(dobrado)