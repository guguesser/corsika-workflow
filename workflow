import subprocess

def generate_DAT_files(command_DAT_files):
    """Execute the command and return the DAT files."""
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error executing the command: {e}"

command_DAT_files = "./corsika77550Linux_EPOS_urqmd < all-inputs-epos"
generate_DAT_files(command_DAT_files)
