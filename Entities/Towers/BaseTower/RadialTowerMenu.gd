class_name RadialTowerMenu
extends TextureButton

## Radius of the Menu; how large it is
@export var menu_radius: int = 120
## How fast the Buttons animate
@export var speed: int = 0.25

## How many Buttons (besides the main RadialTowerMenu Button) there are
var number_of_buttons: int

## Is the main RadialTowerMenu Button pressed?
var active: bool = false

func _ready() -> void:
	$Buttons.hide()
	number_of_buttons = $Buttons.get_child_count()
	
	for button: TextureButton in $Buttons.get_children():
		button.position = self.position

## When main Button is pressed
func _on_pressed() -> void:
	self.disabled = true
	if active == true:
		hide_menu()
	elif active == false:
		show_menu()

func show_menu() -> void:
	var spacing = TAU / number_of_buttons
	
	for button: TextureButton in $Buttons.get_children():
		var a = spacing * button.get_index() - PI/2
		var dest = button.position + Vector2(menu_radius, 0).rotated(a)
		
		## create a tween
		var tween = get_tree().create_tween()
		## tween pos from center to distance
		tween.tween_property(button, "position", dest, speed)
		## tween scale from 0 to 1
		tween.tween_property(button, "scale", Vector2.ONE, speed)
	
	$Buttons.show()

func hide_menu() -> void:
	pass
















