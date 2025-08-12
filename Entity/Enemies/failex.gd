extends ObjectFollowBehaviour

func _process(delta: float):
	super._process(delta)
	if object:
		if global_position.distance_to(object.global_position) < 50:
			#attack_target()
			pass
