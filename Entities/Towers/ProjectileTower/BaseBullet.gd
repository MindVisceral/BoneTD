class_name BaseBullet
extends Area2D


## NOTE: This BaseBullet has no movement code!
## Movement is Bullet-specific, so use the right inherited Bullet for any movement pattern you need


###-------------------------------------------------------------------------###
##### Base Bullet References
###-------------------------------------------------------------------------###

## The Texture which this Bullet's Sprite will use. icon.svg is used by default
@export var sprite_texture: CompressedTexture2D = preload("res://icon.svg")


###-------------------------------------------------------------------------###
##### Base Bullet Variables
###-------------------------------------------------------------------------###

## Bullet's base movement speed
@export var speed: int = 80

## Default damage dealt by this bullet
@export var damage: int = 1

## How many times this Bullet can go through an Enemy/Enemies before it breaks and disappears.
## "0" means that this Bullet does not pierce - it deals damage once and is destroyed,
## "1" means that this Bullet can deal damage up to two times and it's destroyed on the second hit
@export var piercings_left: int = 0


###-------------------------------------------------------------------------###
##### Onready Variables
###-------------------------------------------------------------------------###

@onready var sprite: Sprite2D = $Sprite


###-------------------------------------------------------------------------###
##### Setup function
###-------------------------------------------------------------------------###

func _ready() -> void:
	sprite.texture = sprite_texture


###-------------------------------------------------------------------------###
##### Enemy interaction
###-------------------------------------------------------------------------###

## Check for Enemies. This is just a basic check - replace when needed.
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
		## This Bullet cannot pierce anymore. Time for it to be destroyed.
		else:
			destroy_bullet()


###-------------------------------------------------------------------------###
##### Environment interaction
###-------------------------------------------------------------------------###

## Check for Environment. The Bullet is destroyed by default.
func _on_body_entered(body: Node2D) -> void:
	if body:
		destroy_bullet()


###-------------------------------------------------------------------------###
##### Bullet destruction
###-------------------------------------------------------------------------###

## When the Bullet has served its function - hit an Enemy or an Environmental obstacle
func destroy_bullet() -> void:
	queue_free()

## When this Timer runs out, destroy the bullet to save on performance.
## No need for special effects - destroy_bullet() is for that.
func _on_destroy_timer_timeout() -> void:
	queue_free()
