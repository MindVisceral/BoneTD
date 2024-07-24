extends Node
#####
## THIS IS THE GLOBALS SCRIPT!
## It's an Autoload, loaded the moment the game is launched, in every single scene,
## accesible by every Node in the Tree.
#####

###-------------------------------------------------------------------------###
##### Global level variables
###-------------------------------------------------------------------------###

## Player's remaining health in this Level
var current_health: int

## Player's amount of money at the moment
var current_money: int


###-------------------------------------------------------------------------###
##### Global level functions
###-------------------------------------------------------------------------###

## Player loses Health as Enemies reach their end goal
func lose_health(health_lost: int) -> void:
	current_health -= health_lost
	
	print("health remaining: ", current_health)
	
	if current_health <= 0:
		print("GAME OVER")
		print("Player lost all healh")


## Money is lost as Towers and Upgrades are bought
func lose_money(money_lost: int) -> void:
	current_money -= money_lost


















