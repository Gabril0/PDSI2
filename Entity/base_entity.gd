class_name Entity
extends CharacterBody2D

# Base stats 
@export var health : int = 100
@export var damage : int = 10
@export var attack_range : float = 50.0
@export var attack_speed : float = 1.0
@export var speed : float = 200.0

# Movement properties
@export var friction_force : float = 0.05
@export var acceleration_force : float = 0.1
var direction : Vector2
var attackDirection : Vector2

func move(delta : float) -> void:
	var friction : float = velocity.length() * friction_force
	var acceleration : float = speed * acceleration_force
	
	if velocity.length() < speed:
		velocity += delta * direction * acceleration
	velocity += friction * -velocity.normalized()
	
	move_and_slide()

func take_damage(amount : int) -> void:
	health -= amount
	
	hit_effect()
	
	if health <= 0:
		die()

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
	

func get_all_sprite2d_children(parent_node) -> Array[Sprite2D]:
	var sprites : Array[Sprite2D] = []
	for child in parent_node.get_children():
		if child is Sprite2D:
			sprites.append(child)
		sprites += get_all_sprite2d_children(child)
	print(typeof(sprites))
	return sprites

func die() -> void:
	var lerp_progress : float = 0
	var og_scale : Vector2 = scale
	while(lerp_progress < 1):
		scale = lerp(og_scale, Vector2(0,0), lerp_progress)
		lerp_progress += get_process_delta_time() * 10
		await get_tree().process_frame
	
	queue_free() 


func _init() -> void:
	direction = Vector2.ZERO
	attackDirection = Vector2.ZERO
