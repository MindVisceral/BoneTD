class_name BaseTrail
extends Line2D


## This is a purely visual Node. It creates a Line between a Tower's 'Bullet'-firing point,
## and the Enemy's HitPoint to simulate an effect of a Bullet travelling that distance.


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Exported variables")

## How long this Trail will linger in the Tree before it's queue_free()-d (in seconds)
@export_range(0.01, 5.0) var lifetime: float = 0.05


###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## This Trail's starting position - typically, the Tower's gun barrel.
var trail_start_point: Vector2 = Vector2.ZERO

## This Trail's end point - typically, the Tower's Target/Enemy.
var trail_end_point: Vector2 = Vector2(100, 50)


###-------------------------------------------------------------------------###
##### Functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	## Clear the Trail to avoid any issues
	self.clear_points()
	
	## Add the start- and end-point positions to the Trail
	self.add_point(trail_start_point)
	self.add_point(trail_end_point)
	
	## Wait until 'lifetime' length of time passes and delete this Node.
	await get_tree().create_timer(lifetime).timeout
	queue_free()
