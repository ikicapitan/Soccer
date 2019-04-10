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

var moviendo = false;

var teclas = [false, false, false, false, false, false] #teclas[0] arriba, 1 abajo, 2 izquierda, 3 derecha, 4 patear, 5 pase

func _ready():
	pass

func _physics_process(delta):
	
	if(!gamehandler.momento_gol && !en_lateral):
		procesar_teclas()
		
	if(momento_saque):
		procesar_movimiento_saque(delta)
		
	procesar_movimiento(delta)
	
	if(gamehandler.momento_gol || en_lateral):
		
			
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
				path.remove(0) #Si alcanzamos removemos el nodo path para chequear el proximo
				get_node("AnimationPlayer").play("idle")
				Velocidad = Vector2(0,0)
			
		else:
			if(!momento_saque):
				momento_saque = true
				if(gamehandler.tipo_lateral == 0): #Lateral arriba
					$AnimationPlayer.play("lat_arrm")
					get_tree().get_nodes_in_group("pelota")[0].pos_actual = $pelota_lateral.global_position
					get_tree().get_nodes_in_group("pelota")[0].global_position = $pelota_lateral.global_position
				elif(gamehandler.tipo_lateral == 1): #Lateral abajo
					$AnimationPlayer.play("lat_abm")
					get_tree().get_nodes_in_group("pelota")[0].pos_actual = $pelota_lateral.global_position
					get_tree().get_nodes_in_group("pelota")[0].global_position = $pelota_lateral.global_position
				elif(gamehandler.tipo_lateral == 2): #Lateral izquierda
					$AnimationPlayer.play("der")
					$Sprite.flip_h = false
					if(get_tree().get_nodes_in_group("pelota")[0].global_position.y > 0):
						get_tree().get_nodes_in_group("pelota")[0].pos_actual = get_tree().get_nodes_in_group("corner")[0].get_node("2").get_node("2").global_position
						get_tree().get_nodes_in_group("pelota")[0].global_position = get_tree().get_nodes_in_group("corner")[0].get_node("2").get_node("2").global_position
					else:
						get_tree().get_nodes_in_group("pelota")[0].pos_actual = get_tree().get_nodes_in_group("corner")[0].get_node("1").get_node("1").global_position
						get_tree().get_nodes_in_group("pelota")[0].global_position = get_tree().get_nodes_in_group("corner")[0].get_node("1").get_node("1").global_position
				elif(gamehandler.tipo_lateral == 3): #Lateral derecha
					$AnimationPlayer.play("der")
					$Sprite.flip_h = true
					if(get_tree().get_nodes_in_group("pelota")[0].global_position.y > 0):
						get_tree().get_nodes_in_group("pelota")[0].pos_actual = get_tree().get_nodes_in_group("corner")[0].get_node("4").get_node("4").global_position
						get_tree().get_nodes_in_group("pelota")[0].global_position = get_tree().get_nodes_in_group("corner")[0].get_node("4").get_node("4").global_position
					else:
						get_tree().get_nodes_in_group("pelota")[0].pos_actual = get_tree().get_nodes_in_group("corner")[0].get_node("3").get_node("3").global_position
						get_tree().get_nodes_in_group("pelota")[0].global_position = get_tree().get_nodes_in_group("corner")[0].get_node("3").get_node("3").global_position
	
				if(team == 1):
					gamehandler.target_j1 = self
				else:
					gamehandler.target_j2 = self

	
