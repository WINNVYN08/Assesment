@tool
extends Camera3D


# Store the camera's rotation angles.
var angles = Vector3.ZERO

# Store the vectors used to test the dot product.
var vector_a = Vector3(-1, 1, 0).normalized()
var vector_b = Vector3(1, 0, 0).normalized()


# Enable or disable the post-processing effect.
@export var post_processing := true:
	set(value):
		post_processing = value
		_update_post_processing()


# Update the visibility of the post-processing effect.
func _update_post_processing() -> void:
	if not has_node("post_processing"):
		return

	# Get a reference to the post-processing node.
	var post_processing_node = $post_processing

	# Show or hide the post-processing effect based on the setting.
	post_processing_node.visible = post_processing


# Called when the camera enters the scene tree.
func _ready() -> void:
	_update_post_processing()

	# Calculate and print the dot product of the two vectors.
	var dot_product = vector_a.dot(vector_b)
	print("Dot: ", dot_product)
