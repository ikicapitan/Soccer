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
var momento_saque = false

var moviendo = false;

var teclas = [false, false, false, false, false, false] #teclas[0] arriba, 1 abajo, 2 izquierda, 3 derecha, 4 patear, 5 pase

func _ready():
	pass

func _physics_process(delta):
	
	if(!IA && !gamehandler.saque_arco):
		procesar_teclas()
		
	if(gamehandler.saque_arco):
		if(IA):
			pass
		else:
			procesar_movimiento_saque(delta)
		
	procesar_movimiento(delta)
	
	if(IA):
		
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

				moviendo = true
			else:
				path.remove(0) #Si alcanzamos removemos el nodo path para chequear el proximo
				get_node("AnimationPlayer").play("idle")
				Velocidad = Vector2(0,0)
			
		else:
			if(!momento_saque):
				momento_saque = true
				
				$AnimationPlayer.play("lat_arrm")
				get_tree().get_nodes_in_group("pelota")[0].pos_actual = $pelota_lateral.global_position
				get_tree().get_nodes_in_group("pelota")[0].global_position = $pelota_lateral.global_position
				$Sprite.flip_h = false				
				
				if(!IA):
					if(team == 1):
						gamehandler.target_j1 = self
					else:
						gamehandler.target_j2 = self
	
func procesar_teclas():	
	
	if(teclas[3] && !moviendo): #Si va hacia la derecha
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
	if(gamehandler.pelota.target == self):
		if((teclas[4] || teclas[5])): #Si patea o pasa
			var vel_patear = gamehandler.pelota.vel_arq
			if(direccion == direcciones.derecha):
				$AnimationPlayer.play("pateard")
				gamehandler.pelota.Velocidad = Vector2(vel_patear,0)
			elif(direccion == direcciones.izquierda):
				$AnimationPlayer.play("pateard")
				gamehandler.pelota.Velocidad = Vector2(-vel_patear,0)
			elif(direccion == direcciones.arriba):
				$AnimationPlayer.play("pateard")
				gamehandler.pelota.Velocidad = Vector2(vel_patear,-vel_patear/2)
			elif(direccion == direcciones.abajo):
				$AnimationPlayer.play("pateard")
				gamehandler.pelota.Velocidad = Vector2(vel_patear,-vel_patear/2)
					
			gamehandler.pelota.pase = true
			gamehandler.pelota.target = null
			gamehandler.pelota.get_node("AnimationPlayer").stop()
			gamehandler.pelota.mover(Velocidad*get_node("AnimationPlayer").get_animation("Aba").length)
			gamehandler.fin_saque_arco()
			yield(get_tree().create_timer(0.3),"timeout")
			get_node("AnimationPlayer").play("der")
			momento_saque = false
			gamehandler.instancia_lateral = false
		if(teclas[3] && !moviendo && gamehandler): #Si va hacia la izq
			direccion = direcciones.izquierda
			if(global_position.x < 0):
				$AnimationPlayer.play("at_der")
				$Sprite.flip_h = false
		elif(teclas[2] && !moviendo): #Si der
			direccion = direcciones.derecha
			if(global_position.x > 0):
				$AnimationPlayer.play("at_der")
				$Sprite.flip_h = true
		elif(teclas[1] && !moviendo):
			direccion = direcciones.abajo
			$AnimationPlayer.play("at_ab")
			if(global_position.x < 0):
				$Sprite.flip_h = false
			else:
				$Sprite.flip_h = true
		elif(teclas[0] && !moviendo): 
			direccion = direcciones.arriba
			$AnimationPlayer.play("at_arr")
			if(global_position.x < 0):
				$Sprite.flip_h = false
			else:
				$Sprite.flip_h = true		


func procesar_movimiento(var delta_t):
	
	if(moviendo):
		var obj_colisionado = move_and_collide(Velocidad * delta_t)
		if(gamehandler.pelota.target == self && !gamehandler.pelota.get_node("AnimationPlayer").is_playing() && !gamehandler.pelota.pase): #Tengo pelota en pie
			if(abs($CollisionShape2D.position.distance_to(gamehandler.pelota.get_node("CollisionShape2D").position)) < 4): #Si estan proximos la pelota y el jugador
					#Atajar
					
					gamehandler.pelota.target = self
					gamehandler.saque_arco()
					$AnimationPlayer.play("at_der")
					if(gamehandler.pelota.global_position.x < 0):
						direccion = direcciones.derecha
					else:
						direccion = direcciones.izquierda
					gamehandler.pelota.target = null
					yield(get_tree().create_timer(1.5), "timeout") #Espero 1 segundo
			else:
				gamehandler.pelota.target = null
				
			
		if(obj_colisionado != null && obj_colisionado.collider.is_in_group("pelota")):
			gamehandler.pelota.target = self #Asigno pelota como target
			gamehandler.pelota.ult_toque = team
				
func restaurar_velocidad():
	pass
	

func _on_AnimationPlayer_animation_finished(anim_name):
	moviendo = false
	Velocidad = Vector2(0,0)
	
	
func _on_Area2D_body_entered(body):	
	if body != self:
		pass

func _on_Area2D_body_exited(body):
	pass

func create_path(): #Crea el camino a tal punto
	var nav = get_tree().get_nodes_in_group("nav")[0] #Obtengo el nodo navigation2D
	path = nav.get_simple_path(position, target.position, false) #Genero el camino

func volver_spawn():
	target = p_spawn
	create_path()

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
			
func festejar_gol():
	pass
	
func regreso_half(lista_j):
	for j in lista_j:
		add_collision_exception_with(j)
	add_collision_exception_with(gamehandler.pelota)
	
func fin_regreso(lista_j):
	for j in lista_j:
		remove_collision_exception_with(j)
	remove_collision_exception_with(gamehandler.pelota)