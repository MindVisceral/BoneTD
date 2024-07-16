class_name TowerRange
extends Area2D


## A reference to the Tower
@export var Tower: BaseTower

## Reference to this Area's Collider.
## Necessary to be known by the Tower to show the Tower's range with a Sprite
@export var collider: CollisionShape2D


## When an Enemy (specifically the Enemy's EnemyDetectedArea) enters this Area's range...
func _on_entered(area: EnemyDetectedArea) -> void:
	print("IN RANGE")
	## Tell the Tower what changed
	if area is EnemyDetectedArea:
		Tower.new_enemy_in_range(area.Entity)

## When an Enemy (specifically the Enemy's EnemyDetectedArea) exits this Area's range...
func _on_exited(area: EnemyDetectedArea) -> void:
	print("OUTTA RANGE")
	## Tell the Tower what changed
	if area is EnemyDetectedArea:
		Tower.new_enemy_out_of_range(area.Entity)
