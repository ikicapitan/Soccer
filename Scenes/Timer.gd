extends Timer

var texto

func _ready():
	texto = get_tree().get_nodes_in_group("txt_tmr")[0]

func _on_Timer_timeout():
	gamehandler.clock()
	var tiempo2 = gamehandler.tiempo*gamehandler.duracion_st1/gamehandler.duracion_t1
	var minutos = tiempo2 / 60 #Divido los segundos para mostrar minutos
	minutos = int(minutos/5)
	minutos*= 5
	var segundos = tiempo2 % 60 #Obtengo el resto de division para mostrar segundos
	texto.text = (str(minutos) + ":" + "00") #Convierto a string los resultados para mostrar
