extends KinematicBody2D

var Velocidad = Vector2() #Velocidad actual de desplazamiento
export (float) var vel_desp
export (float) var vel_desp_b
var team
enum direcciones {izquierda, derecha, arriba, abajo, diagabd,diagarrd, diababi, diabarri}
var direccion = direcciones.derecha
var path = [] #Camino (lista)
var target #Objetivo
export (bool) var IA #Manejado por computadora o no
var p_spawn
var equipo_gol = false
var en_lateral = false
var momento_saque = false

var moviendo = false
var mov_p = false #Moviendose hacia el punto previo al balon
var mov_b = false #Moviendose hacia el balon centrado
var mov_c = false #Moviendose para tocar el balon


func _ready():
	vel_desp -= 3
	vel_desp_b -= 3

func _physics_process(delta):

	if(momento_saque):
		procesar_movimiento_saque(delta)

	procesar_movimiento(delta)

	if(!momento_saque):
		if(IA):
			check_distancia_IA()

		if(path.size() > 0):
			var d = $CollisionShape2D.global_position.distance_to(path[0]) #Medimos la distancia a recorrer
			if(d > 5): #Si la distancia es mayor a n, avanzamos
				if(!get_node("AnimationPlayer").is_playing()):
					if(abs($CollisionShape2D.global_position.x - path[0].x) >1): #Me fijo si eje X esta lejos
						if($CollisionShape2D.global_position.x > path[0].x):
							Velocidad.x = -vel_desp*6
						else:
							Velocidad.x = vel_desp*6
					if(abs($CollisionShape2D.global_position.y - path[0].y) > 1): #Me fijo si eje Y esta lejos
						if($CollisionShape2D.global_position.y > path[0].y):
							Velocidad.y = -vel_desp*6
						else:
							Velocidad.y = vel_desp*6
					#Determinamos direcciones de animacion
					if(Velocidad.x > 0):
						if(Velocidad.y > 0):
							get_node("Sprite").flip_h = false
							get_node("AnimationPlayer").call_deferred("play","diaba")
						elif(Velocidad.y < 0):
							get_node("Sprite").flip_h = false
							get_node("AnimationPlayer").call_deferred("play","diarr")
						else:
							get_node("Sprite").flip_h = false
							get_node("AnimationPlayer").call_deferred("play","der")
					elif(Velocidad.x < 0):
						if(Velocidad.y > 0):
							get_node("Sprite").flip_h = true
							get_node("AnimationPlayer").call_deferred("play","diaba")
						elif(Velocidad.y < 0):
							get_node("Sprite").flip_h = true
							get_node("AnimationPlayer").call_deferred("play","diarr")
						else:
							get_node("Sprite").flip_h = true
							get_node("AnimationPlayer").call_deferred("play","der")
					else:
						if(Velocidad.y > 0):
							get_node("AnimationPlayer").call_deferred("play","Aba")
						elif(Velocidad.y < 0):
							get_node("Sprite").flip_h = false
							get_node("AnimationPlayer").call_deferred("play","Arr")
						else:
							pass
					if(equipo_gol):
						get_node("AnimationPlayer").call_deferred("play","gol")
				moviendo = true
			else:
				#check_distancia_IA()
				path.remove(0) #Si alcanzamos removemos el nodo path para chequear el proximo
				get_node("AnimationPlayer").play("idle")
				Velocidad = Vector2(0,0)

		else: #Se termino de mover
			#if(!momento_saque):
			#	momento_saque = true
			#else: #Si es IA y no esta en momento saque
			if(mov_p): #Posiciona cerca
				mov_p = false
				mov_b = true
				mov_c = false
			elif(mov_b): #Centra
				mov_p = false
				mov_b = false
				mov_c = true
			elif(mov_c): #Toca la pelota
				mov_p = false
				mov_b = false
				mov_c = true
				
			if(gamehandler.pelota.target == self):
				mov_c = false
				arco_IA_contrario()
				create_path()
			#	else: #Sino buscar pelota
			#check_distancia_IA()

			

