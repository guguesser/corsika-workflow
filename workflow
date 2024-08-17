import subprocess

def execute_command(command):
    """Execute the command and capture the output."""
    try:
        result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error executing the command: {e}"

command = input("Enter a command: ")
execute_command(command)
