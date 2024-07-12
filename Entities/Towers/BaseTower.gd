class_name BaseTower
extends StaticBody2D

###-------------------------------------------------------------------------###
##### Enemy-related Variables
###-------------------------------------------------------------------------###

@export_group("Enemies")

## Which Enemy in range should this Tower target?
## "First" means the Enemy that is furthest along the track
@export_enum("First", "Last") var target_priority: int = 0


###-------------------------------------------------------------------------###
##### Shooting Variables
###-------------------------------------------------------------------------###

@export_group("Shooting")

## Reference to the Bullet scene, which this Tower will 'shoot' (instantiate)
@export var bullet_scene: PackedScene = \
	preload("res://Entities/Towers/BaseBullet.tscn")

## Time until the next shot can be fired
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

## Angle between this Tower and it's Target
var angle_to_current_target: float


func _ready() -> void:
	## Set ShotDelayTimer's wait_time and start it up
	ShotDelayTimer.wait_time = shot_delay
	ShotDelayTimer.start()


func _physics_process(delta: float) -> void:
	## If there is a current_target...
	if current_target:
		
		## Shot at the current_target if possible.
		if ShotDelayTimer.is_stopped():
			shoot_at_target()


func shoot_at_target() -> void:
	## Get the angle between the Tower and its Target (in radians).
	## The bullet will be fired at this angle.
	angle_to_current_target = self.global_position.angle_to_point(current_target.global_position)
	
	## Instantiate a bullet...
	var bullet: BaseBullet = bullet_scene.instantiate()
	## ...at this Tower's global_position...
	bullet.global_position = self.global_position
	## ...at the angle that will point it at the current_target.
	bullet.rotation = angle_to_current_target
	get_tree().get_root().add_child(bullet)
	
	## Start the Timer again
	ShotDelayTimer.start()

###-------------------------------------------------------------------------###
##### Targetting functions
###-------------------------------------------------------------------------###

## When TowerDetectionArea sees a new Enemy in range...
func new_enemy_in_range(Enemy: BaseEnemy) -> void:
	EnemiesInRangeArray.append(Enemy)
	
	print("ENTERED")
	
	## A new Enemy has entered the Tower's range. Check if it should become the new current_target
	change_current_target()

## When TowerDetectionArea sees an Enemy is out of range...
func new_enemy_out_of_range(Enemy: BaseEnemy) -> void:
	EnemiesInRangeArray.erase(Enemy)
	
	print("EXITED")
	
	## This Enemy which just went out of range may have been the current_target.
	change_current_target()

## Pick a new current_target depending on this Tower's target_priority variable.
func change_current_target() -> void:
	## Forget about the current_target to avoid bugs.
	current_target = null
	
	## First, check if there are any Enemies within range that can be targetted
	if !EnemiesInRangeArray.is_empty():
		## Second, check this Tower's targetting priority
		match target_priority:
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
