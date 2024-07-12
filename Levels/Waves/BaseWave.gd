class_name BaseWave
extends Node2D

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("References")

## Enemy kinds that appear this wave
@export var enemy_scenes: Array[PackedScene]


@export_group("Enemies")

## Which Enemy kind will spawn now. Enemies earlier in the Array spawn first.
## This is an Array of numbers. "0" corresponds to the "0" Enemy in the enemy_scenes Array
@export var enemy_spawns_in_order: Array[int]
## Time before the next Enemy spawns.
## Number "0" corresponds to the time after the first Enemy and before the second Enemy spawns.
@export var time_between_enemies_this_wave: Array[float]


###-------------------------------------------------------------------------###
##### Misc. variables
###-------------------------------------------------------------------------###

## This signal is emmited when all the Enemies are done spawning.
## Used by this Wave's Round node to start the next wave.
signal enemies_done_spawning

## We need a reference to the level's Path2D Node. The Round Nodes know this and pass it on.
var path_reference: Path2D

## Holds all the Enemies that are still alive this Wave.
## Once this Array is empty (all the Enemies are dead), we will queue_free() this Wave
var enemies_left_this_wave: Array

## This Wave was spawned by this specific Round.
## This Round wants to know when this Wave is over, so we will call it to tell it that.
var wave_round: BaseRound


## We use this instead of _ready() to avoid bugs. This Wave's parent/instantilizer calls this func
func initialize() -> void:
	## Loop through all the Enemies this wave. We will spawn them in order,
	## as dictated by the enemy_spawns_in_order Array.
	for enemy in enemy_spawns_in_order:
		
		## This is complicated;
		## enemy_spawns_in_order Array says which Enemy kind will be instantiated now.
		## For example, let's say that enemy_spawns_in_order wants to spawn an Enemy of kind "1".
		## We ask the enemy_scenes Array what kind of an Enemy an "Enemy of kind '1'" is
		## (we get that specific Enemy PackedScene), and we instantiate it.
		var new_enemy = enemy_scenes[enemy].instantiate()
		new_enemy.enemy_wave = self
		enemies_left_this_wave.append(new_enemy)
		path_reference.add_child.call_deferred(new_enemy)
		
		
		## Now we wait a moment before spawning the next Enemy.
		await get_tree().create_timer(time_between_enemies_this_wave[enemy]).timeout
	
	## All Enemies have been spawned already.
	## Send a signal to the Round (that this Wave is a part of) to send in the next Wave.
	enemies_done_spawning.emit()
	
	## This wave is done and now it waits until all of its Enemies are dead.

## An Enemy that was spawned by this Wave is dead, so we will remove it from
## the enemies_left_this_wave Array.
func enemy_is_dead(enemy: BaseEnemy) -> void:
	if enemy in enemies_left_this_wave:
		enemies_left_this_wave.erase(enemy)
	
	## Since all the Enemies are dead, this Wave can be removed too.
	if enemies_left_this_wave.is_empty():
		print("WAVE: ALL ENEMIES IN WAVE ", self, " ARE DEAD")
		wave_is_over()

## This Wave is over, it should be queue_free-d.
func wave_is_over() -> void:
	## We must tell the Round (that this Wave is a part of) that it's over.
	## Once all the Waves are over, the next Round can begin.
	if wave_round:
		wave_round.wave_is_over(self)
		print("WAVE: ", self, " - I AM OVER")
	
	queue_free()
