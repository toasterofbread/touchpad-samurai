extends CharacterBody2D
class_name Player

const STATES_DIR = "res://src/scene/character/player/state/"
const WALK_SPEED = 300.0
const RUN_SPEED = 300.0
var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

signal state_changed(from: PlayerState, to: PlayerState, data)

@onready var animator: PlayerAnimator = $AnimatedSprite2D

enum State {
	WALK, IDLE
}
var states: Dictionary = null
var state: PlayerState = null
var previous_state: PlayerState = null

func _init():
	states = loadStates()
	state = states[State.IDLE]

func loadStates() -> Dictionary:
	var ret: Dictionary = {}
	
	var dir = DirAccess.open(STATES_DIR)
	for file in dir.get_files():
		if not file.ends_with(".gd"):
			continue
		
		var state: PlayerState = load(STATES_DIR + file).new(self)
		
		assert(!ret.has(state.getType()))
		ret[state.getType()] = state
	
	return ret

func changeState(to: State, data = null):
	previous_state = state
	
	state = states[to]
	state.onStateEntered(previous_state, data)
	
	state_changed.emit(previous_state, state, data)
	
	$Label.text = State.keys()[to]

func _process(delta: float):
	state.process(delta)

func _physics_process(delta: float):
	state.physicsProcess(delta)
