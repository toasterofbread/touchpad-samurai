extends PlayerState

const WALK_STOP_FRAMES: Array[int] = [2, 6]

func getType():
	return Player.State.WALK

func onStateEntered(from: PlayerState, data: int):
	player.animator.playAnim(PlayerAnimator.Anim.WALK)
	player.animator.setFacing(data)

func process(delta: float):
	if player.animator.getCurrentFrame() in WALK_STOP_FRAMES:
		var pad_x = I.padx()
		if pad_x == 0:
			changeToState(Player.State.IDLE)
			return
