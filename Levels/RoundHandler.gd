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

## Keeps track of which Round the level is in right now. Nothing by default to avoid confusion.
## NOTE: Value of "1" corresponds to Round of index "0" in the 'rounds' Array
## NOTE: In short, >current_round = rounds + 1<
var current_round: int

###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

## We use this instead of _ready() to avoid bugs.
func _ready() -> void:
	
	## Connect the Global Money and Health signals.
	## When one of these is fired, update Player's Stats UI
	Globals.money_amount_changed.connect(update_stats_tracker)
	Globals.health_amount_changed.connect(update_stats_tracker)
	
	## Loop through all the children of this RoundHandler (they should all be BaseRounds)
	## and add them to the 'rounds' Array
	for child in self.get_children():
		if child is BaseRound:
			rounds.append(child)
	
	
	## Update the UI before we do anything.
	## NOTE: The LevelStats Node must be higher in the hierarchy than this Node for this to work!
	## NOTE: Because its _ready() function must be called first for the Globals Stats to be updated
	update_round_tracker()
	update_stats_tracker()
	
	
	## Before anything happens, we listen for the nextRound_button to be pressed
	await nextRound_button.pressed
	
	## Button pressed, Round started!
	## Loop through all the Rounds
	## (with breaks between them - we Await until a Round is over before the next one is sent)
	for round in rounds:
		
		## The value of current_round variable is equivilent to the index of the current Round in
		## the "rounds" Array, plus 1 - because Arrays start from 0, but we can't have "Round 0"
		current_round = rounds.find(round) + 1
		
		## And update the UI to show that change.
		update_round_tracker()
		
		## Pass on these two references and start the Round.
		round.initialize(path_reference, self)
		
		## Disable the "NEXT ROUND" Button until the current Round is over.
		nextRound_button.disabled = true
		
		## We wait for this Round to be over before we start the next one.
		await round.round_is_over_signal
		print("ROUND: ", round, " IS OVER, queue_free-d")
		
		## Enable the Button
		nextRound_button.disabled = false
		
		## This round is over, now we can (and will) wait for the Player to start the next round
		await nextRound_button.pressed
		print("NEXT ROUND started")
		
	


###-------------------------------------------------------------------------###
##### UI Connections
###-------------------------------------------------------------------------###

## HERE: Temporary arrangement; the UI is not finalized!

## Update the UI element that shows which Round the level is on.
func update_round_tracker() -> void:
	if current_round > 0:
		%RoundTracker.text = "[center]" + "ROUND: " + str(current_round) + \
			" out of " + str(rounds.size())
			
		
	

## Update the UI element that shows how much Money and Health the Player has left.
## Money and Health are copuled here, but that shouldn't have much impact on performance.
func update_stats_tracker() -> void:
	%StatsTracker.text = "[p]" + "[center]" + "MONEY: " + str(Globals.current_money) + \
		"[p]" + "[center]" + "LIFE: " + str(Globals.current_health)
		
	
