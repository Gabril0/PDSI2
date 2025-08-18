extends Node2D

## Sinal emitido quando o jogador entra na área da porta.
## Passa a direção da porta para quem estiver ouvindo (o LevelManager).
signal player_entered(direction: Vector2i)

## A direção que esta porta representa. Será configurada pelo LevelManager.
@export var direction: Vector2i

@onready var fechada_sprite: Sprite2D = $fechada
@onready var area_entrar: Area2D = $area_entrar

func _ready() -> void:
	area_entrar.body_entered.connect(_on_body_entered)
	abrir() # A porta começa aberta por padrão
	# TODO
	# colocar logica para ficar fechada se houver inimigos e abrir ao matar todos

func _on_body_entered(body):
	# Se quem entrou é do grupo "player", emitimos nosso próprio sinal.
	if body.is_in_group("player"):
		print("Player entrou na porta para a direção: ", direction)
		emit_signal("player_entered", direction)

func fechar():
	fechada_sprite.visible = true
	area_entrar.monitoring = false # Impede que o sinal body_entered seja emitido.
	
func abrir():
	fechada_sprite.visible = false
	area_entrar.monitoring = true
