extends Node2D

export (PackedScene) var pt_1 #Equipo 1
export (PackedScene) var pt_2 #Equipo 2
export (PackedScene) var ar_1 #Arquero Eq 1
export (PackedScene) var ar_2 #Arquero Eq 1
export (PackedScene) var pelota
export (int) var cant_jugadores
export (Script) var script_IA
export (Script) var IA_ARQ


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
				newJugador.team = 1
			else:
				newJugador = pt_2.instance() 
				newJugador.add_to_group("Jugador2")
				var vel_desp_b = newJugador.vel_desp_b
				var vel_desp = newJugador.vel_desp
				if(gamehandler.players == 1):
					newJugador.set_script(script_IA)
					newJugador.IA = true
					newJugador.vel_desp_b = vel_desp_b
					newJugador.vel_desp = vel_desp
				else:
					newJugador.IA = false
				newJugador.team = 2
				
			newJugador.global_position = equipos[team].get_node(nombre_nodo).global_position
			newJugador.p_spawn = equipos[team].get_node(nombre_nodo)
			get_tree().get_nodes_in_group("teams")[0].add_child(newJugador)
			
	crear_arqueros()
			
	crear_balon()
	
	gamehandler.target_j1 = get_tree().get_nodes_in_group("Jugador1")[0] #Marco como objetivo un jugador para poder mover
	gamehandler.target_j2 = get_tree().get_nodes_in_group("Jugador2")[0] #Lo mismo con el equipo 2
	
	gamehandler.inicio()


func crear_arqueros():
	var equipos = get_tree().get_nodes_in_group("equipo")
	for team in equipos.size():
		var nombre_nodo = "Spawn_A"
		var newJugador
		if(team == 0):
			newJugador = ar_1.instance()
			newJugador.add_to_group("Jugador1")
			newJugador.team = 1
			gamehandler.ar_1 = newJugador
		else:
			newJugador = ar_2.instance()
			newJugador.add_to_group("Jugador2")
			if(gamehandler.players == 1):
				var vel_desp_b = newJugador.vel_desp_b
				var vel_desp = newJugador.vel_desp
				newJugador.set_script(IA_ARQ)
				newJugador.team = 2
				newJugador.IA = true
				newJugador.vel_desp_b = vel_desp_b
				newJugador.vel_desp = vel_desp
			gamehandler.ar_2 = newJugador
		newJugador.global_position = equipos[team].get_node(nombre_nodo).global_position
		newJugador.p_spawn = equipos[team].get_node(nombre_nodo)
		get_tree().get_nodes_in_group("teams")[0].add_child(newJugador)
		gamehandler.a_d = get_tree().get_nodes_in_group("a_d")[0] #Area disparo IA
			
			
func crear_balon():
	#Se crea la pelota
	var newBall = pelota.instance()
	newBall.global_position = get_tree().get_nodes_in_group("sp")[0].global_position
	get_tree().get_nodes_in_group("teams")[0].add_child(newBall)
	#Referencio la pelota a los arcos
	var arcos = get_tree().get_nodes_in_group("arc")
	for arc in arcos:
		arc.pelota = newBall
		
