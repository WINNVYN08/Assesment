@tool
extends Camera3D


@export var post_processing := true:
	set(p):
		if p:
			$post_processing.show()
			post_processing = p
			var a = Vector3(-1, 1, 0).normalized()
			var b = Vector3(1, 0, 0).normalized()
			print("dot: ", a.dot(b))
		else:
			$post_processing.hide()
			post_processing = p
