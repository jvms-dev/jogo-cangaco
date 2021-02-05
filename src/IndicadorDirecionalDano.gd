extends Node2D

# Distância que a textura vai está em relação ao \
# centro da tela
var raio = -200


func _ready():
	var dimensoes_tela = get_viewport_rect().size
	position = dimensoes_tela / 2
	$Textura.position.y = raio
