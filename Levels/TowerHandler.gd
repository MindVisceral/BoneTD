class_name TowerHandler
extends Node2D

@export_group("References")

## New Towers will be added as children of the 'Towers' Node
@export var towers_node_reference: Node2D

## Different Towers that can be used in this level
@export var tower_scenes: Array[PackedScene]


## This function instantiates a new Tower at the cursor's position.
func prepare_new_tower(tower_scene_number) -> void:
	
	##
	var new_tower = tower_scenes[tower_scene_number].instantiate()
	
	## First, show where the Tower will be placed by making the Tower's sprite follow
	## the Player's cursor.
	
	
	
	## Now, finish instantiating
	towers_node_reference.add_child(new_tower)
	
	
	#place_new_tower(new_tower.global_position)

func place_new_tower(tower_global_position) -> void:
	pass
