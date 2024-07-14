extends Button

## Reference to the Tower which this Button will help select
@export var tower_reference: PackedScene

## 
@export var TempTower: PackedScene

func _ready() -> void:
	call_deferred("initialize")

## 
func initialize() -> void:
	if tower_reference:
		pass

## This button has been pressed, the Player wants to place this button's Tower
func _on_pressed() -> void:
	var temp_tower = TempTower.instantiate()
	temp_tower.tower_to_be_placed = tower_reference
	
	get_tree().get_root().add_child(temp_tower)
