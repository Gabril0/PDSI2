extends ObjectFollowBehaviour

@export var projectile_scene : PackedScene
@export var attack_cooldown : float = 3
@export var attack_indication : float = 1
@export var visuals : Sprite2D

var og_scale : Vector2
var animation_indication_progress : float = 0
var attacking : bool = false

func _ready() -> void:
	super._ready()
	og_scale = visuals.scale

func _process(delta: float) -> void:
	super._process(delta)

	if follow_object and not attacking:
		attack()

func attack() -> void:
	attacking = true
	_do_attack_animation()
	
	# Wait indication time before firing
	await get_tree().create_timer(attack_indication).timeout
	
	if projectile_scene == null:
		print("Projectile scene is missing!")
	else:
		var projectileObj = projectile_scene.instantiate()
		var projectile : Projectile = projectileObj
		projectile.init(
			projectile_speed,
			damage,
			attack_range,
			(follow_object.position - position).normalized(),
			"enemy",
			global_position,
			velocity,
			self
		)
		get_tree().root.add_child(projectile)
	
	# Wait cooldown before being able to attack again
	await get_tree().create_timer(attack_cooldown).timeout
	attacking = false

func _do_attack_animation() -> void:
	animation_indication_progress = 0.0
	var timer := get_tree().create_timer(attack_indication)
	
	while timer.time_left > 0:
		visuals.scale.x = og_scale.x + clamp(1 + 0.5 * sin(animation_indication_progress), 0.5, 1.5)
		visuals.modulate = lerp(Color(1,1,1,1), Color(1,0,0,1), animation_indication_progress)
		animation_indication_progress += get_process_delta_time()
		await get_tree().process_frame
	
	# Reset after animation
	visuals.scale = og_scale
	visuals.modulate = Color(1,1,1,1)
