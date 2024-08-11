extends Node


## To avoid crowding, only one Menu may be visible at a time.
#
## Normally, for example, I would just swap the current Menu scene to the Settings scene
## when the Player clicked the Settings Button, but in this case that would break the background.
#
## Instead, the background will stay, but the Menus will be turned on and off.
## Ex.: we start off with a Main Menu, and when the Player wants to go to the
## options Menu, we disable & hide the Main Menu, and enable & show the Settings Menu.
#
## This Node handles all the Menu switching and scene changes.


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("Menus")

## Reference to the Main Menu.
@export var main_menu: DraggableMenu

## 
@export var settings_menu: DraggableMenu

##
@export var credits_menu: DraggableMenu


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported variables")

## Which Menu is visible and shown/open right now?
@export var current_menu: DraggableMenu

## Array that holds all the Menus
@export var all_menus: Array[DraggableMenu]


###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

func _ready() -> void:
	
	## Turn off every single Menu
	disable_all_menus()
	
	## And switch to the current_menu.
	change_menu(current_menu)


###-------------------------------------------------------------------------###
##### Menu switching function
###-------------------------------------------------------------------------###

## Change the current_menu to the given new_menu.
func change_menu(new_menu: DraggableMenu) -> void:
	current_menu.visible = false
	
	current_menu = new_menu
	current_menu.visible = true
	

## Disable all Menus. Used on _ready() and as a debugging function
func disable_all_menus() -> void:
	for menu in all_menus:
		menu.visible = false
		
	


###-------------------------------------------------------------------------###
##### Connected button functions
###-------------------------------------------------------------------------###

##
func _play_pressed() -> void:
	pass

## Show the Settings Menu
func _settings_pressed() -> void:
	change_menu(settings_menu)

## Show the Credits Menu
func _credits_pressed() -> void:
	change_menu(credits_menu)

## Exit the game as a whole.
func _exit_pressed() -> void:
	get_tree().quit()

## Return back to Main Menu
func _return_pressed() -> void:
	change_menu(main_menu)
