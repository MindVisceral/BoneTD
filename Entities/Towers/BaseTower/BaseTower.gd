## TowerRangeVisuals scale dynamically in Editor to fit tower_range_collider
@tool
## Keep in mind that this 'Tower' is just a base building block - it can't do anything when placed.
class_name BaseTower
extends StaticBody2D

###-------------------------------------------------------------------------###
##### Editor-only variables
###-------------------------------------------------------------------------###

@export_group("Editor-only")

## How is this Tower named in-game? This name will show up in UI.
@export var ingame_name: String = "":
	set(w_name):
		if w_name != ingame_name:
			ingame_name = w_name
			update_configuration_warnings()

## Reference to the level's TowerHandler, the parent of this child Tower.
## This is an @export-ed variable (for when a Tower is placed by the level author),
## but it is overwritten by this Tower's TempTower when this Tower is placed and added as a child.
@export var tower_handler: TowerHandler = null:
	set(w_handler):
		if w_handler != tower_handler:
			tower_handler = w_handler
			update_configuration_warnings()

## This Button is visible in-editor, but invisible in-game (we just remove its Normal texture)
@export var tower_selection_button: TextureButton

###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## Collider of the Area which makes the Tower detect Enemies.
## Used to scale the TowerRangeVisuals on setup() to show the Tower's range to the Player
@export var tower_range_collider: CollisionShape2D

## Sprite, which shows the Tower's range to the Player. Scaled to the right size on setup()
@export var tower_range_visuals: Sprite2D

## Sprite of this Tower.
@export var tower_sprite: Sprite2D

## The Collider of this Tower.
@export var tower_collider: CollisionShape2D

## Point from which the Bullet will spawn.
@export var bullet_spawn_point: Marker2D

## Node which rotates to face the Enemy.
## NOTE: HERE: This way, TowerRange and TowerRangeVisuals don't rotate - this is vestigial
@export var rotation_pivot: Node2D

## Timer that keeps time until next shot
@export var ShotDelayTimer: Timer

## The mask/layer on which all 'Environment' Nodes are on.
@export_flags_2d_physics var environment_layer: int


###-------------------------------------------------------------------------###
##### Tower Variables
###-------------------------------------------------------------------------###

@export_group("Tower variables")

## Time until the next singular shot can be fired; Dictates how many shots per second there are.
## Value of '1' is one shot per second, '0.2' is five shots per second;
## (shot per second = 1.0 / shot_delay)
@export_range(0.05, 15.0, 0.01) var shot_delay: float = 1.0

## How much does this Tower cost to place? If the Player doesn't have
## at least this amount of Money, they can't place this Tower.
## NOTE: This is passed to the Tower's SelectButton.
@export_range(1, 99999, 1) var tower_base_cost: int = 1


###-------------------------------------------------------------------------###
##### Upgrades
###-------------------------------------------------------------------------###

@export_group("Upgrades")

## When this Tower is upgraded, it will be replaced by this "upgrade_1" Tower
@export var upgrade_1: PackedScene

## This String with a large TextEdit widget contains information about this Tower Upgrade 1.
## Information written in this text field will be displayed on the shared SelectedTower Menu.
@export_multiline var upgrade_1_details: String = "UPGRADE 1 DETAILS GO HERE"


## When this Tower is upgraded, it will be replaced by this "upgrade_2" Tower
@export var upgrade_2: PackedScene

## This String with a large TextEdit widget contains information about this Tower Upgrade 1.
## Information written in this text field will be displayed on the shared SelectedTower Menu.
@export_multiline var upgrade_2_details: String = "UPGRADE 2 DETAILS GO HERE"


###-------------------------------------------------------------------------###
##### Enemy-related Variables
###-------------------------------------------------------------------------###

@export_group("Enemy-related")

## Which Enemy in range should this Tower target?
## "First" means the Enemy that is furthest along the track
@export_enum("First", "Last") var target_priority: int = 0


###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

## Total amount of Money this Tower cost to place and upgrade.
var current_cost: int = 0

## Total amount of Money this Tower will give back when Sold
var sell_value: int = 0

## 1 pixel of TowerRange is worth '0.015625' in TowerRangeVisuals scale
## When TowerRange is 20px, TowerRangeVisuals scale is set to 0.3125
const range_to_range_visuals_rate: float = 0.015625

## All Enemies in range of this tower. The first entry in this Array is the first tower added.
var EnemiesInRangeArray: Array = []

## The Enemy which this Tower is currently targetting
var current_target: BaseEnemy

## Angle between this Tower and it's Target
var angle_to_current_target: float


###-------------------------------------------------------------------------###
##### Editor-only functions
###-------------------------------------------------------------------------###

