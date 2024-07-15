class_name TempTower
extends Area2D

## This Tower will be placed at TempTower's position when the Player wants to place it.
## This is passed by the TowerHandler
var tower_to_be_placed: PackedScene

## New Towers will be added as children of the 'Towers' Node. The TowerHandler passes this.
var towers_node_reference: Node2D


func _ready() -> void:
	pass

## Make this Node follow the mouse until it's queue_free()-d
func _physics_process(delta: float) -> void:
	## Keep this TempTower at the mouse's global position at all times.
	self.global_position = get_global_mouse_position()

## Wait for Input
func _input(event: InputEvent) -> void:
	## Placing button pressed; instantiate the right Tower and kill this Node
	if Input.is_action_just_pressed("LMB"):
		var new_tower: BaseTower = tower_to_be_placed.instantiate()
		
		new_tower.global_position = self.global_position
		towers_node_reference.add_child(new_tower)
		
		self.queue_free()
	
	## Cancel placing the Tower.
	elif Input.is_action_just_pressed("RMB"):
		self.queue_free()
