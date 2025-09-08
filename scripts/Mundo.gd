
extends Node2D

@onready var mapa_container: Node2D = $MapaContainer
@onready var player: CharacterBody2D = $Player

func _ready():
	LevelManager.level_number = 0
	LevelManager.generate_level(mapa_container, player)

func _input(event):
	# Para testar, gerar um novo level com a tecla "Enter
	if event.is_action_pressed("ui_text_submit"): # Enter
		LevelManager.generate_level(mapa_container, player)
	# Para testar, vai para o próximo level com "]"
	if event.is_action_pressed("Next_Level"):
		LevelManager.go_to_next_level()
