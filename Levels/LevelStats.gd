class_name LevelStats
extends Node

### Holds the Player's default Health and Money.
## This is passed to the Globals variable for easier access.

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Stats")


## Maximum Player health in this Level
@export_range(1, 999999999) var max_health: int = 1000
#
## Amount of health the Player stars the Level with
@export_range(0, 999999999) var default_health: int = 100

## Maximum money in this Level
@export_range(1, 999999999) var max_money: int = 999999999
#
## Amount of money the Player stars the Level with
@export_range(0, 999999999) var default_money: int = 1000



func _ready() -> void:
	## Clamp default_money amount
	clampi(default_money, 1, max_money)
	## And make Player's amount of money left the same as default_money
	Globals.current_money = default_money
	
	## Clamp default_health amount
	clampi(default_health, 1, max_health)
	## And make Player's amount of health left the same as default_health
	Globals.current_health = default_health

