extends RefCounted

static func create_theme() -> Theme:
	var result := Theme.new()

	result.set_color("font_color", "Label", Color("#263d2c"))
	result.set_color("font_color", "Button", Color("#f7f4df"))
	result.set_color("font_hover_color", "Button", Color("#ffffff"))
	result.set_color("font_pressed_color", "Button", Color("#fff4c2"))
	result.set_color("font_disabled_color", "Button", Color("#a9b5a5"))
	result.set_color("font_color", "OptionButton", Color("#f7f4df"))
	result.set_color("font_hover_color", "OptionButton", Color("#ffffff"))
	result.set_color("font_color", "ProgressBar", Color("#ffffff"))

	result.set_font_size("font_size", "Label", 15)
	result.set_font_size("font_size", "Button", 14)
	result.set_font_size("font_size", "OptionButton", 13)

	result.set_stylebox("panel", "PanelContainer", _panel_style())
	result.set_stylebox("normal", "Button", _button_style(Color("#315b3b"), Color("#c6a85b")))
	result.set_stylebox("hover", "Button", _button_style(Color("#42764a"), Color("#e1c878")))
	result.set_stylebox("pressed", "Button", _button_style(Color("#203f2b"), Color("#f1d98a")))
	result.set_stylebox("disabled", "Button", _button_style(Color("#526b57"), Color("#667c62")))
	result.set_stylebox("focus", "Button", _focus_style())
	result.set_stylebox("normal", "OptionButton", _button_style(Color("#315b3b"), Color("#c6a85b")))
	result.set_stylebox("hover", "OptionButton", _button_style(Color("#42764a"), Color("#e1c878")))
	result.set_stylebox("pressed", "OptionButton", _button_style(Color("#203f2b"), Color("#f1d98a")))
	result.set_stylebox("disabled", "OptionButton", _button_style(Color("#526b57"), Color("#667c62")))
	result.set_stylebox("background", "ProgressBar", _progress_background())
	result.set_stylebox("fill", "ProgressBar", _progress_fill())
	result.set_constant("separation", "VBoxContainer", 8)
	result.set_constant("separation", "HBoxContainer", 8)
	return result


static func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.075, 0.16, 0.105, 0.94)
	style.border_color = Color("#c6a85b")
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	style.shadow_color = Color(0.02, 0.04, 0.025, 0.38)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 3)
	return style


static func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	style.shadow_color = Color(0.015, 0.035, 0.02, 0.32)
	style.shadow_size = 3
	style.shadow_offset = Vector2(0, 2)
	return style


static func _focus_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color("#f4dc8b")
	style.set_border_width_all(2)
	style.set_corner_radius_all(11)
	return style


static func _progress_background() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1b3828")
	style.set_corner_radius_all(8)
	return style


static func _progress_fill() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#d5b95e")
	style.set_corner_radius_all(8)
	return style
