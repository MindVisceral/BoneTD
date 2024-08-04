class_name TempTower
extends Area2D

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

## Sprite, which shows the Tower's range to the Player. Must be scaled to the right size.
@export var tower_range_visuals: Sprite2D

## Sprite of the TempTower. Can just be swapped for the Tower's Sprite.
@export var tower_sprite: Sprite2D

## TempTower's Collider. Can just be made the same as the Tower's own Collider
@export var tower_collider: CollisionShape2D


###-------------------------------------------------------------------------###
##### Received variables
###-------------------------------------------------------------------------###

## This Tower will be placed at TempTower's position when the Player wants to place it.
## This is passed by the TowerHandler
var tower_to_be_placed: PackedScene

## New Towers will be added as children of the TowerHandler Node
var tower_handler: TowerHandler

## The Tower's base cost. Passed down from SelectButton, used when selling the Tower.
var tower_base_cost: int

###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

## The Menu and other UI elements are Areas. If this is true, then the Tower can be placed.
var areas_clear: bool = true
#
## Towers and the Environment are Bodies. If this is true, then the Tower can be placed.
var bodies_clear: bool = true

## This holds an instance of the Tower which will be spawned by this Node.
## Also used to change this TempTower's Sprite, TowerRangeVisuals scale, and Collider size
var new_tower: BaseTower

###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	## Register that the Player is currently holding and trying to place a Tower
	tower_handler.player_placing_tower = true
	
	call_deferred("setup")

## - and
## make sure all the Visuals match the Tower's visuals
func setup() -> void:
	
	## After everything is _ready(), instantiate a tower_to_be_placed.
	## Now we can edit this TempTower's children nodes to be the same as the new_tower's.
	## NOTE: This new_tower is global in this script and it will be used when placing the Tower
	new_tower = tower_to_be_placed.instantiate()
	
	## This new_tower requires tower_handler to function
	new_tower.tower_handler = self.tower_handler
	
	## And it needs to know its base cost.
	new_tower.tower_base_cost = tower_base_cost
	
	## We manually make the new_tower update it's visuals.
	## Await-ing for that to be done on _ready() doesn't seem to work.
	new_tower.update_tower_visuals()
	
	## TowerRangeVisuals must match the Tower's tower_range_visuals
	tower_range_visuals.scale = new_tower.tower_range_visuals.scale
	## Scale the Sprite to the right size and set it to the Tower's Sprite
	## NOTE: Scale first! Doesn't work properly otherwise.
	tower_sprite.scale = new_tower.tower_sprite.scale
	tower_sprite = new_tower.tower_sprite
	## Set the Collider shape to be the same as the Tower's
	tower_collider.shape = new_tower.tower_collider.shape


###-------------------------------------------------------------------------###
##### TempTower core functions
###-------------------------------------------------------------------------###

## Make this Node follow the mouse until it's queue_free()-d
func _physics_process(delta: float) -> void:
	## Keep this TempTower at the mouse's global position at all times.
	self.global_position = get_global_mouse_position()

## This Node relies on Player Input
## This is under _unhandled_input, because we don't want the Tower to be placed
## under UI elements.
func _unhandled_input(event: InputEvent) -> void:
	## Placing button pressed; instantiate the right Tower and kill this Node
	if Input.is_action_just_pressed("LMB"):
		if areas_clear == true and bodies_clear == true:
			
			## Place the Tower [it was already instantiated on _setup()]
			new_tower.global_position = self.global_position
			new_tower.tower_handler = self.tower_handler
			tower_handler.add_child(new_tower)
			tower_handler.all_placed_towers.append(new_tower)
			
			## Placing a Tower costs Money.
			Globals.lose_money(new_tower.tower_base_cost)
			
			## Get things back to status quo
			tower_handler.player_placing_tower = false
			self.queue_free()
		
	
	## Cancel placing the Tower.
	elif Input.is_action_just_pressed("RMB"):
		tower_handler.player_placing_tower = false
		self.queue_free()


###-------------------------------------------------------------------------###
##### Stuff-in-the-way functions
###-------------------------------------------------------------------------###

## Touches a Menu, can't be placed.
func _on_area_entered(area: Area2D) -> void:
	areas_clear = false
#
## All Areas clear, can be placed now.
func _on_area_exited(area: Area2D) -> void:
	areas_clear = true

## Touches another Tower or the Environment, can't be placed.
func _on_body_entered(body: Node2D) -> void:
	bodies_clear = false
#
## All Bodies clear, can be placed now.
func _on_body_exited(body: Node2D) -> void:
	bodies_clear = true


