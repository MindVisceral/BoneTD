class_name RoundHandler
extends Node2D

@export_group("References")

## New Enemies must be added as children of the Path to work properly.
## Waves handle that, so this must be passed to each new Wave
@export var path_reference: Path2D

## Different Rounds that appear in this level
@export var round_scenes: Array[PackedScene]

## Button the Player presses to start the next round
@export var nextRound_button: Button


@export_group("Rounds")

## Number of Rounds in this level
@export_range(1, 999, 1) var number_of_rounds: int = 0

## Which different Rounds will happen now. Rounds earlier in the Array happen first.
## This is an Array of numbers. "0" corresponds to the "0" Round in the round_scenes Array
@export var rounds_in_order: Array[int]

@export_group("Start")
## This map will start with this round
@export_range(0, 999, 1) var starting_round: int = 0
## If not 0, this round will start during this wave. Typically rounds start with Wave 0
@export_range(0, 999, 1) var starting_wave: int = 0


@export_group("End")
## This map will end with this round
@export_range(1, 999, 1) var ending_round: int = 0
## If not 999, this round will end after this wave. Typically rounds just end with the last wave
@export_range(0, 999, 1) var ending_wave: int = 0

func _ready() -> void:
	call_deferred("initialize")

## We use this instead of _ready() to avoid bugs.
func initialize() -> void:
	
	## Before anything happens, wait for the Player to start the next round
	await nextRound_button.pressed
	
	## Round started!
	## Loop through all the Waves this round. We will make them happen in order,
	## as dictated by the waves_in_order Array.
	for round in rounds_in_order:
		
		## This is complicated;
		## waves_in_order Array says which Wave will be instantiated now.
		## For example, let's say that waves_in_order wants to spawn a Wave of kind "1".
		## We ask the wave_scenes Array what kind of a Wave a "Wave of kind '1'" is
		## (we get that specific Wave PackedScene), and we instantiate it.
		var new_round = round_scenes[round].instantiate()
		new_round.path_reference = path_reference
		## Tell this Round who made it
		new_round.round_handler = self
		self.add_child(new_round)
		
		new_round.initialize()
		
		## We wait for this Round to be over before we start the next one.
		await new_round.round_is_over_signal
		print("ROUND: ", new_round, " IS OVER, queue_free-d")
		## This round is over, now we can (and will) wait for the Player to start the next round
		await nextRound_button.pressed
		print("NEXT ROUND started")
