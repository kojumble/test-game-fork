extends Label

@onready var camRot = $"/root/3dgamescene/guy/guyCamRot"
@onready var plrRot = $"/root/3dgamescene/guy"

func add_text(text_to_add):
	text += text_to_add   # same as doing like "text = text + text_to_add" but cooler

func _process(delta):
	set_text("X rotation: " + str(("%.3f" % plrRot.rotation_degrees.y)))
	add_text("\nY rotation: " + str(("%.3f" % camRot.rotation_degrees.x)))
pass
