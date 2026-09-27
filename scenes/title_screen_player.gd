extends CharacterBody3D


# Movement constants.
const DASH_SPEED = 60
const WALK_SPEED = 30
const SPRINT_SPEED = 40
const JUMP_VELOCITY = 15
const SENSITIVITY = 0.009
const MAX_HEALTH = 100

# Head bob variables.
# These control how much the camera moves while the player is walking.
const BOB_FREQ = 0.4
const BOB_AMP = 0.15
var t_bob = 0.0
var damage = false

# FOV variables.
# The FOV increases slightly when the player moves faster.
const BASE_FOV = 75.0
const FOV_CHANGE = 0.5
var can_dash = true
var speed = 0

# Gravity variables.
var gravity = -0.1
var weight = 60

# Load the bullet scene so a new bullet can be created when the player shoots.
var bullet = load("res://scenes/bullet.tscn")
var instance

# Health variables.
# The player's health is reset to the maximum when the scene starts.
var max_health = 100
@export var health = 0

# References to important nodes in the player scene.
@onready var head = $Node3D
@onready var camera = $Node3D/Camera3D
@onready var gun_animation = (
	$Node3D/Camera3D/Sketchfab_Scene/AnimationPlayer
)
@onready var gun_ray = $Node3D/Camera3D/Sketchfab_Scene/RayCast3D


# Set the player's starting health when the scene loads.
func _ready():
	health = max_health

	# Store a reference to the player in the global script.
	# This allows other scripts to access the player.
	global.player = self


# Handle mouse movement for looking around.
func _unhandled_input(event):
	# Check if the input event was caused by mouse movement.
	if event is InputEventMouseMotion:
		# Rotate the player's head from left to right.
		head.rotate_y(-event.relative.x * SENSITIVITY / 8)

		# Rotate the camera up and down.
		camera.rotate_x(-event.relative.y * SENSITIVITY / 8)

		# Limit how far the player can look up and down.
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-90),
			deg_to_rad(90)
		)


# Handle the player's movement, shooting, jumping, and camera effects.
func _physics_process(delta):
	# Check if the player's health has reached zero.
	# If it has, reload the current scene.
	if health <= 0:
		get_tree().reload_current_scene()

	# Check if the player has pressed the shoot button.
	if Input.is_action_just_pressed("shoot"):
		# Only allow the player to shoot if the gun animation has finished.
		if not gun_animation.is_playing():
			# Play the laser shooting sound.
			$LaserShoot.play()

			# Play the shooting animation on the gun.
			gun_animation.play("shoot")

			# Create a new bullet from the loaded bullet scene.
			instance = bullet.instantiate()

			# Place the bullet at the end of the gun's raycast.
			instance.position = gun_ray.global_position

			# Make the bullet face the same direction as the gun.
			instance.transform.basis = gun_ray.global_transform.basis

			# Add the bullet to the player's parent node.
			get_parent().add_child(instance)

	# Apply gravity while the player is in the air.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Check if the player presses the jump button while standing on the floor.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		# Play the jumping sound.
		$Jump.play()

		# Apply an upward force to the player.
		velocity.y = JUMP_VELOCITY - abs(velocity.x) * 0.1

	# Check if the sprint button is being held.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the player's movement input.
	var input_dir = Input.get_vector("left", "right", "up", "down")

	# Convert the input direction into a 3D direction based on
	# the direction the player's head is facing.
	var direction = (
		head.transform.basis
		* transform.basis
		* Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	# Handle movement when the player is standing on the floor.
	if is_on_floor():
		if direction:
			velocity.x = lerp(
				velocity.x,
				direction.x * speed,
				delta * 4
			)
			velocity.z = lerp(
				velocity.z,
				direction.z * speed,
				delta * 4
			)
		else:
			# Smoothly slow the player down when no movement input is given.
			velocity.x = lerp(
				velocity.x,
				direction.x * speed,
				delta * 3
			)
			velocity.z = lerp(
				velocity.z,
				direction.z * speed,
				delta * 3
			)
	else:
		# Allow some movement control while the player is in the air.
		velocity.x = lerp(
			velocity.x,
			direction.x * speed,
			delta
		)
		velocity.z = lerp(
			velocity.z,
			direction.z * speed,
			delta
		)
		
	t_bob += delta * velocity.length() * float(is_on_floor())

	# Apply the head bob movement to the camera.
	camera.transform.origin = _headbob(t_bob)

	# Calculate the player's current movement speed.
	# This is used to change the camera's FOV.
	var velocity_clamped = clamp(
		velocity.length(),
		0.5,
		SPRINT_SPEED * 2
	)

	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped

	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO

	# Move the camera up and down using a sine wave.
	pos.y = sin(time * BOB_FREQ) * BOB_AMP

	# Move the camera from side to side using a cosine wave.
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP

	# Return the calculated camera position.
	return pos


# Detect when an enemy enters the player's damage area.
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("enemy"):
		# Set the damage variable to true.
		damage = true

		health -= 5

		$HitHurt.play()
		await get_tree().create_timer(0.2).timeout
		print(damage)


func _on_kill_floor_area_entered(area: Area3D) -> void:
	# Reload the current scene when the player falls into the kill area.
	get_tree().reload_current_scene()
