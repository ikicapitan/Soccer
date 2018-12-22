extends Area2D

export (int) var equipo

func _ready():
	pass


func _on_Arco_body_entered(body):
	if(body.is_in_group("pelota")):
		if(equipo ==  0):
			gamehandler.gol(0)
		else:
			gamehandler.gol(1)
