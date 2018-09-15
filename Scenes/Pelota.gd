extends KinematicBody2D

var Velocidad = Vector2()
export (float) var friccion

func _ready():
	pass
	#Velocidad.x = 15

func _physics_process(delta):
	move_and_collide(Velocidad * delta)

func _on_AnimationPlayer_animation_finished(anim_name):
	Velocidad = Vector2(0,0) #Se termina la animacion, reseteo velocidad a 0

func mover(var vel):
	Velocidad = vel
	if(vel.x > 0): #Si estoy yendo hacia derecha
		get_node("AnimationPlayer").play("mov_der")
	else:
		get_node("AnimationPlayer").play("mov_izq")