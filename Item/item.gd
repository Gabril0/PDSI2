extends Node
class_name Item

@export var i_name : String
@export var icon : Texture
@export var description: String

var player_ref : Player

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
