class_name TowerHandler
extends Node2D
###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## Reference to the TempTower scene.
## That's the placeholder which follows the mouse and displays where a Tower will be placed.
@export var temp_tower: PackedScene

## This Button takes up the whole scren, is invisible,
## and when it's pressed selected_tower_ref is set to null to deselect the current Tower.
@export var deselector: Button

## This Menu is used to Upgrade and Sell Towers.
@export var selected_tower_menu: Control


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
## NOTE: This is also called when a Tower is deleted in some way (or sold or upgraded).
## NOTE: In result, all other Towers' visuals are updated when that happens.
## NOTE: Make a new signal if that is undesirable.
signal new_tower_selected

## Does the Player have a Tower selected right now? Which Tower specifically?
## This allows for the Tower Upgrade Menu to show up. Only one Tower may be selected at a time.
var selected_tower_ref: BaseTower = null


###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

func _ready() -> void:
	## A Tower is not selected by default, so this will disable SelectedTowerMenu.
	toggle_tower_selection()
	## Selecting a Tower will call this toggle_tower_selection() function
	self.new_tower_selected.connect(toggle_tower_selection)
	


###-------------------------------------------------------------------------###
##### Spawned Tower stuff
###-------------------------------------------------------------------------###

## All the Tower currently placed (children of the towers_node_reference "Towers" Node).
## Appended by TempTower (I think?)
var all_placed_towers: Array


## Prepare a Tower to be placed, as dictated by a Tower's SelectButton
func prepare_new_tower(tower_reference, tower_base_cost) -> void:
	
	## Instantiate a TempTower
	var new_TempTower = temp_tower.instantiate()
	
	## Pass the right references to the TempTower Node.
	## It will add the actual Tower as a child of this TowerHandler Node
	new_TempTower.tower_to_be_placed = tower_reference
	new_TempTower.tower_handler = self
	## Pass the Tower's base cost from its SelectButton. This is used when selling the Tower.
	new_TempTower.tower_base_cost = tower_base_cost
	
	self.add_child(new_TempTower)


###-------------------------------------------------------------------------###
##### UI - Tower deselection
###-------------------------------------------------------------------------###

## Deselect currently selected Tower
func deselect_tower() -> void:
	selected_tower_ref = null
	
	## All Towers are connected to this signal, and in result they all become deselected.
	## This signal also fires the toggle_tower_selection function down below,
	## which disables the shared SelectedTowerMenu.
	new_tower_selected.emit()
	

## Disable the Deselector button - necessary when attempting to place a new Tower.
## TempTower just cannot place anything, because it's blocked by the Button.
func disable_deselector() -> void:
	deselector.disabled = true
	deselector.visible = false
	

## Enable the Deselector button.
func enable_deselector() -> void:
	deselector.disabled = false
	deselector.visible = true
	


###-------------------------------------------------------------------------###
##### Tower functions
###-------------------------------------------------------------------------###

## When the "Sell" button is pressed, sell the current Tower and get some money back.
func _on_sell_pressed() -> void:
	## First, check if the Player has a Tower selected at the moment.
	## The menu should disappear without a Tower, but do this just in case.
	if selected_tower_ref != null:
		## The Tower handles selling itself. We just call that function in this script.
		selected_tower_ref.sell_tower()
		
	

## All Towers share Upgrade buttons, both of them located in the SelectedTowerMenu.
## These two buttons are connected to these functions, and these functions simply
## upgrade the currently selected Tower.
func _on_upgrade1_pressed() -> void:
	## First, check if the Player has a Tower selected at the moment.
	## The menu should disappear without a Tower, but do this just in case.
	if selected_tower_ref != null:
		selected_tower_ref.upgrade_1_tower()
		
	
#
func _on_upgrade2_pressed() -> void:
	## First, check if the Player has a Tower selected at the moment.
	## The menu should disappear without a Tower, but do this just in case.
	if selected_tower_ref != null:
		selected_tower_ref.upgrade_2_tower()
		
	

###-------------------------------------------------------------------------###
##### UI - Selected Tower Menu
###-------------------------------------------------------------------------###

## The SelectedTowerMenu depends on the new_tower_selected signal,
## which is connected to this function.
## Just toggles
func toggle_tower_selection() -> void:
	## Check whether SelectedTowerMenu should be enabled or not.
	#
	## If no Tower is selected, take SelectedTowerMenu off the screen.
	if selected_tower_ref == null:
		selected_tower_menu.visible = false
		
	
	## A Tower is selected, so make SelectedTowerMenu visible
	## and update its information on the currently selected Tower
	else:
		selected_tower_menu.visible = true
		
		update_tower_selection()
		
	

## Updates all Tower-specific information available in SelectedTowerMenu.
## This includes: Tower's cost, its upgrades, viewport showing the Tower.
func update_tower_selection() -> void:
	
	## NOTE: HERE: This is almost certainly temporary;
	## the UI is not yet finalized and the code is messy
	
	
	## Put up the Tower's in-game name in the UI's default Label in the top of the Window.
	$"../GUI/TemporaryGUI/SelectedTowerDraggableMenu/Label".text = \
		selected_tower_ref.ingame_name
	
	## Update the label which shows currently selected Tower's sell value
	%MoneyLabel.text = "[center]Value: [img]res://placeholder_2.png[/img]" + \
		str(selected_tower_ref.sell_value)
		
	
	## Update the description of Upgrade 1 and 2 - what do they do?
	## This information is found in HERE: where?
	%Upgrade1DetailsLabel.text = selected_tower_ref.upgrade_1_details
	%Upgrade2DetailsLabel.text = selected_tower_ref.upgrade_2_details
	
