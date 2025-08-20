# RoomInfo.gd
class_name RoomInfo
extends Node

# Enum é melhor que strings para evitar erros de digitação
enum RoomType { NORMAL, BOSS, SHOP, ITEM, START }

@onready var porta_cima: Marker2D = $"../ConnectionPoints/Porta_Cima"
@onready var porta_baixo: Marker2D = $"../ConnectionPoints/Porta_Baixo"
@onready var porta_esquerda: Marker2D = $"../ConnectionPoints/Porta_Esquerda"
@onready var porta_direita: Marker2D = $"../ConnectionPoints/Porta_Direita"
@export var doors: Array[Marker2D]
@export var enemy_spawns: Array[Marker2D]
@export var room_type: RoomType = RoomType.NORMAL

# Essas variáveis serão preenchidas pelo LevelManager
var room_level: int = 1
var is_visited: bool = false
var is_cleared: bool = false

func _ready():
	# Salas especiais só podem ter uma porta, por regra.
	if room_type != RoomType.NORMAL and doors.size() > 1:
		push_warning("Salas especiais (Boss, Shop, etc.) devem ter apenas UMA porta.")

# Chamado quando o jogador entra na sala
func on_player_enter():
	if is_visited or is_cleared:
		return
	is_visited = true
	print("Jogador entrou na sala! Spawning inimigos de nível ", room_level)
	# Lógica para instanciar inimigos aqui
	# for spawn_point in enemy_spawns:
	#    var enemy = enemy_scene.instantiate()
	#    enemy.global_position = spawn_point.global_position
	#    add_child(enemy)

# Chamado quando todos os inimigos da sala são derrotados
func on_enemies_cleared():
	is_cleared = true
	print("Sala conquistada!")
	# Lógica para abrir portas trancadas, dar recompensas, etc.
