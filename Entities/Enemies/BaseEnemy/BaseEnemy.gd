class_name BaseEnemy
extends PathFollow2D

###-------------------------------------------------------------------------###
##### Variables of Movement
###-------------------------------------------------------------------------###

### Movement variables
@export_group("Base movement")

## Enemy speed in pixels travelled every frame
@export_range(10, 9999, 1) var speed: int = 50





func _physics_process(delta: float) -> void:
	## Move the Enemy along the Level's path
	progress += speed * delta

func receive_DamageData(damageData: DamageData) -> void:
	pass
