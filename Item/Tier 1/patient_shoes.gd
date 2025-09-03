extends Item
@export var speed_increase = 300

func activate() -> void:
	player_ref.speed += speed_increase
