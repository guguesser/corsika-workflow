import subprocess

def generate_DAT_files(command_DAT_files):
    """Execute the command and return the DAT files."""
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error executing the command: {e}"

def traks2root(command_traks2root):
    """Execute the command and return the files in text format."""
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error executing the command: {e}"

def process_files(file_list):
    """Optimize the files so that they are accepted in the animation."""
    for file_name in file_list:
        with open(file_name, 'r') as file, open(f'ED{file_name}', 'w') as output_file:
            for line in file:
                line = line.strip()
                words = line.split(' ')

                if '' not in words and words[2] != words[6]:
                    output_file.write(' '.join(words) + '\n')

command_DAT_files = "./corsika77500Linux_EPOS_urqmd < all-inputs-epos"
execute_command_DAT_files(command_DAT_files)

#command_traks2root = "perl tracks2root.pl"
#execute_command_traks2root(command_traks2root)

file_list = ['rezultate_em', 'rezultate_mu', 'rezultate_hd']
process_files(file_list)
