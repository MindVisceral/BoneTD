class_name TowerDetectionArea
extends Area2D


## A reference to the Tower
@export var Tower: BaseTower

## When an Enemy (specifically the Enemy's EnemyDetectedArea) enters this Area's range...
func _on_entered(area: EnemyDetectedArea) -> void:
	## Tell the Tower what changed
	if area is EnemyDetectedArea:
		Tower.new_enemy_in_range(area.Entity)

## When an Enemy (specifically the Enemy's EnemyDetectedArea) exits this Area's range...
func _on_exited(area: EnemyDetectedArea) -> void:
	## Tell the Tower what changed
	if area is EnemyDetectedArea:
		Tower.new_enemy_out_of_range(area.Entity)
