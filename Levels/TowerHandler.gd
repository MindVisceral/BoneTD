class_name TowerHandler
extends Node2D
###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## Reference to the TempTower scene.
## That's the placeholder which follows the mouse and displays where a Tower will be placed.
@export var temp_tower: PackedScene


###-------------------------------------------------------------------------###
##### Tower placing stuff
###-------------------------------------------------------------------------###

## Is the Player holding and currently trying to place down a Tower?
## This action should prevent some Inputs from registering, like selecting a placed Tower.
var player_placing_tower: bool = false


###-------------------------------------------------------------------------###
##### Tower selection stuff
###-------------------------------------------------------------------------###

## Whenever a new Tower is selected, this signal is fired. This is to let all the Tower that
## they are not selected to make sure that only one Tower may be selected at a time.
signal new_tower_selected

## Does the Player have a Tower selected right now?
## This allows for a Tower's upgrade menu to show up. Only one Tower may be selected at a time.
var player_selected_tower: bool = false
#
## Which Tower specifically is selected at the moment?
var selected_tower_ref: BaseTower = null


###-------------------------------------------------------------------------###
##### Spawned Tower stuff
###-------------------------------------------------------------------------###

## All the Tower currently placed (children of the towers_node_reference "Towers" Node).
## Appended by TempTower (I think?)
var all_placed_towers: Array


## Prepare a Tower to be placed, as dictated by a Tower's SelectButton
func prepare_new_tower(tower_reference) -> void:
	
	## Instantiate a TempTower
	var new_TempTower = temp_tower.instantiate()
	
	## Pass the right references to the TempTower Node.
	## It will add the actual Tower as a child of this TowerHandler Node
	new_TempTower.tower_to_be_placed = tower_reference
	new_TempTower.tower_handler = self
	
	self.add_child(new_TempTower)


###-------------------------------------------------------------------------###
##### Tower functions
###-------------------------------------------------------------------------###

## When the "Sell" button is pressed, sell the Tower and get some money back.
func _on_sell_pressed() -> void:
	## First, check if a Tower is selected in the first place.
	if player_selected_tower == true:
		## Kill the selected Tower and add some money back,
		## depending on the Tower's base value and upgrades
		selected_tower_ref











