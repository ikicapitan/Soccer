extends KinematicBody2D

var Velocidad = Vector2()
var pos_actual

func _ready():
	pos_actual = global_position #Posicion actual de la bola al spawnear

func _physics_process(delta):
	if(Velocidad == Vector2(0,0)): #Si no hay velocidad en la pelota
		global_position = pos_actual #No la muevo por mas que haya alguna otra colision
	move_and_collide(Velocidad * delta)

func _on_AnimationPlayer_animation_finished(anim_name):
	Velocidad = Vector2(0,0) #Se termina la animacion, reseteo velocidad a 0
	pos_actual = global_position #Actualizo la posicion actual al terminar animacion

func mover(var vel):
	#d = v*t
	Velocidad = vel*3*get_node("AnimationPlayer").get_animation("mov_der").length
	if(vel.x > 0): #Si estoy yendo hacia derecha
		get_node("AnimationPlayer").play("mov_der")
	else:
		get_node("AnimationPlayer").play("mov_izq")