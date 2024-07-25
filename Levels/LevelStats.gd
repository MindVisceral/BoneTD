class_name LevelStats
extends Node

### Holds the Player's default Health and Money.
## This is passed to the Globals variable for easier access.

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Health")

## Maximum Player health in this Level
@export_range(1, 999999999) var max_health: int = 1000
#
## Amount of health the Player stars the Level with
@export_range(0, 999999999) var default_health: int = 100


@export_group("Money")

## Maximum money in this Level
@export_range(1, 999999999) var max_money: int = 999999999
#
## Amount of money the Player stars the Level with
@export_range(0, 999999999) var default_money: int = 1000


@export_group("Cost")

## Tower Cost multiplier. Depending on the Level difficulty,
## Towers cost proportionally less or more.
@export_range(0.1, 100, 0.1) var cost_multiplier: float = 1.0

## The percentage of Money the Player will get back from selling a Tower;
## If a Tower and it's upgrades costed 100 Money total and base_sell_multiplier is 0.5,
## the Player will get 50 Money back.
@export_range(0.05, 1.0, 0.05) var sell_multiplier: float = 0.85






func _ready() -> void:
	## Clamp default_money amount
	clampi(default_money, 1, max_money)
	## And make Player's amount of money left the same as default_money
	Globals.current_money = default_money
	
	## Clamp default_health amount
	clampi(default_health, 1, max_health)
	## And make Player's amount of health left the same as default_health
	Globals.current_health = default_health

