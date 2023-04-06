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

func playAnim(anim: Anim, reverse: bool = false):
	var anim_id: String
	match anim:
		Anim.IDLE:
			anim_id = "idle"
		Anim.WALK:
			anim_id = "walk"
		Anim.RUN:
			anim_id = "run"
		Anim.CROUCH:
			anim_id = "crouch"
		_:
			assert(false, "Animation not implemented: " + str(anim))
			return
	
	if not reverse:
		play(anim_id)
	else:
		play_backwards(anim_id)

func getFacing() -> int:
	return -1 if flip_h else 1

func setFacing(direction: int):
	assert(direction == -1 || direction == 1)
	flip_h = direction == -1