func check_distancia_IA(): #CHequea distancia entre punto spawn jugador y pelota
	path = []
	var d = p_spawn.global_position.distance_to(gamehandler.pelota.global_position)
	if(gamehandler.pelota.target != null):
		if(gamehandler.pelota.target != self):
			check_IA_possesion()
			create_path()
		else:
			arco_IA_contrario()
			create_path()
	elif(d <= 70): #Se dirige al punto previo
		target = gamehandler.pelota
		if(!mov_b && !mov_p && !mov_c):#Punto previo
			create_path_tp()
		elif(!mov_p && mov_b &&!mov_c): #Centrando
			create_path_ball()
		elif(mov_c && !mov_p && !mov_b): #Colisionando
			create_path_col()

	elif(d > 70): #Vuelve al punto de Spawn
		target = p_spawn
		create_path()
		mov_p = false
		mov_b = false
		
	path.remove(0)


func check_IA_possesion():
	if(gamehandler.pelota.target.team == team): #Es de mi propio equipo
		target = p_spawn

func arco_IA_contrario():
	if(team == 1):
		target = get_tree().get_nodes_in_group("ar_e2")[0]
	else:
		target = get_tree().get_nodes_in_group("ar_e1")[0]
	path = []

func procesar_movimiento_saque(delta):
	if(0): #Si patea o pasa
		var vel_patear = gamehandler.pelota.vel_saq
		if(direccion == direcciones.derecha):
			if(gamehandler.tipo_lateral == 0): #Lateral Arriba
				$AnimationPlayer.play("lat_arri2")
				gamehandler.pelota.Velocidad = Vector2(vel_patear,vel_patear*2)
			elif(gamehandler.tipo_lateral == 1): #Lateral Abajo
				$AnimationPlayer.play("lat_abi2")
				gamehandler.pelota.Velocidad = Vector2(vel_patear,-vel_patear)
		elif(direccion == direcciones.izquierda):
			if(gamehandler.tipo_lateral == 0): #Lateral Arriba
				$AnimationPlayer.play("lat_arri2")
				gamehandler.pelota.Velocidad = Vector2(-vel_patear,vel_patear*2)
			elif(gamehandler.tipo_lateral == 1): #Lateral Abajo
				$AnimationPlayer.play("lat_abi2")
				gamehandler.pelota.Velocidad = Vector2(-vel_patear,-vel_patear)
		elif(direccion == direcciones.arriba):
			$AnimationPlayer.play("lat_arrm2")
			gamehandler.pelota.Velocidad = Vector2(0,vel_patear*2)
		elif(direccion == direcciones.abajo):
			$AnimationPlayer.play("lat_abm2")
			gamehandler.pelota.Velocidad = Vector2(0,-vel_patear)

		if(gamehandler.tipo_lateral == 2): #Izq
			if(gamehandler.pelota.global_position.y > 0):
				gamehandler.pelota.Velocidad = Vector2(gamehandler.pelota.vel_corner/2,-gamehandler.pelota.vel_corner*2)
			else:
				gamehandler.pelota.Velocidad = Vector2(gamehandler.pelota.vel_corner/2,gamehandler.pelota.vel_corner*2)
		elif(gamehandler.tipo_lateral == 3): #Der
			if(gamehandler.pelota.global_position.y > 0):
				gamehandler.pelota.Velocidad = Vector2(-gamehandler.pelota.vel_corner/2,-gamehandler.pelota.vel_corner*2)
			else:
				gamehandler.pelota.Velocidad = Vector2(-gamehandler.pelota.vel_corner/2,gamehandler.pelota.vel_corner*2)

		gamehandler.pelota.pase = true
		gamehandler.pelota.target = null
		gamehandler.pelota.get_node("AnimationPlayer").stop()
		gamehandler.pelota.mover(Velocidad*get_node("AnimationPlayer").get_animation("Aba").length)
		en_lateral = false
		get_tree().get_nodes_in_group("laterales")[0].activar_jugadores()

		yield(get_tree().create_timer(0.3),"timeout")
		momento_saque = false
		gamehandler.instancia_lateral = false
	elif(gamehandler.tipo_lateral == 0 || gamehandler.tipo_lateral == 1): #Si se mueve mientras esta en saque
		if(1 && !moviendo && gamehandler): #Si va hacia la derecha
			direccion = direcciones.derecha
			if(gamehandler.tipo_lateral == 0):
				$AnimationPlayer.play("lat_arri")
				$Sprite.flip_h = true
			else:
				$AnimationPlayer.play("lat_abi")
				$Sprite.flip_h = true
		elif(2 && !moviendo): #Si izquierda
			direccion = direcciones.izquierda
			if(gamehandler.tipo_lateral == 0):
				$AnimationPlayer.play("lat_arri")
				$Sprite.flip_h = false
			else:
				$AnimationPlayer.play("lat_abi")
				$Sprite.flip_h = false
		elif(3 || 4): #Arriba o Abajo
			if(gamehandler.tipo_lateral == 0):
				$AnimationPlayer.play("lat_arrm")
				direccion = direcciones.arriba
			elif(gamehandler.tipo_lateral == 1):
				$AnimationPlayer.play("lat_abm")
				direccion = direcciones.abajo

