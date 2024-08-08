#import struct
import bpy
import time
import os
from math import cos


# Função que instala o corsika caso não esteja presente no sistema


# --- TRACKS ---
# Função que produz os tracks


# Função que usa o plottracks para produzir a imagem


# Função que mostra a saída produzida pelo plottracks


# --- ANIMATION ---
# Executar o arquivo perl
# Função que converte arquivos binários para txt
# Não testado
def tracks_to_root(DAT_em, DAT_mu, DAT_hd):
    """Convert the original binary file to a new text file."""
    datafiles = [DAT_em, DAT_mu, DAT_hd]
    rezultates = 'rezultate_'

    for datafile in datafiles:
        rezultate_file = resultates + data_file

        with open(data_file, 'rb') as data_file, open(rezultate_file, 'w') as rezult_file:
            flag = 0

            while True:
                buffer2 = data_file.read(48)
                if not buffer2:
                    break

                # Ignoring the first 4 bytes and taking the next 40 bytes.
                buffer = buffer2[4:44]

                propriet = []
                for i in range(0, 40, 4):
                    # Unpacking as float.
                    propriet.append(struct.unpack('f', buffer[i:i+4])[0])

                # Writing to the results file.
                rezult_file.write(" ".join(map(str, propriet)) + "\n")

                flag += 1


# Função que checa e otimiza os arquivos antes de serem usados na animação
def check_file(rezultate_em, rezultate_mu, rezultate_hd):
    """It checks the input files to ensure they are optimized."""
    datas = ['rezultate_em', 'rezultate_mu', 'rezultate_hd']
    
    for data in datas:
        file = open(data, 'r')
        new_data_file = open(f'ED{data}', '+w')

        for lines in data:
            line = lines.replace('\n', '')
            l = line.split(' ')

            if '' not in l and l[2] != l[6]:
                for obj in l:
                    new_data_file.write(obj)
                    new_data_file.write(' ')
                new_data_file.write('\n')

        file.close()

# Funções que produzem a animação
arquivos_nome = ["EDrezultate_em","EDrezultate_mu","EDrezultate_hd"]
limite = -1 # quantas linhas serão lidas em cada arquivo. -1 para ler todas

def make_curve(points,loop2):
    '''
    Funcao que cria curva no blender
    '''
    # create the Curve Datablock

    curveData = bpy.data.curves.new(f'myCurve{loop2}', type='CURVE')
    curveData.dimensions = '3D'
    curveData.resolution_u = 4

    # map coords to spline
    polyline = curveData.splines.new('POLY')
    polyline.points.add(len(points)-1)
    for i, coord in enumerate(points):
        x,y,z = coord
        polyline.points[i].co = (x, y, z, 1)

    # create Object
    curveOB = bpy.data.objects.new(f'myCurve{loop2}', curveData)
    curveData.bevel_resolution = 6
    curveData.bevel_depth = 0.001667


    # attach to scene and validate context
    scn = bpy.context.scene
    scn.collection.objects.link(curveOB)

    bpy.ops.object.shade_smooth()

def remove_materials_objects():
    '''
    Função que remove todos materiais, objetos e curvas
    '''

    for material in bpy.data.materials: #remove materiais existentes
        bpy.data.materials.remove(material)
    
    for object in bpy.data.objects: # remove todos objetos
        bpy.data.objects.remove(object)
    
    for curva in bpy.data.curves: # remove todas curvas
        bpy.data.curves.remove(curva)    

def create_material(loop):
    '''
    Função que cria novo material

    Argumento loop representa o arquivo que está sendo usado
    '''
    bpy.data.materials.new(name="base"+f'{loop}') # cria material
    mat = bpy.data.materials[f'base{loop}'] # seleciona material criado
    
    mat.use_nodes = True
    Princi = mat.node_tree.nodes['Principled BSDF'] # nodo Principled BSDF
    
    if loop == 0: # primeiro arquivo cor vermelha
        Princi.inputs['Base Color'].default_value = (1.0, 0.028571, 0.021429, 0.4) # R G B Alpha
    elif loop == 1: # segundo arquivo cor verde
        Princi.inputs['Base Color'].default_value = (0.028571, 1, 0.021429, 0.4) # R G B Alpha
    elif loop == 2: # terceiro arquivo cor azul
        Princi.inputs['Base Color'].default_value = (0.028571, 0.021429, 1, 0.4) # R G B Alpha
    else: # mais arquivos tem a cor decidida por cos()
        Princi.inputs['Base Color'].default_value = (cos(loop*3.14), 1/cos(loop*3.14), cos(loop*3.14*2), 0.4) # R G B Alpha

    Princi.inputs['Roughness'].default_value = 0.445455
    Princi.inputs['Specular'].default_value = 0.08636365830898285

def insert_material(loop,loop2):
    '''
    Função que insere o material loop na curva loop2
    '''
    mat = bpy.data.materials['base'+f'{loop}']
    curva = bpy.data.objects[f'myCurve{loop2}']
    
    curva.data.materials.append(mat)

def anima(t_i,t_f,loop2):
    '''
    Função responsável pela animação da curva, utiliza somente o tempo final e inicial da curva
    '''
    if(t_i>t_f): #caso esteja trocado
        d= t_f
        t_f= t_i
        t_i= d
    scene = bpy.context.scene
    curva = bpy.data.curves[f'myCurve{loop2}'] 
    
    scene.frame_set(t_f)

    curva.keyframe_insert(data_path='bevel_factor_end')
    
    scene.frame_set(t_i)
    curva.bevel_factor_end = 0
    curva.keyframe_insert(data_path='bevel_factor_end')
    curva.animation_data.action.fcurves[0].keyframe_points[0].interpolation = 'LINEAR'
    curva.bevel_factor_mapping_end = 'SPLINE'     

