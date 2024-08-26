## Check superior BaseTower script for @tool use
@tool
class_name AutoDirectTower
extends DirectTower


## This type of Tower can overheat, at which point it stops firing until it's cooled down.
## 'heat_percentage' tracks this value


###-------------------------------------------------------------------------###
##### References unique to Automatic-type DirectTowers
###-------------------------------------------------------------------------###

@export_group("References")

## This Timer keeps track of how much time must pass until the Heat can start dissipating.
@export var HeatDissipationTimer: Timer


###-------------------------------------------------------------------------###
##### Exported variables unique to Automatic-type DirectTowers
###-------------------------------------------------------------------------###

@export_group("Automatic Turret Variables")

## How much 'Heat' is added to the heat_percentage variable every single shot.
## Consider this value to be % of Heat added per shot.
## If this value is set to 2.0, then the Turret can fire up to 50 times before it overheats,
## because the upper limit of heat is 100%; (shots until overheat = 100 / heat_gain_per_shot)
@export_range(0.5, 100.0, 0.5) var heat_gain_per_shot: float = 2.0
## NOTE: Do (heat_gain_per_shot * (1 / shot_delay)) to get how many seconds this Turret
## NOTE: can fire for before it overheats.
## NOTE: At heat_gain_per_shot = 2.0 and shot_delay = 0.2 that's 10 seconds.

## How much time must pass since the previous shot before Heat can start to disippate? (in seconds)
@export_range(0.05, 5.0, 0.05) var time_until_heat_dissipation: float = 0.7

## Heat starts to dissipate after ^some time^ passes without the Turret shooting at anything.
## After that happens, how much time should pass before Heat fully dissipates?
@export_range(0.1, 30.0, 0.1) var time_until_cooled_down: float = 5.0
## NOTE: If, instead, you'd like to know how much Heat is lost per second from this variable,
## NOTE: just do (100.0 / time_until_cooled_down).
## NOTE: At time_until_cooled_down = 5.0, that's 50 Heat every second.
## NOTE: This formula is used in the actual Heat loss part of this script way below!


###-------------------------------------------------------------------------###
##### Regular variables unique to Automatic-type DirectTowers
###-------------------------------------------------------------------------###

## This variable tracks this Tower's Heat value (in %); 0 is minimum, 100 is maximum.
var heat_percentage: float = 0.0

## When heat_percentage has reached 100% this flag is set to true,
## this Turret is overheated and it must dissipate all its Heat before it can fire again.
var overheated: bool = false


###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	## Call the superior class' _ready() function too. It would be overriden without this!
	## NOTE: This applies to ALL functions with the same name as the ones in the superior class!
	super()
	
	## Set the HeatDissipationTimer's wait_time to the right value.
	HeatDissipationTimer.wait_time = time_until_heat_dissipation
	

## Setup this Tower
func setup() -> void:
	super()
	


###-------------------------------------------------------------------------###
##### Shooting functions
###-------------------------------------------------------------------------###

## Every frame check if the Target can be shot.
func _physics_process(delta: float) -> void:
	## NOTE: No super() in this function in this script! It works a little different.
	
	## When not in Editor...
	if !Engine.is_editor_hint():
		
		## Check if enough time has passed since the last shot for the Heat to begin dissipating.
		if HeatDissipationTimer.is_stopped():
			## Remove some heat every frame. 'time_until_cooled_down' (counted in seconds) is used
			## here instead of an arbitrary value, because that's easier to imagine/visualize.
			heat_percentage -= ((100.0 / time_until_cooled_down) * delta)
			heat_percentage = clampf(heat_percentage, 0.0, 100.0)
			
			## If the Tower is overheated (we don't check for that) and the Heat goes back to 0%,
			## the Tower is no longer considered overheated; it may start firing again.
			if heat_percentage <= 0.0:
				overheated = false
			
		
		
		## If there is a current_target...
		if current_target:
			## And the shooting cooldown is over...
			if ShotDelayTimer.is_stopped():
				
				## The Tower may only fire when it's not overheated!
				if overheated == false:
					
					## Check if the Target can be seen from the Tower's position with a Ray.
					## The Tower cannot see from behind obstacles.
					if can_see_target() == true:
						shoot_at_target()
						
					
				
			
		
	


## Deal damage to the chosen Target directly, without use of any projectiles.
## NOTE: This function's code is unique to this Tower type!
func fire() -> void:
	## NOTE: No super() in this function in this script! It works a little different.
	
	
	## Send over an exported DamageData Resource to the Target
	current_target.receive_DamageData(damage_data)
	
	## Create a Trail between this Tower and its Target
	var trail_effect_instance: BaseTrail = trail_effect.instantiate()
	## Tell the Trail where it should start and end
	trail_effect_instance.trail_start_point = bullet_spawn_point.global_position
	trail_effect_instance.trail_end_point = current_target.hit_point.global_position
	#
	## And add the Trail to the Tree - independent from this Tower.
	## It will queue_free() itself when it's done.
	get_tree().get_root().add_child(trail_effect_instance)
	
	
	## This Tower has fired a shot, add some heat.
	heat_percentage += heat_gain_per_shot
	## Clamp heat_percentage between 0 and 100.
	heat_percentage = clampf(heat_percentage, 0.0, 100.0)
	
	## If there is too much Heat, the Tower must stop firing until the Heat dissipates back to 0%.
	if heat_percentage >= 100.0:
		overheated = true
		
	
	## Restart the HeatDissipationTimer. If this Time passes without the Turret firing,
	## then the Heat will begin to dissipate.
	HeatDissipationTimer.start()
	
