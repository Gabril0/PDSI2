class_name Player
extends Entity

func _init() -> void:
	super._init()
	direction = Vector2.ZERO
	attackDirection = Vector2.ZERO

func _process(delta: float) -> void:
	movement_input_check()
	attack_input_check()
	
	move(delta)

func movement_input_check() -> void:
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

func attack_input_check() -> void:
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
	
	
