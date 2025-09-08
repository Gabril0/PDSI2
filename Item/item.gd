extends Resource #Avisar a rapaziada que trocou de item para resource pq ai todos os novos objetos item vão usar o mesmo modelo de script
class_name Item

@export var i_name : String
@export var description: String
@export var price: int
@export var icon : Texture2D

#@export var icon : Texture

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
