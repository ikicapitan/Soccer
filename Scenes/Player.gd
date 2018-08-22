extends KinematicBody2D

var Velocidad = Vector2() #Velocidad actual de desplazamiento
export (float) var vel_desp
export (float) var vel_desp_b
enum direcciones {izquierda, derecha, arriba, abajo, diagabd,diagarrd, diababi, diabarri}
var direccion = derecha


var moviendo = false;

var teclas = [false, false, false, false] #teclas[0] arriba, 1 abajo, 2 izquierda, 3 derecha

func _ready():
	pass

func _physics_process(delta):
	
	if(Input.is_action_just_pressed("tecla_a")):
		teclas[2] = true
	elif(Input.is_action_just_released("tecla_a")):
		teclas[2] = false
	
	if(Input.is_action_just_pressed("tecla_w")):
		teclas[0] = true
	elif(Input.is_action_just_released("tecla_w")):
		teclas[0] = false
		
	if(Input.is_action_just_pressed("tecla_s")):
		teclas[1] = true
	elif(Input.is_action_just_released("tecla_s")):
		teclas[1] = false
		
	if(Input.is_action_just_pressed("tecla_d")):
		teclas[3] = true
	elif(Input.is_action_just_released("tecla_d")):
		teclas[3] = false
		
	procesar_teclas()
	procesar_movimiento(delta)
	
		
func procesar_teclas():
	
	if(teclas[3] && !moviendo):
		Velocidad = Vector2(vel_desp, 0)
		get_node("AnimationPlayer").call_deferred("play","der")
		direccion = derecha
		moviendo = true

func procesar_movimiento(var delta_t):
	if(moviendo):
		move_and_collide(Velocidad * delta_t)