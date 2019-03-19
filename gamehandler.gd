extends Node

var jugador_1 = 1
var jugador_2 = 2
var index1 = 0 #Elemento actual recorrido en la lista de jugadores
var index2 = 0 #Elemento actual recorrido en la lista de jugadores

var momento_gol = false
var instancia_lateral = false
var equipo_lateral = 0
var tipo_lateral #0 arriba, 1 abajo, 2 izq arr, 3 izq aba, 4 der arr, 5 der aba

var goles = [0,0]

var pelota #La pelota de todo el juego men

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
		
	if(Input.is_action_just_pressed("tecla_pase")):
		target_j1.teclas[5] = true
	elif(Input.is_action_just_released("tecla_pase")):
		target_j1.teclas[5] = false
		
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
		
	if(Input.is_action_just_pressed("tecla_pasej2")):
		target_j2.teclas[5] = true
	elif(Input.is_action_just_released("tecla_pasej2")):
		target_j2.teclas[5] = false
		
	if(Input.is_action_just_pressed("tecla_select2")):
		index2 += 1
		if(!index2 < get_tree().get_nodes_in_group("main")[0].cant_jugadores): #Si supere cantidad de jugadores
			index2 = 0 #Vuelvo al primer elemento
		target_j2 = get_tree().get_nodes_in_group("Jugador2")[index2] #Selecciono objetivo a mover
	get_tree().set_input_as_handled()
	
	
func gol(eq):
	goles[eq] += 1
	var txtnombre = "txte" + String(eq+1)
	get_tree().get_nodes_in_group(txtnombre)[0].text = "EQ " + String(eq+1) + ": " + String(goles[eq])
	momento_gol = true
	var jugadores = get_tree().get_nodes_in_group("player")
	var pelota = get_tree().get_nodes_in_group("pelota")[0]
	var cam = get_tree().get_nodes_in_group("cam")[0]
	for j in jugadores:
		j.volver_spawn()
		j.festejar_gol(eq+1, jugadores, pelota)
	yield(get_tree().create_timer(3.0), "timeout")
	
	pelota.global_position = get_tree().get_nodes_in_group("sp")[0].global_position
	pelota.pos_actual = get_tree().get_nodes_in_group("pelota")[0].global_position
	cam.gol()
	yield(get_tree().create_timer(5.0), "timeout")
	momento_gol = false
	for j in jugadores:
		j.fin_festejo(jugadores, pelota)
	cam.gol = false

func reset_match():
	goles = [0,0]


func inicio():
	pelota = get_tree().get_nodes_in_group("pelota")[0]