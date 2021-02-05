extends Control


onready var texturas = [
							$TextureRect,
							$TextureRect2,
							$TextureRect3,
							$TextureRect4,
							$TextureRect5]
var valor:float = 0.0


func _ready():
	
	for i in range(texturas.size()):
		texturas[i].hide()
	texturas[0].show()
