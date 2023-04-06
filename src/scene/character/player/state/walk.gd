extends PlayerState

const WALK_STOP_FRAMES: Array[int] = [0, 4]
const RUN_STOP_FRAMES: Array[int] = [0, 5]
const WALK_SPEED = 30.0
const RUN_SPEED = 100.0

var running = false
var first_frame = true

func getType():
	return Player.State.WALK

func onStateEntered(from: PlayerState, data: int):
	setRunning(Input.is_action_pressed("run"))
	player.animator.setFacing(data)
	first_frame = true

func process(delta: float):
	if not player.controllable:
		return
	
	if not first_frame and player.animator.getCurrentFrame() in (RUN_STOP_FRAMES if running else WALK_STOP_FRAMES):
		setRunning(Input.is_action_pressed("run"))
		
		var pad_x = I.padx()
		if pad_x != 0:
			player.animator.setFacing(pad_x)
		if pad_x == 0:
			changeToState(Player.State.IDLE)
			return

func physicsProcess(delta: float):
	var direction = player.animator.getFacing()
	player.velocity.x = (RUN_SPEED if running else WALK_SPEED) * direction

func init():
	player.animator.frame_changed.connect(onAnimatorFrameChanged)

func onAnimatorFrameChanged():
	first_frame = false

func setRunning(value: bool):
	running = value
	player.animator.playAnim(PlayerAnimator.Anim.RUN if running else PlayerAnimator.Anim.WALK)