func procesar_teclas():	
	if((teclas[4] || teclas[5]) && !moviendo): #Si patea o pasa
		Velocidad = Vector2(0,0)
		moviendo = true
		if(teclas[4]):
			patear(1)
		elif(teclas[5]):
			patear(0)
	elif(teclas[3] && !moviendo): #Si va hacia la derecha
		if(teclas[0]): #Si ademas va hacia arriba (SERIA DIAGONAL ARRIBA)
			Velocidad = Vector2(vel_desp/get_node("AnimationPlayer").get_animation("diarr").length, -vel_desp/get_node("AnimationPlayer").get_animation("diarr").length)
			get_node("AnimationPlayer").call_deferred("play","diarr")
			get_node("Sprite").flip_h = false
			direccion = direcciones.diagarrd
			moviendo = true
		elif(teclas[1]): #Sino si ademas es abajo y derecha (DIAG ABAJO DERECHA)
			Velocidad = Vector2(vel_desp/get_node("AnimationPlayer").get_animation("diaba").length, vel_desp/get_node("AnimationPlayer").get_animation("diaba").length)
			get_node("AnimationPlayer").call_deferred("play","diaba")
			get_node("Sprite").flip_h = false
			direccion = direcciones.diagabd
			moviendo = true
		else: #Si no va hacia arriba o abajo adicionalmente, entonces solo es derecha
			Velocidad = Vector2(vel_desp/get_node("AnimationPlayer").get_animation("der").length, 0)
			get_node("AnimationPlayer").call_deferred("play","der")
			direccion = direcciones.derecha
			get_node("Sprite").flip_h = false
			moviendo = true
	elif(teclas[2] && !moviendo): #Si izquierda
		if(teclas[0]): #Si ademas arriba
			Velocidad = Vector2(-vel_desp/get_node("AnimationPlayer").get_animation("diarr").length, -vel_desp/get_node("AnimationPlayer").get_animation("diarr").length)
			get_node("AnimationPlayer").call_deferred("play","diarr")
			get_node("Sprite").flip_h = true
			direccion = direcciones.diabarri
			moviendo = true
		elif(teclas[1]): #Si ademas abajo
			Velocidad = Vector2(-vel_desp/get_node("AnimationPlayer").get_animation("diaba").length, vel_desp/get_node("AnimationPlayer").get_animation("diaba").length)
			get_node("AnimationPlayer").call_deferred("play","diaba")
			get_node("Sprite").flip_h = true
			direccion = direcciones.diababi
			moviendo = true
		else:
			Velocidad = Vector2(-vel_desp/get_node("AnimationPlayer").get_animation("der").length, 0)
			get_node("AnimationPlayer").call_deferred("play","der")
			direccion = direcciones.izquierda
			get_node("Sprite").flip_h = true
			moviendo = true
	elif(teclas[0] && !moviendo):
		Velocidad = Vector2(0, -vel_desp/get_node("AnimationPlayer").get_animation("Arr").length)
		get_node("AnimationPlayer").call_deferred("play","Arr")
		direccion = direcciones.arriba
		moviendo = true
	elif(teclas[1] && !moviendo):
		Velocidad = Vector2(0, vel_desp/get_node("AnimationPlayer").get_animation("Aba").length)
		get_node("AnimationPlayer").call_deferred("play","Aba")
		direccion = direcciones.abajo
		moviendo = true
	
func procesar_movimiento_saque(delta):
	if((teclas[4] || teclas[5])): #Si patea o pasa
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
		if(teclas[3] && !moviendo && gamehandler): #Si va hacia la derecha
			direccion = direcciones.derecha
			if(gamehandler.tipo_lateral == 0):
				$AnimationPlayer.play("lat_arri")
				$Sprite.flip_h = true
			else:
				$AnimationPlayer.play("lat_abi")
				$Sprite.flip_h = true
		elif(teclas[2] && !moviendo): #Si izquierda
			direccion = direcciones.izquierda
			if(gamehandler.tipo_lateral == 0):
				$AnimationPlayer.play("lat_arri")
				$Sprite.flip_h = false
			else:
				$AnimationPlayer.play("lat_abi")
				$Sprite.flip_h = false
		elif(teclas[0] || teclas[1]): #Arriba o Abajo
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
				if(check_direction_player(gamehandler.pelota.get_node("Area2D/CollisionShape2D").global_position) && $AnimationPlayer.current_animation_position <= 0.1):
					
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
				
func restaurar_velocidad():
	pass
	
func check_direction_player(var ball_pos): #Testea direccion del player y posicion de la bola a ver si la mueve o no
	match(direccion):
		direcciones.izquierda:
			if(ball_pos.x < $CollisionShape2D.global_position.x):
				return true
		direcciones.derecha:
			if(ball_pos.x > $CollisionShape2D.global_position.x):
				return true
		direcciones.arriba:
			if(ball_pos.y < $CollisionShape2D.global_position.y):
				return true
		direcciones.abajo:
			if(ball_pos.y > $CollisionShape2D.global_position.y):
				return true
		direcciones.diagabd:
			if(ball_pos.y > $CollisionShape2D.global_position.y):
				if(ball_pos.x > $CollisionShape2D.global_position.x):
					return true
		direcciones.diagarrd:
			if(ball_pos.y < $CollisionShape2D.global_position.y):
				if(ball_pos.x > $CollisionShape2D.global_position.x):
					return true
		direcciones.diababi:
			if(ball_pos.y > $CollisionShape2D.global_position.y):
				if(ball_pos.x < $CollisionShape2D.global_position.x):
					return true
		direcciones.diabarri:
			if(ball_pos.y < $CollisionShape2D.global_position.y):
				if(ball_pos.x < $CollisionShape2D.global_position.x):
					return true
	return false

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
	
func _on_Area2D_body_entered(body):	
	if body != self:
		pass

func _on_Area2D_body_exited(body):
	pass

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
			


