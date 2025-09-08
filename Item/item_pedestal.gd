extends Area2D

var item_held : Item
@export var visuals : Sprite2D
@export var pedestal_tier : int = 1

@onready var og_scale : Vector2 

func _ready() -> void:
	item_held = ItemPool.get_random_from_tier(pedestal_tier)
	visuals.texture = item_held.icon
	og_scale = visuals.scale
	body_entered.connect(_on_body_entered)

func _process(delta : float) -> void:
	if visuals:
		visuals.scale.x = og_scale.x + clamp( 1 + 0.5 * sin(Time.get_ticks_msec() / 1000.0),0.5, 1.5)
	
	
func _on_body_entered(body):
	if body.is_in_group("player") && visuals:
		var player : Player = body as Player
		item_held.player_ref = player
		player.add_item(item_held)
		visuals.queue_free()
