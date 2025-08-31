extends Node

@export var life_bar: TextureProgressBar
@export var blood: TextureProgressBar  # Red bar with shader - moves immediately
@export var old_bar: TextureProgressBar  # Delayed bar
@export var width_per_life: float = 0.27
@export var blood_lerp_speed: float = 0.1      # speed for blood bar (immediate)
@export var old_lerp_speed: float = 0.05       # slower speed for old bar (delayed)
@export var damage_delay: float = 1.0          # delay before old bar starts following

var target_life: float = 1.0
var current_life: float = 1.0
var blood_life: float = 1.0    # blood bar follows immediately
var old_life: float = 1.0      # old bar follows with delay

var animating: bool = false
var damage_timer: float = 0.0
var taking_damage: bool = false

func _ready() -> void:
	# Setup blood shader material
	if blood and not blood.material:
		var shader_material = ShaderMaterial.new()
		var shader = load("res://shaders/UI/ui_blood.gdshader")
		shader_material.shader = shader
		blood.material = shader_material
	
	# Initialize all bars to full
	_update_bar_visuals()

func _process(delta: float) -> void:
	if taking_damage:
		damage_timer += delta
		
		# Update main life bar immediately
		if abs(current_life - target_life) > 0.001:
			current_life = lerp(current_life, target_life, blood_lerp_speed)
			life_bar.value = clamp(current_life * life_bar.max_value, 0, life_bar.max_value)
			life_bar.size.x = life_bar.max_value * width_per_life
		
		# Update blood bar immediately (no delay)
		if abs(blood_life - target_life) > 0.001:
			blood_life = lerp(blood_life, target_life, blood_lerp_speed)
		
		# Update old bar after delay
		if damage_timer >= damage_delay:
			if abs(old_life - target_life) > 0.001:
				old_life = lerp(old_life, target_life, old_lerp_speed)
			else:
				# All bars caught up
				taking_damage = false
				animating = false
		
		_update_blood_bar()
		_update_old_bar(old_life)

func _update_old_bar(value: float) -> void:
	old_life = value
	old_bar.value = old_life * old_bar.max_value
	old_bar.size.x = old_bar.max_value * width_per_life

func _update_blood_bar() -> void:
	# Don't pass progress to shader - let it use the default (1.0)
	# The shader effect should be independent of the health value
	if blood.material is ShaderMaterial:
		# Only set shader parameters if you want to control the effect
		# Remove or comment out the progress parameter
		pass
	
	blood.value = clamp(blood_life * blood.max_value, 0, blood.max_value)
	blood.size.x = blood.max_value * width_per_life

func _update_bar_visuals() -> void:
	# Update all bar sizes and values
	for bar in [life_bar, blood, old_bar]:
		if bar:
			bar.value = clamp(current_life * bar.max_value, 0, bar.max_value)
			bar.size.x = bar.max_value * width_per_life
	
	blood_life = current_life
	old_life = current_life
	_update_blood_bar()

func update_life_bar(new_life: float, max_life: float) -> void:
	if animating:
		return
	
	# Set max values
	life_bar.max_value = max_life
	blood.max_value = max_life
	old_bar.max_value = max_life
	
	var new_target = clamp(new_life / max_life, 0, 1)
	
	# Only animate if life decreased (taking damage)
	if new_target < target_life:
		target_life = new_target
		animating = true
		taking_damage = true
		damage_timer = 0.0
	else:
		# Healing - update all bars immediately
		target_life = new_target
		current_life = new_target
		blood_life = new_target
		old_life = new_target
		_update_bar_visuals()
