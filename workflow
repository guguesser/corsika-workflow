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
