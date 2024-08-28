import subprocess

def generate_DAT_files(command_DAT_files):
    """Execute the command and return the DAT files."""
    try:
        result = subprocess.run(command_DAT_files, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error executing the command: {e}"

def tracks2root(command_tracks2root):
    """Execute the command and return the files in text format."""
    try:
        result = subprocess.run(command_tracks2root, shell=True, check=True, text=True, capture_output=True)
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

def delete_files(command_delete_files):
    """Deletes files that are no longer needed to generate the simulation."""
    try:
        result = subprocess.run(command_delete_files, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error executing the command: {e}"

def create_folder(command_create_folder):
    """Create a folder to organize the workflow."""
    try:
        result = subprocess.run(command_create_folder, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error executing the command: {e}"

def move_files(command_move_files):
    """Move files to folders."""
    try:
        result = subprocess.run(command_move_files, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error executing the command: {e}"

# MAIN
print("Hello, welcome to the simulation and animation workflow of atmospheric showers.")
flag = True
while flag:
  answer = input("\nPlease indicate if you already have CORSIKA installed on your machine (yes/no/quit): ")
  if answer == "yes":
    flag_2 = True
    while flag_2:
      answer_2 = input("\nTo work correctly, this file must be executed within the 'run' folder of CORSIKA. Are you at 'run' folder? (yes/no/quit): ")
      if answer_2 == "yes":
        print("\nLet's start with running the simulation.")
        print("\nGenerating the DAT files...")
        command_DAT_files = "./corsika77550Linux_EPOS_urqmd < all-inputs-epos"
        generate_DAT_files(command_DAT_files)
        print("\nConverting DAT files to TXT format...")
        command_tracks2root = "perl tracks2root.pl"
        tracks2root(command_tracks2root)
        command_delete_files = "rm *.map"
        delete_files(command_delete_files)
        print("\nOptimizing TXT files...")
        file_list = ['rezultate_em', 'rezultate_mu', 'rezultate_hd']
        process_files(file_list)
        command_delete_files = "rm rezultate*"
        delete_files(command_delete_files)
        command_create_folder = "mkdir result"
        create_folder(command_create_folder)
        command_move_files = "mv EDrezultate* result/"
        move_files(command_move_files)
        flag_2 = False
        flag = False
      elif answer_2 == "no":
        print("\nPlease execute this file within the 'run' folder to proceed.")
        flag_2 = False
        flag = False
      elif answer_2 == "quit":
        flag_2 = False
        flag = False
      else:
        print("\nInvalid command. Please enter 'yes', 'no' or 'quit'.")
  elif answer == "no":
    print("\nFirstly, send an email to tanguy.pierog@kit.edu expressing interest in using the software so that he can provide the password required for the program installation.")
    print("The installation of CORSIKA77500 and all its folders is available at the following link: https://web.iap.kit.edu/corsika/download/")
    print("Enter the username 'corsika' and the password provided through the email received from the software's technical team.\n")
    flag = False
  elif answer == "quit":
    flag = False
  else:
    print("\nInvalid command. Please enter 'yes', 'no' or 'quit'.")
