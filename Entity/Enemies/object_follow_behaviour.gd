class_name ObjectFollowBehaviour
extends Enemy

@export var vision_distance: float = 500.0
@export var memory_time: float = 5.0
@export var nav: NavigationAgent2D
@export var target_group: String = "player"
@export var can_fly: bool = false

var follow_object: Node2D = null
var last_seen_position: Vector2
var memory_timer: float = 0.0

var patrol_timer: float = 0.0
var patrol_target: Vector2 = Vector2.ZERO

@onready var raycast: Raycast = Raycast.new()

func _ready():
	add_child(raycast)
	nav.velocity_computed.connect(_on_velocity_computed)
	vision_loop()

func _process(delta: float) -> void:
	print(follow_object)
	if follow_object:
		if memory_timer > 0:
			memory_timer -= delta
			last_seen_position = follow_object.global_position
			move_to_target(last_seen_position)
		else:
			follow_object = null
			velocity = Vector2.ZERO
			move_and_slide()
	else:
		# Patrol logic
		if patrol_timer <= 0:
			_start_random_patrol()
		else:
			patrol_timer -= delta
			move_to_target(patrol_target)

func vision_loop() -> void:
	while true:
		var hits: Array[Dictionary] = raycast.circle_cast(global_position, vision_distance)
		for hit in hits:
			var collider = hit.collider
			if collider.is_in_group(target_group):
				follow_object = collider
				memory_timer = memory_time
		await get_tree().create_timer(0.25).timeout

func move_to_target(target_pos: Vector2) -> void:
	if can_fly:
		velocity = (target_pos - global_position).normalized() * speed
	else:
		nav.target_position = target_pos
		if nav.is_navigation_finished():
			velocity = Vector2.ZERO
		else:
			var next_point = nav.get_next_path_position()
			velocity = (next_point - global_position).normalized() * speed
			nav.set_velocity(velocity)
	move_and_slide()

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	if not can_fly:
		velocity = safe_velocity
	move_and_slide()
	
func take_damage(ammount : int, attacker: Node2D) -> void:
	super.take_damage(ammount, attacker)
	var hits: Array[Dictionary] = raycast.circle_cast(global_position, vision_distance * 100)
	for hit in hits:
		var collider = hit.collider
		if collider.is_in_group(target_group):
			follow_object = collider
			memory_timer = memory_time

func _start_random_patrol() -> void:
	var directions = [
		Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
		Vector2(1,1).normalized(), Vector2(-1,1).normalized(),
		Vector2(1,-1).normalized(), Vector2(-1,-1).normalized()
	]
	var dir = directions[randi() % directions.size()]
	var distance = 50 + randi() % 100
	patrol_target = global_position + dir * distance
	patrol_timer = 0.0 + randf() * 1.0
	if not can_fly:
		nav.target_position = patrol_target
