extends KinematicBody2D

var Velocidad = Vector2()
var pos_actual #Posicion actual del balon
var dim_original #Dimension original del Sprite del balon
var dim_maxima #Dimension maxima que tomara el balon al patearse (pase)
var posl_o #Posicion original del balon local (cuando no hay pase)
var posl_m #Posicion que separa al balon de la sombra cuando hay pase (pos maxima)
var ult_toque = 0 #Que equipo toco ultimo el balon
var target #Que jugador la tiene actualmente
export (float) var vel_pas #Velocidad de pase
export (float) var vel_shoot #Velocidad de disparo
export (float) var vel_saq #Velocidad de saque manos
export (float) var vel_corner #Velocidad de corner
export (float) var vel_arq #Velocidad saque arco

var pase = false
var shoot = false #Patear

export (float) var vel_z #A que velocidad se eleva


func _ready():
	posl_o = $Sprite.position
	posl_m = posl_o * -2
	dim_original = $Sprite.scale #Guardo la dimension de cuando esta en el suelo
	dim_maxima = dim_original * 1.5
	pos_actual = global_position #Posicion actual de la bola al spawnear

###########FUNCION UPDATE##############
func _physics_process(delta):
	if(Velocidad == Vector2(0,0)): #Si no hay velocidad en la pelota
		global_position = pos_actual #No la muevo por mas que haya alguna otra colision
	
	var obj_colisionado = move_and_collide(Velocidad * delta)
	
	if(obj_colisionado != null && obj_colisionado.collider.is_in_group("arquero") && target == null):
		if(abs(get_node("CollisionShape2D").position.distance_to(obj_colisionado.collider.get_node("CollisionShape2D").position)) < 4): #Si estan proximos la pelota y el jugador
			#Atajar	
			gamehandler.saque_arco()
			target = obj_colisionado.collider
			
			target.get_node("AnimationPlayer").play("at_der")
			if(gamehandler.pelota.global_position.x < 0):
				target.direccion = target.direcciones.derecha
			else:
				target.direccion = target.direcciones.izquierda
			#target = null
			
			yield(get_tree().create_timer(1.5), "timeout") #Espero 1 segundo
	
	if(pase): #Si esta en proceso de pase (fue pateado para un pase)
		pase(delta)
	elif(shoot):
		patear(delta)

###########FUNCION DE PATEAR##############
func patear(delta):
	if(get_node("AnimationPlayer").current_animation_position <= get_node("AnimationPlayer").get_animation("anim_airder").length / 3):
		$Sprite.scale+= delta * dim_maxima/3 / (get_node("AnimationPlayer").get_animation("anim_airder").length / 2)
		$Sprite.position+= delta * posl_m /3/ (get_node("AnimationPlayer").get_animation("anim_airder").length / 3)
	elif(get_node("AnimationPlayer").current_animation_position <= (get_node("AnimationPlayer").get_animation("anim_airder").length / 3)*2):
		pass
		#$Sprite.position-= delta * posl_m / (get_node("AnimationPlayer").get_animation("anim_airder").length / 3)
	else:
		$Sprite.scale-= delta * dim_maxima/3 / (get_node("AnimationPlayer").get_animation("anim_airder").length / 2)
		$Sprite.position-= delta * posl_m /3/ (get_node("AnimationPlayer").get_animation("anim_airder").length / 3)


###########FUNCION DE PASE##############
func pase(delta):
	if(get_node("AnimationPlayer").current_animation_position <= get_node("AnimationPlayer").get_animation("anim_airder").length / 3):
		$Sprite.scale+= delta * dim_maxima / (get_node("AnimationPlayer").get_animation("anim_airder").length / 2)
		$Sprite.position+= delta * posl_m / (get_node("AnimationPlayer").get_animation("anim_airder").length / 3)
	elif(get_node("AnimationPlayer").current_animation_position <= (get_node("AnimationPlayer").get_animation("anim_airder").length / 3)*2):
		pass
		#$Sprite.position-= delta * posl_m / (get_node("AnimationPlayer").get_animation("anim_airder").length / 3)
	else:
		$Sprite.scale-= delta * dim_maxima / (get_node("AnimationPlayer").get_animation("anim_airder").length / 2)
		$Sprite.position-= delta * posl_m / (get_node("AnimationPlayer").get_animation("anim_airder").length / 3)
	
	if($Sprite.scale > dim_original + dim_maxima / 3): #Al alcanzar cierta altura deshabilito el colisionador de la bola
		excepciones(true) #Agrega excepcion de colision con los player
	else:
		excepciones(false) #Quita la excepcion de colision con los player
		
		
func excepciones(valor): #Agrega o quita excepcion colision de pelota con players
	var jugadores = get_tree().get_nodes_in_group("player")
	if(valor):
		for j in jugadores:
			add_collision_exception_with(j)
	else:
		for j in jugadores:
			remove_collision_exception_with(j)	
			
		


###########FUNCION DE MOVIMIENTO##############
func mover(vel):
	#d = v*t
	
	if(!pase && !shoot):
		Velocidad = vel*3*get_node("AnimationPlayer").get_animation("mov_der").length

	if(!pase && !shoot):
		if(vel.x > 0): #Si estoy yendo hacia derecha
			get_node("AnimationPlayer").play("mov_der")
		else:
			get_node("AnimationPlayer").play("mov_izq")
	else:
		if(vel.x > 0): #Si estoy yendo hacia derecha
			get_node("AnimationPlayer").play("anim_airder")
		else:
			get_node("AnimationPlayer").play("anim_airizq")
			

func _on_AnimationPlayer_animation_finished(anim_name):
	Velocidad = Vector2(0,0) #Se termina la animacion, reseteo velocidad a 0
	pos_actual = global_position #Actualizo la posicion actual al terminar animacion
	pase = false
	shoot = false
	$Sprite.scale = dim_original
	$Sprite.position = posl_o
	