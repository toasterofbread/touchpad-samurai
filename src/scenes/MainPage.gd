extends Control

const KANJIDIC_PATH: String = "res://src/resources/kanjidic2.xml"
const KANJIVG_PATH: String = "res://src/resources/kanjivg.zip"

@onready var canvas: Canvas = $MarginContainer/VBoxContainer/AspectRatioContainer/Canvas

var kanji_data: Dictionary = {}
var kanjivg: ZIPReader

func _ready():
	kanjivg = ZIPReader.new()
	
	var err = kanjivg.open(KANJIVG_PATH)
	if err != OK:
		push_error(error_string(err))
		return
	
#	$Label.text = str(OS.get_system_dark_mode())
	
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
	canvas.hint_char = findKanji("桜")

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