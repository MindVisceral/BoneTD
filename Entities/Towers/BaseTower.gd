class_name BaseTower
extends StaticBody2D

###-------------------------------------------------------------------------###
##### Enemy-related Variables
###-------------------------------------------------------------------------###

@export_group("Enemies")

## Which Enemy in range should this Tower target?
## "First" means the Enemy that is furthest along the track
@export_enum("First", "Last") var enemy_to_target: int = 0


###-------------------------------------------------------------------------###
##### Shooting Variables
###-------------------------------------------------------------------------###

@export_group("Shooting")

## Time between individual shots
@export_range(0.05, 2.0, 0.05) var shot_delay: float = 1.0


###-------------------------------------------------------------------------###
##### Onready Variables
###-------------------------------------------------------------------------###

## Timer that keeps time until next shot
@onready var ShotDelayTimer: Timer = $ShotDelayTimer


###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

## All Enemies in range of this tower. The first entry in this Array is the first tower added.
var EnemiesInRangeArray: Array = []

## The Enemy which this Tower is currently targetting
var current_target: BaseEnemy


func _ready() -> void:
	## Set ShotDelayTimer's wait_time
	ShotDelayTimer.wait_time = shot_delay

func _physics_process(delta: float) -> void:
	## If the current_target isn't null...
	if current_target:
		current_target.speed = 20
	## If there is no current_target, attempt to find one in the Array
	elif !EnemiesInRangeArray.is_empty():
		change_current_target()


func change_current_target() -> void:
	## First, check which Enemy this Tower is set to target
	match enemy_to_target:
		## If this Tower is set to "First"...
		0:
			## Set the current target to the Enemy that is furthest along the track
			## (The Enemy that was added to the EnemiesInRangeArray earliest)
			current_target = EnemiesInRangeArray[0]
		## If this Tower is set to "Last"...
		1:
			## Set the current target to the first Enemy within this Tower's range
			## (The Enemy that was added to the EnemiesInRangeArray latest)
			current_target = EnemiesInRangeArray.back()


## When TowerDetectionArea sees a new Enemy in range...
func new_enemy_in_range(Enemy: BaseEnemy) -> void:
	EnemiesInRangeArray.append(Enemy)

## When TowerDetectionArea sees an Enemy is out of range...
func new_enemy_out_of_range(Enemy: BaseEnemy) -> void:
	EnemiesInRangeArray.erase(Enemy)









