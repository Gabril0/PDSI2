# ChargingBouncingBoss.gd
class_name SlideBoss
extends Entity

# --- Variáveis de Comportamento (Ajuste no Inspector) ---
@export var charge_speed: float = 800.0
@export var charge_duration: float = 5.0       # Quanto tempo ele fica quicando
@export var time_between_charges: float = 3.0  # Tempo parado entre as investidas
@export var charge_indication_time: float = 1.0

@export var portrait_texture: Texture2D


# --- Máquina de Estados Simplificada ---
enum State { IDLE, AIMING_CHARGE, CHARGING }
var current_state = State.IDLE

# --- Referências ---
@export var visuals: Node2D
var player_ref: Node2D
var charge_direction: Vector2

# --- Timers (Ambos ainda são usados) ---
@onready var action_timer: Timer = $ActionTimer # Renomeado mentalmente para CooldownTimer
@onready var charge_timer: Timer = $ChargeTimer # Controla a duração do dash

# --- Sinal de Morte ---
signal boss_defeated

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	if not player_ref:
		print("ERRO: Jogador não encontrado no grupo 'player'.")
		queue_free()
		return
		
	action_timer.wait_time = time_between_charges
	charge_timer.wait_time = charge_duration
	
	action_timer.timeout.connect(_prepare_to_charge)
	charge_timer.timeout.connect(_stop_charge)
	
	# Inicia o ciclo de ações
	action_timer.start()

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE or State.AIMING_CHARGE:
			velocity = Vector2.ZERO # Fica parado
			
		State.CHARGING:
			# --- INÍCIO DA LÓGICA DE DESACELERAÇÃO ---
			
			# 1. Calcula o progresso do charge (de 0.0 no início a 1.0 no fim)
			var charge_progress = (charge_timer.wait_time - charge_timer.time_left) / charge_timer.wait_time
			
			# 2. Usa lerp() para calcular a velocidade atual baseada no progresso
			# A velocidade vai de 'charge_speed' (no início) para 0.0 (no fim)
			var current_speed = lerp(charge_speed, 0.0, charge_progress)
			
			# 3. Atualiza a velocidade, mantendo a direção atual mas com a nova magnitude
			velocity = velocity.normalized() * current_speed
			
			# --- FIM DA LÓGICA DE DESACELERAÇÃO ---

			# Lógica de movimento e quique (continua a mesma)
			var collision = move_and_collide(velocity * delta)
			if collision:
				velocity = velocity.bounce(collision.get_normal())

# --- Funções de Controle de Estado ---

func _prepare_to_charge():
	if not is_instance_valid(player_ref): return

	current_state = State.AIMING_CHARGE
	# Captura a direção do jogador UMA VEZ
	charge_direction = (player_ref.global_position - global_position).normalized()
	_do_charge_animation()
	
	# Após a animação, inicia a carga
	await get_tree().create_timer(charge_indication_time).timeout
	_start_charge()

func _start_charge():
	current_state = State.CHARGING
	velocity = charge_direction * charge_speed
	charge_timer.start()

func _stop_charge():
	# Quando o tempo de carga termina, ele para e espera o próximo ciclo
	current_state = State.IDLE
	action_timer.start()

# --- Função de Animação ---

func _do_charge_animation():
	if not visuals: return
	visuals.modulate = Color.ORANGE
	var tween = create_tween()
	var original_scale = visuals.scale
	tween.tween_property(visuals, "scale", original_scale * Vector2(0.5, 1.5), charge_indication_time * 0.7)
	tween.tween_property(visuals, "scale", original_scale, charge_indication_time * 0.3)
	
# --- Funções de Imunidade e Morte ---

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
