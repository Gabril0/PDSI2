class_name Entity
extends CharacterBody2D

# Base stats 
@export var health : int = 100
@export var damage : int = 10
@export var attack_range : float = 50.0
@export var attack_speed : float = 1.0
@export var speed : float = 200.0
@export var projectile_speed : float = 800.0

var max_health : int

# Movement properties
@export var friction_force : float = 0.05
@export var acceleration_force : float = 0.1
@export var hit_particles : PackedScene
@export var death_particles : PackedScene

# Knockback properties
var knockback_vector: Vector2 = Vector2.ZERO
@export var knockback_strength: float = 50000.0
@export var knockback_friction: float = 5.0

var direction : Vector2
var attackDirection : Vector2

# Control flag
var can_move: bool = true

func _init() -> void:
	direction = Vector2.ZERO
	attackDirection = Vector2.ZERO
	max_health = health

func move(delta: float) -> void:
	
	var friction: float = velocity.length() * friction_force
	var acceleration: float = speed * acceleration_force
	if can_move:
		if direction != Vector2.ZERO:
			velocity += direction.normalized() * acceleration * delta
			if velocity.length() > speed:
				velocity = velocity.normalized() * speed
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction)


	move_and_slide()



func take_damage(ammount: int, attacker: Node2D) -> void:
	health -= ammount
	var knockback_dir = (global_position - attacker.global_position).normalized()
	
	apply_knockback(knockback_dir)
	
	hit_effect()
	
	if health <= 0:
		die()


func apply_knockback(direction: Vector2) -> void:
	can_move = false
	var knockback_velocity = direction * knockback_strength
	var duration := 0.25
	var elapsed := 0.0
	
	while elapsed < duration:
		var delta = get_process_delta_time()
		elapsed += delta
		velocity += (knockback_velocity * delta) *( 1 - (elapsed/duration))
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		
		move_and_slide()
		await get_tree().process_frame
	
	can_move = true

func hit_effect() -> void:
	var sprites : Array[Sprite2D] = get_all_sprite2d_children(self)

	for sprite in sprites:
		sprite.modulate = Color(1, 0, 0)
		
	var original_positions = {}
	for sprite in sprites:
		original_positions[sprite] = sprite.position
		
	var timer = 0.0
	var duration = 0.1
	var direction = -1
	
	while timer < duration:
		var delta = get_process_delta_time()
		timer += delta
		
		for sprite in sprites:
			sprite.position.x = original_positions[sprite].x + direction * 5
		
		await get_tree().process_frame

		if int(timer / 0.025) % 2 == 1:
			direction = 1
		else:
			direction = -1

	for sprite in sprites:
		sprite.modulate = Color(1, 1, 1)
		sprite.position = original_positions[sprite]
		
	if hit_particles:
		var particles: CPUParticles2D = hit_particles.instantiate()
		particles.emitting = true
		add_child(particles)

func get_all_sprite2d_children(parent_node) -> Array[Sprite2D]:
	var sprites : Array[Sprite2D] = []
	for child in parent_node.get_children():
		if child is Sprite2D:
			sprites.append(child)
		sprites += get_all_sprite2d_children(child)
	return sprites

func heal(heal_value : int) -> void:
	health = clamp(health + heal_value, 0, max_health)

func die() -> void:
	var lerp_progress : float = 0
	var og_scale : Vector2 = scale
	while(lerp_progress < 1):
		scale = lerp(og_scale, Vector2(0,0), lerp_progress)
		lerp_progress += get_process_delta_time() * 10
		await get_tree().process_frame
	
	if death_particles:
		var particles: CPUParticles2D = death_particles.instantiate()
		particles.emitting = true
		particles.position = global_position
		get_tree().root.add_child(particles)
	queue_free() 
