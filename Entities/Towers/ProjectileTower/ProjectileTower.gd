## Check superior BaseTower script for @tool use
@tool
class_name ProjectileTower
extends BaseTower


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")


###-------------------------------------------------------------------------###
##### Shooting Variables
###-------------------------------------------------------------------------###

@export_group("Shooting")

## Reference to the Bullet scene, which this Tower will 'shoot' (instantiate).
## NOTE: This is unique to Projectile-type Towers!
@export var bullet_scene: PackedScene


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

func _physics_process(delta: float) -> void:
	super(delta)

func shoot_at_target() -> void:
	super()


## Instantiate and fire a bullet...
## NOTE: This function's code is unique to this Tower type! It instantiates a projectile Bullet.
func fire() -> void:
	#super() ## This might be unnecessary because it's an empty dummy function.
	
	## Instantiate the Bullet which will be fired.
	var bullet: BaseBullet = bullet_scene.instantiate()
	
	
	print(bullet)
	
	
	## Adjust the Bullet's rotation so it will hit the Enemy.
	## NOTE: HERE: This should be independent from the Bullet's visuals, but they are bound!
	bullet.rotation = angle_to_current_target
	## The Bullet should be fired from this Tower's bullet_spawn_point
	bullet.global_position = bullet_spawn_point.global_position
	
	## And add the Bullet to the Tree
	get_tree().get_root().add_child(bullet)
