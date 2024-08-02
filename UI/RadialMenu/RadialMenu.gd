class_name RadialTowerMenu
extends TextureButton

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("References")

## Reference to the Buttons Control Node, which all the radial Buttons are children of.
@export var buttons_node: Control

## Reference to the Radial Buttons around the Main Button.
## 
@export var radial_button_reference: PackedScene


@export_group("Button settings")

## How many Buttons there are around the Main Button
@export var number_of_radial_buttons: int = 3

## Radius of the Menu;
## how far away the centers of Radius Buttons will be away from the center of the Main Button
@export var menu_radius: int = 120
## How fast the Buttons animate in seconds. '0' is instant
@export_range(0, 10, 0.05) var speed: float = 0.25


###-------------------------------------------------------------------------###
##### Regular variables & flags
###-------------------------------------------------------------------------###

## Array of all the Radial Buttons. Used when looping through all the Buttons.
var radial_buttons: Array[TextureButton]

## How many Buttons (besides the main RadialTowerMenu Button) there are
var number_of_buttons: int

## Is the main RadialTowerMenu Button pressed?
var active: bool = false


###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

## Prepare everything
func _ready() -> void:
	## Enable the Main Button, just in case.
	self.disabled = false
	
	## Hide the radial Buttons
	buttons_node.hide()
	## Calculate how many buttons there are.
	number_of_buttons = buttons_node.get_child_count()
	## Store all the Radial Buttons (children of exported buttons_node) in the radial_buttons Array
	for button: TextureButton in buttons_node.get_children():
		radial_buttons.append(button)
	
	
	## Put every Button in the same position as the main RadialTowerMenu Button,
	## and make sure it's the middle of that Button by adding its pivot_offset.
	## Make every Button's scale 0 to make sure the show_menu() animation looks the same every time
	for button: TextureButton in radial_buttons:
		button.position = self.position + self.pivot_offset
		button.scale = Vector2.ZERO
	


###-------------------------------------------------------------------------###
##### Enable/Disable this Radial Menu
###-------------------------------------------------------------------------###

## When main Button is pressed...
func _on_pressed() -> void:
	#toggle_main_button()
	pass


## Toggle the Main Button, animate the Radial buttons
func toggle_main_button() -> void:
	## Disable the Button so that it can't be pressed when it's in a middle of the animation
	## hide_menu() and show_menu() functions enable it again.
	self.disabled = true
	
	## Simple switch. We either hide or show the Menu, depending on if it's active or not.
	if active == true:
		hide_menu()
	elif active == false:
		show_menu()
		
	

## Instead of toggling, enable the button.
func enable() -> void:
	self.disabled = true
	#self.active = true
	show_menu()

## Instead of toggling, disable the button.
func disable() -> void:
	self.disabled = true
	#self.active = false
	hide_menu()



## Clicking the Button when the Radial Menu is inactive will activate it
func show_menu() -> void:
	## First we need to calculate the number of degrees between each individual radial buttons
	var spacing = TAU / number_of_buttons
	
	## First we can show all the Buttons. They're scaled to 0, so they're invisible anyway.
	buttons_node.show()
	
	## For every Button...
	for button: TextureButton in radial_buttons:
		## We find this Button's rotation in the circle.
		## We take the spacing between the Buttons,
		## and multiply it as the Button's order among its siblings increases.
		## Then we subtract that by 90 degrees,
		## so the first Button's position is above the Main RadialTowerMenu Button
		var rotation_in_circle = spacing * button.get_index() - PI/2
		## Now that we have the Button's rotation in the circle, we must put it in its position.
		## We take the Button's position [which is the same as the Main Button's - check _ready()],
		## we add our target radius to that. Then we rotate it by rotation_in_circle we just got.
		var dest = button.position + Vector2(menu_radius, 0).rotated(rotation_in_circle)
		
		## Create a Tween, which will animate the Button
		var tween = get_tree().create_tween()
		## The Button will travel from the center to its destination at set speed.
		tween.parallel().tween_property(button, "position", dest, speed)
		## And the Button is scaled so it doesn't pop out of nowhere, also at speed.
		tween.parallel().tween_property(button, "scale", Vector2.ONE, speed)
		
	
	## Now we wait until the animation is done. Since each Button has a separate Tween made for it,
	## we can't wait for a Tween's 'finished' signal. So we just use the 'speed' variable.
	await get_tree().create_timer(speed).timeout
	
	## The animation is finished, we can enable the Main Button again
	self.disabled = false
	## The Radial Buttons are visible, so the Radial Menu is considered 'active'
	active = true

## Clicking the Button when the Radial Menu is active will deactivate it
func hide_menu() -> void:
	## For every Button...
	for button in radial_buttons:
		
		## Create a Tween, which will animate the Button
		var tween = get_tree().create_tween()
		## The Button will travel from its position to the center at set speed.
		## NOTE: Main Button's pivot_offset is added so that Button's center is its actual center
		tween.parallel().tween_property(button, "position", self.position + self.pivot_offset, speed)
		## And the Button is scaled so it doesn't visibly pop out of existance, also at speed.
		tween.parallel().tween_property(button, "scale", Vector2.ZERO, speed)
		
	
	## Now we wait until the animation is done. Since each Button has a separate Tween made for it,
	## we can't wait for a Tween's 'finished' signal. So we just use the 'speed' variable.
	## NOTE: We ask the Globals Autoload to get_tree(), because TempTower calls a Tower's
	## NOTE: update_tower_visuals() function before that Tower is added to the Tree, which calls
	## NOTE: this hide_menu function, which crashes the game, because it can't get_tree(). Annoying.
	await Globals.get_tree().create_timer(speed).timeout
	
	## Everything is done animating, we can hide the Buttons now
	buttons_node.hide()
	
	## The animation is finished, we can enable the Main Button again
	self.disabled = false
	## The Radial Buttons are invisible, so the Radial Menu is considered not 'active'
	active = false
