extends LineEdit

func _on_text_changed(new_text: String) -> void:
	%WorldGenerator.settings.radius = int(new_text)
