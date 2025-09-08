
class_name DvdBoss
extends Entity # Ou CharacterBody2D se não estiver usando a classe Entity

@export var projectile_scene: PackedScene
@export var number_of_projectiles: int = 10
@export var attack_cooldown: float = 3.0

@export var portrait_texture: Texture2D


signal boss_defeated

# Agora aceita qualquer nó que herde de Node2D (incluindo Sprite2D e AnimatedSprite2D)
@export var visuals: Node2D

@onready var attack_timer: Timer = $AttackTimer # Você precisa adicionar um nó Timer na cena do chefe

var og_scale: Vector2

func _ready() -> void:
	# Ignora a lógica de "seguir" e define um movimento inicial aleatório
	var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	velocity = random_direction * speed
	
	# Pega a escala inicial do nó visual, seja ele qual for
	if visuals:
		og_scale = visuals.scale
		
	# Configura e inicia o timer para os ataques
	attack_timer.wait_time = attack_cooldown
	attack_timer.timeout.connect(attack)
	attack_timer.start()

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())

func attack() -> void:
	_do_attack_animation()
	
	if projectile_scene == null:
		print("Cena do projétil não definida!")
		return

	var angle_step = (2 * PI) / number_of_projectiles
	
	for i in range(number_of_projectiles):
		var angle = i * angle_step
		var direction_vector = Vector2.from_angle(angle)
		
		var p_instance = projectile_scene.instantiate()
		var projectile: ProjectileBoss = p_instance
		
		# AQUI ESTÁ A MUDANÇA PRINCIPAL:
		# Chamamos a função 'init' do projétil com os dados do chefe.
		projectile.init(
			projectile_speed,   # _speed
			damage,             # _damage
			attack_range,       # _range
			direction_vector,   # _direction
			"enemy",          # _ignore_group (para não acertar outros inimigos)
			global_position,    # pos (posição inicial)
			Vector2.ZERO,           # caster_velocity (para o momentum)
			self                # _caster (o próprio chefe)
		)
		
		get_tree().root.add_child(projectile)


func _do_attack_animation() -> void:
	if not visuals: return

	# O "await" foi removido daqui para que a animação rode em paralelo ao ataque
	var attack_indication_time = 1.0
	var tween = create_tween().set_parallel()
	
	# Anima a cor (modulate)
	tween.tween_property(visuals, "modulate", Color.RED, attack_indication_time * 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(visuals, "modulate", Color.WHITE, attack_indication_time * 0.5).set_delay(attack_indication_time * 0.5)
	
	# Anima a escala (efeito de "pulso")
	tween.tween_property(visuals, "scale", og_scale * 1.5, attack_indication_time * 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(visuals, "scale", og_scale, attack_indication_time * 0.5).set_delay(attack_indication_time * 0.5)

func die() -> void:
	Engine.time_scale = 0.2
	await get_tree().create_timer(2, true, false, true).timeout
	Engine.time_scale = 1.0
	LevelManager.go_to_next_level()
	super.die()

func get_portrait_texture() -> Texture2D:
	return portrait_texture
