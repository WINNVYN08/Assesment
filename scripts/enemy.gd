extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export var SPEED = 25
@export var player_path: NodePath
@export var health = 2
@export var gravity = 20

var player: Node3D

func _ready() -> void:
	player = get_node_or_null(player_path)

func _physics_process(delta: float) -> void:
	if player == null:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	navigation_agent_3d.target_position = player.global_position

	var next_nav_point = navigation_agent_3d.get_next_path_position()
	var direction = (next_nav_point - global_position).normalized()

	velocity = direction * SPEED
	move_and_slide()


func _on_area_3d_enemy_hit(dam: Variant) -> void:
	health -=dam
	if health <= 0:
		queue_free()
	pass # Replace with function body.
