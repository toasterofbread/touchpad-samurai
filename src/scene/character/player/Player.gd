extends CharacterBody2D
class_name Player

const STATES_DIR = "res://src/scene/character/player/state/"
var GRAVITY: float = 980

signal state_changed(from: PlayerState, to: PlayerState, data)

@onready var animator: PlayerAnimator = $AnimatedSprite2D
@onready var hud: PlayerHUD = $HUD
@onready var camera: Camera2D = $Camera

enum State {
	WALK, IDLE, CROUCH
}
var states: Dictionary = null
var state: PlayerState = null
var previous_state: PlayerState = null

var controllable = true

func _ready():
	states = loadStates()
	state = states[State.IDLE]
	state.onStateEntered(null, null)
	
	assert(Game.player == null)
	Game.player = self

func loadStates() -> Dictionary:
	var ret: Dictionary = {}
	
	var dir = DirAccess.open(STATES_DIR)
	for file in dir.get_files():
		if not file.ends_with(".gd"):
			continue
		
		var state: PlayerState = load(STATES_DIR + file).new(self)
		
		assert(!ret.has(state.getType()))
		ret[state.getType()] = state
	
	for s in State.values():
		var state: PlayerState = ret.get(s)
		
		if state == null:
			push_error("No script loaded for state " + State.keys()[state])
			continue
		
		state.init()
	
	return ret

func getState(state: State) -> PlayerState:
	return states[state]

func changeState(to: State, data = null):
	previous_state = state
	
	state = states[to]
	state.onStateEntered(previous_state, data)
	
	state_changed.emit(previous_state, state, data)
	
	$Label.text = State.keys()[to]

func _process(delta: float):
	state.process(delta)

func _physics_process(delta: float):
	velocity.x = 0
#	velocity.y += GRAVITY * delta
	
	state.physicsProcess(delta)
	move_and_slide()

func enemySighted(enemy: Enemy):
	Game.beginEncounter(enemy)
