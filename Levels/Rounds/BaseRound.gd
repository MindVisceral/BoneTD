class_name BaseRound
extends Node

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("References")

## This RoundEnemyData Resource holds all the information this Round needs to spawn Enemies.
@export var enemy_resources: Array[RoundSingleEnemyData] = []


###-------------------------------------------------------------------------###
##### Variables
###-------------------------------------------------------------------------###

## This signal is emmited when all the Enemies are done spawning.
signal enemies_done_spawning

## We need a reference to the level's Path2D Node;
## Enemies are instantiated as children of this Node
var path_reference: Path2D

## Holds all the Enemies that are still alive this Round.
## Once this Array is empty (all the Enemies are dead), we will queue_free() this Round
var enemies_left_this_round: Array

## This signal is emmited when all the Enemies spawned by this Round are dead.
signal round_is_over_signal

## This Round was spawned by this level's RoundHandler
## It wants to know when this Round is over for the next Round to start.
var round_handler: RoundHandler


###-------------------------------------------------------------------------###
##### Setup and round start
###-------------------------------------------------------------------------###

## We use this instead of _ready() to avoid bugs. This Round's parent/instantilizer calls this func
func initialize(path_reference, round_handler) -> void:
	
	## Remember these two references.
	self.path_reference = path_reference
	self.round_handler = round_handler
	
	## Everything is ready, start this Round.
	round_start()

## Instantiate Enemies; take each Enemy's Scene, interval between Enemies,
## and interval between individual Resources into account.
func round_start() -> void:
	## Loop through all the RoundEnemyData Resources...
	for index in enemy_resources.size():
		## We separate the resource itself and its index. Things would get messy otherwise.
		var resource = enemy_resources[index]
		
		
		## We check how many Enemies this current Resource wants us to instantiate
		## and we just loop until the number of spawned Enemies is right.
		for enemy_index in resource.number_of_enemies:
			
			## First, get what Enemy this should be (from the current provided Resource),
			## and instantiate it.
			var new_enemy: BaseEnemy = enemy_resources[index].enemy_scene.instantiate()
			
			## This bit doesn't have anything to do with the Resource itself.
			## This is just stuff this Enemy and Round need to function properly.
			new_enemy.enemy_round = self
			enemies_left_this_round.append(new_enemy)
			## And now instantiate the Enemy as a child of the level's Path Node
			path_reference.add_child.call_deferred(new_enemy)
			
			
			## The Resource has a variable which specifies how much time must pass until
			## the next Enemy can be spawned.
			## We create a Timer and wait until that time passes.
			await get_tree().create_timer(resource.enemy_spawn_interval).timeout
			
			
			## Result: A single new Enemy has been instantiated, and some time has passed
			## since it was first instantiated - this creates some distance between this
			## Enemy and the next one in this sub-loop.
			
		
		## Loop is finished, all the Enemies have been instantiated!
		
		## The Resource also has a variable which specifies how much time must pass until
		## the next Resource is used and *its* Enemeis are spawned.
		## We create a Timer and wait until *that* time passes too.
		await get_tree().create_timer(resource.time_until_next_enemies).timeout
		
	
	
	## Finally, all the Resources have been exhausted - all their Enemies have been spawned.
	## Send out a signal; the RoundHandler will receive it and it will start the next Round.
	enemies_done_spawning.emit()
	
	## This Round is done,
	## and now it waits until all of its Enemies are dead before it's queue_free()-d.
	


## An Enemy that was spawned by this Round died, so we will erase it from enemies_left_this_wave
func enemy_is_dead(enemy: BaseEnemy) -> void:
	if enemy in enemies_left_this_round:
		enemies_left_this_round.erase(enemy)
	
	## Since all the Enemies are dead, this Round can be removed too.
	if enemies_left_this_round.is_empty():
		print("ALL ENEMIES IN ROUND ", self, " ARE DEAD")
		round_is_over_signal.emit()
		
		queue_free()
