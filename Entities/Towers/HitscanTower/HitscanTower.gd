## Check superior BaseTower script for @tool use
@tool
class_name HitscanTower
extends BaseTower


###-------------------------------------------------------------------------###
##### Exported variables unique to HitscanTowers
###-------------------------------------------------------------------------###

@export_group("Variables unique to Hitscan Towers")

## This variable holds layers which this Tower's RayCast can detect.
@export_flags_2d_physics var raycast_layers: int

## How many Enemies can the shot go through before it stops?
@export_range(0, 9999) var piercings: int = 0


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


## Cast a RayCast in the direction of this Tower's target
## NOTE: This function's code is unique to this Tower type!
func fire() -> void:
	#super() ## This might be unnecessary because it's an empty dummy function.
	
	
	## Get the world's space_state. We need this to cast a Ray
	var space_state = get_world_2d().direct_space_state
	
	## The position from which the Ray will be cast.
	## NOTE: The Ray fires from the Tower's BulletSpawnPoint
	var start_pos: Vector2 = bullet_spawn_point.global_position
	#
	## The position at which the Ray will end.
	## NOTE: Since the Tower can pierce and doesn't just stop at the Target,
	## we subtract the Tower's position from the Target's position,
	## and we get the direction in which the Tower is pointing.
	## Then we normalize that, add 5000 units of distance (chosen arbitrarily),
	## and now the Ray goes through the whole map.
	var end_pos: Vector2 = (current_target.global_position - start_pos).normalized() * 5000
	#
	## The mask on which the Environment and Enemies' Hurtboxes lie.
	var mask: int = raycast_layers
	
	## Put together all of those variables above.
	var parameters: PhysicsRayQueryParameters2D = \
		PhysicsRayQueryParameters2D.create(start_pos, end_pos, mask)
	
	## We must also turn on Area2D detection for this Ray to catch Enemies' HurtBoxes
	parameters.collide_with_areas = true
	
	
	## Since Rays currently can only detect one Collider at a time, we will 'while' loop
	## until we have detected everything there is to detect.
	#
	## An Array which holds all the colliders.
	## This will be updated by the loop, and these colliders will be excluded from future iterations
	var all_colliders: Array = []
	#
	while true:
		## First, exclude all colliders found so far (this copies the 'all_colliders' Array)
		parameters.exclude = all_colliders
		
		## Cast a Ray with the 'parameters' variable as its parameters
		var result = space_state.intersect_ray(parameters)
		
		## If the Ray detects anything, and that thing has a collider...
		if (result != null) and (result.has("collider")):
			## Get the collider info from the result dictionary and add it to the Array.
			all_colliders.append(result.collider)
				
			
		## If no collider was found, clean the exlusion Array and break the loop
		else:
			parameters.exclude = []
			break
			
		
	
	## This Tower can pierce through Enemies.
	## In the 'for' loop, we only go to the next Enemy if there is still some piercing power left
	## after the first Enemy.
	var piercings_left: int = piercings
	#
	## Loop through all the colliders caught in the Ray.
	for collider: Hurtbox in all_colliders:
		
		## We can only damage as many Enemies in the 'all_colliders' Array as there are 'piercings'
		if piercings_left >= 0:
			
			## Send over an exported DamageData Resource to the Target, if it accepts such a Resource.
			if collider is Hurtbox:
				collider.pass_DamageData(damage_data)
				
			
		## All 'piercing power' is gone, we cannot damage any more Enemies.
		else:
			break
			
		
		## Remove one 'piercing power' point every interation through the loop
		piercings_left -= 1
		
	
	
	
	## And create a Trail between this Tower and the Target
	var trail_effect_instance: BaseTrail = trail_effect.instantiate()
	## Tell the Trail where it should start and end
	trail_effect_instance.trail_start_point = bullet_spawn_point.global_position
	trail_effect_instance.trail_end_point = end_pos
	
	## And add the Trail to the Tree - independent from this Tower.
	## It will queue_free() itself when it's done.
	get_tree().get_root().add_child(trail_effect_instance)
