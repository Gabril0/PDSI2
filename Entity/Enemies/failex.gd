extends ObjectFollowBehaviour

@export var portrait_texture: Texture2D

func _ready() -> void:
	super._ready()

func _process(delta: float):
	super._process(delta)
	if follow_object:
		pass

func get_portrait_texture() -> Texture2D:
	return portrait_texture
