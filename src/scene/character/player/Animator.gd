extends AnimatedSprite2D
class_name PlayerAnimator

enum Anim {
	IDLE,
	WALK,
	RUN,
	CROUCH,
	GUARD,
	HURT,
	JUMP,
	ATTACK_A,
	ATTACK_B,
	ATTACK_C
}

func getCurrentFrame() -> int:
	return frame

func playAnim(anim: Anim):
	match anim:
		Anim.IDLE:
			play("idle")
		Anim.WALK:
			play("walk")
		_:
			push_error("Animation not implemented: " + str(anim))
			return

func setFacing(direction: int):
	assert(direction == -1 || direction == 1)
	flip_h = direction == -1
