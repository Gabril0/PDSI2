class_name PlayerAnimationHandler
extends Node

@export var head_animation : AnimationPlayer
@export var torso_animation : AnimationPlayer
@export var legs_animation : AnimationPlayer

func update_animation(velocity : Vector2, attack_direction : Vector2) -> void:
	var regular_direction : String = get_direction(velocity, attack_direction)
	var legs_direction : String = get_legs_direction(velocity)
	var is_moving : bool = velocity.length() > 0.1
	var animation_type : String = "walk" if is_moving else "idle"
	var animation_name : String = "idle_" + regular_direction
	var legs_animation_name : String = animation_type + "_" + legs_direction
	
	if head_animation:
		head_animation.play(animation_name)
	
	if torso_animation:
		torso_animation.play(animation_name)
	
	if legs_animation:
		legs_animation.play(legs_animation_name)

func get_direction(velocity : Vector2, attack_direction : Vector2) -> String:
	var is_attacking : bool = attack_direction.length() > 0.1
	var direction_vector : Vector2 = attack_direction if is_attacking else velocity
	if is_attacking:
		direction_vector.y = - direction_vector.y
	
	return direction_aux(direction_vector)

func get_legs_direction(velocity : Vector2) -> String:
	return direction_aux(velocity)
	
func direction_aux(velocity : Vector2) -> String:
	if velocity.length() < 0.1:
		return "down"
		
	var abs_x : float = abs(velocity.x)
	var abs_y : float= abs(velocity.y)
	
	if abs_x > abs_y:
		if velocity.x > 0:
			return "right"
		else:
			return "left"
	else:
		if velocity.y > 0:
			return "down"
		else:
			return "up"
