class_name TempTower
extends Area2D

## This Tower will be placed at TempTower's position when the Player wants to place it.
## This is passed by each Tower's SelectButton
var tower_to_be_placed: PackedScene



## 
func _physics_process(delta: float) -> void:
	## Keep this TempTower at the mouse's global position at all times.
	self.global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("LMB"):
		var new_tower: BaseTower = tower_to_be_placed.instantiate()
		
		new_tower.global_position = self.global_position
		get_tree().get_root().add_child(new_tower)
		
		self.queue_free()
