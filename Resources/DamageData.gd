class_name DamageData
extends Resource

## Damage value. Subtract this from the Target's health
@export_range(0.5, 9999.0, 0.5) var damage_value: float = 1.0

## This effect of class BaseHitEffect is instantiated at the hit_point.
## Effect is chosen at the Tower-level but instantiated by the Enemy
@export var hit_effect: PackedScene


### The point at which the Hitbox and the Hurtbox overlap (in global space) .
#var hit_point: Vector2 = Vector2.ZERO
## HERE: Not used anywhere yet. The Enemy already places the right hit_effect at its own hit_point
## without the need for this.
