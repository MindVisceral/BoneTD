class_name BaseEnemy
extends PathFollow2D


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## The Enemy's HitPoint - a HitEffect will be instantiated at this Marker's position.
## HERE: Maybe - don't know how this hould work yet.
@export var hit_point: Marker2D


###-------------------------------------------------------------------------###
##### Exported stats
###-------------------------------------------------------------------------###

### Movement variables
@export_group("Base movement")

## Enemy speed in pixels travelled every frame
@export_range(5, 9999, 1) var speed: int = 20


@export_group("Health")

## This Enemy's maximum health
@export_range(1, 9999, 1) var max_health: int = 1


@export_group("Damage")

## Amount of damage this Enemy deals to the Player
@export_range(1, 9999, 1) var damage: int = 1


@export_group("Money")

## Amount of Money the Player gains from killing this Enemy
@export_range(0, 999999999, 1) var default_money: int = 5


###-------------------------------------------------------------------------###
##### Actual stats
###-------------------------------------------------------------------------###

## How much Health does this Enemy have remaining?
var current_health: int = 1


###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## The Enemy's position last frame. Used to calculate the 'direction' variable.
var position_last_frame: Vector2

## The Enemy's direction of movement. Required for the right Enemy 'rotation' sprite to be used.
var direction: Vector2 = Vector2.ZERO

## The Enemy's velocity. Used, along with the 'direction' variable, by Towers to predict
## the Enemy's position. This allows Towers that shoot projectiles to hit Enemies more reliably.
var velocity: Vector2 = Vector2.ZERO


###-------------------------------------------------------------------------###
##### Misc. variables
###-------------------------------------------------------------------------###

## This Enemy was spawned by this specific Round, and it wants to know when this Enemy dies
## so that it can be queue_free()-d whan all its spawned Enemies are dead.
var enemy_round: BaseRound


###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	apply_stats()
	
	## Update 'position_last_frame' variable.
	position_last_frame = self.global_position

## When this Enemy is ready, apply their Exported Stats to Actual Stats
func apply_stats() -> void:
	current_health = max_health


###-------------------------------------------------------------------------###
##### Movement
###-------------------------------------------------------------------------###

## The Enemy's movement behaviour.
func _physics_process(delta: float) -> void:
	## Move the Enemy along the Level's path
	progress += speed * delta
	
	## Calculate the Enemy's movement direction (and velocity).
	## To get 'direction', we create a Vector2 out of
	## the Enemy's current position and their position last frame.
	#
	## Find the 'direction' vector, which is just a vector
	## pointing from position_last_frame to position_this_frame
	direction = self.global_position - position_last_frame
	direction.normalized()
	
	## HERE: I'm not sure if this even works!
	## Calculate velocity from the Enemy's direction and speed, taking delta into account.
	## NOTE: That part in parentheses must be the same as the Enemy's 'progress' line above.
	#velocity = direction * (speed * delta)
	velocity = direction * speed
	
	
	## NOTE, HERE: This is checked every frame, so performance may take a hit.
	## When the Enemy reaches the end of the Path...
	if is_equal_approx(progress_ratio, 1):
		## Player loses health equal to this Enemy's damage value.
		Globals.lose_health(damage)
		
		## And the Enemy "dies".
		death()
		
	
	## Update 'position_last_frame' so it can be used next frame.
	position_last_frame = self.global_position


###-------------------------------------------------------------------------###
##### Visuals
###-------------------------------------------------------------------------###

## Enemy's visual updates.
func _process(delta: float) -> void:
	update_sprite()

## Use the right sprite depending on the Enemy's movement direction.
func update_sprite() -> void:
	pass


###-------------------------------------------------------------------------###
##### Taking damage and death
###-------------------------------------------------------------------------###

## This Enemy has been hit, time to take some Damage
func receive_DamageData(damageData: DamageData) -> void:
	## Lose some Health
	self.current_health -= damageData.damage_value
	
	## If health is all gone, time to die.
	if current_health <= 0:
		death()
		
	
	## If a HitEffect was passed down with damageData,
	## instantiate that hit effect at this Enemy's HitPoint Marker
	if damageData.hit_effect:
		var hit_effect_instance = damageData.hit_effect.instantiate()
		hit_point.add_child(hit_effect_instance)

## Make the Enemy die
func death() -> void:
	print("ENEMY ", self, " IS DEAD")
	## We must tell the Wave (if this Enemy is a part of one) that it has died
	if enemy_round:
		enemy_round.enemy_is_dead(self)
	else:
		printerr("Enemy: ", self, " is dead but wasn't assigned to a Wave!")
		
	
	## This Enemy is dead, the Player should receive some Money for killing it
	Globals.gain_money(default_money)
	
	## And now we can safely delete this Enemy
	queue_free()
