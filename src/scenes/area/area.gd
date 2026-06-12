extends Node2D
class_name Area


enum Shape {
	CIRCLE,
	RECTANGLE
}

var shape: Shape

var radius: float

var width: float
var height: float

var duration: float

var follow_target: Node2D
var follow_rotation: bool
var offset: Vector2


func _physics_process(delta: float) -> void:
	if follow_target:
		global_position = follow_target.global_position + offset
		
		if follow_rotation:
			global_rotation = follow_target.global_rotation

	duration -= delta

	if duration <= 0.0:
		queue_free()


func _draw() -> void:
	if !visible:
		return

	match shape:
		Shape.CIRCLE:
			draw_circle(Vector2.ZERO, radius, Color.WHITE)

		Shape.RECTANGLE:
			draw_rect(Rect2(Vector2(width / -2.0, height / -2.0), Vector2(width, height)),
				Color.WHITE,
				false,
				2.0
			)


func get_targets(group_name: String) -> Array[CharacterBase]:
	match shape:
		Shape.CIRCLE:
			return get_targets_circle(group_name)

		Shape.RECTANGLE:
			return get_targets_rectangle(group_name)

	return []


func get_targets_circle(group_name: String) -> Array[CharacterBase]:
	var shape_circle: CircleShape2D = CircleShape2D.new()

	shape_circle.radius = radius

	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

	query.shape = shape_circle
	query.transform = Transform2D(
		0.0,
		global_position
	)

	query.collide_with_areas = true

	var result: Array[Dictionary] = (
		Ingame.current
		.get_world_2d()
		.direct_space_state
		.intersect_shape(query)
	)

	var targets: Array[CharacterBase]

	for hit in result:
		var collider: Object = hit["collider"]

		if collider is CharacterBase:
			if collider.is_in_group(group_name):
				targets.append(collider)

	return targets


func get_targets_rectangle(group_name: String) -> Array[CharacterBase]:
	var shape_rectangle: RectangleShape2D = RectangleShape2D.new()

	shape_rectangle.size = Vector2(
		width,
		height
	)

	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

	query.shape = shape_rectangle

	query.transform = Transform2D(
		global_rotation,
		global_position
	)

	query.collide_with_areas = true

	var result: Array[Dictionary] = (
		Ingame.current
		.get_world_2d()
		.direct_space_state
		.intersect_shape(query)
	)

	var targets: Array[CharacterBase]

	for hit in result:
		var collider: Object = hit["collider"]

		if collider is CharacterBase:
			if collider.is_in_group(group_name):
				targets.append(collider)

	return targets


static func create_circle(
	position_: Vector2,
	radius_: float,
	duration_: float,
	follow_target_: Node2D = null,
	follow_rotation_: bool = false,
	offset_: Vector2 = Vector2.ZERO
) -> Area:

	var area: Area = Area.new()

	area.shape = Shape.CIRCLE

	area.global_position = position_

	area.radius = radius_

	area.duration = duration_

	area.follow_target = follow_target_
	area.follow_rotation = follow_rotation_
	area.offset = offset_

	Ingame.current.areas.add_child(area)

	return area


static func create_rectangle(
	position_: Vector2,
	rotation_: float,
	width_: float,
	height_: float,
	duration_: float,
	follow_target_: Node2D = null,
	follow_rotation_: bool = false,
	offset_: Vector2 = Vector2.ZERO
) -> Area:

	var area: Area = Area.new()

	area.shape = Shape.RECTANGLE

	area.global_position = position_
	area.rotation = rotation_

	area.width = width_
	area.height = height_

	area.duration = duration_

	area.follow_target = follow_target_
	area.follow_rotation = follow_rotation_
	area.offset = offset_

	Ingame.current.areas.add_child(area)

	return area
