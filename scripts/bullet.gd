extends Node3D


# Set the speed at which the bullet travels.
const SPEED = 50.0

# Set the amount of time the bullet remains in the scene after hitting something.
const IMPACT_LIFETIME = 10.0

# Set the direction the bullet travels in local space.
const BULLET_DIRECTION = Vector3(0, 0, -1)

# Store the enemy group name so it is not repeated as a magic string.
const ENEMY_GROUP = "enemy"

# References to the bullet's mesh, collision ray, and particle effect.
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D


# Called when the bullet enters the scene tree.
func _ready() -> void:
	# Make sure the collision ray is enabled when the bullet is created.
	ray.enabled = true


# Move the bullet and check for collisions every frame.
func _process(delta: float) -> void:
	# Check that delta is a valid value before using it for movement.
	if delta <= 0:
		return

	# Move the bullet forward based on its current rotation.
	position += (
		transform.basis * BULLET_DIRECTION * SPEED * delta
	)

	# Check if the bullet has collided with something.
	if ray.is_colliding():
		_handle_collision()


# Handle the bullet's collision with another object.
func _handle_collision() -> void:
	# Disable the ray so the collision cannot be detected repeatedly.
	ray.enabled = false

	# Get the object that the bullet collided with.
	var collider = ray.get_collider()

	# Check that a valid object was found before trying to use it.
	if collider == null:
		_start_impact_effect()
		return

	# Check if the object belongs to the enemy group.
	if collider.is_in_group(ENEMY_GROUP):
		# Check that the enemy has a hit function before calling it.
		if collider.has_method("hit"):
			collider.hit()

	# Start the bullet impact effect.
	_start_impact_effect()


# Hide the bullet, play the impact effect, and remove the bullet.
func _start_impact_effect() -> void:
	# Hide the bullet mesh after it hits an object.
	mesh.visible = false

	# Play the impact particle effect.
	particles.emitting = true

	# Wait before removing the bullet from the scene.
	await get_tree().create_timer(IMPACT_LIFETIME).timeout

	# Remove the bullet from the scene.
	queue_free()
