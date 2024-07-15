class_name TempTower
extends Area2D

## This Tower will be placed at TempTower's position when the Player wants to place it.
## This is passed by the TowerHandler
var tower_to_be_placed: PackedScene

## New Towers will be added as children of the 'Towers' Node. The TowerHandler passes this.
var towers_node_reference: Node2D


## The Menu and other UI elements are Areas. If this is true, then the Tower can be placed.
var areas_clear: bool = true

## Towers and the Environment are Bodies. If this is true, then the Tower can be placed.
var bodies_clear: bool = true

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
		if areas_clear == true and bodies_clear == true:
			var new_tower: BaseTower = tower_to_be_placed.instantiate()
			
			new_tower.global_position = self.global_position
			towers_node_reference.add_child(new_tower)
			
			self.queue_free()
	
	## Cancel placing the Tower.
	elif Input.is_action_just_pressed("RMB"):
		self.queue_free()


## Touches a Menu, can't be placed.
func _on_area_entered(area: Area2D) -> void:
	areas_clear = false
	print("areas taken")

## All Areas clear, can be placed now.
func _on_area_exited(area: Area2D) -> void:
	areas_clear = true
	print("areas clear")


## Touches another Tower or the Environment, can't be placed.
func _on_body_entered(body: Node2D) -> void:
	bodies_clear = false
	print("bodies taken")

## All Bodies clear, can be placed now.
func _on_body_exited(body: Node2D) -> void:
	bodies_clear = true
	print("bodies clear")
