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

command_DAT_files = "./corsika77500Linux_EPOS_urqmd < all-inputs-epos"
execute_command_DAT_files(command_DAT_files)

#command_traks2root = "perl tracks2root.pl"
#execute_command_traks2root(command_traks2root)
