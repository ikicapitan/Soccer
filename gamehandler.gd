extends Node

var jugador_1 = 1
var jugador_2 = 2
var index1 = 0 #Elemento actual recorrido en la lista de jugadores
var index2 = 0 #Elemento actual recorrido en la lista de jugadores

var target_j1 #Jugador seleccionado
var target_j2 #Jugador seleccionado

func _input(event): #Procesamos globalmente todas las teclas

#PLAYER 1

	if(Input.is_action_just_pressed("tecla_a")):
		target_j1.teclas[2] = true
	elif(Input.is_action_just_released("tecla_a")):
		target_j1.teclas[2] = false
	
	if(Input.is_action_just_pressed("tecla_w")):
		target_j1.teclas[0] = true
	elif(Input.is_action_just_released("tecla_w")):
		target_j1.teclas[0] = false
		
	if(Input.is_action_just_pressed("tecla_s")):
		target_j1.teclas[1] = true
	elif(Input.is_action_just_released("tecla_s")):
		target_j1.teclas[1] = false
		
	if(Input.is_action_just_pressed("tecla_d")):
		target_j1.teclas[3] = true
	elif(Input.is_action_just_released("tecla_d")):
		target_j1.teclas[3] = false
		
	if(Input.is_action_just_pressed("tecla_patear")):
		target_j1.teclas[4] = true
	elif(Input.is_action_just_released("tecla_patear")):
		target_j1.teclas[4] = false
		
	if(Input.is_action_just_pressed("tecla_select")):
		index1 += 1
		if(!index1 < get_tree().get_nodes_in_group("main")[0].cant_jugadores): #Si supere cantidad de jugadores
			index1 = 0 #Vuelvo al primer elemento
		target_j1 = get_tree().get_nodes_in_group("Jugador1")[index1] #Selecciono objetivo a mover
		
#PLAYER 2
		
	if(Input.is_action_just_pressed("tecla_j")):
		target_j2.teclas[2] = true
	elif(Input.is_action_just_released("tecla_j")):
		target_j2.teclas[2] = false
	
	if(Input.is_action_just_pressed("tecla_i")):
		target_j2.teclas[0] = true
	elif(Input.is_action_just_released("tecla_i")):
		target_j2.teclas[0] = false
		
	if(Input.is_action_just_pressed("tecla_k")):
		target_j2.teclas[1] = true
	elif(Input.is_action_just_released("tecla_k")):
		target_j2.teclas[1] = false
		
	if(Input.is_action_just_pressed("tecla_l")):
		target_j2.teclas[3] = true
	elif(Input.is_action_just_released("tecla_l")):
		target_j2.teclas[3] = false
		
	if(Input.is_action_just_pressed("tecla_.")):
		target_j2.teclas[4] = true
	elif(Input.is_action_just_released(".")):
		target_j2.teclas[4] = false
		
	if(Input.is_action_just_pressed("tecla_select2")):
		index2 += 1
		if(!index2 < get_tree().get_nodes_in_group("main")[0].cant_jugadores): #Si supere cantidad de jugadores
			index2 = 0 #Vuelvo al primer elemento
		target_j2 = get_tree().get_nodes_in_group("Jugador2")[index2] #Selecciono objetivo a mover
	get_tree().set_input_as_handled()