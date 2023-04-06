extends Node

var player: Player = null

func delay(time: float) -> Signal:
	return get_tree().create_timer(time).timeout

func beginEncounter(enemy: Enemy):
	player.controllable = false
	
	await delay(0.5)
	player.getState(Player.State.WALK).setRunning(false)
	await delay(1)
	player.hud.setBarsVisible(true, player.camera)
	await delay(1)
	
	player.state.changeToState(Player.State.IDLE)
	
	
