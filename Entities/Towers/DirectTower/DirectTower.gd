## Check superior BaseTower script for @tool use
@tool
class_name DirectTower
extends BaseTower


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")


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
	
	current_target.receive_DamageData(damageData)
