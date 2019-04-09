extends Node2D

var jugadores = false #False 1 jugador, true 2 jugadores
export (PackedScene) var juego

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if(Input.is_action_just_pressed("tecla_select")):
		jugadores = !jugadores
		actualizar_opcion()
	elif(Input.is_action_just_pressed("tecla_start")):
		if(!jugadores):
			gamehandler.players = 1
		else:
			gamehandler.players = 2
		get_tree().change_scene_to(juego)
		
func actualizar_opcion():
	if(!jugadores):
		get_node("GUI/select").global_position = get_node("GUI/op1").global_position
	else:
		get_node("GUI/select").global_position = get_node("GUI/op2").global_position