import sys

# Function to read input file
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

# Main function that performs actions based on the input card
def main():
    input_card = "input_card.txt"  # Configuration file name

    # Reads settings from file
    config = read_input_card(input_card)

    # Run the simulation if the user wishes
    if config.get('execute_simulation') == 'yes':
        print("Executando a simulação...")
        # Call your simulation function here
    else:
        print("Simulação ignorada.")

    # Show the graph if the user wants
    if config.get('show_graph') == 'yes':
        print("Mostrando o gráfico...")
        # Call your plot function here
    else:
        print("Gráfico não exibido.")

    # Checks whether the program should terminate
    if config.get('exit_program') == 'yes':
        print("Encerrando o programa...")
        sys.exit(0)

    print("Continuando a execução do programa...")

if __name__ == "__main__":
    main()
