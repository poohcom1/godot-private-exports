const DisplayModeKey = "private_exports/inspector/display_mode"

enum DisplayMode {
	Always = 0,  # Always show
	Modified = 1,  # Only non-public value and selected values
	Selected = 2,  # Only selected values
}


# Setup
static func init():
	var settings := EditorInterface.get_editor_settings()

	if not settings.has_setting(DisplayModeKey):
		settings.set_setting(DisplayModeKey, DisplayMode.Always)
	settings.set_initial_value(DisplayModeKey, DisplayMode.Always, false)
	settings.add_property_info(
		{
			"name": DisplayModeKey,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Always,Modified,Selected"
		}
	)


# Settings
static func get_display_mode() -> DisplayMode:
	return EditorInterface.get_editor_settings().get_setting(DisplayModeKey)
