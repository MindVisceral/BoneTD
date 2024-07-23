extends Button

## Reference to the Tower which this Button will spawn
@export var tower_reference: PackedScene

## Reference to the Towerhandler Node of this level. It will spawn a TempTower scene and
## it will instantiatehandle TempTower and Towers
@export var tower_handler: TowerHandler


## This button has been pressed, the Player wants to place this button's Tower.
## The TowerHandler will handle that.
func _on_pressed() -> void:
	## Only allow the Player to pick and place one Tower at a time.
	## TempTower Node also checks for this.
	if tower_handler.player_placing_tower == false:
		tower_handler.prepare_new_tower(tower_reference)
