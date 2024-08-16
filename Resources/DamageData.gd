class_name DamageData
extends Resource

## Damage value. Subtract this from health
@export var damage_value: int = 0
## The point in which the Hitbox and the Hurtbox overlap (in global space) 
@export var hit_point: Vector2 = Vector2.ZERO