func procesar_movimiento(var delta_t):

	if(moviendo):
		var obj_colisionado = move_and_collide(Velocidad * delta_t)
		if(gamehandler.pelota.target == self && !gamehandler.pelota.get_node("AnimationPlayer").is_playing() && !gamehandler.pelota.pase): #Tengo pelota en pie
			if(abs($CollisionShape2D.position.distance_to(gamehandler.pelota.get_node("CollisionShape2D").position)) < 4): #Si estan proximos la pelota y el jugador
				if($AnimationPlayer.current_animation_position <= 0.1): #check_direction_player(gamehandler.pelota.get_node("Area2D/CollisionShape2D").global_position (esta bien sacarlo?)
					gamehandler.pelota.mover(Velocidad*get_node("AnimationPlayer").get_animation("Aba").length)
					gamehandler.pelota.ult_toque = team
					gamehandler.pelota.target = null #Suelto la pelota
					var vel_provis = Velocidad
					Velocidad /= 4
					yield(get_tree().create_timer(1.5), "timeout") #Espero 1 segundo
					Velocidad = vel_provis

			else:
				gamehandler.pelota.target = null

		if(obj_colisionado != null && obj_colisionado.collider.is_in_group("pelota") && gamehandler.pelota.target == null):
			if(!obj_colisionado.collider.get_node("AnimationPlayer").is_playing()):
				gamehandler.pelota.target = self #Asigno pelota como target
				gamehandler.pelota.ult_toque = team

func _on_AnimationPlayer_animation_finished(anim_name):
	moviendo = false
	Velocidad = Vector2(0,0)

func patear(numero): #Numero 0 es pase, numero 1 es patear
	var velocidad_patear

	if(gamehandler.pelota.target == self): #Si no esta pateando el aire
		gamehandler.pelota.ult_toque = team
		match(numero):
			0: #Pase
				velocidad_patear = gamehandler.pelota.vel_pas
			1: #Patear
				velocidad_patear = gamehandler.pelota.vel_shoot

	match direccion:
		direcciones.derecha:
			get_node("AnimationPlayer").call_deferred("play","pateard")
			if(gamehandler.pelota.target == self && !gamehandler.pelota.pase && !gamehandler.pelota.shoot):
				gamehandler.pelota.Velocidad = Vector2(velocidad_patear, 0)
		direcciones.izquierda:
			get_node("AnimationPlayer").call_deferred("play","pateard")
			if(gamehandler.pelota.target == self && !gamehandler.pelota.pase && !gamehandler.pelota.shoot):
				gamehandler.pelota.Velocidad = Vector2(-velocidad_patear, 0)
		direcciones.arriba:
			get_node("AnimationPlayer").call_deferred("play","pateararr")
			if(gamehandler.pelota.target == self && !gamehandler.pelota.pase && !gamehandler.pelota.shoot):
				gamehandler.pelota.Velocidad = Vector2(0, -velocidad_patear)
		direcciones.abajo:
			get_node("AnimationPlayer").call_deferred("play","patearabaj")
			if(gamehandler.pelota.target == self && !gamehandler.pelota.pase && !gamehandler.pelota.shoot):
				gamehandler.pelota.Velocidad = Vector2(0, velocidad_patear)
		direcciones.diagabd:
			get_node("AnimationPlayer").call_deferred("play","pateardaba")
			if(gamehandler.pelota.target == self && !gamehandler.pelota.pase && !gamehandler.pelota.shoot):
				gamehandler.pelota.Velocidad = Vector2(velocidad_patear, velocidad_patear)
		direcciones.diagarrd:
			get_node("AnimationPlayer").call_deferred("play","pateardarr")
			if(gamehandler.pelota.target == self && !gamehandler.pelota.pase && !gamehandler.pelota.shoot):
				gamehandler.pelota.Velocidad = Vector2(velocidad_patear, -velocidad_patear)
		direcciones.diababi:
			get_node("AnimationPlayer").call_deferred("play","pateardaba")
			if(gamehandler.pelota.target == self && !gamehandler.pelota.pase && !gamehandler.pelota.shoot):
				gamehandler.pelota.Velocidad = Vector2(-velocidad_patear, velocidad_patear)
		direcciones.diabarri:
			get_node("AnimationPlayer").call_deferred("play","pateardarr")
			if(gamehandler.pelota.target == self && !gamehandler.pelota.pase && !gamehandler.pelota.shoot):
				gamehandler.pelota.Velocidad = Vector2(-velocidad_patear, -velocidad_patear)

	if(gamehandler.pelota.target == self): #Si esta en posesion del balon en ese momento
		match(numero):
			0:
				gamehandler.pelota.pase = true
			1:
				gamehandler.pelota.shoot = true
		gamehandler.pelota.get_node("AnimationPlayer").stop()
		gamehandler.pelota.mover(Velocidad*get_node("AnimationPlayer").get_animation("Aba").length)


	yield(get_tree().create_timer(0.5), "timeout")

	match direccion:
		direcciones.derecha:
			get_node("AnimationPlayer").play("der")
		direcciones.izquierda:
			get_node("AnimationPlayer").play("der")
		direcciones.arriba:
			get_node("AnimationPlayer").play("Arr")
		direcciones.abajo:
			get_node("AnimationPlayer").play("Aba")
		direcciones.diagabd:
			get_node("AnimationPlayer").play("diaba")
		direcciones.diagarrd:
			get_node("AnimationPlayer").play("diarr")
		direcciones.diababi:
			get_node("AnimationPlayer").play("diaba")
		direcciones.diabarri:
			get_node("AnimationPlayer").play("diarr")

