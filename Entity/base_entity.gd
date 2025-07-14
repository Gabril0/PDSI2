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
    if health <= 0:
        die()

func die() -> void:
    queue_free() 


func _init() -> void:
    direction = Vector2.ZERO
    attackDirection = Vector2.ZERO

