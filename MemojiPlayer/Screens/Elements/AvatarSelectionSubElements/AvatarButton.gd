extends Button

export (int) var avatar_id 

signal avatar_button_pressed(id)

func _on_AvatarButton_pressed():
	emit_signal("avatar_button_pressed", avatar_id)
