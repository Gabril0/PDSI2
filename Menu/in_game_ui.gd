extends Node

@export var life_bar: TextureProgressBar
@export var blood: TextureProgressBar
@export var old_bar: TextureProgressBar
@export var width_per_life: float = 0.27
@export var blood_lerp_speed: float = 0.1
@export var old_lerp_speed: float = 0.05
@export var damage_delay: float = 1.0

var target_life: float = 1.0
var current_life: float = 1.0
var blood_life: float = 1.0
var old_life: float = 1.0

var animating: bool = false
var damage_timer: float = 0.0
var taking_damage: bool = false

func _ready() -> void:
	if blood and not blood.material:
		var shader_material = ShaderMaterial.new()
		var shader = load("res://shaders/UI/ui_blood.gdshader")
		shader_material.shader = shader
		blood.material = shader_material
	_update_bar_visuals()

func _process(delta: float) -> void:
	if animating:
		damage_timer += delta
		if abs(current_life - target_life) > 0.001:
			current_life = lerp(current_life, target_life, blood_lerp_speed)
			life_bar.value = clamp(current_life * life_bar.max_value, 0, life_bar.max_value)
			life_bar.size.x = life_bar.max_value * width_per_life
		if abs(blood_life - target_life) > 0.001:
			blood_life = lerp(blood_life, target_life, blood_lerp_speed)
		var is_healing = target_life > old_life
		if is_healing or damage_timer >= damage_delay:
			if abs(old_life - target_life) > 0.001:
				old_life = lerp(old_life, target_life, old_lerp_speed)
			else:
				animating = false
				taking_damage = false
		_update_blood_bar()
		_update_old_bar(old_life)

func _update_old_bar(value: float) -> void:
	old_life = value
	old_bar.value = old_life * old_bar.max_value
	old_bar.size.x = old_bar.max_value * width_per_life

func _update_blood_bar() -> void:
	if blood.material is ShaderMaterial:
		var shader_material = blood.material as ShaderMaterial
		shader_material.set_shader_parameter("progress", blood_life)
	blood.value = clamp(blood_life * blood.max_value, 0, blood.max_value)
	blood.size.x = blood.max_value * width_per_life
	blood.scale.x = 0.65
	old_bar.scale.x = 0.65

func _update_bar_visuals() -> void:
	for bar in [life_bar, blood, old_bar]:
		if bar:
			bar.value = clamp(current_life * bar.max_value, 0, bar.max_value)
			bar.size.x = bar.max_value * width_per_life
	blood_life = current_life
	old_life = current_life
	_update_blood_bar()

func update_life_bar(new_life: float, max_life: float) -> void:
	life_bar.max_value = max_life
	blood.max_value = max_life
	old_bar.max_value = max_life
	var new_target = clamp(new_life / max_life, 0, 1)
	target_life = new_target
	animating = true
	taking_damage = new_target < current_life
	damage_timer = 0.0
