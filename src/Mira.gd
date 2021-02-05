extends Control


const PORCENTAGEM = 0.1

var raio_minimo = 5.0
var raio_maximo = 20.0
var raio:float = 5.0


func _process(_delta):
	raio = clamp(raio, raio_minimo, raio_maximo)
	raio = lerp(raio, raio_minimo, PORCENTAGEM)
	update()



func _draw():
	_circunferencia()
	_raios()


func _circunferencia(ar_posicao:Vector2=Vector2.ZERO, ar_cor:Color=Color.white, ar_espessura:int=2) -> void:
	var ar_qualidade = 2.4 * raio
	var pontos = PoolVector2Array()
	var angulo = deg2rad(360.0/ar_qualidade)

	for i in range(ar_qualidade + 1):
		pontos.push_back(ar_posicao + Vector2(cos(angulo * i), sin(angulo * i)) * raio)
	
	for index in range(ar_qualidade):
		draw_line(pontos[index], pontos[index + 1], ar_cor, ar_espessura)


func _raios(ar_tamanho:float=2.0, ar_espessura:int=2, ar_distancia:float=2.0, ar_cor:Color=Color.white):
	var posicoes = [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT]

	for i in range(4):
		var pos_inicial = posicoes[i] * raio * ar_distancia
		draw_line(pos_inicial, pos_inicial * ar_tamanho, ar_cor, ar_espessura)



