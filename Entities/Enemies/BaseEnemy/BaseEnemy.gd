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

@export_range(1, 9999, 1) var max_health: int = 1


###-------------------------------------------------------------------------###
##### Actual stats
###-------------------------------------------------------------------------###

## How much Health does this Enemy have remaining?
var current_health: int = 1



func _ready() -> void:
	apply_stats()

## When this Enemy is ready, apply their Exported Stats to Actual Stats
func apply_stats() -> void:
	current_health = max_health


func _physics_process(delta: float) -> void:
	## Move the Enemy along the Level's path
	progress += speed * delta


## This Enemy has been hit, time to take some Damage
func receive_DamageData(damageData: DamageData) -> void:
	## Lose some Health
	self.current_health -= damageData.damage_value
	
	## Health is all gone, time to die.
	if current_health <= 0:
		death()


## Make the Enemy die
func death() -> void:
	queue_free()
