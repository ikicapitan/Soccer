extends KinematicBody2D

var Velocidad = Vector2() #Velocidad actual de desplazamiento
export (float) var vel_desp
export (float) var vel_desp_b
enum direcciones {izquierda, derecha, arriba, abajo, diagabd,diagarrd, diababi, diabarri}
var direccion = derecha
var t_pelota #Si tiene o no pelota en pie
var target_z #Si colisiono con otra area de otro jugador

var moviendo = false;

var teclas = [false, false, false, false, false] #teclas[0] arriba, 1 abajo, 2 izquierda, 3 derecha, 4 patear

func _ready():
	pass

func _physics_process(delta):
	procesar_teclas()
	procesar_movimiento(delta)
	if(target_z):
		check_z()
	
		
func procesar_teclas():
	
	if(teclas[4] && !moviendo): #Si patea
		Velocidad = Vector2(0,0)
		moviendo = true
		patear()
	elif(teclas[3] && !moviendo): #Si va hacia la derecha
		if(teclas[0]): #Si ademas va hacia arriba (SERIA DIAGONAL ARRIBA)
			Velocidad = Vector2(vel_desp/get_node("AnimationPlayer").get_animation("diarr").length, -vel_desp/get_node("AnimationPlayer").get_animation("diarr").length)
			get_node("AnimationPlayer").call_deferred("play","diarr")
			get_node("Sprite").flip_h = false
			direccion = diagarrd
			moviendo = true
		elif(teclas[1]): #Sino si ademas es abajo y derecha (DIAG ABAJO DERECHA)
			Velocidad = Vector2(vel_desp/get_node("AnimationPlayer").get_animation("diaba").length, vel_desp/get_node("AnimationPlayer").get_animation("diaba").length)
			get_node("AnimationPlayer").call_deferred("play","diaba")
			get_node("Sprite").flip_h = false
			direccion = diagabd
			moviendo = true
		else: #Si no va hacia arriba o abajo adicionalmente, entonces solo es derecha
			Velocidad = Vector2(vel_desp/get_node("AnimationPlayer").get_animation("der").length, 0)
			get_node("AnimationPlayer").call_deferred("play","der")
			direccion = derecha
			get_node("Sprite").flip_h = false
			moviendo = true
	elif(teclas[2] && !moviendo): #Si izquierda
		if(teclas[0]): #Si ademas arriba
			Velocidad = Vector2(-vel_desp/get_node("AnimationPlayer").get_animation("diarr").length, -vel_desp/get_node("AnimationPlayer").get_animation("diarr").length)
			get_node("AnimationPlayer").call_deferred("play","diarr")
			get_node("Sprite").flip_h = true
			direccion = diabarri
			moviendo = true
		elif(teclas[1]): #Si ademas abajo
			Velocidad = Vector2(-vel_desp/get_node("AnimationPlayer").get_animation("diaba").length, vel_desp/get_node("AnimationPlayer").get_animation("diaba").length)
			get_node("AnimationPlayer").call_deferred("play","diaba")
			get_node("Sprite").flip_h = true
			direccion = diababi
			moviendo = true
		else:
			Velocidad = Vector2(-vel_desp/get_node("AnimationPlayer").get_animation("der").length, 0)
			get_node("AnimationPlayer").call_deferred("play","der")
			direccion = izquierda
			get_node("Sprite").flip_h = true
			moviendo = true
	elif(teclas[0] && !moviendo):
		Velocidad = Vector2(0, -vel_desp/get_node("AnimationPlayer").get_animation("Arr").length)
		get_node("AnimationPlayer").call_deferred("play","Arr")
		direccion = arriba
		moviendo = true
	elif(teclas[1] && !moviendo):
		Velocidad = Vector2(0, vel_desp/get_node("AnimationPlayer").get_animation("Aba").length)
		get_node("AnimationPlayer").call_deferred("play","Aba")
		direccion = abajo
		moviendo = true
	

func procesar_movimiento(var delta_t):
	if(moviendo):
		var obj_colisionado = move_and_collide(Velocidad * delta_t)
		if(t_pelota != null && !t_pelota.get_node("AnimationPlayer").is_playing()): #Tengo pelota en pie
			t_pelota.mover(Velocidad*get_node("AnimationPlayer").get_animation("Aba").length)
			t_pelota = null #Suelto la pelota
			var vel_provis = Velocidad
			Velocidad /= 4
			yield(get_tree().create_timer(1.5), "timeout") #Espero 1 segundo
			Velocidad = vel_provis
			
		if(obj_colisionado != null && obj_colisionado.collider.is_in_group("pelota")):
			if(!get_node("AnimationPlayer").is_playing() && !obj_colisionado.collider.get_node("AnimationPlayer").is_playing()):
				t_pelota = obj_colisionado.collider #Asigno pelota como target
		else:
			t_pelota = null #Borrar target
			
func restaurar_velocidad():
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	moviendo = false
	Velocidad = Vector2(0,0)
	
func patear():
	match direccion:
		derecha:
			get_node("AnimationPlayer").call_deferred("play","pateard")
		izquierda:
			get_node("AnimationPlayer").call_deferred("play","pateard")
		arriba:
			get_node("AnimationPlayer").call_deferred("play","pateararr")
		abajo:
			get_node("AnimationPlayer").call_deferred("play","patearabaj")
		diagabd:
			get_node("AnimationPlayer").call_deferred("play","pateardaba")
		diagarrd:
			get_node("AnimationPlayer").call_deferred("play","pateardarr")
		diababi:
			get_node("AnimationPlayer").call_deferred("play","pateardaba")
		diabarri:
			get_node("AnimationPlayer").call_deferred("play","pateardarr")
			
	yield(get_tree().create_timer(0.5), "timeout")
	
	match direccion:
		derecha:
			get_node("AnimationPlayer").play("der")
		izquierda:
			get_node("AnimationPlayer").play("der")
		arriba:
			get_node("AnimationPlayer").play("Arr")
		abajo:
			get_node("AnimationPlayer").play("Aba")
		diagabd:
			get_node("AnimationPlayer").play("diaba")
		diagarrd:
			get_node("AnimationPlayer").play("diarr")
		diababi:
			get_node("AnimationPlayer").play("diaba")
		diabarri:
			get_node("AnimationPlayer").play("diarr")
	
func _on_Area2D_body_entered(body):	
	if body != self:
		target_z = body

func check_z():
	if(get_node("CollisionShape2D").global_position.y > target_z.get_node("CollisionShape2D").global_position.y):
		get_node("Sprite").z_index = 1
		target_z.get_node("Sprite").z_index = 0
	else:
		target_z.get_node("Sprite").z_index = 1
		get_node("Sprite").z_index = 0


func _on_Area2D_body_exited(body):
	target_z = null
	get_node("Sprite").z_index = 0
	body.get_node("Sprite").z_index = 0
