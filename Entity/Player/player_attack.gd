extends Node2D

@onready var player : Player = $"../.."
@onready var currentAttackDirection : Vector2 = Vector2.ZERO

var _attack_timer : float = 0.0

@export var projectile_scene : PackedScene

func DirectionCheck() -> void:
	if player.attackDirection == Vector2.ZERO:
		currentAttackDirection = Vector2.ZERO
	if player.attackDirection == currentAttackDirection:
		return
	if player.attackDirection.x > 0:
		currentAttackDirection = Vector2(1,0)
	if player.attackDirection.x < 0:
		currentAttackDirection = Vector2(-1,0)
	if player.attackDirection.y > 0:
		currentAttackDirection = Vector2(0,-1)
	if player.attackDirection.y < 0:
		currentAttackDirection = Vector2(0,1)

func shoot_projectile() -> void:
	DirectionCheck()
	if projectile_scene == null:
		print("Projectile scene is missing!")
		return
	var projectileObj = projectile_scene.instantiate()
	var projectile : Projectile = projectileObj
	
	projectile.init(player.speed, player.damage, player.attack_range,  currentAttackDirection, "player", global_position, player.velocity)
	
	get_tree().root.add_child(projectile)
