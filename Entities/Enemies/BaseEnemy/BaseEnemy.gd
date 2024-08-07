class_name BaseEnemy
extends PathFollow2D

###-------------------------------------------------------------------------###
##### Exported stats
###-------------------------------------------------------------------------###

### Movement variables
@export_group("Base movement")

## Enemy speed in pixels travelled every frame
@export_range(5, 9999, 1) var speed: int = 20


@export_group("Health")

## This Enemy's maximum health
@export_range(1, 9999, 1) var max_health: int = 1


@export_group("Damage")

## Amount of damage this Enemy deals to the Player
@export_range(1, 9999, 1) var damage: int = 1


@export_group("Money")

## Amount of Money the Player gains from killing this Enemy
@export_range(0, 999999999, 1) var default_money: int = 5


###-------------------------------------------------------------------------###
##### Actual stats
###-------------------------------------------------------------------------###

## How much Health does this Enemy have remaining?
var current_health: int = 1


###-------------------------------------------------------------------------###
##### Misc. variables
###-------------------------------------------------------------------------###

## This Enemy was spawned by this specific Wave.
## This Wave wants to know when this Enemy dies, so we will call it to tell it that.
var enemy_wave: BaseWave


func _ready() -> void:
	apply_stats()

## When this Enemy is ready, apply their Exported Stats to Actual Stats
func apply_stats() -> void:
	current_health = max_health


func _physics_process(delta: float) -> void:
	## Move the Enemy along the Level's path
	progress += speed * delta
	
	## When the Enemy reaches the end of the Path...
	if is_equal_approx(progress_ratio, 1):
		## Player loses health equal to this Enemy's damage value.
		Globals.lose_health(damage)
		
		## And the Enemy "dies".
		death()


## This Enemy has been hit, time to take some Damage
func receive_DamageData(damageData: DamageData) -> void:
	## Lose some Health
	self.current_health -= damageData.damage_value
	
	## If health is all gone, time to die.
	if current_health <= 0:
		death()


## Make the Enemy die
func death() -> void:
	## We must tell the Wave (that this Enemy is a part of) that it has died
	enemy_wave.enemy_is_dead(self)
	print("ENEMY ", self, " IS DEAD")
	## This Enemy is dead, the Player should receive some Money for kiling it
	Globals.gain_money(default_money)
	
	## And now delete this Enemy
	queue_free()
