## Check superior BaseTower script for @tool use
@tool
class_name DirectTower
extends BaseTower


###-------------------------------------------------------------------------###
##### DamageData
###-------------------------------------------------------------------------###

@export_group("DamageData")

## This DamageData Resource holds all the information this Tower's Target needs when it's been hit.
## This includes the Tower's damage dealth and the hit effect.
## NOTE: Read the DamageData script for more info.
@export var damage_data: DamageData:
	set(w_damagedata):
		if w_damagedata != damage_data:
			damage_data = w_damagedata
			update_configuration_warnings()


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

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
##### Editor-only functions
###-------------------------------------------------------------------------###

## Show a warning when the Tower is not set up properly in the Editor.
func _get_configuration_warnings() -> PackedStringArray:
	## This is a derived class, so take superior warnings into account.
	var warnings: PackedStringArray = super()
	
	if damage_data == null:
		## We we want this warning to show up first in the Array. Weirdly, PackedStringArray
		## have no 'push_front' function like regular Arrays - hence 'insert' at index 0 instead.
		warnings.insert(0, "No DamageData is set for this Tower!")
		
	
	return warnings

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
	current_target.receive_DamageData(damage_data)
	
	## And create a Trail between this Tower and the Target
	var trail_effect_instance: BaseTrail = trail_effect.instantiate()
	## Tell the Trail where it should start and end
	trail_effect_instance.trail_start_point = bullet_spawn_point.global_position
	trail_effect_instance.trail_end_point = current_target.hit_point.global_position
	
	
	## And add the Trail to the Tree - independent from this Tower.
	## It will queue_free() itself when it's done.
	get_tree().get_root().add_child(trail_effect_instance)
