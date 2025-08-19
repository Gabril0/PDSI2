extends Node
class_name Item

@export var i_name : String
@export var icon : Sprite2D
@export var description: String

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

func on_move() -> void:
	pass

func on_die() -> void:
	pass

func on_floor_exit() -> void:
	pass
	

func activate() -> void:
	# Restructure this:
	# You can have passive items for player and for projectiles
	# Items can happen at events, like on hit, on shoot, etc
	# all the itens effects should run on a behaviour stack
	
	# The player should have a behaviour loop and action calls
	pass
