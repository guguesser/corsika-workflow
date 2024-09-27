import subprocess
import os
import sys

def read_input_card(filename):
    '''Function to read input file'''
    config = {}
    try:
        with open(filename, 'r') as file:
            for line in file:
                key, value = line.strip().split('=')
                config[key] = value.lower()
    except FileNotFoundError:
        print(f"Error: File {filename} not found.")
        sys.exit(1)
    return config

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

def blender_script():
    # Opens the file 'blender_script.py' in write mode ('w')
    with open('blender_script.py', 'w') as file:
        # Writes the Python script to the file
        file.write("import bpy\n")
        file.write("import time\n")
        file.write("from math import cos, pi\n")
        file.write("import os\n\n")
        file.write("# ARGUMENTS\n")
        file.write("files_name = ['EDrezultate_em','EDrezultate_mu','EDrezultate_hd']\n")
        file.write("limit = -1 # Number of lines to be read from each file. -1 to read all.\n\n")
        file.write("def make_curve(points, loop2):\n")
        file.write("	# Function that creates a curve in Blender\n")
        file.write("	# Create the Curve Datablock\n")
        file.write("	curveData = bpy.data.curves.new(f'myCurve{loop2}', type='CURVE')\n")
        file.write("	curveData.dimensions = '3D'\n")
        file.write("	curveData.resolution_u = 4\n\n")
        file.write("	# Map coords to spline\n")
        file.write("	polyline = curveData.splines.new('POLY')\n")
        file.write("	polyline.points.add(len(points) - 1)\n")
        file.write("	for i, coord in enumerate(points):\n")
        file.write("		x, y, z = coord\n")
        file.write("		polyline.points[i].co = (x, y, z, 1)\n\n")
        file.write("	# Create object\n")
        file.write("	curveOB = bpy.data.objects.new(f'myCurve{loop2}', curveData)\n")
        file.write("	curveData.bevel_resolution = 6\n")
        file.write("	curveData.bevel_depth = 0.001667\n\n")
        file.write("	# Attach to scene and validate context\n")
        file.write("	scn = bpy.context.scene\n")
        file.write("	scn.collection.objects.link(curveOB)\n\n")
        file.write("	bpy.ops.object.shade_smooth()\n\n")
        file.write("def remove_materials_objects():\n")
        file.write("	# Function that removes all materials, objects and curves\n")
        file.write("	for material in bpy.data.materials: # Remove existing materials\n")
        file.write("		bpy.data.materials.remove(material)\n\n")
        file.write("	for object in bpy.data.objects: # Remove all objects\n")
        file.write("		bpy.data.objects.remove(object)\n\n")
        file.write("	for curve in bpy.data.curves: # Remove all curves\n")
        file.write("		bpy.data.curves.remove(curve)\n\n")
        file.write("def create_material(loop):\n")
        file.write("	# Function that creates a new material\n")
        file.write("	# Argument 'loop' represents the file being used\n")
        file.write("	bpy.data.materials.new(name='base' + f'{loop}') # Create material\n")
        file.write("	mat = bpy.data.materials[f'base{loop}'] # Select created material\n\n")
        file.write("	mat.use_nodes = True\n")
        file.write("	Princi = mat.node_tree.nodes['Principled BSDF'] # Node Principled BSDF\n\n")
        file.write("	if loop == 0: # First file red color\n")
        file.write("		Princi.inputs['Base Color'].default_value = (1.0, 0.0, 0.0, 1.0) # (R, G, B, Alpha)\n")
        file.write("	elif loop == 1: # Second file green color\n")
        file.write("		Princi.inputs['Base Color'].default_value = (0.0, 1.0, 0.0, 1.0) # (R, G, B, Alpha)\n")
        file.write("	elif loop == 2: # Third file blue color\n")
        file.write("		Princi.inputs['Base Color'].default_value = (0.0, 0.0, 1.0, 1.0) # (R, G, B, Alpha)\n")
        file.write("	else: # Additional files have colors determined by 'cos()'\n")
        file.write("		Princi.inputs['Base Color'].default_value = (cos(loop * pi), 1 / cos(loop * pi), cos(loop * 2 * pi), 1.0) # (R, G, B, Alpha)\n\n")
        file.write("	Princi.inputs['Roughness'].default_value = 0.5\n")
        file.write("	Princi.inputs['Specular'].default_value = 0.1\n\n")
        file.write("def insert_material(loop, loop2):\n")
        file.write("	# Function that assigns the material 'loop' to the curve 'loop2'\n")
        file.write("	mat = bpy.data.materials['base' + f'{loop}']\n")
        file.write("	curve = bpy.data.objects[f'myCurve{loop2}']\n\n")
        file.write("	curve.data.materials.append(mat)\n\n")
        file.write("def animate(t_s, t_e, loop2):\n")
        file.write("	# Function responsible for animating the curve, using only the start and end times of the curve\n")
        file.write("	if t_s > t_e: # In case it's swapped\n")
        file.write("		d = t_e\n")
        file.write("		t_e = t_s\n")
        file.write("		t_s = d\n")
        file.write("	scene = bpy.context.scene\n")
        file.write("	curve = bpy.data.curves[f'myCurve{loop2}']\n\n")
        file.write("	scene.frame_set(t_e)\n\n")
        file.write("	curve.keyframe_insert(data_path='bevel_factor_end')\n\n")
        file.write("	scene.frame_set(t_s)\n")
        file.write("	curve.bevel_factor_end = 0\n")
        file.write("	curve.keyframe_insert(data_path='bevel_factor_end')\n")
        file.write("	curve.animation_data.action.fcurves[0].keyframe_points[0].interpolation = 'LINEAR'\n")
        file.write("	curve.bevel_factor_mapping_end = 'SPLINE'\n\n")
        file.write("def process_curve_data(data):\n")
        file.write("	# Function that returns the data separated into different curves\n")
        file.write("	x = []\n")
        file.write("	y = []\n\n")
        file.write("	x_end = []\n")
        file.write("	y_end = []\n\n")
        file.write("	data_new = []\n")
        file.write("	for line in data:\n")
        file.write("		ligne = line.replace('\n', '')\n")
        file.write("		l = ligne.split(' ')\n")
        file.write("		print(l)\n")
        file.write("		data_new.append(l)\n\n")
        file.write("		x.append(float(l[2]) / 1000000)\n")
        file.write("		x_end.append(float(l[6]) / 1000000)\n\n")
        file.write("		y.append(float(l[3]) / 1000000)\n")
        file.write("		y_end.append(float(l[7]) / 1000000)\n\n")
        file.write("	x_if = init_final(x, x_end)\n")
        file.write("	y_if = init_final(y, y_end)\n\n")
        file.write("	same_x = same_line(x_if)\n")
        file.write("	same_y = same_line(y_if)\n\n")
        file.write("	same = (same_x, same_y)\n")
        file.write("	all_curves_x = []\n")
        file.write("	all_curves_y = []\n")
        file.write("	for loop, dat in enumerate(same):\n")
        file.write("		for line in dat:\n")
        file.write("			indexes = []\n")
        file.write("			for j in range(0, len(line)):\n")
        file.write("				if loop == 0:\n")
        file.write("					indexes.append(x.index(line[j][0]))\n")
        file.write("				else:\n")
        file.write("					indexes.append(y.index(line[j][0]))\n\n")
        file.write("			data_save = []\n")
        file.write("			for g in range(0, len(line)):\n")
        file.write("				data_save.append(data_new[indexes[g]])\n\n")
        file.write("			if loop == 0:\n")
        file.write("				all_curves_x.append(data_save)\n")
        file.write("			else:\n")
        file.write("				all_curves_y.append(data_save)\n\n")
        file.write("	if all_curves_x < all_curves_y:\n")
        file.write("		biggest_curve = all_curves_y.copy()\n")
        file.write("		smallest_curve = all_curves_x.copy()\n")
        file.write("	else:\n")
        file.write("		biggest_curve = all_curves_x.copy()\n")
        file.write("		smallest_curve = all_curves_y.copy()\n\n")
        file.write("	all_curves = []\n")
        file.write("	for dat in biggest_curve:\n")
        file.write("		if dat in smallest_curve:\n")
        file.write("			all_curves.append(dat)\n\n")
        file.write("	return all_curves\n\n")
        file.write("def same_line(initial_final):\n")
        file.write("	# Function that finds equal points in the data to classify\n")
        file.write("	# them as belonging to the same curve. It also detecs line\n")
        file.write("	# bifurcation, making the two lines separate curves to\n")
        file.write("	# avoid erros\n\n")
        file.write("	# 'initial_final = [x, y, z, xend, yend, zend]'\n")
        file.write("	lines = []\n")
        file.write("	initials = [f[0] for f in initial_final]\n")
        file.write("	finals = [f[1] for f in initial_final]\n\n")
        file.write("	k = 0\n")
        file.write("	for i, f in initial_final:\n")
        file.write("		print(i)\n")
        file.write("		if i in initials and i not in finals: # New line\n")
        file.write("			lines.append([[i, f]])\n")
        file.write("			continue\n\n")
        file.write("		count_bif = 0\n")
        file.write("		for curve in lines: # Detects bifurcation\n")
        file.write("			for x_i, x_f in curve:\n")
        file.write("				if i == x_i or i == x_f:\n")
        file.write("					count_bif += 1\n\n")
        file.write("				if count_bif > 1:\n")
        file.write("					lines.append([[i, f]])\n")
        file.write("					break\n")
        file.write("			if count_bif > 1:\n")
        file.write("				break\n")
        file.write("		if count_bif > 1:\n")
        file.write("			continue\n")
        file.write("		loop = 0\n")
        file.write("		for curve in lines: # Add curve to an existing line\n")
        file.write("			for x_i, x_f in curve:\n")
        file.write("				if i == x_f:\n")
        file.write("					lines[loop].append([i, f])\n\n")
        file.write("			loop += 1\n\n")
        file.write("	return lines\n\n")
        file.write("def init_final(l_i, l_f):\n")
        file.write("	# Function that organizes the data into '[start, end]'\n")
        file.write("	tu = []\n")
        file.write("	for i in range(0, len(l_i)):\n")
        file.write("		tu.append([l_i[i], l_f[i]])\n\n")
        file.write("	return tu\n\n")
        file.write("# MAIN CODE\n\n")
        file.write("start_time = time.time()\n\n")
        file.write("remove_materials_objects()\n\n")
        file.write("loop2 = 0\n")
        file.write("last_frame = 0 # To find the last frame\n")
        file.write("for loop, file_name in enumerate(files_name):\n")
        file.write("	file = open(os.path.join('data', file_name), 'r')\n")
        file.write("	tabraw = file.readlines(limit)\n")
        file.write("	file.close()\n\n")
        file.write("	data_curves = process_curve_data(tabraw)\n\n")
        file.write("	create_material(loop)\n\n")
        file.write("	# MAIN LOOP\n")
        file.write("	for curve in data_curves:\n")
        file.write("		loop2 += 1\n")
        file.write("		dots = []\n")
        file.write("		for count, l in enumerate(curve):\n")
        file.write("			print(f'{count / len(curve) * 100}% ine: {l}') # How much has been done\n")
        file.write("			x = float(l[2]) / 1000000\n")
        file.write("			y = float(l[3]) / 1000000\n")
        file.write("			z = float(l[4]) / 1000000\n")
        file.write("			t_init = float(l[5]) * 1000000\n")
        file.write("			x_end = float(l[6]) / 1000000\n")
        file.write("			y_end = float(l[7]) / 1000000\n")
        file.write("			z_end = float(l[8]) / 1000000\n")
        file.write("			t_final = float(l[9]) / 1000000\n\n")
        file.write("			dots.append((x, y, z))\n\n")
        file.write("			if count == 0:\n")
        file.write("				initial_time = int(t_init)\n")
        file.write("			final_time = int(t_final)\n\n")
        file.write("			if initial_time == final_time:\n")
        file.write("				final_time = initial_time + 1\n\n")
        file.write("		make_curve(dots, loop2)\n\n")
        file.write("		# Material handling\n")
        file.write("		insert_material(loop, loop2)\n\n")
        file.write("		animate(initial_time, final_time, loop2)\n\n")
        file.write("		if final_time > last_frame: # Finding the last frame\n")
        file.write("			last_frame = final_time\n\n")
        file.write("bpy.context.scene.frame_current = 0 # Return to the initial frame\n\n")
        file.write("# Light\n")
        file.write("bpy.ops.object.light_add(type='SUN', align='WORLD', location=(0, -5.04, 4.6), rotation=(1.05418, 0, 0))\n\n")
        file.write("# Camera\n")
        file.write("bpy.ops.object.camera_add(enter_editmode=False, align='VIEW', location=(-1.7681, -5.40785, 1.12727), rotation=(87.3975/57.3, 0, -12.974/57.3))\n\n")
        file.write("bpy.context.scene.render.resolution_x = 1080\n")
        file.write("bpy.context.scene.render.resolution_y = 1920\n\n")
        file.write("bpy.data.objects['Camera'].select_set(True)\n\n")
        file.write("bpy.data.scenes[0].camera = bpy.data.objects['Camera']\n\n")
        file.write("# Render\n")
        file.write("bpy.data.worlds['World'].node_tree.nodes['Background'].inputs[0].default_value = (0, 0, 0, 1) #Dark background\n\n")
        file.write("bpy.context.scene.frame_end = last_frame + 10\n")
        file.write("bpy.context.scene.eevee.use_bloom = True\n")
        file.write("bpy.context.scene.eevee.use_gtao = True\n")
        file.write("bpy.context.scene.eevee.use_ssr = True\n")
        file.write("bpy.context.scene.eevee.use_motion_blur = True\n\n")
        file.write("# Save\n")
        file.write("bpy.ops.wm.save_mainfile(filepath=os.getcwd()+'output.blend') # Save as output.blend\n")
        file.write("print(f'Final frame: {last_frame}')\n")
        file.write("print('It took {} minutes'.format((time.time() - start_time)/60))\n")


