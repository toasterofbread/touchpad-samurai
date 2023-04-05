class_name I

const PAD_LEFT: String = "move_left"
const PAD_RIGHT: String = "move_right"
const PAD_UP: String = null
const PAD_DOWN: String = "crouch"

static func pad() -> Vector2:
	return Vector2(padx(), pady())

static func padx() -> int:
	var ret: int = 0
	if PAD_LEFT != null and Input.is_action_pressed(PAD_LEFT):
		ret -= 1
	if PAD_RIGHT != null and Input.is_action_pressed(PAD_RIGHT):
		ret += 1
	return ret

static func pady() -> int:
	var ret: int = 0
	if PAD_UP != null and Input.is_action_pressed(PAD_UP):
		ret -= 1
	if PAD_DOWN != null and Input.is_action_pressed(PAD_DOWN):
		ret += 1
	return ret

static func padJust() -> Vector2:
	return Vector2(padJustx(), padJusty())

static func padJustx() -> int:
	var ret: int = 0
	if PAD_LEFT != null and Input.is_action_just_pressed(PAD_LEFT):
		ret -= 1
	if PAD_RIGHT != null and Input.is_action_just_pressed(PAD_RIGHT):
		ret += 1
	return ret

static func padJusty() -> int:
	var ret: int = 0
	if PAD_UP != null and Input.is_action_just_pressed(PAD_UP):
		ret -= 1
	if PAD_DOWN != null and Input.is_action_just_pressed(PAD_DOWN):
		ret += 1
	return ret
