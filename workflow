import subprocess

def execute_command(command):
    """Execute the command on the terminal command line."""
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
        command = "./corsika77550Linux_EPOS_urqmd < all-inputs-epos"
        execute_command(command)
        print("\nConverting DAT files to TXT format...")
        command = "perl tracks2root.pl"
        execute_command(command)
        command = "rm *.map"
        execute_command(command)
        print("\nOptimizing TXT files...")
        file_list = ['rezultate_em', 'rezultate_mu', 'rezultate_hd']
        process_files(file_list)
        command = "rm rezultate*"
        execute_command(command)
        command = "mkdir result"
        execute_command(command)
        command = "mv EDrezultate* result/"
        execute_command(command)
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
