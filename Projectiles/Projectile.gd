class_name Projectile
extends Area2D

@export var speed : float = 400.0
var decay_ammount : float = 400
var direction : Vector2 = Vector2.ZERO
@export var damage : int = 10
@export var range : float = 300.0
var ignore_group = ""

var _distance_traveled : float = 0.0
var _start_position : Vector2
var initial_momentum : Vector2 = Vector2.ZERO
var momentum_decay : float = 0.95 # quanto menor, mais rápido o momentum decai

func _ready() -> void:
	print("add entity momentum to bullet initiation direction")
	
func init(_speed:float, _damage:float, _range:float, _direction : Vector2, _ignore_group: String, pos : Vector2, caster_velocity : Vector2) -> void:
	speed = _speed
	damage = _damage
	range = _range
	ignore_group = _ignore_group
	position = pos
	direction = _direction
	initial_momentum = caster_velocity

func _process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return
	initial_momentum *= momentum_decay
	var total_velocity = direction.normalized() * speed + initial_momentum
	var movement = total_velocity * delta
	position += movement
	_distance_traveled += movement.length()
	if _distance_traveled >= range * 0.8:
		position.y += decay_ammount / range
	if _distance_traveled >= range:
		queue_free()

func _on_body_entered(body):

	if not body.is_in_group(ignore_group):
		if body is Entity:
			body.take_damage(damage)
		queue_free()
