## Check superior BaseTower script for @tool use
@tool
class_name DirectTower
extends BaseTower


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## This DamageData Resource holds all the information this Tower's Target needs when it's been hit.
## This includes the Tower's damage dealth and the hit effect.
## NOTE: Read the DamageData script for more info.
@export var damage_data: DamageData

## This TrailEffect PackedScene Node of class BaseTrail
## is instantiated to create the effect of a Bullet between this Tower and the Enemy
@export var trail_effect: PackedScene


###-------------------------------------------------------------------------###
##### Shooting Variables
###-------------------------------------------------------------------------###


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###


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
	#super() ## This might be unnecessary because it's an empty dummy function.
	
	## Send over an exported DamageData Resource to the Target
	if damage_data:
		current_target.receive_DamageData(damage_data)
		
	## This error print is useful; it's easy to forget to set up the DamageData for each Tower.
	else:
		printerr("DamageData Resource has not been set for ", self, "!")
	
	## And create a Trail between this Tower and the Target
	var trail_effect_instance: BaseTrail = trail_effect.instantiate()
	## Tell the Trail where it should start and end
	trail_effect_instance.trail_start_point = bullet_spawn_point.global_position
	trail_effect_instance.trail_end_point = current_target.hit_point.global_position
	
	
	## And add the Trail to the Tree - independent from this Tower.
	## It will queue_free() itself when it's done.
	get_tree().get_root().add_child(trail_effect_instance)
