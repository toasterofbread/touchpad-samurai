extends Control

var ds4: DS4Godot = DS4Godot.new()

# Called when the node enters the scene tree for the first time.
func _ready():
#	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var path = "/dev/input/event16"
	
	ds4.grab()
	var err = ds4.open(path)
	if err != OK:
		push_error(error_string(err))
		return
	
	add_child(ds4)
	ds4.finger_position_changed.connect(onFingerPositionChanged)

var a = Vector2.ZERO
var b = Vector2.ZERO

func onFingerPositionChanged(finger: int, pos: Vector2, rel: Vector2):
	if finger == 0:
		a = pos
	else:
		b = pos
	
	$Label.text = "A: " + str(a) + "\nB: " + str(b)

func _exit_tree():
	ds4.close()

#func _input(event: InputEvent):
#
#	if event is InputEventMouseMotion:
#		print(event.relative)
