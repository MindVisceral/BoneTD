extends Button

## Reference to the Tower which this Button will help select
@export var tower_reference: PackedScene

## Reference to the Sprite child of this Button, which will dispaly the Tower's sprite
@export var button_tower_sprite: Sprite2D


func _ready() -> void:
	call_deferred("initialize")

## 
func initialize() -> void:
	if tower_reference:
		button_tower_sprite = tower_reference.tower_sprite
