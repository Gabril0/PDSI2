class_name Player
extends CharacterBody2D

@export var speed : float = 200.0
var direction : Vector2
var attackDirection : Vector2

func _init() -> void:
	direction = Vector2.ZERO
	attackDirection = Vector2.ZERO

func _process(delta: float) -> void:
	MovementInputCheck()
	AttackInputCheck()
	
	var friction : float = velocity.length() /20
	var acceleration : float = speed /15
	velocity += direction * acceleration + (friction * -velocity.sign())
	move_and_slide()

func MovementInputCheck() -> void:
	direction = Vector2.ZERO

	if Input.is_action_pressed("Right"):
		direction.x += 1
	if Input.is_action_pressed("Left"):
		direction.x -= 1
	if Input.is_action_pressed("Down"):
		direction.y += 1
	if Input.is_action_pressed("Up"):
		direction.y -= 1

	direction = direction.normalized()

func AttackInputCheck() -> void:
	attackDirection = Vector2.ZERO
	
	if Input.is_action_pressed("AimRight"):
		attackDirection.x += 1
	if Input.is_action_pressed("AimLeft"):
		attackDirection.x -= 1
	if Input.is_action_pressed("AimDown"):
		attackDirection.y -= 1
	if Input.is_action_pressed("AimUp"):
		attackDirection.y += 1

	attackDirection = attackDirection.normalized()
	
	
