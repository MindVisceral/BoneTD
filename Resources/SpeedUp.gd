extends Node


## THis Node/Script controls game speed.
## This is extremly useful when Player wants to speed up the action when they have nothing to do.


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

## Default time_scale. Should always be set to 1.0
@export var default_time_scale: float = 1.0

## The target time_scale. When time is sped up, this is the time_scale we're aiming for.
@export_range(0.05, 1.0, 0.05) var target_time_scale: float = 5.0

## Time (in seconds) it takes for the time_scale to reach the lower/upper limit;
@export_range(0.05, 1.0, 0.05) var time_until_limit: float = 0.3


###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Current time_scale, set to be the same as default_time_scale on _ready().
var time_scale: float = 1.0

## We only need one Tween; If we made a new one on every time, they would interfere with each other
var time_tween: Tween


###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

func _ready() -> void:
	time_scale = default_time_scale
	


###-------------------------------------------------------------------------###
##### Core function
###-------------------------------------------------------------------------###

## Function called when the Player wants to speed up the game.
## NOTE: Connected with the right button through the Editor
func change_time_scale() -> void:
	
	## If time_scale is about equal to default_time_scale time, we tween to target_time_scale
	if time_scale >= (default_time_scale - 0.05):
		
		## And now we may apply the new time scale.
		time_tween = get_tree().create_tween()
		
		## We must make sure the Tween's time works in real time
		## and isn't affected by the time_scale changing.
		time_tween.set_speed_scale(1.0 / time_scale)
		
		time_tween.tween_property(Engine, "time_scale", target_time_scale, time_until_limit)
		time_tween.tween_property(AudioServer, "playback_speed_scale", \
			target_time_scale, time_until_limit)
		
	
	## Otherwise, we tween back to default_time_scale time.
	else:
		
		## And now we may apply the new time scale.
		time_tween = get_tree().create_tween()
		
		time_tween.set_speed_scale(1.0 / time_scale)
		
		time_tween.tween_property(Engine, "time_scale", default_time_scale, time_until_limit)
		time_tween.tween_property(AudioServer, "playback_speed_scale", \
			default_time_scale, time_until_limit)
		
	