# MAIN
print("Hello, welcome to the simulation and animation workflow of atmospheric showers.")
continue_workflow = True
while continue_workflow:
  installation_response = input("\nPlease indicate if you already have CORSIKA installed on your machine (yes/no/quit): ")
  if installation_response == "yes":
    ready_for_simulation = True
    while ready_for_simulation:
      directory_response = input("\nTo work correctly, this file must be executed within the 'run' directory of CORSIKA. Are you at 'run' directory? (yes/no/quit): ")
      if directory_response == "yes":
        print("\n\n----- Let's start with running the simulation. -----")
        print("\nGenerating the DAT files...")
        command = "./corsika77550Linux_EPOS_urqmd < all-inputs-epos"
        execute_command(command)
        print("\nConverting DAT files to TXT format...")
        file_path = "tracks2root.pl"
        if os.path.exists(file_path):
            continue
        else:
            tracks2root()
        command = "perl tracks2root.pl"
        execute_command(command)
        print("\nOptimizing TXT files...")
        file_list = ['rezultate_em', 'rezultate_mu', 'rezultate_hd']
        process_files(file_list)
        command = "mkdir data"
        execute_command(command)
        command = "head -n 1000 EDrezultate_em > EDrezultate_em_1k"
        execute_command(command)
        command = "mv EDrezultate* data/"
        execute_command(command)
        print("\nCreating the atmospheric shower animation...")
        file_path = "blender_script.py"
        if os.path.exists(file_path):
            continue
        else:
            blender_script()
        command = "blender -b -P blender_script.py -E BLENDER_EEVEE -o img###.png -a"
        execute_command(command)
        command = "cat *.png | ffmpeg -f image2pipe -r 30 -i - output.mp4 -y"
        execute_command(command)
        command = "rm *.png"
        execute_command(command)
        print("\nAnimation completed and saved as 'output.mp4'")
        ready_for_simulation = False
        continue_workflow = False
      elif directory_response == "no":
        print("\nPlease execute this file within the 'run' directory to proceed.")
        ready_for_simulation = False
        continue_workflow = False
      elif directory_response == "quit":
        ready_for_simulation = False
        continue_workflow = False
      else:
        print("\nInvalid command. Please enter 'yes', 'no', or 'quit'.")
  elif installation_response == "no":
    print("\nFirstly, send an email to tanguy.pierog@kit.edu expressing interest in using the software so that he can provide the password required for the program installation.")
    print("The installation of CORSIKA77500 and all its directories is available at the following link: https://web.iap.kit.edu/corsika/download/")
    print("Enter the username 'corsika' and the password provided through the email received from the software's technical team.\n")
    continue_workflow = False
  elif installation_response == "quit":
    continue_workflow = False
  else:
    print("\nInvalid command. Please enter 'yes', 'no', or 'quit'.")
