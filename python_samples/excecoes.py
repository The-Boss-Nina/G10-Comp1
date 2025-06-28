try:
    x = 10 / 0
except ZeroDivisionError:
    print("Erro: divisão por zero!")

try:
    print("Executando código seguro.")
except:
    print("Isso não deve ser exibido.")