def curva(dados):
    '''
    Funcao que retorna os dados separados em diferentes curvas.
    '''
    x=[]
    y=[]

    xend=[]
    yend=[]

    dados_new=[]
    for linha in dados:
        ligne=linha.replace('\n','')
        l=ligne.split(' ')
        print(l)
        dados_new.append(l)

        x.append(float(l[2])/1000000)
        xend.append(float(l[6])/1000000)

        y.append(float(l[3])/1000000)
        yend.append(float(l[7])/1000000)

    xif = inif(x,xend) # [inicial,final]
    yif = inif(y,yend) # [inicial,final]

    mesmax = mesmalinha(xif)
    print("oi")
    mesmay = mesmalinha(yif)

    mesma = (mesmax, mesmay)
    todas_curvas_x = []
    todas_curvas_y = []
    for loop,dado in enumerate(mesma):    
        for linha in dado: #colocar em funÃ§Ã£o
            indexes = []
            for j in range (0,len(linha)):
                if loop == 0:
                    indexes.append(x.index(linha[j][0]))
                else:
                    indexes.append(y.index(linha[j][0]))        

            dados_salvar=[]
            for g in range (0,len(linha)):
                dados_salvar.append(dados_new[indexes[g]])
                
            if loop ==0:
                todas_curvas_x.append(dados_salvar)
            else:
                todas_curvas_y.append(dados_salvar)
    
    if todas_curvas_x < todas_curvas_y:
        maior_curva = todas_curvas_y.copy()
        menor_curva = todas_curvas_x.copy()
    else:
        maior_curva = todas_curvas_x.copy()
        menor_curva = todas_curvas_y.copy()
    
    todas_curvas = []
    for dado in maior_curva:
        if dado in menor_curva:
            todas_curvas.append(dado)   
    return(todas_curvas)

def mesmalinha(inicial_final):
    '''
    Função que encontra pontos iguais nos dados para serem
    classificados como sendo da mesma curva. Também detecta 
    bifurcação da linha, fazendo as duas linhas serem curvas
    diferentes, evitando erros. 
    
    inicial_final = [x,y,z,xend,yend,zend]
    '''


    linhas=[]
    iniciais =[f[0] for f in inicial_final]
    finais = [f[1] for f in inicial_final]
    
    k=0
    for i,f in inicial_final:
        print(i)
        if f in iniciais and i not in finais: # nova linha
            linhas.append([[i,f]])
            continue
        
        count_bif =0
        for curva in linhas: # detecta bifurcação
            for xi,xf in curva:
                if i == xi or i == xf:
                    count_bif +=1

                if count_bif > 1:
                    linhas.append([[i,f]])
                    break
            if count_bif >1:
                break
        if count_bif >1:
            continue
        loop = 0
        for curva in linhas: # adiciona curva a uma linha já existente
            for xi,xf in curva:
                if i == xf:
                    linhas[loop].append([i,f])

            loop+=1

    return(linhas)

def inif(li,lf):
    '''
    Funcao que organiza os dados em [inicial,final]
    '''
    tu=[]
    for i in range(0,len(li)):
        tu.append([li[i],lf[i]])
    return(tu)

##                  
## CODIGO PRINCIPAL 
##                  

start_time= time.time()

remove_materials_objects()

loop2 = 0
last_frame = 0 #para encontrar o ultimo frame
for loop,arquivo_nome in enumerate(arquivos_nome):
    arquivo = open(os.path.join("dados",arquivo_nome),'r')
    tabraw = arquivo.readlines(limite)
    arquivo.close()

    dados_curvas = curva(tabraw)
    
    create_material(loop)
    
    # LOOP PRINCIPAL
    for curve in dados_curvas:

        loop2 += 1
        pontos =[]        
        for count,l in enumerate(curve):
            
            print(f"{count/len(curve)*100}% linha: {l}") # O quanto foi feito 
    
            x=float(l[2])/1000000
            y=float(l[3])/1000000 
            z=float(l[4])/1000000
            tini=float(l[5])*1000000
            xend=float(l[6])/1000000 
            yend=float(l[7])/1000000 
            zend=float(l[8])/1000000 
            tend=float(l[9])*1000000 

            pontos.append((x,y,z))

            if count == 0:
                tempo_inicial = int(tini)
            tempo_final = int(tend)
            
            if tempo_inicial == tempo_final:
                tempo_final = tempo_inicial + 1
            
        make_curve(pontos,loop2)

        # manejo materiais
        insert_material(loop,loop2)    

        anima(tempo_inicial, tempo_final,loop2) 

        if tempo_final > last_frame: #encontrando ultimo frame
            last_frame = tempo_final

bpy.context.scene.frame_current = 0 # retorna para frame inicial 

# luz
bpy.ops.object.light_add(type='SUN', align='WORLD', location=(0, -5.04, 4.6), rotation=(1.05418, 0, 0))

##camera
bpy.ops.object.camera_add(enter_editmode=False, align='VIEW', location=(-1., -5., 1.5), rotation=(87.3975/57.3, 0, -12.974/57.3))

bpy.context.scene.render.resolution_x = 1080
bpy.context.scene.render.resolution_y = 1920

bpy.data.objects['Camera'].select_set(True)

bpy.data.scenes[0].camera = bpy.data.objects['Camera']

# render
bpy.data.worlds["World"].node_tree.nodes["Background"].inputs[0].default_value = (0., 0., 0., 1) #background escuro

bpy.context.scene.frame_end = last_frame + 10
bpy.context.scene.eevee.use_bloom = True
bpy.context.scene.eevee.use_gtao = True
bpy.context.scene.eevee.use_ssr = True
bpy.context.scene.eevee.use_motion_blur = True
