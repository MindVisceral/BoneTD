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
##### Variables and flags
###-------------------------------------------------------------------------###

## This button can only be pressed if it's active.
var active: bool = true

## How much does this Tower cost to place? If the Player doesn't have
## at least this amount of Money, they can't place this Tower.
## We get this information from the Tower (tower_reference)
var tower_base_cost: int = 1

###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

func _ready() -> void:
	## If active is true, disable this button and vice versa.
	self.disabled = !active
	
	## Update this Button's TowerCost to be the same as the cost that is set in the Tower scene.
	## But first, the Tower must be instantiated. We can't get this info from a pure PackedScene.
	var temporary_tower_instance: BaseTower = tower_reference.instantiate()
	tower_base_cost = temporary_tower_instance.tower_base_cost
	## And we remove this temporary Tower instance right away. Janky, but it works.
	temporary_tower_instance = null
	
	## Connect the Globals money_amount_changed signal to this Node's money_check function.
	Globals.money_amount_changed.connect(money_check)
	
	## And call money_check() so the Player cannot buy this Tower
	## if they don't have the money on _ready()
	money_check()


###-------------------------------------------------------------------------###
##### Core functions
###-------------------------------------------------------------------------###

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
		
	
