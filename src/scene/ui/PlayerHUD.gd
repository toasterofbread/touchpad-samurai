extends CanvasLayer
class_name PlayerHUD

const BAR_HEIGHT: float = 100
const BAR_ANIM_DURATION: float = 2.0

func _ready():
	%TopBar.size.y = 0
	%BottomBar.size.y = 0

func setBarsVisible(value: bool, camera: Camera2D):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_parallel(true)
	
	if value:
		tween.tween_property(%TopBar, "size:y", BAR_HEIGHT, BAR_ANIM_DURATION)
		tween.tween_property(%BottomBar, "size:y", BAR_HEIGHT, BAR_ANIM_DURATION)
		tween.tween_property(%BottomBar, "position:y", -BAR_HEIGHT, BAR_ANIM_DURATION)
		
		if camera != null:
			tween.tween_property(camera, "offset:y", BAR_HEIGHT / camera.zoom.y, BAR_ANIM_DURATION)
	else:
		tween.tween_property(%TopBar, "size:y", 0, BAR_ANIM_DURATION)
		tween.tween_property(%BottomBar, "size:y", 0, BAR_ANIM_DURATION)
		tween.tween_property(%BottomBar, "position:y", 0, BAR_ANIM_DURATION)
		
		if camera != null:
			tween.tween_property(camera, "offset:y", 0, BAR_ANIM_DURATION)
