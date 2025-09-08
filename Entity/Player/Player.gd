class_name Player
extends Entity

@onready var animation_handler : PlayerAnimationHandler = $Visuals

signal room_changed(grid_pos: Vector2i)
const ROOM_SIZE = Vector2(800, 600)  #Isso muda
var current_grid_pos: Vector2i = Vector2i.ZERO

var itemPassiveDecorator
@onready var sprite_nodes: Array[Sprite2D] = get_sprite_nodes()

var items : Array[Item]
var is_invulnerable : bool = false
var invulnerability_time : float = 1.0
var invulnerability_timer : Timer
var flash_timer : Timer
var flash_on : bool = false

var original_materials : Dictionary = {} 


func _init() -> void:
	super._init()
	direction = Vector2.ZERO
	attackDirection = Vector2.ZERO
	


func _ready() -> void:
	for s in sprite_nodes:
		original_materials[s] = s.material
	
	InGameUi.update_life_bar(health, max_health)
	invulnerability_timer = Timer.new()
	invulnerability_timer.one_shot = true
	invulnerability_timer.wait_time = invulnerability_time
	add_child(invulnerability_timer)
	invulnerability_timer.timeout.connect(_on_invulnerability_timer_timeout)

	flash_timer = Timer.new()
	flash_timer.wait_time = 0.1
	flash_timer.one_shot = false
	add_child(flash_timer)
	flash_timer.timeout.connect(_on_flash_timer_timeout)


func _process(delta: float) -> void:
	var new_pos = Vector2i(global_position / ROOM_SIZE)
	
	if new_pos != current_grid_pos:
		current_grid_pos = new_pos
		room_changed.emit(current_grid_pos)
	
	for item in items:
		item.on_process()
	movement_input_check()
	attack_input_check()
	animation_handler.update_animation(direction, attackDirection)


func _physics_process(delta: float) -> void:
	move(delta)
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider() if collision else null
		if body and (body.is_in_group("enemy") or body.is_in_group("hazard")):
			take_damage(10, body)


func take_damage(amount: int, attacker: Node2D) -> void:
	for item in items:
		item.on_hit()
		
	if is_invulnerable:
		return
	
	super.take_damage(amount, attacker)
	InGameUi.update_life_bar(health, max_health)
	is_invulnerable = true
	flash_on = false
	flash_timer.start()
	invulnerability_timer.start()

func heal(health_value : int) -> void:
	super.heal(health_value)
	InGameUi.update_life_bar(health, max_health)

func _on_invulnerability_timer_timeout() -> void:
	is_invulnerable = false
	flash_timer.stop()
	reset_sprite()


func _on_flash_timer_timeout() -> void:
	if flash_on:
		reset_sprite()
	else:
		flash_white()
	flash_on = !flash_on


func flash_white() -> void:
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;
		uniform float flash_strength : hint_range(0.0, 1.0) = 0.6;

		void fragment() {
			vec4 tex_color = texture(TEXTURE, UV);
			COLOR = mix(tex_color, vec4(1.0, 1.0, 1.0, tex_color.a), flash_strength);
		}
	"""
	var mat := ShaderMaterial.new()
	mat.shader = shader

	for s in sprite_nodes:
		s.material = mat


func reset_sprite() -> void:
	for s in sprite_nodes:
		if s in original_materials:
			s.material = original_materials[s]


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

func get_sprite_nodes() -> Array[Sprite2D]:
	var arr: Array[Sprite2D] = []
	_collect_sprites($Visuals, arr)
	return arr

func _collect_sprites(node: Node, arr: Array[Sprite2D]) -> void:
	for child in node.get_children():
		if child is Sprite2D:
			arr.append(child)
		_collect_sprites(child, arr)
		
func add_item(item : Item) -> void:
	items.append(item)
	item.activate()
	
func die() -> void:
	for item in items:
		item.on_die()
	super.die()
