class_name TowerHandler
extends Node2D

@export_group("References")

## Reference to the TempTower scene.
## That's the placeholder which follows the mouse and displays where a Tower will be placed.
@export var temp_tower: PackedScene

## New Towers will be added as children of the 'Towers' Node
@export var towers_node_reference: Node2D


## Prepare a Tower to be placed, as dictated by a Tower's SelectButton
func prepare_new_tower(tower_reference) -> void:
	
	## Instantiate a TempTower
	var new_TempTower = temp_tower.instantiate()
	
	## Pass the right references.
	new_TempTower.tower_to_be_placed = tower_reference
	new_TempTower.towers_node_reference = towers_node_reference
	
	towers_node_reference.add_child(new_TempTower)
