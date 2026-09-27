extends CharacterBody3D


# Enemy movement and health constants.
const DEFAULT_SPEED: float = 25.0
const DEFAULT_HEALTH: int = 2
const DEFAULT_GRAVITY: float = 30

# Enemy attribute ranges.
const MIN_SPEED: float = 5.0
const MAX_SPEED: float = 25
const MIN_HEALTH: int = 1
const MAX_HEALTH: int = 7


# Store different enemy attribute types.
var enemy_attributes: Dictionary = {
	"speed": 0.0,
	"helth": 0,
	"gravity": DEFAULT_GRAVITY
}


# Reference to the NavigationAgent3D used to find a path to the player.
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

# Set the enemy's movement speed.
@export var speed: float = DEFAULT_SPEED

# Set the path to the player node.
@export var player_path: NodePath

# Set the enemy's starting health.
@export var helth: int = DEFAULT_HEALTH

# Set the amount of gravity applied to the enemy.
@export var gravity: float = DEFAULT_GRAVITY


# Store a reference to the player.
var player: Node3D


# Find the player and generate random enemy attributes.
func _ready() -> void:
	# Check that a player path has been assigned.
	if player_path.is_empty():
		return

	# Try to find the player using the exported NodePath.
	player = get_node_or_null(player_path)

	# Check that the player was successfully found.
	if player == null:
		return

	# Generate random attributes for this enemy.
	_enemies_attributes()


# Generate random attributes for the enemy.
func _enemies_attributes() -> void:
	# Create random values for speed and health.
	var random_speed = randf_range(MIN_SPEED, MAX_SPEED)
	var random_health = randi_range(MIN_HEALTH, MAX_HEALTH)
	enemy_attributes["speed"] = random_speed
	enemy_attributes["health"] = random_health
	speed = enemy_attributes["speed"]
	helth = enemy_attributes["helth"]


# Handle enemy movement and navigation every physics frame.
func _physics_process(delta: float) -> void:
	# Stop the function if the player cannot be found.
	if player == null:
		return

	# Apply gravity while the enemy is not standing on the floor.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# Set the player's position as the navigation target.
	navigation_agent_3d.target_position = player.global_position

	# Check if the navigation agent has reached the target.
	if navigation_agent_3d.is_navigation_finished():
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	# Get the next position along the navigation path.
	var next_nav_point = navigation_agent_3d.get_next_path_position()
	var direction = next_nav_point - global_position
	direction.y = 0.0

	# Check that the direction has a length before normalising it.
	if direction.length() > 0.0:
		direction = direction.normalized()

		# Move the enemy horizontally towards the next navigation point.
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		# Stop horizontal movement if there is no valid direction.
		velocity.x = 0.0
		velocity.z = 0.0

	# Apply the movement and handle collisions.
	move_and_slide()


# Reduce the enemy's health when it is hit.
func _on_area_3d_enemy_hit(dam: Variant) -> void:
	# Check that the damage value is valid before using it.
	if dam == null:
		return

	# Check that the damage is a number.
	if not (dam is int or dam is float):
		return

	# Convert the damage value to an integer.
	var damage_amount: int = int(dam)

	# Ignore zero or negative damage values.
	if damage_amount <= 0:
		return

	# Subtract the damage amount from the enemy's health.
	helth -= damage_amount

	# Check if the enemy has no health remaining.
	if helth <= 0:
		# Remove the enemy from the scene.
		queue_free()
