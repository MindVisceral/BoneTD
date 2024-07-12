class_name BaseBullet
extends Area2D

###-------------------------------------------------------------------------###
##### Bullet Variables
###-------------------------------------------------------------------------###

## NOTE: These are all set by the Tower which shoots this Bullet.
## NOTE: Check the BaseTower script for more information

## Bullet's base speed
var speed: int = 80
## Default damage dealt by this bullet
var damage: int = 1
## How many times this Bullet can go through an Enemy/Enemies before breaking.
## "0" means that this Bullet does not pierce - it deals damage once and is destroyed,
## "1" means that this Bullet can deal damage up to two times and it's destroyed on the second hit
var piercings_left: int = 0


func _physics_process(delta: float) -> void:
	## Make the bullet move at speed over time
	global_position += transform.x * speed * delta


## Check for Enemies
func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		
		## Create a new DamageData to send over, give it this bullet's variables, and send it over
		## to the area's (which is a Hurtbox) Entity (which should be an Enemy)
		var damageData = DamageData.new()
		damageData.damage_value = damage
		## Finally, pass over that DamageData
		area.pass_DamageData(damageData)
		
		## If the Bullet still has some piercing power after this hit, let it continue
		if piercings_left > 0:
			piercings_left -= 1
		## This Bullet cannot pierce anymore. Time to be destroyed
		else:
			## And destroy the bullet
			queue_free()

## Check for Environment
func _on_body_entered(body: Node2D) -> void:
	if body:
		queue_free()


## When this Timer runs out, destroy the bullet to save on performance.
func _on_destroy_timer_timeout() -> void:
	queue_free()
