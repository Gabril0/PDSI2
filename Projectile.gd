class_name Projectile
extends Area2D

@export var speed : float = 400.0
var decay_ammount : float = 400
var direction : Vector2 = Vector2.ZERO
@export var damage : int = 10
@export var range : float = 300.0

var _distance_traveled : float = 0.0
var _start_position : Vector2


func _process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return
	var movement = direction.normalized() * speed * delta
	position += movement
	_distance_traveled += movement.length()
	if _distance_traveled >= range * 0.8:
		position.y += decay_ammount / range
	if _distance_traveled >= range:
		queue_free()

func _on_body_entered(body):

	queue_free()
