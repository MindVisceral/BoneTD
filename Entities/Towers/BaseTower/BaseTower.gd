## TowerRangeVisuals scale dynamically in Editor to fit tower_range_collider
@tool
## Keep in mind that this 'Tower' is just a base building block - it can't do anything when placed.
class_name BaseTower
extends StaticBody2D

###-------------------------------------------------------------------------###
##### Editor-only variables
###-------------------------------------------------------------------------###

@export_group("Editor-only")

## Reference to the level's TowerHandler, the parent of this child Tower.
## This is an @export-ed variable (for when a Tower is placed by the level author),
## but it is overwritten by this Tower's TempTower when this Tower is placed and added as a child.
@export var tower_handler: TowerHandler = null:
	set(p_handler):
		if p_handler != tower_handler:
			tower_handler = p_handler
			update_configuration_warnings()

## This Button is visible in-editor, but invisible in-game (we remove its Normal texture)
@export var tower_selection_button: RadialTowerMenu

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


###-------------------------------------------------------------------------###
##### Upgrades
###-------------------------------------------------------------------------###

@export_group("Upgrades")

## When this Tower is upgraded, it will be replaced by this "upgrade_1" Tower
@export var upgrade_1: PackedScene

## When this Tower is upgraded, it will be replaced by this "upgrade_2" Tower
@export var upgrade_2: PackedScene


###-------------------------------------------------------------------------###
##### Enemy-related Variables
###-------------------------------------------------------------------------###

@export_group("Enemy-related")

## Which Enemy in range should this Tower target?
## "First" means the Enemy that is furthest along the track
@export_enum("First", "Last") var target_priority: int = 0


###-------------------------------------------------------------------------###
##### Shooting Variables
###-------------------------------------------------------------------------###

@export_group("Base Shooting")

## Time until the next singular shot can be fired
@export_range(0.05, 15.0, 0.05) var shot_delay: float = 1.0


###-------------------------------------------------------------------------###
##### Bullet Variables
###-------------------------------------------------------------------------###

@export_group("Bullet stuff")

## Default damage dealt by the bullet
@export_range(0, 9999, 1) var bullet_damage: int = 1

## How many times a Bullet created by this Tower can go through an Enemy/Enemies before breaking.
## "0" means that this Bullet does not pierce - it deals damage once and is destroyed,
## "1" means that this Bullet can deal damage up to two times and it's destroyed on the second hit
@export_range(0, 9999, 1) var bullet_piercing_amount: int = 0


###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

## How much did this Tower cost to place?
## This is passed down from this Tower's SelectButton, which instantiates it in the first place.
var tower_base_cost: int = 1

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
	
	if tower_handler == null:
		warnings.append("TowerHandler must be selected as an @export-ed variable
			when a Tower is placed in Editor!")
			
		
	
	return warnings


###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	
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
	
	## Remove this button's texture_normal on _ready to make it invisible in-game
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
			
			## Shot at the current_target, if possible.
			if ShotDelayTimer.is_stopped():
				shoot_at_target()
				
			
		
	

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
## NOTE: Towers, and this functions code depends on that Tower's code.
func fire() -> void:
	pass


###-------------------------------------------------------------------------###
##### Targetting functions
###-------------------------------------------------------------------------###

## When TowerRange sees a new Enemy in range...
func new_enemy_in_range(Enemy: BaseEnemy) -> void:
	EnemiesInRangeArray.append(Enemy)
	
	print("ENTERED")
	
	## A new Enemy has entered the Tower's range. Check if it should become the new current_target
	change_current_target()

## When TowerRange sees an Enemy is out of range...
func new_enemy_out_of_range(Enemy: BaseEnemy) -> void:
	EnemiesInRangeArray.erase(Enemy)
	
	print("EXITED")
	
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


## When the Tower is instantiated (including 'upgrades') or otherwise changed,
## some of its visuals must be updated.
## NOTE: This function shouldn't be used every frame, though it is used that way in the Editor!
## NOTE: During regular play, it should work more like signals.
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
		
		## NOTE: Toggle TowerRangeVisuals visibility - it only matters when Tower is selected;
		## If a Tower is selected...
		if tower_handler.player_selected_tower == true:
			## And the selected Tower is this Tower...
			if tower_handler.selected_tower_ref == self:
				## Make this Tower's TowerRangeVisuals visible
				tower_range_visuals.visible = true
				## And enable the Tower's Radial Menu, if it's not enabled (active) already.
				## NOTE: Without this, the Radial buttons just get further and further away from
				## NOTE: the Main Button, because they're animated with Tweens. Could be useful?
				if tower_selection_button.active == false:
					tower_selection_button.enable()
					
				
			
			## Otherwise, when this Tower is not selected...
			else:
				## Make this Tower's TowerRangeVisuals invisible
				tower_range_visuals.visible = false
				## And disable this Tower's Radial Menu
				tower_selection_button.disable()
			
		
		
		## HERE:
		## presumably, bullet sprite should be included here too (???),
		## among other stuff. Function WIP!


## When this Tower's TowerSelectionButton is pressed...
func _on_tower_selection_pressed() -> void:
	
	## A Tower can only be selected if the Player isn't already trying to place a Tower.
	if tower_handler.player_placing_tower == false:
		## Make it known that a Tower is currently selected and that it is this Tower
		tower_handler.player_selected_tower = true
		tower_handler.selected_tower_ref = self
		
	
	## Other Towers must know that they are not selected!
	tower_handler.new_tower_selected.emit()
	
	## And finally, update this Tower's visuals
	update_tower_visuals()


###-------------------------------------------------------------------------###
##### Upgrade functions
###-------------------------------------------------------------------------###

## Both of these functions upgrade this Tower by one level, but each option offers a different path.
## Practically, this just instantiates a new, better Tower and deletes this Tower.
## The right UpgradeButton is manually signal-connected to its respective function.
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
	queue_free()
