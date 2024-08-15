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
@export var bullet_scene: PackedScene = \
	preload("res://Entities/Towers/BaseTower/BaseBullet.tscn")


###-------------------------------------------------------------------------###
##### Bullet Variables
###-------------------------------------------------------------------------###

@export_group("Bullet stuff")


## NOTE: HERE: DECIDE IF THE BULLET OR TOWER SHOULD HANDLE ALL THIS!


## The Tower holds the Bullet's sprite
@export var bullet_sprite: Texture = \
	preload("res://icon.svg")

## Bullet's base speed
@export_range(0, 9999, 1) var bullet_speed: int = 80


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
	
	## Adjust the Bullet's rotation so it will hit the Enemy.
	## NOTE: HERE: This should be independent from the Bullet's visuals, but they are bound.
	bullet.rotation = angle_to_current_target
	
	## Pass on the bullet variables
	## NOTE: This is done this way so I don't have to create a thousand bullets for each Tower upgrade
	## NOTE: that only differ in stats. The Tower handles most of it
	## NOTE: (but not unique Bullet behaviour like homing!)
	bullet.speed = bullet_speed
	bullet.damage = bullet_damage
	bullet.piercings_left = bullet_piercing_amount
	
	## Update Bullet visuals, just in case.
	## HERE: This should be changed; either the Bullet OR the Tower/upgrade should know the visuals
	bullet.sprite_texture = bullet_sprite
	
	## The Bullet should be fired from this Tower's bullet_spawn_point
	bullet.global_position = bullet_spawn_point.global_position
	
	## And add the Bullet to the Tree
	get_tree().get_root().add_child(bullet)
