class_name WaveHandler
extends Node2D

@export var path_reference: Path2D

@export var enemy_scene: PackedScene

@export var enemy_number: int = 6
@export var time_between_enemy_spawns: float = 0.8

@export var time_before_wave_start: float = 1.5

func _ready() -> void:
	for i in enemy_number:
		if i != 0:
			await get_tree().create_timer(time_between_enemy_spawns).timeout
		else:
			await get_tree().create_timer(time_before_wave_start).timeout
		
		var new_enemy = enemy_scene.instantiate()
		path_reference.add_child(new_enemy)
