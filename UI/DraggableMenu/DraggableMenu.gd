class_name DraggableMenu
extends Control


###-------------------------------------------------------------------------###
##### Menu variables
###-------------------------------------------------------------------------###

## A simple boolean - should the Menu follow the mouse right now?
## Toggled when the DragButton is pressed/released.
var follow_mouse: bool = false

## The mouse pointer's local position relative to the Menu's top left corner.
## Without this, if you were to click and drag the Menu by its ex. middle point,
## the Menu would snap and it would be dragged by its top left corner.
var mouse_pos_offset: Vector2 = Vector2.ZERO


###-------------------------------------------------------------------------###
##### Core - Menu Movement
###-------------------------------------------------------------------------###

func _physics_process(delta: float) -> void:
	## When the Player wants to drag this Menu...
	if follow_mouse == true:
		## Just make this Menu follow the Mouse;
		## and take into account the offset from the Menu's top left corner.
		self.global_position = get_global_mouse_position() - mouse_pos_offset


###-------------------------------------------------------------------------###
##### Menu dragging toggle
###-------------------------------------------------------------------------###

## Button pressed down, make menu follow the mouse
func _drag_button_held() -> void:
	## Reset mouse_pos_offset
	mouse_pos_offset = Vector2.ZERO
	
	## Register the mouse's position relative to the Menu's origin
	mouse_pos_offset = get_local_mouse_position()
	
	follow_mouse = true

## Button released, make menu stop following the mouse
func _drag_button_released() -> void:
	## Reset mouse_pos_offset
	mouse_pos_offset = Vector2.ZERO
	
	follow_mouse = false
