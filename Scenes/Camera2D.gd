extends Camera2D

var vel_x = 0
var maximo
var minimo
var pos_ini
var target
var gol = false
var path = []



func _ready():
	pos_ini = global_position
	maximo = get_tree().get_nodes_in_group("max")[0]
	minimo = get_tree().get_nodes_in_group("min")[0]

func _physics_process(delta):
	if(vel_x != 0 && $max/CollisionShape2D.global_position.x < maximo.global_position.x && $min/CollisionShape2D.global_position.x > minimo.global_position.x):
		global_position.x += vel_x * delta
		align()
		
	if(gol):
		if(path.size() > 0):
			if(abs(position.x - pos_ini.x) > 1.0): #Medimos la distancia a recorrer
				#print("si2")
				if(position.x > path[0].x):
					vel_x = 40
				else:
					vel_x = -40
			else:
				vel_x = 0
		else:
			vel_x = 0
	

func restaurar_vel():
	vel_x = 0

func _on_min_body_entered(body):
	
	if(body.is_in_group("pelota")):
		vel_x = body.Velocidad.x*3
	yield(get_tree().create_timer(0.5), "timeout")
	restaurar_vel()


func _on_max_body_entered(body):
	if(body.is_in_group("pelota")):
		vel_x = body.Velocidad.x*3
	yield(get_tree().create_timer(0.5), "timeout")
	restaurar_vel()
	
func gol():
	gol = true
	target = pos_ini
	create_path()
	
	
func create_path(): #Crea el camino a tal punto
	var nav = get_tree().get_nodes_in_group("nav")[0] #Obtengo el nodo navigation2D
	path = nav.get_simple_path(position, target, false) #Genero el camino
