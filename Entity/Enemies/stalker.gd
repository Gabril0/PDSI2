extends ObjectFollowBehaviour

@export var animation_player : AnimationPlayer

func _process(delta : float) -> void:
	super._process(delta)
	if follow_object && !can_move && !animation_player.current_animation.begins_with("Run"):
		animation_player.play("Transformation")
	if !follow_object && velocity == Vector2.ZERO: 
		animation_player.play("idle")
		can_move = false

func run() -> void:
	can_move = true
	animation_player.play("Run")
