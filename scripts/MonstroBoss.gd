# JumpingLandfallBoss.gd
class_name JumpingLandfallBoss
extends Entity

# --- Variáveis de Comportamento (Ajuste no Inspector) ---
@export var time_between_jumps: float = 3.0
@export var projectile_scene: PackedScene

@export_group("Pulo / Dash")
@export var jump_distance: float = 600.0
@export var jump_duration: float = 0.8
@export var jump_height: float = 150.0

@export var portrait_texture: Texture2D

@export_group("Ataque na Aterrisagem")
@export var nova_pellets: int = 8

# --- Referências de Nós (Arraste no Inspector) ---
@export var visuals_container: Node2D
@export var sprite: AnimatedSprite2D
@export var shadow: Sprite2D

# --- Controle Interno ---
var player_ref: Node2D
var is_acting: bool = false
@onready var action_timer: Timer = $ActionTimer
@onready var jump_timer: Timer = $JumpTimer # Adicione este Timer na cena!

enum State { IDLE, JUMPING } # Máquina de estados simplificada
var current_state = State.IDLE

signal boss_defeated

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	if not player_ref:
		print("ERRO: Jogador não encontrado.")
		queue_free()
		return
		
	action_timer.wait_time = time_between_jumps
	jump_timer.wait_time = jump_duration
	jump_timer.one_shot = true
	
	action_timer.timeout.connect(_start_jump_sequence)
	jump_timer.timeout.connect(_land) # Conecta o fim do pulo à aterrissagem
	
	action_timer.start()

func _physics_process(delta: float):
	# Apenas move o corpo se estiver no estado de pulo
	if current_state == State.JUMPING:
		var collision = move_and_collide(velocity * delta)
		if collision:
			# Se bater em algo, para o movimento imediatamente
			velocity = Vector2.ZERO

func _start_jump_sequence():
	if is_acting or not is_instance_valid(player_ref):
		return
		
	is_acting = true
	_execute_jump_and_attack()

func _execute_jump_and_attack():
	var direction = (player_ref.global_position - global_position).normalized()
	var target_position = global_position + direction * jump_distance
	
	# --- LÓGICA DE MOVIMENTO CORRIGIDA ---
	# 1. Calcula a velocidade necessária para chegar ao alvo na duração do pulo
	velocity = (target_position - global_position) / jump_duration
	current_state = State.JUMPING
	jump_timer.start()
	
	# --- ANIMAÇÃO CORRIGIDA ---
	# O tween visual acontece em paralelo ao movimento físico
	
	# Animação de Squash & Stretch e Arco do Pulo
	var original_scale = sprite.scale
	var squashed_scale = original_scale * Vector2(1.4, 0.6)
	var stretched_scale = original_scale * Vector2(0.7, 1.3)
	
	# CORREÇÃO: Removido o .set_loops()
	var anim_tween = create_tween()
	anim_tween.tween_property(sprite, "scale", squashed_scale, 0.2)
	anim_tween.tween_property(sprite, "scale", stretched_scale, jump_duration * 0.3)
	anim_tween.tween_property(sprite, "position:y", -jump_height, jump_duration * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	anim_tween.tween_property(sprite, "position:y", 0, jump_duration * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	anim_tween.tween_property(sprite, "scale", squashed_scale, 0.2).set_delay(jump_duration - 0.4)
	anim_tween.tween_property(sprite, "scale", original_scale, 0.2)
	
	# Animação da Sombra
	var shadow_tween = create_tween()
	shadow_tween.tween_property(shadow, "scale", Vector2.ZERO, jump_duration * 0.4)
	shadow_tween.tween_property(shadow, "scale", shadow.scale, jump_duration * 0.4).set_delay(jump_duration * 0.4)

func _land():
	# Chamado quando o jump_timer termina
	velocity = Vector2.ZERO
	current_state = State.IDLE
	
	_attack_nova_burst() # Ataca ao aterrissar
	
	is_acting = false
	action_timer.start() # Inicia o cooldown para o próximo pulo

func _attack_nova_burst():
	var angle_step = (2 * PI) / nova_pellets
	for i in range(nova_pellets):
		var angle = i * angle_step
		var direction = Vector2.from_angle(angle)
		_spawn_standard_projectile(direction)

func _spawn_standard_projectile(direction: Vector2):
	if projectile_scene == null: return
	var projectile: ProjectileBoss = projectile_scene.instantiate()
	projectile.init(
		projectile_speed, damage, attack_range,
		direction, "enemy", global_position,
		Vector2.ZERO, self
	)
	get_tree().root.add_child(projectile)

func apply_knockback(direction: Vector2) -> void: pass

func die() -> void:
	emit_signal("boss_defeated")
	super.die()

func get_portrait_texture() -> Texture2D:
	return portrait_texture
