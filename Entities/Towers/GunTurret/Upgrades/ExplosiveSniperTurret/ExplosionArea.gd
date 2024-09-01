extends Area2D


###-------------------------------------------------------------------------###
##### DamageData
###-------------------------------------------------------------------------###

@export_group("DamageData")

## This DamageData Resource holds all the information this Tower's Target needs when it's been hit.
## This includes the Tower's damage dealth and the hit effect.
## NOTE: Read the DamageData script for more info.
@export var damage_data: DamageData:
	set(w_damagedata):
		if w_damagedata != damage_data:
			damage_data = w_damagedata
			update_configuration_warnings()
			
		
	


###-------------------------------------------------------------------------###
##### Editor-only
###-------------------------------------------------------------------------###

## Show a warning when the Tower is not set up properly in the Editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if damage_data == null:
		## We we want this warning to show up first in the Array. Weirdly, PackedStringArray
		## have no 'push_front' function like regular Arrays - hence 'insert' at index 0 instead.
		warnings.insert(0, "No DamageData is set for this Tower!")
	
	return warnings


###-------------------------------------------------------------------------###
##### Core function
###-------------------------------------------------------------------------###

## When a Hurtbox enters this Explosion's range,
## send over DamageData to all nearby Hurtbox-containing entities.
func explode_area(area: Area2D) -> void:
	
	if area is Hurtbox:
		area.pass_DamageData(damage_data)
		print("passed")
		
	
