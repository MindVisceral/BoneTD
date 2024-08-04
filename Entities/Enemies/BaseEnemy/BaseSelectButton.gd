extends Button

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

## Reference to the Tower which this Button will spawn
@export var tower_reference: PackedScene

## Reference to the Towerhandler Node of this level. It will spawn a TempTower scene and
## it will instantiatehandle TempTower and Towers
@export var tower_handler: TowerHandler


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

## How much does this Tower cost to place? If the Player doesn't have
## at least this amount of Money, they can't place this Tower.
## This is passed down to the Tower, because the base cost is taken into account when selling.
@export_range(1, 99999, 1) var tower_base_cost: int = 1


###-------------------------------------------------------------------------###
##### Variables and flags
###-------------------------------------------------------------------------###

## This button can only be pressed if it's active.
var active: bool = true


func _ready() -> void:
	## If active is true, disable this button and vice versa.
	self.disabled = !active
	
	## Connect the Globals money_amount_changed signal to this Node's money_check function.
	Globals.money_amount_changed.connect(money_check)


## Check if the Player has enough Money to buy a Tower every time the Money amount changes .
func money_check() -> void:
	## Not enough Money, disable button
	if Globals.current_money < tower_base_cost:
		disable_button()
	## Enough Money to buy Tower, enable button
	else:
		enable_button()


## Enable this Button.
func enable_button() -> void:
	self.disabled = false


## Disable this Button.
func disable_button() -> void:
	self.disabled = true


## This button has been pressed, the Player wants to place this button's Tower.
## The TowerHandler will handle that.
func _on_pressed() -> void:
	
	## Only allow the Player to pick and place one Tower at a time.
	## TempTower Node also checks for this.
	if tower_handler.player_placing_tower == false:
		tower_handler.prepare_new_tower(tower_reference, tower_base_cost)
