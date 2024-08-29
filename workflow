import bpy
import time
from math import cos
import os

'''
Background script that transforms CORSIKA data into 3D curve models,
with the curve animations saved in PNG format using the command:

blender -b -P blender_visu_script.py -E CYCLES -o img###.png -a

Or for faster rendering:

blender -b -P blender_visu_script.py -E BLENDER_EEVEE -o img###.png -a

To convert to MP4, you can use (on Linux) ffmpeg:

cat *.png | ffmpeg -f image2pipe -r 30 -i - output.mp4 -y

rm *.png
'''

# ARGUMENTS

files_name = ["EDrezultate_em_1k","EDrezultate_mu","EDrezultate_hd"]
limit = -1 # Number of lines to be read from each file. -1 to read all.

def make_curve(points, loop2):
    '''
    Function that creates a curve in Blender
    '''
    # Create the Curve Datablock
    curveData = bpy.data.curves.new(f'myCurve{loop2}', type='CURVE')
    curveData.dimensions = '3D'
    curveData.resolution_u = 4
    
    # Map coords to spline
    polyline = curveData.splines.new('POLY')
    polyline.points.add(len(points) - 1)
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
    
    for object in bpy.data.objects: # Remove all objects
        bpy.data.objects.remove(object)
    
    for curve in bpy.data.curves: # Remove all curves
        bpy.data.curves.remove(curve)

def create_material(loop):
    '''
    Function that creates a new material
    Argument `loop` represents the file being used
    '''
    bpy.data.materials.new(name="base" + f'{loop}') # Create material
    mat = bpy.data.materials[f'base{loop}'] # Select created material
    
    mat.use_nodes = True
    Princi = mat.node_tree.nodes['Principled BSDF'] # Node Principled BSDF
    
    if loop == 0: # First file red color
        Princi.inputs['Base Color'].default_value = (1.0, 0.0, 0.0, 1.0) # (R, G, B, Alpha)
    elif loop == 1: # Second file green color
        Princi.inputs['Base Color'].default_value = (0.0, 1.0, 0.0, 1.0) # (R, G, B, Alpha)
    elif loop == 2: # Third file blue color
        Princi.inputs['Base Color'].default_value = (0.0, 0.0, 1.0, 1.0) # (R, G, B, Alpha)
    else: # Additional files have colors determined by `cos()`
        Princi.inputs['Base Color'].default_value = (cos(loop * 3.14), 1 / cos(loop * 3.14), cos(loop * 3.14 * 2), 1.0) # (R, G, B, Alpha)
    
    Princi.inputs['Roughness'].default_value = 0.5
    Princi.inputs['Specular'].default_value = 0.1

def insert_material(loop, loop2):
    '''
    Function that assigns the material `loop` to the curve `loop2`
    '''
    mat = bpy.data.materials['base' + f'{loop}']
    curve = bpy.data.objects[f'myCurve{loop2}']
    
    curve.data.materials.append(mat)

def animate(t_s, t_e, loop2):
    '''
    Function responsible for animating the curve, using only the start and end times of the curve.
    '''
    if t_s > t_e: # In case it's swapped
        d = t_e
        t_e = t_s
        t_s = d
    scene = bpy.context.scene
    curve = bpy.data.curves[f'myCurve{loop2}']
    
    scene.frame_set(t_e)
    
    curve.keyframe_insert(data_path='bevel_factor_end')
    
    scene.frame_set(t_s)
    curve.bevel_factor_end = 0
    curve.keyframe_insert(data_path='bevel_factor_end')
    curve.animation_data.action.fcurves[0].keyframe_points[0].interpolation = 'LINEAR'
    curve.bevel_factor_mapping_end = 'SPLINE'

def process_curve_data(data):
    '''
    Function that returns the data separated into different curves.
    '''
    x = []
    y = []
    
    x_end = []
    y_end = []
    
    data_new = []
    for line in data:
        ligne = line.replace('\n', '')
        l = ligne.split(' ')
        print(l)
        data_new.append(l)
        
        x.append(float(l[2]) / 1000000)
        x_end.append(float(l[6]) / 1000000)
        
        y.append(float(l[3]) / 1000000)
        y_end.append(float(l[7]) / 1000000)
        
    x_if = init_final(x, x_end)
    y_if = init_final(y, y_end)
    
    same_x = same_line(x_if)
    same_y = same_line(y_if)
    
    same = (same_x, same_y)
    all_curves_x = []
    all_curves_y = []
    for loop, dat in enumerate(same):
        for line in dat:
            indexes = []
            for j in range(0, len(line)):
                if loop == 0:
                    indexes.append(x.index(line[j][0]))
                else:
                    indexes.append(y.index(line[j][0]))
                
            data_save = []
            for g in range(0, len(line)):
                data_save.append(data_new[indexes[g]])
            
            if loop == 0:
                all_curves_x.append(data_save)
            else:
                all_curves_y.append(data_save)
    
    if all_curves_x < all_curves_y:
        biggest_curve = all_curves_y.copy()
        smallest_curve = all_curves_x.copy()
    else:
        biggest_curve = all_curves_x.copy()
        smallest_curve = all_curves_y.copy()
    
    all_curves = []
    for dat in biggest_curve:
        if dat in smallest_curve:
            all_curves.append(dat)
            
    return(all_curves)

