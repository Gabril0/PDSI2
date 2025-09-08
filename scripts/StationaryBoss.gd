class_name StationaryPatternBoss
extends Entity

@export var time_between_attacks: float = 4.0
@export var shot_indication_time: float = 1.0
@export var projectile_scene: PackedScene

@export_group("Padrão 1: Shotgun")
@export var shotgun_pellets: int = 5
@export var shotgun_spread_degrees: float = 30.0

@export_group("Padrão 2: Triple Nova")
@export var triple_nova_bursts: int = 3
@export var triple_nova_projectiles: int = 10
@export var triple_nova_delay: float = 0.3

@export var portrait_texture: Texture2D

@export_group("Padrão 3: Staggered Nova")
@export var staggered_nova_bursts: int = 6
@export var staggered_nova_projectiles: int = 10
@export var staggered_nova_delay: float = 0.7

@export_group("Padrão 4: Rapid Fire")
@export var rapid_fire_count: int = 40
@export var rapid_fire_delay: float = 0.05

@export var visuals: Node2D
var player_ref: Node2D
var is_attacking: bool = false
@onready var attack_timer: Timer = $ActionTimer
var attack_patterns: Array[Callable] = []

signal boss_defeated

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	if not player_ref:
		print("ERRO: Jogador não encontrado no grupo 'player'.")
		queue_free()
		return

	attack_patterns = [
		Callable(self, "_attack_shotgun"),
		Callable(self, "_attack_triple_nova"),
		Callable(self, "_attack_staggered_nova"),
		Callable(self, "_attack_rapid_fire")
	]
	
	attack_timer.wait_time = time_between_attacks
	attack_timer.timeout.connect(_start_attack_sequence)
	attack_timer.start()

func _start_attack_sequence():
	if is_attacking or not is_instance_valid(player_ref):
		return
		
	is_attacking = true

	_do_shot_animation()
	await get_tree().create_timer(shot_indication_time).timeout
	
	var chosen_attack = attack_patterns.pick_random()
	await chosen_attack.call()
	
	is_attacking = false

func _attack_shotgun():
	var direction_to_player = (player_ref.global_position - global_position).normalized()
	var base_angle = direction_to_player.angle()
	var spread_rad = deg_to_rad(shotgun_spread_degrees)
	var start_angle = base_angle - spread_rad / 2
	var angle_step = spread_rad / (shotgun_pellets - 1)

	for i in range(shotgun_pellets):
		var angle = start_angle + i * angle_step
		var direction = Vector2.from_angle(angle)
		_spawn_projectile(direction)

func _attack_triple_nova():
	var angle_step = (2 * PI) / triple_nova_projectiles
	for burst in range(triple_nova_bursts):
		for i in range(triple_nova_projectiles):
			var angle = i * angle_step
			var direction = Vector2.from_angle(angle)
			_spawn_projectile(direction)
		# Pausa curta entre as rajadas
		if burst < triple_nova_bursts - 1:
			await get_tree().create_timer(triple_nova_delay).timeout

func _attack_staggered_nova():
	var angle_step = (2 * PI) / staggered_nova_projectiles
	for burst in range(staggered_nova_bursts):
		for i in range(staggered_nova_projectiles):
			var angle = i * angle_step
			var direction = Vector2.from_angle(angle)
			_spawn_projectile(direction)
		# Pausa longa entre as rajadas
		if burst < staggered_nova_bursts - 1:
			await get_tree().create_timer(staggered_nova_delay).timeout

func _attack_rapid_fire():
	for i in range(rapid_fire_count):
		if not is_instance_valid(player_ref): break
		var direction = (player_ref.global_position - global_position).normalized()
		_spawn_projectile(direction)
		await get_tree().create_timer(rapid_fire_delay).timeout

func _spawn_projectile(direction: Vector2):
	if projectile_scene == null: return

	var projectile: ProjectileBoss = projectile_scene.instantiate()
	projectile.init(
		projectile_speed, damage, attack_range,
		direction, "enemy", global_position,
		Vector2.ZERO, self
	)
	get_tree().root.add_child(projectile)

func _do_shot_animation():
	if not visuals: return
	visuals.modulate = Color.WHITE
	var tween = create_tween()
	var original_scale = visuals.scale
	tween.tween_property(visuals, "scale", original_scale * 1.2, shot_indication_time * 0.5)
	tween.tween_property(visuals, "scale", original_scale, shot_indication_time * 0.5).set_delay(shot_indication_time * 0.5)

func apply_knockback(direction: Vector2) -> void:
	pass

func die() -> void:
	Engine.time_scale = 0.2
	await get_tree().create_timer(2, true, false, true).timeout
	Engine.time_scale = 1.0
	LevelManager.go_to_next_level()
	super.die()

func get_portrait_texture() -> Texture2D:
	return portrait_texture
