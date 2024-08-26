import subprocess
import bpy
import time
from math import cos
import os

def generate_DAT_files(command_DAT_files):
    """Execute the command and return the DAT files."""
    try:
        result = subprocess.run(command_DAT_files, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error executing the command: {e}"

def traks2root():
    """Execute the command and return the files in text format."""
    command_traks2root = "perl tracks2root.pl"
    try:
        result = subprocess.run(command_traks2root, shell=True, check=True, text=True, capture_output=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error executing the command: {e}"

def process_files():
    """Optimize the files so that they are accepted in the animation."""
    file_list = ['rezultate_em', 'rezultate_mu', 'rezultate_hd']
    for file_name in file_list:
        with open(file_name, 'r') as file, open(f'ED{file_name}', 'w') as output_file:
            for line in file:
                line = line.strip()
                words = line.split(' ')

                if '' not in words and words[2] != words[6]:
                    output_file.write(' '.join(words) + '\n')

def process_curves_from_files(limit=-1):
    '''
    Main function to process and animate curves from specified files.
    
    Parameters:
    - file_names: List of filenames to read data from.
    - limit: Number of lines to read from each file. -1 to read all lines.
    '''

    file_names = ["EDrezultate_em", "EDrezultate_mu", "EDrezultate_hd"]

    def make_curve(points, loop2):
        '''
        Function that creates a curve in Blender
        '''
        # Create the Curve Datablock
        curveData = bpy.data.curves.new(f'myCurve{loop2}', type='CURVE')
        curveData.dimensions = '3D'
        curveData.resolution_u = 4

        # Map coordinates to spline
        polyline = curveData.splines.new('POLY')
        polyline.points.add(len(points)-1)
        for i, coord in enumerate(points):
            x, y, z = coord
            polyline.points[i].co = (x, y, z, 1)

        # Create Object
        curveOB = bpy.data.objects.new(f'myCurve{loop2}', curveData)
        curveData.bevel_resolution = 6
        curveData.bevel_depth = 0.001667

        # Attach to scene and validate context
        scn = bpy.context.scene
        scn.collection.objects.link(curveOB)

        bpy.ops.object.shade_smooth()

    def remove_materials_objects():
        '''
        Function that removes all materials, objects, and curves
        '''
        for material in bpy.data.materials: # Remove existing materials
            bpy.data.materials.remove(material)
    
        for obj in bpy.data.objects: # Remove all objects
            bpy.data.objects.remove(obj)
    
        for curve in bpy.data.curves: # Remove all curves
            bpy.data.curves.remove(curve)

    def create_material(loop):
        '''
        Function that creates a new material

        The argument loop represents the file being used
        '''
        bpy.data.materials.new(name="base"+f'{loop}') # Create material
        mat = bpy.data.materials[f'base{loop}'] # Select created material
    
        mat.use_nodes = True
        Principled = mat.node_tree.nodes['Principled BSDF'] # Principled BSDF node
    
        if loop == 0: # First file, red color
            Principled.inputs['Base Color'].default_value = (1.0, 0.028571, 0.021429, 0.4) # R G B Alpha
        elif loop == 1: # Second file, green color
            Principled.inputs['Base Color'].default_value = (0.028571, 1, 0.021429, 0.4) # R G B Alpha
        elif loop == 2: # Third file, blue color
            Principled.inputs['Base Color'].default_value = (0.028571, 0.021429, 1, 0.4) # R G B Alpha
        else: # More files, color decided by cos()
            Principled.inputs['Base Color'].default_value = (cos(loop*3.14), 1/cos(loop*3.14), cos(loop*3.14*2), 0.4) # R G B Alpha

        Principled.inputs['Roughness'].default_value = 0.445455
        Principled.inputs['Specular'].default_value = 0.08636365830898285

    def insert_material(loop, loop2):
        '''
        Function that assigns material loop to curve loop2
        '''
        mat = bpy.data.materials['base'+f'{loop}']
        curve = bpy.data.objects[f'myCurve{loop2}']
    
        curve.data.materials.append(mat)

    def animate(t_i, t_f, loop2):
        '''
        Function responsible for animating the curve, only uses the start and end time of the curve
        '''
        if t_i > t_f: # If times are swapped
            d = t_f
            t_f = t_i
            t_i = d
        scene = bpy.context.scene
        curve = bpy.data.curves[f'myCurve{loop2}']
    
        scene.frame_set(t_f)
        curve.keyframe_insert(data_path='bevel_factor_end')
    
        scene.frame_set(t_i)
        curve.bevel_factor_end = 0
        curve.keyframe_insert(data_path='bevel_factor_end')
    
        curve.animation_data.action.fcurves[0].keyframe_points[0].interpolation = 'LINEAR'
        curve.bevel_factor_mapping_end = 'SPLINE'

    def curve(data):
        '''
        Function that returns the data separated into different curves.
        '''
        x = []
        y = []

        xend = []
        yend = []

        new_data = []
        for line in data:
            line = line.replace('\n', '')
            l = line.split(' ')
            print(l)
            new_data.append(l)

            x.append(float(l[2]) / 1000000)
            xend.append(float(l[6]) / 1000000)

            y.append(float(l[3]) / 1000000)
            yend.append(float(l[7]) / 1000000)

        x_range = get_range(x, xend) # [start, end]
        y_range = get_range(y, yend) # [start, end]

        max_x = find_max(x_range)
        print("hello")
        max_y = find_max(y_range)

        ranges = (max_x, max_y)
        all_curves_x = []
        all_curves_y = []
        for loop, data_range in enumerate(ranges):    
            for line in data_range: # move to function
                indexes = []
                for j in range(len(line)):
                    if loop == 0:
                        indexes.append(x.index(line[j][0]))
                    else:
                        indexes.append(y.index(line[j][0]))        

                data_to_save = []
                for g in range(len(line)):
                    data_to_save.append(new_data[indexes[g]])
                
                if loop == 0:
                    all_curves_x.append(data_to_save)
                else:
                    all_curves_y.append(data_to_save)
    
        if len(all_curves_x) < len(all_curves_y):
            larger_curve = all_curves_y.copy()
            smaller_curve = all_curves_x.copy()
        else:
            larger_curve = all_curves_x.copy()
            smaller_curve = all_curves_y.copy()
    
        all_curves = []
        for data in larger_curve:
            if data in smaller_curve:
                all_curves.append(data)   
        return all_curves

    def find_same_line(start_end):
        '''
        Function that finds equal points in the data to classify them as belonging to the same curve. It also detects
        line bifurcation, making the two lines different curves to avoid errors.
    
        start_end = [x, y, z, xend, yend, zend]
        '''

        lines = []
        starts = [f[0] for f in start_end]
        ends = [f[1] for f in start_end]
    
        k = 0
        for i, f in start_end:
            print(i)
            if f in starts and i not in ends: # New line
                lines.append([[i, f]])
                continue
        
            count_bif = 0
            for curve in lines: # Detect bifurcation
                for xi, xf in curve:
                    if i == xi or i == xf:
                        count_bif += 1

                    if count_bif > 1:
                        lines.append([[i, f]])
                        break
                if count_bif > 1:
                    break
            if count_bif > 1:
                continue
            loop = 0
            for curve in lines: # Add curve to an existing line
                for xi, xf in curve:
                    if i == xf:
                        lines[loop].append([i, f])

                loop += 1

        return lines

    def get_range(start_list, end_list):
        '''
        Function that organizes the data into [start, end]
        '''
        tuples = []
        for i in range(len(start_list)):
            tuples.append([start_list[i], end_list[i]])
        return tuples

    ##                  
    ## MAIN CODE 
    ##                  

    start_time = time.time()

    remove_materials_objects()

    loop2 = 0
    last_frame = 0 # To find the last frame

    for loop, file_name in enumerate(file_names):
        with open(os.path.join("data", file_name), 'r') as file:
            raw_data = file.readlines(limit)

        curve_data = curve(raw_data)
    
        create_material(loop)
    
        # MAIN LOOP
        for curve in curve_data:
            loop2 += 1
            points = []
            for count, line in enumerate(curve):
            
                print(f"{count / len(curve) * 100}% line: {line}") # Progress

                x = float(line[2]) / 1000000
                y = float(line[3]) / 1000000
                z = float(line[4]) / 1000000
                t_initial = float(line[5]) * 1000000
                x_end = float(line[6]) / 1000000
                y_end = float(line[7]) / 1000000
                z_end = float(line[8]) / 1000000
                t_end = float(line[9]) * 1000000

                points.append((x, y, z))

                if count == 0:
                    time_initial = int(t_initial)
                time_final = int(t_end)
            
                if time_initial == time_final:
                    time_final = time_initial + 1
            
            make_curve(points, loop2)

            # Handle materials
            insert_material(loop, loop2)    

            animate(time_initial, time_final, loop2) 

            if time_final > last_frame: # Finding the last frame
                last_frame = time_final

    bpy.context.scene.frame_current = 0 # Return to initial frame

    # Light
    bpy.ops.object.light_add(type='SUN', align='WORLD', location=(0, -5.04, 4.6), rotation=(1.05418, 0, 0))

    # Camera
    bpy.ops.object.camera_add(enter_editmode=False, align='VIEW', location=(-1.0, -5.0, 1.5), rotation=(87.3975 / 57.3, 0, -12.974 / 57.3))

    bpy.context.scene.render.resolution_x = 1080
    bpy.context.scene.render.resolution_y = 1920

    bpy.data.objects['Camera'].select_set(True)

    bpy.data.scenes[0].camera = bpy.data.objects['Camera']

    # Render
    bpy.data.worlds["World"].node_tree.nodes["Background"].inputs[0].default_value = (0.0, 0.0, 0.0, 1) # Dark background

    bpy.context.scene.frame_end = last_frame + 10
    bpy.context.scene.eevee.use_bloom = True
    bpy.context.scene.eevee.use_gtao = True
    bpy.context.scene.eevee.use_ssr = True
    bpy.context.scene.eevee.use_motion_blur = True

    # Save
    bpy.ops.wm.save_mainfile(filepath=os.getcwd() + "output.blend") # Save as output.blend
    print(f"Final frame: {last_frame}")
    print('Took {} minutes'.format((time.time() - start_time) / 60))

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
        command_DAT_files = "./corsika77500Linux_EPOS_urqmd < all-inputs-epos"
        generate_DAT_files(command_DAT_files)
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
