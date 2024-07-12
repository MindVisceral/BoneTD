class_name BaseRound
extends Node2D

@export_group("References")

## Different Waves that appear this Round
@export var wave_scenes: Array[PackedScene]


@export_group("Waves")

## Which different Waves will happen now. Waves earlier in the Array happen first.
## This is an Array of numbers. "0" corresponds to the "0" Wave in the wave_scenes Array
@export var waves_in_order: Array[int]


## We need a reference to the level's Path2D Node. The RoundHandler knows this and passes it.
var path_reference: Path2D

## A wave is queue_free-d when it's done spawning all its Enemies.
## The next round can only be played when all the waves of the current round are done.
var waves_left: Array

## This Round was spawned by this level's RoundHandler
## It wants to know when this Round is over, so we will call it to tell it that.
var round_handler: RoundHandler


## We use this instead of _ready() to avoid bugs. This Round's parent/instantilizer calls this func
func initialize() -> void:
	## Loop through all the Waves this round. We will make them happen in order,
	## as dictated by the waves_in_order Array.
	for wave in waves_in_order:
		
		## This is complicated;
		## waves_in_order Array says which Wave will be instantiated now.
		## For example, let's say that waves_in_order wants to spawn a Wave of kind "1".
		## We ask the wave_scenes Array what kind of a Wave a "Wave of kind '1'" is
		## (we get that specific Wave PackedScene), and we instantiate it.
		var new_wave = wave_scenes[wave].instantiate()
		new_wave.path_reference = path_reference
		print("NEW WAVE path: ", new_wave.path_reference)
		self.get_parent().add_child(new_wave)
		
		new_wave.initialize()
		
		## Now we wait a moment before spawning the next Wave.
		await true

## An Enemy that was spawned by this Wave is dead, so we will remove it from
## the enemies_left_this_wave Array.
func wave_is_over(wave: BaseWave) -> void:
	if wave in waves_left:
		waves_left.erase(wave)
		print("waves erased from Round")
	
	## Since all the Enemies are dead, this Wave can be removed too.
	if waves_left.is_empty():
		round_is_over()

## This Round is over, it should be queue_free-d so that the next round can begin.
func round_is_over() -> void:
	## We must tell the RoundHandler (that this Round is a part of) that it's over.
	## Now the next Round can begin.
	round_handler.round_is_over(self)
	print("ROUND", self, " IS OVER, queue_free()")
	queue_free()