func create_path_tp(): #Crea el camino a punto previo a la bola
	var nav = get_tree().get_nodes_in_group("nav")[0] #Obtengo el nodo navigation2D
	if(global_position.y < target.get_node("t_e").global_position.y):
		path = nav.get_simple_path(position, target.get_node("t_p2").global_position, false) #Genero el camino
	else:
		path = nav.get_simple_path(position, target.get_node("t_p1").global_position, false) #Genero el camino

func create_path_col(): #Crea el camino a tal punto
	var nav = get_tree().get_nodes_in_group("nav")[0] #Obtengo el nodo navigation2D
	path = nav.get_simple_path(position, target.get_node("bola").global_position, false) #Genero el camino

func create_path_ball(): #Crea el camino a centrado
	var nav = get_tree().get_nodes_in_group("nav")[0] #Obtengo el nodo navigation2D
	path = nav.get_simple_path(position, target.get_node("t_e").global_position, false) #Genero el camino

func create_path(): #Crea el camino a tal punto
	var nav = get_tree().get_nodes_in_group("nav")[0] #Obtengo el nodo navigation2D
	path = nav.get_simple_path(position, target.position, false) #Genero el camino

func lateral_path(): #Crea el camino a tal punto en el caso de que sea lateral inferior
	var nav = get_tree().get_nodes_in_group("nav")[0] #Obtengo el nodo navigation2D
	target.position += Vector2(0,20)
	path = nav.get_simple_path(position, target.position, false) #Genero el camino

func volver_spawn():
	target = p_spawn
	create_path()

func festejar_gol(equipo, lista_j, pelota):
	for j in lista_j:
		add_collision_exception_with(j)
	add_collision_exception_with(pelota)
	if(team == equipo):
		equipo_gol = true

func regreso_half(lista_j):
	for j in lista_j:
		add_collision_exception_with(j)
	add_collision_exception_with(gamehandler.pelota)

func fin_regreso(lista_j):
	for j in lista_j:
		remove_collision_exception_with(j)
	remove_collision_exception_with(gamehandler.pelota)

func fin_festejo(lista_j, pelota):
	for j in lista_j:
		remove_collision_exception_with(j)
	remove_collision_exception_with(pelota)
	get_node("AnimationPlayer").play("idle")
	equipo_gol = false

func exception_eq(estado):
	var jugadores = get_tree().get_nodes_in_group("player")
	if(estado):
		for j in jugadores:
			add_collision_exception_with(j)
			gamehandler.pelota.target = null
			add_collision_exception_with(get_tree().get_nodes_in_group("pelota")[0])
	else:
		for j in jugadores:
			remove_collision_exception_with(j)
			remove_collision_exception_with(get_tree().get_nodes_in_group("pelota")[0])