def same_line(initial_final):
    '''
    Function that finds equal points in the data to classify
    them as belonging to the same curve. It also detects line
    bifurcation, making the two lines separate curves to
    avoid errors.

    `initial_final = [x, y, z, xend, yend, zend]`
    '''
    lines = []
    initials = [f[0] for f in initial_final]
    finals = [f[1] for f in initial_final]
    
    k = 0
    for i, f in initial_final:
        print(i)
        if f in initials and i not in finals: # New line
            lines.append([[i, f]])
            continue
        
        count_bif = 0
        for curve in lines: # Detects bifurcation
            for x_i, x_f in curve:
                if i == x_i or i == x_f:
                    count_bif +=1
                
                if count_bif > 1:
                    lines.append([[i, f]])
                    break
            if count_bif > 1:
                break
        if count_bif > 1:
            continue
        loop = 0
        for curve in lines: # Add curve to an existing line
            for x_i, x_f in curve:
                if i == x_f:
                    lines[loop].append([i, f])
                    
            loop += 1
    
    return(lines)
    
def init_final(l_i, l_f):
    '''
    Function that organizes the data into `[start, end]`
    '''
    tu = []
    for i in range(0, len(l_i)):
        tu.append([l_i[i], l_f[i]])
    
    return(tu)

# MAIN CODE

start_time = time.time()

remove_materials_objects()

loop2 = 0
last_frame = 0 # To find the last frame
for loop, file_name in enumerate(files_name):
    file = open(os.path.join("data", file_name), 'r')
    tabraw = file.readlines(limit)
    file.close()
    
    data_curves = process_curve_data(tabraw)
    
    create_material(loop)
    
    # MAIN LOOP
    for curve in data_curves:
        
        loop2 += 1
        dots = []
        for count, l in enumerate(curve):
            
            print(f"{count / len(curve) * 100}% line: {l}") # How much has been done
            
            x = float(l[2]) / 1000000
            y = float(l[3]) / 1000000
            z = float(l[4]) / 1000000
            t_init = float(l[5]) * 1000000
            x_end = float(l[6]) / 1000000
            y_end = float(l[7]) / 1000000
            z_end = float(l[8]) / 1000000
            t_final = float(l[9]) / 1000000
            
            dots.append((x, y, z))
            
            if count == 0:
                initial_time = int(t_init)
            final_time = int(t_final)
            
            if initial_time == final_time:
                final_time = initial_time + 1
            
        make_curve(dots, loop2)
        
        # Material handling
        insert_material(loop, loop2)
        
        animate(initial_time, final_time, loop2)
        
        if final_time > last_frame: # Finding the last frame
            last_frame = final_time

bpy.context.scene.frame_current = 0 # Return to the initial frame 

# Light
bpy.ops.object.light_add(type='SUN', align='WORLD', location=(0, -5.04, 4.6), rotation=(1.05418, 0, 0))

# Camera
bpy.ops.object.camera_add(enter_editmode=False, align='VIEW', location=(-1.7681, -5.40785, 1.12727), rotation=(87.3975/57.3, 0, -12.974/57.3))

bpy.context.scene.render.resolution_x = 1080
bpy.context.scene.render.resolution_y = 1920

bpy.data.objects['Camera'].select_set(True)

bpy.data.scenes[0].camera = bpy.data.objects['Camera']

# Render
bpy.data.worlds["World"].node_tree.nodes["Background"].inputs[0].default_value = (0, 0, 0, 1) #Dark background

bpy.context.scene.frame_end = last_frame + 10
bpy.context.scene.eevee.use_bloom = True
bpy.context.scene.eevee.use_gtao = True
bpy.context.scene.eevee.use_ssr = True
bpy.context.scene.eevee.use_motion_blur = True

# Save
bpy.ops.wm.save_mainfile(filepath=os.getcwd()+"output.blend") # Save as output.blend
print(f"Final frame: {last_frame}")
print('It took {} minutes'.format((time.time() - start_time)/60))
