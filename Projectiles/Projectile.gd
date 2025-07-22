class_name Projectile
extends Area2D

@export var speed : float = 400.0
var decay_ammount : float = 400
var direction : Vector2 = Vector2.ZERO
@export var damage : int = 10
@export var range : float = 300.0 # range agora representa o tempo de vida em segundos
@export var momentum_boost : float = 2.25
@onready var line : Line2D = $Line2D
var last_positions : Array[Vector2]

var _elapsed_time : float = 0.0
var initial_momentum : Vector2 = Vector2.ZERO
var momentum_decay : float = 0.98

func _ready() -> void:
	print("add entity momentum to bullet initiation direction")
	
func init(caster_velocity : Vector2) -> void:
	initial_momentum = caster_velocity

func _process(delta: float) -> void:
	trail_renderer()
	if direction == Vector2.ZERO:
		return
	initial_momentum *= momentum_decay
	var total_velocity = direction.normalized() * speed + initial_momentum * momentum_boost
	var movement = total_velocity * delta
	position += movement
	_elapsed_time += delta
	if _elapsed_time >= range * 0.9:
		position.y += decay_ammount * delta / range
	if _elapsed_time >= range:
		queue_free()

func _on_body_entered(body):
	queue_free()
	
func trail_renderer():
	await get_tree().create_timer(0.01).timeout
	last_positions.append(global_position)
	line.clear_points()
	if last_positions.size() > 500:
		last_positions.pop_at(500)
	for pos in last_positions:
		line.add_point(pos)
	
	
