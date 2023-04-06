extends PlayerState

var uncrouching = false

func getType():
	return Player.State.CROUCH

func onStateEntered(from: PlayerState, data: int):
	player.animator.playAnim(PlayerAnimator.Anim.CROUCH)
	uncrouching = false

func process(delta: float):
	if uncrouching or not player.controllable:
		return
	
	var pad_x = I.padx()
	if pad_x != 0 or Input.is_action_pressed("pad_up"):
		uncrouch()

func uncrouch():
	player.animator.playAnim(PlayerAnimator.Anim.CROUCH, true)
	player.animator.animation_finished.connect(onUncrouchFinished)
	uncrouching = true

func onUncrouchFinished():
	player.animator.animation_finished.disconnect(onUncrouchFinished)
	changeToState(Player.State.IDLE)
