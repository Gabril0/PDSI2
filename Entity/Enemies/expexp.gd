extends ObjectFollowBehaviour

@export var explosion_radius : float = 500
@export var explosion_damage : float = 30

func die() -> void:
	
	await get_tree().create_timer(2).timeout
	var explosion_raycast: Raycast = Raycast.new()
	add_child(explosion_raycast)
	explosion_raycast.visualization_color = Color(1,0,0,0.5)
	var hits : Array[Dictionary] = explosion_raycast.circle_cast(position, explosion_radius )
	
	for hit in hits:
		var collider : CollisionObject2D = hit.collider
		if collider.is_in_group("player"):
			var player : Player = collider as Player
			player.take_damage(explosion_damage, self)
			
	super.die()
	
