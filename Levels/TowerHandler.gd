class_name TowerHandler
extends Node2D

@export_group("References")

## New Towers will be added as children of the 'Towers' Node
@export var towers_node_reference: Node2D

## Different Towers that can be used in this level
@export var tower_scenes: Array[PackedScene]



func _ready() -> void:
	call_deferred("initialize")

## We use this instead of _ready() to avoid bugs.
func initialize() -> void:
	pass
