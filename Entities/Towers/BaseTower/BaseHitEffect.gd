class_name BaseHitEffect
extends AnimatedSprite2D


## When this Hit Effect is instantiated, its animation is played immediately,
## and when its finished the whole Effect is queue_free()-d


###-------------------------------------------------------------------------###
##### The sole function
###-------------------------------------------------------------------------###

## Animation done, kill this Node!
func _on_animation_finished() -> void:
	queue_free()
	
