extends Area2D

export (int) var equipo
var pelota

func _ready():
	pass

func _physics_process(delta):
	if(!gamehandler.momento_gol):
		if(pelota.global_position.y < global_position.y): #Si la pelota esta arriba del arco
			z_index = 1
		else:
			z_index = 0
	else:
		z_index = 1


func _on_Arco_body_entered(body):
	if(body.is_in_group("pelota")):
		if(equipo ==  0):
			gamehandler.gol(0)
		else:
			gamehandler.gol(1)
