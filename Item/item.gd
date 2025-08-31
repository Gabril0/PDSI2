extends Node
class_name Item

@export var i_name : String
@export var icon : Sprite2D
@export var description: String

func _init() -> void:
	print("please implement on floor exit")
	
func on_attack() -> void:
	pass
	
func on_projectile_end() -> void:
	pass

func on_process() -> void: # Happens every frame
	pass
	
func on_projectile_process() -> void:
	pass
	
func on_hit() -> void:
	pass

func on_die() -> void:
	pass

func on_floor_exit() -> void:
	pass

func activate() -> void:
	pass
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		var player : Player = body as Player
		player.add_item(self)
