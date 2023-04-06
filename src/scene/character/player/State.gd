extends RefCounted
class_name PlayerState

var player: Player

func _init(player: Player):
	self.player = player

func init():
	pass

func getType() -> Player.State:
	push_error("Not implemented")
	return null

func onStateEntered(from: PlayerState, data) -> void:
	pass

func changeToState(to: Player.State, data = null) -> void:
	player.changeState(to, data)

func process(delta: float) -> void:
	pass

func physicsProcess(delta: float) -> void:
	pass
