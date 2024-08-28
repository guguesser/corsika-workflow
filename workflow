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

def tracks2root():
    # Opens the file 'tracks2root.pl' in write mode ('w')
    with open('tracks2root.pl', 'w') as file:
        # Writes the Perl script to the file
        file.write('#!/usr/bin/perl -w\n\n')
        file.write("# Define the corresponding input and output files\n")
        file.write('@files = (\n')
        file.write("    {input => 'DAT000001.track_mu', output => 'rezultate_mu'},\n")
        file.write("    {input => 'DAT000001.track_em', output => 'rezultate_em'},\n")
        file.write("    {input => 'DAT000001.track_hd', output => 'rezultate_hd'}\n")
        file.write(');\n\n')
        file.write("# Process each file\n")
        file.write('foreach $file (@files) {\n')
        file.write('    my $datafile = $file->{input};\n')
        file.write('    my $results = $file->{output};\n\n')
        file.write('    # Open the input file\n')
        file.write('    open(DATAFILE, $datafile) or die "Unable to open $datafile: $!";\n')
        file.write('    binmode(DATAFILE);\n\n')
        file.write('    # Open the output file\n')
        file.write('    open(RESULTS, ">$results") or die "Unable to create $results: $!";\n\n')
        file.write('    sysseek(DATAFILE, 0, 0) or die "Unable to seek byte 0 in $datafile: $!";\n')
        file.write('    my $counter = 0;\n\n')
        file.write('    while (read(DATAFILE, my $buffer2, 48)) {\n')
        file.write('        my $buffer = substr($buffer2, 4, 40);\n')
        file.write('        my @properties = unpack("A4" x 10, $buffer);\n')
        file.write('        for (my $i = 0; $i < 10; $i++) {\n')
        file.write('            $properties[$i] = unpack("f", pack("A*", $properties[$i]));\n')
        file.write('        }\n')
        file.write('        print RESULTS join(" ", @properties);\n')
        file.write('        print RESULTS "\\n";\n')
        file.write('        $counter++;\n')
        file.write('    }\n\n')
        file.write('    close(RESULTS);\n')
        file.write('    close(DATAFILE);\n')
        file.write('}\n')

# MAIN
print("Hello, welcome to the simulation and animation workflow of atmospheric showers.")
flag = True
while flag:
  answer = input("\nPlease indicate if you already have CORSIKA installed on your machine (yes/no/quit): ")
  if answer == "yes":
    flag_2 = True
    while flag_2:
      answer_2 = input("\nTo work correctly, this file must be executed within the 'run' directory of CORSIKA. Are you at 'run' directory? (yes/no/quit): ")
      if answer_2 == "yes":
        print("\n### Let's start with running the simulation. ###")
        print("\nGenerating the DAT files...")
        command = "./corsika77550Linux_EPOS_urqmd < all-inputs-epos"
        execute_command(command)
        print("\nConverting DAT files to TXT format...")
        tracks2root()
        command = "perl tracks2root.pl"
        execute_command(command)
        command = "rm *.map"
        execute_command(command)
        print("\nOptimizing TXT files...")
        file_list = ['rezultate_em', 'rezultate_mu', 'rezultate_hd']
        process_files(file_list)
        command = "rm rezultate*"
        execute_command(command)
        command = "mkdir dados"
        execute_command(command)
        command = "head -n 1000 EDrezultate_em > EDrezultate_em_1k"
        execute_command(command)
        command = "mv EDrezultate* dados/"
        execute_command(command)
        print("\nCreating the atmospheric shower animation...")
        command = "blender -b -P blender_visu_script.py -E BLENDER_EEVEE -o img###.png -a"
        execute_command(command)
        command = "cat *.png | ffmpeg -f image2pipe -r 30 -i - output.mp4 -y"
        execute_command(command)
        command = "rm *.png"
        execute_command(command)
        print("\nAnimation completed and saved as 'output.mp4'")
        flag_2 = False
        flag = False
      elif answer_2 == "no":
        print("\nPlease execute this file within the 'run' directory to proceed.")
        flag_2 = False
        flag = False
      elif answer_2 == "quit":
        flag_2 = False
        flag = False
      else:
        print("\nInvalid command. Please enter 'yes', 'no' or 'quit'.")
  elif answer == "no":
    print("\nFirstly, send an email to tanguy.pierog@kit.edu expressing interest in using the software so that he can provide the password required for the program installation.")
    print("The installation of CORSIKA77500 and all its directories is available at the following link: https://web.iap.kit.edu/corsika/download/")
    print("Enter the username 'corsika' and the password provided through the email received from the software's technical team.\n")
    flag = False
  elif answer == "quit":
    flag = False
  else:
    print("\nInvalid command. Please enter 'yes', 'no' or 'quit'.")
