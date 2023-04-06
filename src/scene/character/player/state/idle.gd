extends PlayerState

func getType():
	return Player.State.IDLE

func onStateEntered(from: PlayerState, data: int):
	player.animator.playAnim(PlayerAnimator.Anim.IDLE)

func process(delta: float):
	
	if not player.controllable:
		return
	
	if Input.is_action_pressed("crouch"):
		changeToState(Player.State.CROUCH)
		return
	
	var pad_x = I.padx()
	if pad_x != 0:
		changeToState(Player.State.WALK, pad_x)
		return
