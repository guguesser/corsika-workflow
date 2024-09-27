import sys

# Função para ler o arquivo de entrada
def read_input_card(filename):
    config = {}
    try:
        with open(filename, 'r') as file:
            for line in file:
                key, value = line.strip().split('=')
                config[key] = value.lower()
    except FileNotFoundError:
        print(f"Erro: arquivo {filename} não encontrado.")
        sys.exit(1)
    return config

# Função principal que executa as ações baseadas no card de entrada
def main():
    input_card = "input_card.txt"  # Nome do arquivo de configuração

    # Lê as configurações do arquivo
    config = read_input_card(input_card)

    # Executa a simulação se o usuário desejar
    if config.get('execute_simulation') == 'yes':
        print("Executando a simulação...")
        # Chame sua função de simulação aqui
    else:
        print("Simulação ignorada.")

    # Mostra o gráfico se o usuário desejar
    if config.get('show_graph') == 'yes':
        print("Mostrando o gráfico...")
        # Chame sua função de plotagem aqui
    else:
        print("Gráfico não exibido.")

    # Verifica se o programa deve encerrar
    if config.get('exit_program') == 'yes':
        print("Encerrando o programa...")
        sys.exit(0)

    print("Continuando a execução do programa...")

if __name__ == "__main__":
    main()
