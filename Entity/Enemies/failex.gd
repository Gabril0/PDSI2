extends ObjectFollowBehaviour

func _ready() -> void:
	super._ready()

func _process(delta: float):
	super._process(delta)
	if follow_object:
		if global_position.distance_to(follow_object.global_position) < 50:
			#attack_target()
			pass
