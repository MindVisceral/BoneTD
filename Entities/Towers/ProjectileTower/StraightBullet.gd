class_name StraightBullet
extends BaseBullet


## NOTE: This Bulletuses the default damage calculation script seen in BaseBullet.


###-------------------------------------------------------------------------###
##### Setup function
###-------------------------------------------------------------------------###

func _ready() -> void:
	super()


###-------------------------------------------------------------------------###
##### Bullet Movement
###-------------------------------------------------------------------------###

## The only difference between this and the BaseBullet is that this one moves in a straight line.
func _physics_process(delta: float) -> void:
	## Make the bullet move at speed over time
	global_position += transform.x * speed * delta
