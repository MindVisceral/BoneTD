## Check superior BaseTower script for @tool use
@tool
class_name DirectTower
extends BaseTower


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## This HitEffect PackedScene Node of class BaseHitEffect
## is passed onto the Enemy through DamageData,
## and instantiated at that Enemy's hit point.
@export var hit_effect: PackedScene

## This TrailEffect PackedScene Node of class BaseTrail
## is instantiated to create the effect of a Bullet between this Tower and the Enemy
@export var trail_effect: PackedScene


###-------------------------------------------------------------------------###
##### Shooting Variables
###-------------------------------------------------------------------------###


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported variables")

## Damage this Tower deals directly to the Enemy.
@export_range(0, 9999, 1) var damage: int = 1


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
	
	## Create a new DamageData to send over, give it this Towers damage-related variables,
	## and send it over directly to the Enemy, bypassing its Hurtbox completely.
	var damageData = DamageData.new()
	damageData.damage_value = damage
	damageData.hit_effect = hit_effect
	
	current_target.receive_DamageData(damageData)
	
	## And create a Trail between this Tower and the Target
	var trail_effect_instance: BaseTrail = trail_effect.instantiate()
	
	## Tell the Trail where it should start and end
	trail_effect_instance.trail_start_point = bullet_spawn_point.global_position
	trail_effect_instance.trail_end_point = current_target.global_position
	
	## And add the Enemy to the Tree - independent from this Tower.
	## It will queue_free() itself when it's done.
	get_tree().get_root().add_child(trail_effect_instance)
