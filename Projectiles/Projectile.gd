class_name Projectile
extends Area2D

@export var speed : float = 400.0
var decay_ammount : float = 400
var direction : Vector2 = Vector2.ZERO
@export var damage : int = 10
@export var range : float = 300.0
var ignore_group : String = ""
@export var momentum_boost : float = 2.25
@export var sprite : Sprite2D
var last_positions : Array[Vector2]

var _elapsed_time : float = 0.0
var initial_momentum : Vector2 = Vector2.ZERO
var momentum_decay : float = 0.98
@onready var original_scale : Vector2 = scale
@onready var particles_end : CPUParticles2D = $Sprite2D/HitParticles

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
	original_scale = scale

func _process(delta: float) -> void:
	initial_momentum *= momentum_decay
	if direction.dot(initial_momentum.normalized()) < 0:
		initial_momentum = - direction.normalized() * 3
	if initial_momentum == Vector2.ZERO:
		initial_momentum = Vector2(0.001,0.001)
	var total_velocity : Vector2 = direction.normalized() * speed + initial_momentum * momentum_boost
	var movement : Vector2 = total_velocity * delta
	check_side(movement.normalized())
	position += movement
	_elapsed_time += delta
	
	if _elapsed_time <= range * 0.25:
		scale = lerp(Vector2.ZERO, original_scale, _elapsed_time / (range * 0.25))
	
	if _elapsed_time >= range * 0.9:
		position.y += decay_ammount * delta / range
	if _elapsed_time >= range * 0.8:
		var fade_time = range * 0.2
		var t = (_elapsed_time - range * 0.8) / fade_time
		scale = original_scale.lerp( Vector2.ZERO, t)
	if _elapsed_time >= range:
		end_projectile()
		
func end_projectile() -> void:
	var p = particles_end.duplicate()
	get_tree().root.add_child(p)
	p.scale = Vector2(1,1)
	p.position = position
	queue_free()

func _on_body_entered(body):

	if not body.is_in_group(ignore_group):
		if body is Entity:
			body.take_damage(damage)
		end_projectile()
		
func check_side(direc : Vector2):
	if direc.length() > 0:
		sprite.rotation = direc.angle()
		
	

	
	
