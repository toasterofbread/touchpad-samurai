extends PlayerState

func getType():
	return Player.State.IDLE

func onStateEntered(from: PlayerState, data: int):
	player.animator.playAnim(PlayerAnimator.Anim.IDLE)

func process(delta: float):
	var pad_x = I.padJustx()
	if pad_x != 0:
		changeToState(Player.State.WALK, pad_x)
