extends Control
class_name Canvas

const POINT_OFFSET = Vector2(0.5, 0.5)
var MODEL_PATH = ProjectSettings.globalize_path("res://addons/ds4godot/handwriting-ja.model")

signal stroke_finished(stroke: Stroke)

var hint_char: Kanji = null : set = setHintChar
var kanji_data: Dictionary
var strokes: Dictionary = {}
var internal_strokes: Dictionary = {}

func _ready():
	setHintChar(null)
	onCanvasResized()

func setHintChar(value: Kanji):
	hint_char = value
	
	$HintCharTextureRect.visible = hint_char != null
	if hint_char != null:
		$HintCharTextureRect.texture = hint_char.getTexture()

func _collectStrokePoints(forEachPoint: Callable, highres: bool):
	for i in $Lines.get_child_count():
		var line: Line2D = $Lines.get_child(i)
		
		if highres:
			for point in line.points:
				forEachPoint.call(i, (point + POINT_OFFSET) * size)
		else:
			forEachPoint.call(i, (line.points[0] + POINT_OFFSET) * size)
			forEachPoint.call(i, (line.points[-1] + POINT_OFFSET) * size)
		
		while line.get_child_count() != 0:
			assert(line.get_child_count() == 1)
			line = line.get_child(0)
		
			if highres:
				for point in line.points:
					forEachPoint.call(i, (point + POINT_OFFSET) * size)
			else:
				forEachPoint.call(i, (line.points[-1] + POINT_OFFSET) * size)

func recogniseWrittenCharacter(order_independent: bool = false, highres: bool = true, max_chars: int = 5) -> Array:
	var ret: Array
	
	if order_independent:
		var strokes = []
		var forEachPoint: Callable = func (stroke: int, point: Vector2): 
			while strokes.size() - 1 < stroke:
				strokes.append([])
			strokes[stroke].append(point)
		
		_collectStrokePoints(forEachPoint, highres)
		
		ret = KanjiMatcher.orderIndependentStrokeMatch(MODEL_PATH, 1, size, strokes)
	else:
		var matcher = KanjiMatcher.new()
		matcher.loadModel(MODEL_PATH)
		matcher.setSize(size)
		
		_collectStrokePoints(func(stroke, point): matcher.addStrokePoint(stroke, point), highres)
		
		ret = matcher.matchStrokes(max_chars)
	
	ret.sort_custom(func (a, b): return a[1] > b[1])
	return ret.slice(0, max_chars)

func clear():
	strokes.clear()
	internal_strokes.clear()
	
	for line in $Lines.get_children():
		line.queue_free()

func getStroke(id) -> Stroke:
	var stroke = strokes.get(id)
	if stroke == null:
		stroke = _createNewStroke()
		strokes[id] = stroke
	return stroke

func _getInternalStroke(id) -> Stroke:
	var stroke = internal_strokes.get(id)
	if stroke == null:
		stroke = _createNewStroke()
		internal_strokes[id] = stroke
	return stroke

func _createNewStroke() -> Stroke:
	var stroke = Stroke.new(_createNewLine)
	stroke.finished.connect(_onStrokeFinished.bind(stroke))
	return stroke

func _createNewLine(parent: Node = null):
	var ret = AntialiasedLine2D.new()
	ret.width = 0.025
	(parent if parent != null else $Lines).add_child(ret)
	return ret

func _onStrokeFinished(stroke: Stroke):
	stroke_finished.emit(stroke)

func _gui_input(event: InputEvent):
	if event is InputEventScreenTouch:
		if not event.pressed:
			_getInternalStroke(event.index).finish()
	elif event is InputEventScreenDrag:
		_getInternalStroke(event.index).move(event.position / size, event.relative / size)

class Stroke:
	var line: Line2D = null
	var length: float = 0.0
	var prev_speed: Vector2 = null
	var _createNewLine: Callable
	
	signal finished
	
	func _init(createNewLine: Callable):
		self._createNewLine = createNewLine
	
	func finish():
		line = null
		finished.emit()
	
	func move(pos: Vector2, rel: Vector2):
		if line == null:
			rel = Vector2.ZERO
		
		if line == null or line.get_point_count() > 100:
			if line != null:
				_lineHane(0.0)
			
			length = 0.0
			line = _createNewLine.call(line)
			line.add_point((pos - rel) - POINT_OFFSET)
		
		line.add_point(pos - POINT_OFFSET)
		length += (rel).length_squared()
		
		_lineHane((rel).length_squared())

	func _lineHane(length_squared: float):
		if length == 0:
			return
		
		if line.width_curve == null:
			line.width_curve = Curve.new()
		else:
			line.width_curve.clear_points()
		
		var curve: Curve = line.width_curve
		curve.add_point(Vector2(0.0, 1.0))
		
		if length_squared == 0.0:
			curve.add_point(Vector2(1.0, 1.0))
		else:
			curve.add_point(Vector2(1.0 - ((length_squared * 2.0) / length), 1.0))
			curve.add_point(Vector2(1.0, 0.0))

func onCanvasResized():
	$Lines.scale = Vector2.ONE * min(size.x, size.y)
