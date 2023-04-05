extends Control

const DS4_DEVICE_NAME = "Sony Interactive Entertainment Wireless Controller Touchpad"
const KANJIDIC_PATH: String = "res://src/resource/other/kanjidic2.xml"
const KANJIVG_PATH: String = "res://src/resource/other/kanjivg.zip"

@onready var canvas: Canvas = $MarginContainer/VBoxContainer/AspectRatioContainer/Canvas

var kanji_data: Dictionary = {}
var kanjivg: ZIPReader

var ds4: DS4Godot = DS4Godot.new()
var ds4_resolution = ds4.getResolution()

var a = Vector2.ZERO
var b = Vector2.ZERO

func _ready():
#	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#	$Label.text = str(OS.get_system_dark_mode())
	
	initDS4()
	initCanvas()

func _exit_tree():
	ds4.close()

func _process(_delta: float):
	
	if Input.is_action_just_pressed("ui_accept"):
		canvas.clear()

func initCanvas():
	kanjivg = ZIPReader.new()
	
	var err = kanjivg.open(KANJIVG_PATH)
	if err != OK:
		push_error(error_string(err))
		return
	
	var file = FileAccess.open("res://kanji_data.json", FileAccess.READ)
	
	for data in JSON.parse_string(file.get_as_text()):
		var kanji = Kanji.new(data, kanjivg)
		if not kanji.jlpt in kanji_data:
			kanji_data[kanji.jlpt] = [kanji]
		else:
			kanji_data[kanji.jlpt].append(kanji)

	for level in kanji_data.values():
		level.sort_custom(func(a, b): Kanji.sorter(a, b))

	canvas.kanji_data = kanji_data
	canvas.hint_char = findKanji("水")
	
	canvas.stroke_finished.connect(func(a): updateGuesses())

func initDS4():
	var devices = ds4.getDeviceList()
	var device: String = null
	
	for path in devices:
		if devices[path] == DS4_DEVICE_NAME:
			device = path
			break
	
	if device == null:
		return
	
	var err = ds4.open(device)
	if err != OK:
		push_error(error_string(err))
		return
	
	ds4.grab()
	ds4.finger_position_changed.connect(onFingerPositionChanged)
	ds4.finger_touching_changed.connect(onFingerTouchingChanged)
	
	add_child(ds4)

func onFingerPositionChanged(finger: int, pos: Vector2, rel: Vector2):
	pos = pos / ds4_resolution
	
	if finger == 0:
		a = pos
	else:
		b = pos
	
	canvas.getStroke(finger).move(pos, rel / ds4_resolution)

func onFingerTouchingChanged(finger: int, touching: bool):
	if not touching:
		canvas.getStroke(finger).finish()

func updateGuesses():
	var text = "DEPENDENT\n"
	
	var guesses: Array = canvas.recogniseWrittenCharacter(false)
	
	for guess in guesses:
		text += guess[0] + " - " + str(guess[1]) + "\n"

	text += "\nINDEPENDENT\n"
	guesses = canvas.recogniseWrittenCharacter(true)
	for guess in guesses:
		text += guess[0] + " - " + str(guess[1]) + "\n"
	
	$Label.text = text

func findKanji(literal: String):
	assert(len(literal) == 1)
	
	for level in kanji_data.values():
		for kanji in level:
			if kanji.literal == literal:
				return kanji
	
	return null

func loadKanjiData() -> Array:
	var parser = XMLParser.new()
	var ERROR_MSG: String = "Error while parsing kanji data at path '%s' (%d)"
	
	var error = parser.open(KANJIDIC_PATH)
	if error != OK:
		push_error(ERROR_MSG % [KANJIDIC_PATH, error])
		return null
	
	var ret: Array = []
	var current_char: Dictionary = null
	var current_element: PackedStringArray = []
	
	while true:
		
		if current_char == null:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT and parser.get_node_name() == "character":
				current_char = {}
		else:
			match parser.get_node_type():
				XMLParser.NODE_ELEMENT:
					current_element.append(parser.get_node_name())
				XMLParser.NODE_ELEMENT_END:
					if parser.get_node_name() == "character":
						ret.append(current_char)
						current_char = null
					else:
						current_element.remove_at(current_element.size() - 1)
				XMLParser.NODE_TEXT:
					var node = current_char
					for i in current_element.size():
						var element: String = current_element[i]
						if i + 1 == current_element.size():
							var data = {"value": parser.get_node_data()}
							for attr in parser.get_attribute_count():
								data[parser.get_attribute_name(attr)] = parser.get_attribute_value(attr)
							
							if element in node:
								if not node[element] is Array:
									node[element] = [node[element], data]
								else:
									node[element].append(data)
							else:
								node[element] = data
						else:
							if not element in node:
								node[element] = {}
							node = node[element]
		
		error = parser.read()
		if error != OK:
			if error != ERR_FILE_EOF:
				push_error(ERROR_MSG % [KANJIDIC_PATH, error])
				return null
			break
	
	return ret
