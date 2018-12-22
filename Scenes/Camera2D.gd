extends Camera2D

var vel_x = 0
var maximo
var minimo


func _ready():
	maximo = get_tree().get_nodes_in_group("max")[0]
	minimo = get_tree().get_nodes_in_group("min")[0]

func _physics_process(delta):
	if(vel_x != 0 && $max/CollisionShape2D.global_position.x < maximo.global_position.x && $min/CollisionShape2D.global_position.x > minimo.global_position.x):
		global_position.x += vel_x * delta
		align()
	

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
