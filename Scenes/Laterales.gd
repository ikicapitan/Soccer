extends Node2D

var punto_salida


func _ready():
	pass

func _on_Area2D_body_entered(body): #Sup
	if(body.is_in_group("pelota")):
		lateral_inicio(body, 0)
		
func _on_Area2D2_body_entered(body): #Inf
	if(body.is_in_group("pelota")):
		lateral_inicio(body, 1)

func _on_Area2D3_body_entered(body): #Izq
	if(body.is_in_group("pelota")):
		lateral_inicio(body, 2)

func _on_Area2D4_body_entered(body): #Der
	if(body.is_in_group("pelota")):
		lateral_inicio(body, 3)

func lateral_inicio(body, tipo):
	#body.excepciones(true)
	#body.get_node("CollisionShape2D").call_deferred("disabled",true)
	gamehandler.equipo_lateral = body.ult_toque
	punto_salida = body
	var jugadores = get_tree().get_nodes_in_group("player")
	var jmas_cercano = jugadores[0]
	for j in jugadores:
		j.exception_eq(true)
		if(jmas_cercano.team == gamehandler.equipo_lateral):
			if(j.team != gamehandler.equipo_lateral):
				jmas_cercano = j
		
		if(j.team != gamehandler.equipo_lateral):
			if(abs(j.global_position.x - punto_salida.global_position.x) + abs(j.global_position.y - punto_salida.global_position.y)) < (abs(jmas_cercano.global_position.x - punto_salida.global_position.x) + abs(jmas_cercano.global_position.y - punto_salida.global_position.y)): 
				jmas_cercano = j
	jmas_cercano.target = punto_salida
	gamehandler.pelota.target = jmas_cercano
	jmas_cercano.en_lateral = true
	if(tipo != 1): #Si no es del tipo 1, es porque es lateral arriba o costados
		jmas_cercano.create_path()
	elif(tipo == 0): #Hacia abajo
		jmas_cercano.lateral_path()
	#jmas_cercano.get_node("CollisionShape2D").call_deferred("disabled",true)
	gamehandler.tipo_lateral = tipo
	
func activar_desactivar_areas():
	var jugadores = get_tree().get_nodes_in_group("player")
	for j in jugadores:
		j.exception_eq(false)
	$AreaA/CollisionShape2D.disabled = true
	$AreaD/CollisionShape2D.disabled = true
	$AreaD/CollisionShape2D2.disabled = true
	$AreaI/CollisionShape2D.disabled = true
	$AreaI/CollisionShape2D2.disabled = true
	$AreaS/CollisionShape2D.disabled = true
	yield(get_tree().create_timer(2.0),"timeout")
	$AreaA/CollisionShape2D.disabled = false
	$AreaD/CollisionShape2D.disabled = false
	$AreaD/CollisionShape2D2.disabled = false
	$AreaI/CollisionShape2D.disabled = false
	$AreaI/CollisionShape2D2.disabled = false
	$AreaS/CollisionShape2D.disabled = false
	
	
	