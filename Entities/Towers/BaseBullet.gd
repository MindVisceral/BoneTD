class_name BaseBullet
extends Area2D

@export_range(20, 9999, 1) var speed: int = 80


func _physics_process(delta: float) -> void:
	## Make the bullet move at speed over time
	global_position += transform.x * speed * delta


## Check for Enemies
func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		print("HIT")
		
		## And destroy the bullet
		queue_free()

## Check for Environment
func _on_body_entered(body: Node2D) -> void:
	if body:
		queue_free()


## When this Timer runs out, destroy the bullet to save on performance.
func _on_destroy_timer_timeout() -> void:
	queue_free()
