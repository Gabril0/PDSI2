class_name Enemy
extends Entity

var daeth_healing_radius : float  = 3

func _init() -> void:
	super._init()
	direction = Vector2.ZERO
	attackDirection = Vector2.ZERO
	
func die() -> void:
	super.die()
	var raycast: Raycast = Raycast.new()
	add_child(raycast)
	
	var hits : Array[Dictionary] = raycast.circle_cast(position, 3)
	for hit in hits:
		var collider : CollisionObject2D = hit.collider
		if collider.is_in_group("player"):
			print("continue here")
	
