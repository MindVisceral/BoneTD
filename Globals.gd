extends Node
#####
## THIS IS THE GLOBALS SCRIPT!
## It's an Autoload, loaded the moment the game is launched, in every single scene,
## accesible by every Node in the Tree.
#####

#####
## Tower placing stuff
#####

## Is the Player holding and currently trying to place down a Tower?
## This action should prevent some Inputs from registering, like selecting a placed Tower.
var player_placing_tower: bool = false



#####
## Tower selection stuff
#####

signal new_tower_selected

## Does the Player have a Tower selected right now?
## This allows for a Tower's upgrade menu to show up. Only one Tower may be selected at a time.
var player_selected_tower: bool = false
#
## Which Tower specifically is selected at the moment?
var selected_tower_ref: BaseTower = null
