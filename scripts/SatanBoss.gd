# SatanBoss.gd
class_name SatanBoss
extends Entity

# --- Variáveis de Comportamento ---
@export var time_between_attacks: float = 3.5
@export var projectile_scene: PackedScene

@export_group("Movimento")
# A velocidade base foi movida para cá para ser mais fácil de achar.
# A classe Entity já tem 'speed', mas podemos sobrescrever o valor aqui.
@export var move_speed: float = 120.0
@export var dash_speed: float = 1500.0
@export var dash_duration: float = 0.4

# --- Variáveis de Padrões de Ataque (Ajuste no Inspector) ---
@export_group("Padrão 1: Alternating")
@export var alt_repetitions: int = 6
@export var alt_tri_shot_spread: float = 20.0
@export var alt_v_shot_spread: float = 30.0
@export var alt_delay: float = 0.3

@export var portrait_texture: Texture2D

@export_group("Padrão 2: Converging Streams")
@export var stream_pellets: int = 25
@export var stream_start_angle: float = 60.0
@export var stream_end_angle: float = 5.0
@export var stream_delay: float = 0.04
@export var stream_final_shotgun_pellets: int = 8

@export_group("Padrão 3: Shotgun")
@export var shotgun_pellets: int = 12
@export var shotgun_spread: float = 45.0

@export_group("Padrão 4: Spiral")
@export var spiral_pellets_per_wave: int = 4 # Não mude, são 4 direções
@export var spiral_waves: int = 50
@export var spiral_rotation_speed: float = 0.1
@export var spiral_delay: float = 0.05

# --- Controle Interno ---
enum State { FOLLOWING, ATTACKING, DASHING }
var current_state = State.FOLLOWING

@export var visuals: Node2D
var player_ref: Node2D
@onready var action_timer: Timer = $ActionTimer
var attack_patterns: Array[Callable] = []

signal boss_defeated

func _ready() -> void:
	speed = move_speed # Define a velocidade de movimento
	player_ref = get_tree().get_first_node_in_group("player")
	if not player_ref:
		print("ERRO: Jogador não encontrado.")
		queue_free()
		return
		
	attack_patterns = [
		Callable(self, "_attack_alternating_bursts"),
		Callable(self, "_attack_converging_streams"),
		Callable(self, "_attack_shotgun"),
		Callable(self, "_attack_spiral"),
		Callable(self, "_attack_dash")
	]
	
	action_timer.wait_time = time_between_attacks
	action_timer.timeout.connect(_start_attack_sequence)
	action_timer.start()

func _physics_process(delta: float):
	# A lógica de movimento agora depende do estado
	match current_state:
		State.FOLLOWING:
			if is_instance_valid(player_ref):
				var direction = (player_ref.global_position - global_position).normalized()
				velocity = velocity.lerp(direction * speed, 0.1) # Suaviza o movimento
				move_and_slide()
		
		State.ATTACKING:
			velocity = Vector2.ZERO
			move_and_slide()
			
		State.DASHING:
			# Durante o dash, apenas movemos, sem mudar a velocidade
			move_and_slide()

func _start_attack_sequence():
	if current_state == State.ATTACKING or not is_instance_valid(player_ref):
		return
		
	current_state = State.ATTACKING
	
	var chosen_attack = attack_patterns.pick_random()
	await chosen_attack.call()
	
	# Após o ataque terminar, volta a perseguir e reinicia o timer
	current_state = State.FOLLOWING
	action_timer.start()

# --- Os 5 Padrões de Ataque ---

func _attack_alternating_bursts():
	for i in range(alt_repetitions):
		var dir_to_player = (player_ref.global_position - global_position).normalized()
		if i % 2 == 0: # Rajada de 3 tiros
			_spawn_projectile(dir_to_player)
			_spawn_projectile(dir_to_player.rotated(deg_to_rad(alt_tri_shot_spread)))
			_spawn_projectile(dir_to_player.rotated(deg_to_rad(-alt_tri_shot_spread)))
		else: # Rajada de 2 tiros (em V)
			_spawn_projectile(dir_to_player.rotated(deg_to_rad(alt_v_shot_spread)))
			_spawn_projectile(dir_to_player.rotated(deg_to_rad(-alt_v_shot_spread)))
		
		await get_tree().create_timer(alt_delay).timeout

func _attack_converging_streams():
	var dir_to_player = (player_ref.global_position - global_position).normalized()
	var base_angle = dir_to_player.angle()
	
	for i in range(stream_pellets):
		var progress = float(i) / stream_pellets
		var current_spread = lerp(deg_to_rad(stream_start_angle), deg_to_rad(stream_end_angle), progress)
		
		_spawn_projectile(Vector2.from_angle(base_angle + current_spread))
		_spawn_projectile(Vector2.from_angle(base_angle - current_spread))
		await get_tree().create_timer(stream_delay).timeout
		
	await get_tree().create_timer(0.3).timeout
	
	for i in range(stream_final_shotgun_pellets):
		var spread = deg_to_rad(shotgun_spread / 2)
		var random_angle = randf_range(-spread, spread)
		_spawn_projectile(dir_to_player.rotated(random_angle))

func _attack_shotgun():
	var dir_to_player = (player_ref.global_position - global_position).normalized()
	for i in range(shotgun_pellets):
		var spread = deg_to_rad(shotgun_spread / 2)
		var random_angle = randf_range(-spread, spread)
		_spawn_projectile(dir_to_player.rotated(random_angle))
	await get_tree().create_timer(0.5).timeout # Pequena pausa pós-ataque

func _attack_spiral():
	var base_angle = randf_range(0, PI)
	for i in range(spiral_waves):
		for j in range(spiral_pellets_per_wave):
			var angle = base_angle + (j * PI / 2) # Cria a forma de +
			_spawn_projectile(Vector2.from_angle(angle))
		
		base_angle += spiral_rotation_speed
		await get_tree().create_timer(spiral_delay).timeout

func _attack_dash():
	await get_tree().create_timer(0.3).timeout
	if not is_instance_valid(player_ref): return
	var direction = (player_ref.global_position - global_position).normalized()
	velocity = direction * dash_speed
	current_state = State.DASHING
	await get_tree().create_timer(dash_duration).timeout
	velocity = Vector2.ZERO

## auxiliares
func _spawn_projectile(direction: Vector2):
	if projectile_scene == null: return
	var projectile: ProjectileBoss = projectile_scene.instantiate()
	projectile.init(projectile_speed, damage, attack_range, direction, "enemy", global_position, Vector2.ZERO, self)
	get_tree().root.add_child(projectile)

func apply_knockback(direction: Vector2) -> void: pass


func die() -> void:
	Engine.time_scale = 0.2
	await get_tree().create_timer(2, true, false, true).timeout
	Engine.time_scale = 1.0
	LevelManager.end_run(true)
	super.die()

func get_portrait_texture() -> Texture2D:
	return portrait_texture
