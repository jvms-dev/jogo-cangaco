extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $MeshInstance2/RayCast.is_colliding():
		$MeshInstance2/RayCast.get_collider().direcao_dano($MeshInstance2/RayCast.get_collision_point())
	
	if $MeshInstance3/RayCast.is_colliding():
		$MeshInstance3/RayCast.get_collider().direcao_dano($MeshInstance3/RayCast.get_collision_point())
	
	if $MeshInstance4/RayCast.is_colliding():
		$MeshInstance4/RayCast.get_collider().direcao_dano($MeshInstance4/RayCast.get_collision_point())
