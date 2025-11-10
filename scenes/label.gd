@tool
extends Label

@export var keep_time: float = 1.0
@export var fade_time: float = 1.0

var _timer: float = 0.0
var _fading: bool = false

func _ready() -> void:
	modulate.a = 0.0  # Start invisible

# Call this to change text
func show_text(new_text: String) -> void:
	text = new_text
	modulate.a = 1.0
	_timer = keep_time
	_fading = false
	set_process(true)

func _process(delta: float) -> void:
	if _timer > 0:
		_timer -= delta
		if _timer <= 0 and not _fading:
			_fading = true
			_timer = fade_time
		return

	if _fading:
		_timer -= delta
		modulate.a = lerpf(1.0, 0.0, 1.0 - _timer / fade_time)
		if _timer <= 0:
			modulate.a = 0.0
			set_process(false)
