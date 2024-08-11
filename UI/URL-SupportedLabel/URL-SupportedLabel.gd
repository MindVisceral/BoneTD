class_name URL_SLabel
extends RichTextLabel


## The sole purpose of this script is
## to make this RichTextLabel's url links work.


###-------------------------------------------------------------------------###
##### The sole function
###-------------------------------------------------------------------------###

## This function opens the clicked url link in the default browser.
func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
	print(meta)
