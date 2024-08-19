class_name RoundHandler
extends Node

###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")


## New Enemies must be added as children of the Path to work properly.
## Waves handle that, so this must be passed to each new Wave
@export var path_reference: Path2D

## Button the Player presses to start the next round
@export var nextRound_button: Button


###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Array of all the Rounds that will be "played" on this Level/Map.
## This Array is filled on _ready() with the RoundHandler's children (whicha are all Rounds)
var rounds: Array[BaseRound] = []


###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

## We use this instead of _ready() to avoid bugs.
func _ready() -> void:
	
	## Loop through all the children of this RoundHandler (they should all be BaseRounds)
	## and add them to the 'rounds' Array
	for child in self.get_children():
		if child is BaseRound:
			rounds.append(child)
	
	
	## Before anything happens, we listen for the nextRound_button to be pressed
	await nextRound_button.pressed
	
	## Button pressed, Round started!
	## Loop through all the Rounds
	## (with breaks between them - we Await until a Round is over before the next one is sent)
	for round in rounds:
		
		## Pass on these two references and start the Round.
		round.initialize(path_reference, self)
		
		## We wait for this Round to be over before we start the next one.
		await round.round_is_over_signal
		print("ROUND: ", round, " IS OVER, queue_free-d")
		## This round is over, now we can (and will) wait for the Player to start the next round
		await nextRound_button.pressed
		print("NEXT ROUND started")
