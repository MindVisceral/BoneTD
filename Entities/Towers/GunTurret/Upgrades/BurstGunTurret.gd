## Check superior BaseTower script for @tool use
@tool
class_name BurstDirectTower
extends DirectTower


###-------------------------------------------------------------------------###
##### Exported variables unique to Burst-type DirectTowers
###-------------------------------------------------------------------------###

## How many times does this Turret shoot in a single burst?
@export_range(1, 10, 1) var shots_in_a_burst: int = 3

## Time between each individual shot in each burst.
@export_range(0.05, 1.0, 0.05) var shot_interval: float = 0.08


###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###


###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	## Call the superior class' _ready() function too. It would be overriden without this!
	## NOTE: This applies to ALL functions with the same name as the ones in the superior class!
	super()

## Setup this Tower
func setup() -> void:
	super()


###-------------------------------------------------------------------------###
##### Shooting functions
###-------------------------------------------------------------------------###

## Every frame, check if the Target can be shot.
func _physics_process(delta: float) -> void:
	super(delta)

## Shooting the Target should be possible, 
func shoot_at_target() -> void:
	super()


## Deal damage to the chosen Target directly, without any use of projectiles.
## NOTE: This function's code is unique to this Tower type!
func fire() -> void:
	## NOTE: No super() in this function in this script! It works a little different.
	
	## The Bursts should only work against a single target;
	## If a Target dies halfway through the burst, the next target is shot immediately,
	## but that looks jarring. So, if a Target is different between shots, we do not fire at all.
	var target_this_burst: BaseEnemy = current_target
	#
	## Loop through the shots in a Burst, all working separately.
	for shot in shots_in_a_burst:
		## The reason for this line is explained above.
		if current_target == target_this_burst:
			
			## Sometimes the Enemy dies before a Burst is done and another Enemy can be picked,
			## so we do this check to avoid crashes.
			if current_target != null:
				
				## Send over an exported DamageData Resource to the Target
				current_target.receive_DamageData(damage_data)
				
				## And create a Trail between this Tower and the Target
				var trail_effect_instance: BaseTrail = trail_effect.instantiate()
				## Tell the Trail where it should start and end
				trail_effect_instance.trail_start_point = bullet_spawn_point.global_position
				trail_effect_instance.trail_end_point = current_target.hit_point.global_position
				
				
				## And add the Trail to the Tree - independent from this Tower.
				## It will queue_free() itself when it's done.
				get_tree().get_root().add_child(trail_effect_instance)
				
				## We wait a moment before the next shot in this burst is fired
				await get_tree().create_timer(shot_interval).timeout
				
			
		
	
