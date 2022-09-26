extends Node3D

@export_range(0,1000,1) var movment_speed = 20

@export_range(0,90) var min_elevation_angle = 10
@export_range(0,90) var max_elevation_angle = 90
@export_range(0,1000,0.1) var rotation_speed = 10

@export var allow_rotation : bool = true

@onready var elevation := $Elevation

var _last_mouse_position := Vector2()
var camera_rotate : bool = false

func _process(delta):
	_move(delta)
	_rotate(delta)

func _unhandled_input(event):
	if event.is_action_pressed("rotate_camera"):
		camera_rotate = true
		_last_mouse_position = get_viewport().get_mouse_position()
	if event.is_action_released("rotate_camera"):
		camera_rotate = false

func _move(delta):
	
	var velocity := Vector3()
	if Input.is_action_pressed("cam_up"):
		velocity += transform.basis.y
	if Input.is_action_pressed("cam_down"):
		velocity -= transform.basis.y
	if Input.is_action_pressed("move_right"):
		velocity += transform.basis.x
	if Input.is_action_pressed("move_left"):
		velocity -= transform.basis.x
	if Input.is_action_pressed("move_forwards"):
		velocity -= transform.basis.z
	if Input.is_action_pressed("move_backwards"):
		velocity += transform.basis.z
	velocity = velocity.normalized()
	position += velocity * delta * movment_speed
	

func _rotate(delta):
	if not camera_rotate or not allow_rotation:
		return
	var displacment := _get_mouse_displacment()
	_rotate_left_right(delta,displacment.x)
	_elevate(delta,displacment.y)
	
func _get_mouse_displacment() -> Vector2:
	var current_mouse_position := get_viewport().get_mouse_position()
	var displacment = _last_mouse_position - current_mouse_position
	_last_mouse_position = current_mouse_position
	return displacment

func _rotate_left_right(delta : float, val: float):
	rotation.y += deg_to_rad(val * delta * rotation_speed)

func _elevate(delta : float, val : float):
	var new_elevation = rad_to_deg(elevation.rotation.x) + val * delta * rotation_speed
	new_elevation = clamp(new_elevation, -max_elevation_angle, -min_elevation_angle)
	elevation.rotation.x = deg_to_rad(new_elevation)
