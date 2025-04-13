# Este é um programa Python de exemplo
def calcular_media(valores):
    total = 0
    for valor in valores:
        total += valor
    
    if len(valores) > 0:
        return total / len(valores)
    else:
        return None

# Teste da função
numeros = [10, 20, 30, 40, 50]
media = calcular_media(numeros)
print("A média é:", media)

# Verificação condicional
if media > 30:
    print("Média acima de 30")
else:
    print("Média abaixo ou igual a 30")