extends Resource #Avisar a rapaziada que trocou de item para resource pq ai todos os novos objetos item vão usar o mesmo modelo de script
class_name Item

@export var i_name : String = "Novo Item"
@export var description: String = "Descricao do item"
@export var price: int = 0 
@export var icon : Texture2D


func activate() -> void:
	pass
