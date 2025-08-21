class_name ObjectFollowBehaviour
extends Enemy

@export var vision_distance: float = 300.0
@export var memory_time: float = 2.0
@export var squarecast: Area2D
@export var nav: NavigationAgent2D

@export var target_group: String = "player"
var object: Node2D = null
var last_seen_position: Vector2
var memory_timer: float = 0.0

func _ready():
	nav.velocity_computed.connect(_on_velocity_computed)

func _process(delta: float):
	if object:
		var dir = (object.global_position - global_position).normalized()
		ray.target_position = dir * vision_distance
	else:
		ray.target_position = Vector2.RIGHT.rotated(rotation) * vision_distance
	
	ray.force_raycast_update()

	if ray.is_colliding():
		var hit = ray.get_collider()
		if hit:
			if (target_group != "" and hit.is_in_group(target_group)):
				object = hit
				last_seen_position = object.global_position
				memory_timer = memory_time
	
	if object:
		if memory_timer > 0:
			memory_timer -= delta
			last_seen_position = object.global_position
			move_to_target(last_seen_position)
		else:
			object = null
			velocity = Vector2.ZERO
			move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func move_to_target(target_pos: Vector2):
	nav.target_position = target_pos
	if nav.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_point = nav.get_next_path_position()
		velocity = (next_point - global_position).normalized() * speed
		nav.set_velocity(velocity)
	move_and_slide()

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()
