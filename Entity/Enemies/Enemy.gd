class_name Enemy
extends Entity

var death_healing_radius : float  = 3

func _init() -> void:
	super._init()
	direction = Vector2.ZERO
	attackDirection = Vector2.ZERO
	
func die() -> void:	
	var raycast: Raycast = Raycast.new()
	add_child(raycast)
	
	var hits : Array[Dictionary] = raycast.circle_cast(position, death_healing_radius)
	for hit in hits:
		var collider : CollisionObject2D = hit.collider
		if collider.is_in_group("player"):
			var player : Player = collider as Player
			player.health += death_healing_radius - (position - player.position).length()
	super.die()
