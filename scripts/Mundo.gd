
extends Node2D

@onready var mapa_container: Node2D = $MapaContainer
@onready var player: CharacterBody2D = $Player

func _ready():
	LevelManager.generate_level(mapa_container, player)

func _input(event):
	# Para testar, gerar um novo level com a tecla R
	if event.is_action_pressed("ui_text_submit"): # Enter
		LevelManager.generate_level(mapa_container, player)