## Show a warning when the Tower is not set up properly in the Editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if ingame_name == "":
		warnings.append("This Tower does not have its in-game name set!")
	
	if tower_handler == null:
		warnings.append("TowerHandler must be selected as an @export-ed variable
			when a Tower is placed in Editor!")
			
		
	
	return warnings


###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	## Only matters when not in Editor
	if not Engine.is_editor_hint():
		call_deferred("setup")
		
		## Set ShotDelayTimer's wait_time and start it up
		ShotDelayTimer.wait_time = shot_delay
		ShotDelayTimer.start()

## Setup this Tower
func setup() -> void:
	
	## Make sure this Tower's total cost is correct
	update_tower_cost()
	
	## The update_tower_visuals function is called whenever the TowerHandler
	## fires the new_tower_selected signal - which is when a new Tower is selected.
	tower_handler.new_tower_selected.connect(update_tower_visuals)
	
	## Remove this button's texture_normal to make it invisible in-game
	tower_selection_button.texture_normal = null
	
	## Make sure the TowerRangeVisuals Sprite is invisible
	tower_range_visuals.visible = false
	
	## And make all the UI invisible too
	update_tower_visuals()
	


###-------------------------------------------------------------------------###
##### Shooting functions
###-------------------------------------------------------------------------###

func _physics_process(delta: float) -> void:
	## If not in Editor...
	if !Engine.is_editor_hint():
		
		## If there is a current_target...
		if current_target:
			## And the shooting cooldown is over...
			if ShotDelayTimer.is_stopped():
				## Check if the Target can be seen from the Tower's position with a Ray.
				## The Tower cannot see from behind obstacles.
				if can_see_target() == true:
					shoot_at_target()
				
			
		
	

## A simple RayCast which checks for any Environmental Obstacles
## between the Tower and the current_target.
func can_see_target() -> bool:
	var can_tower_see_target: bool = true
	
	## Get the world's space_state. We need this to cast a Ray
	var space_state = get_world_2d().direct_space_state
	
	## The position from which the Ray will be cast.
	var start_pos: Vector2 = self.global_position
	#
	## The position at which the Ray will end.
	var end_pos: Vector2 = current_target.global_position
	#
	## The mask on which the Environment lies.
	## We don't care about anything else in the way, not even other Enemies.
	var mask: int = environment_layer
	
	## Put together all of those variables above.
	## NOTE: All the other default settings are fine. No need for changing body and area booleans.
	var parameters: PhysicsRayQueryParameters2D = \
		PhysicsRayQueryParameters2D.create(start_pos, end_pos, mask)
	
	
	## Cast a Ray with the 'parameters' variable as its parameters
	var result = space_state.intersect_ray(parameters)
	
	## If the RayCast detects any obstacles (that are on the Environment layer),
	## then the Tower cannot see its Target.
	if result:
		can_tower_see_target = false
	
	
	## Return a boolean - can the Tower see its Target?
	return can_tower_see_target


## This function makes the Tower shoot its Target.
func shoot_at_target() -> void:
	
	## First, we must determine variables that all types of Towers need to shoot at Targets.
	angle_to_current_target = self.global_position.angle_to_point(current_target.global_position)
	
	## Fire a Bullet - this function is a dummy! Read its NOTE down below.
	## We use a dummy function, because it must be called here, before the ShotDelayTimer starts.
	fire()
	
	## Start the Timer again
	ShotDelayTimer.start()
	


## NOTE: This is a dummy function! The actual firing function is located in the inheriting
## NOTE: Towers, and this function's code depends on that Tower's code.
func fire() -> void:
	pass


###-------------------------------------------------------------------------###
##### Targetting functions
###-------------------------------------------------------------------------###

## When TowerRange sees a new Enemy in range...
func new_enemy_in_range(Enemy: BaseEnemy) -> void:
	EnemiesInRangeArray.append(Enemy)
	
	#print("ENTERED")
	
	## A new Enemy has entered the Tower's range. Check if it should become the new current_target
	change_current_target()

## When TowerRange sees an Enemy is out of range...
func new_enemy_out_of_range(Enemy: BaseEnemy) -> void:
	EnemiesInRangeArray.erase(Enemy)
	
	#print("EXITED")
	
	## This Enemy which just went out of range may have been the current_target.
	change_current_target()

## Pick a new current_target depending on this Tower's target_priority variable.
func change_current_target() -> void:
	## Forget about the current_target to avoid bugs.
	current_target = null
	
	## First, check if there are any Enemies within range that can be targetted
	if !EnemiesInRangeArray.is_empty():
		## Second, check this Tower's targetting priority
		match target_priority:
			## If this Tower is set to "First"...
			0:
				## Set the current target to the Enemy that is furthest along the track
				## (The Enemy that was added to the EnemiesInRangeArray earliest)
				current_target = EnemiesInRangeArray[0]
			## If this Tower is set to "Last"...
			1:
				## Set the current target to the first Enemy within this Tower's range
				## (The Enemy that was added to the EnemiesInRangeArray latest)
				current_target = EnemiesInRangeArray.back()



###-------------------------------------------------------------------------###
##### Visuals and selection functions
###-------------------------------------------------------------------------###

## Tower's visuals that are updated every frame.
func _process(delta: float) -> void:
	
	## Update visuals when in Editor. NOTE: EDITOR-ONLY!
	if Engine.is_editor_hint():
		update_tower_visuals()
		
	
	## The Tower's sprite could be updated every physics frame,
	## along with the direction variable upon which it depends, but that would be unperformative.
	## NOTE: HERE: This is bullshit because there is no direction var yet.
	## NOTE: There is angle_to_current_target though
	update_tower_sprite()

## HERE: WIP!
func update_tower_sprite() -> void:
	pass


## When the Tower is instantiated (including 'upgrades') or when it's otherwise changed,
## some of its visuals must be updated.
## NOTE: This function shouldn't be used every frame, though it is used that way in the Editor!
## NOTE: During regular play, it depends on signals.
func update_tower_visuals() -> void:
	## TowerRangeVisuals must match TowerRange collider's radius.
	## To this end, we scale TowerRangeVisuals Sprite2D by the right amount, which I determinted to
	## be equal to range_to_range_visuals_rate.
	## NOTE: This value depends on the the actual TowerRangeVisuals Texture's resolution!
	## NOTE: If that is changed, range_to_range_visuals_rate must be changed too.
	if tower_range_collider.shape: ## This is here to avoid constant errors *in Editor*.
		tower_range_visuals.scale = Vector2( \
			tower_range_collider.shape.radius * range_to_range_visuals_rate, 
			tower_range_collider.shape.radius * range_to_range_visuals_rate)
			
		
	
	## Everything that follows only matters when not in the Editor!
	if not Engine.is_editor_hint():
		
		## If this Tower specifically is currently selected...
		if tower_handler.selected_tower_ref == self:
			## Make this Tower's TowerRangeVisuals visible
			tower_range_visuals.visible = true
				
			
		## Otherwise, when this Tower is not selected...
		else:
			## Make this Tower's TowerRangeVisuals invisible
			tower_range_visuals.visible = false
			
		
		
		## HERE:
		## presumably, bullet sprite should be included here too (???) - NOTE: Not anymore! Ignore.
		## among other stuff. Function WIP!
		
	


## When this Tower's TowerSelectionButton is pressed...
func _on_tower_selection_pressed() -> void:
	
	## A Tower can only be selected if the Player isn't already trying to place a Tower.
	if tower_handler.player_placing_tower == false:
		## Make it known that this Tower is currently selected
		tower_handler.selected_tower_ref = self
		
	
	## Other Towers must know that they are not selected!
	## This signal is connected to each Tower's update_tower_visuals() function.
	## So this signal makes every Tower update its visuals, including this one!
	tower_handler.new_tower_selected.emit()


###-------------------------------------------------------------------------###
##### Upgrade functions
###-------------------------------------------------------------------------###

## Both of these functions upgrade this Tower by one level, but each option offers a different path.
## Practically, this just instantiates a new, better Tower and deletes this Tower.
## These functions are called by the level's TowerHandler, which is connected to the Upgrade Menu,
## shared by all Towers.
## 
func upgrade_1_tower() -> void:
	var replacement_upgrade_tower: BaseTower = upgrade_1.instantiate()
	
	replacement_upgrade_tower.global_position = self.global_position
	replacement_upgrade_tower.tower_handler = self.tower_handler
	
	## And finally create this new "upgraded" Tower
	tower_handler.add_child(replacement_upgrade_tower)
	## And now we can get rid of this Tower.
	destroy_tower()
#
func upgrade_2_tower() -> void:
	var replacement_upgrade_tower: BaseTower = upgrade_2.instantiate()
	
	replacement_upgrade_tower.global_position = self.global_position
	replacement_upgrade_tower.tower_handler = self.tower_handler
	
	## And finally create this new "upgraded" Tower
	tower_handler.add_child(replacement_upgrade_tower)
	## And now we can get rid of this Tower.
	destroy_tower()


###-------------------------------------------------------------------------###
##### Sell functions
###-------------------------------------------------------------------------###

## Sell this Tower.
## The SellButton is manually signal connected to this function.
func sell_tower() -> void:
	## Calculate how much this Tower cost and how much it will sell for
	update_tower_cost()
	
	## Give the Player the rigth amount of Money, equivalent to this Tower's sell_value
	Globals.gain_money(sell_value)
	## Now we may delete this Tower.
	destroy_tower()


## Recalculate how much this Tower costs at the moment
func update_tower_cost() -> void:
	## First, reset current_cost back to this Tower's base cost
	current_cost = tower_base_cost
	## Add up the cost of all individual upgrades
	current_cost
	
	
	## Recalculate how much Money this Tower will give back when Sold,
	## rounded to the nearest(?) full integer.
	sell_value = snappedi(current_cost * Globals.level_sell_multiplier, 1.0)


###-------------------------------------------------------------------------###
##### Destroy Tower
###-------------------------------------------------------------------------###

## For whatever reason, this Tower must be queue_free()-d. Typically it's because it was sold.
func destroy_tower() -> void:
	## TowerHandler should forget about this Tower before we queue_free() it.
	tower_handler.selected_tower_ref = null
	
	## Ignore the signal's name. This is here just to disable all Menus that rely on this Tower,
	## like the SelectedTowerMenu.
	## NOTE: As things are currently, this also updates all other Towers' visuals!
	## NOTE: HERE: Make a new signal if that is undesirable.
	tower_handler.new_tower_selected.emit()
	
	
	queue_free()
