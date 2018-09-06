extends Node

export (PackedScene) var pt_1 #Equipo 1
export (PackedScene) var pt_2 #Equipo 2
export (PackedScene) var pelota
export (int) var cant_jugadores


func _ready():
	iniciar_nivel()
	
func iniciar_nivel():
	spawn_teams()
	
func spawn_teams():
	var equipos = get_tree().get_nodes_in_group("equipo")
	
	for team in equipos.size():
		for i in cant_jugadores:
			var nombre_nodo = "Spawn_J" + String(i+1)
			var newJugador
			if(team == 0):
				newJugador = pt_1.instance()
				newJugador.add_to_group("Jugador1")
			else:
				newJugador = pt_2.instance() 
				newJugador.add_to_group("Jugador2")
			newJugador.global_position = equipos[team].get_node(nombre_nodo).global_position
			equipos[team].add_child(newJugador)
			
	var newBall = pelota.instance()
	newBall.global_position = get_tree().get_nodes_in_group("sp")[0].global_position
	add_child(newBall)
	gamehandler.target_j1 = get_tree().get_nodes_in_group("Jugador1")[0] #Marco como objetivo un jugador para poder mover
	gamehandler.target_j2 = get_tree().get_nodes_in_group("Jugador2")[0] #Lo mismo con el equipo 2
