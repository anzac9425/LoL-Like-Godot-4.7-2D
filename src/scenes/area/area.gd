extends Node2D
class_name Area


enum Shape {
	CIRCLE,
	RECTANGLE,
	POLYGON
}

var shape: Shape

var radius: float

var width: float
var height: float

var polygon: PackedVector2Array

var duration: float

var follow_target: Node2D
var follow_rotation: bool
var offset: Vector2


func _physics_process(_delta: float) -> void:
	if follow_target:
		if follow_rotation:
			global_position = (
				follow_target.global_position
				+ offset.rotated(
					follow_target.global_rotation
				)
			)

			global_rotation = follow_target.global_rotation

		else:
			global_position = (
				follow_target.global_position
				+ offset
			)


func _draw() -> void:
	if !visible:
		return
	
	match shape:
		Shape.CIRCLE:
			draw_arc(
				Vector2.ZERO,
				radius,
				0,
				TAU,
				64,
				Color.WHITE,
				2
			)
		
		Shape.RECTANGLE:
			draw_rect(
				Rect2(
					Vector2(-width/2, -height/2),
					Vector2(width, height)
				),
				Color.WHITE,
				false,
				2
			)
		
		Shape.POLYGON:
			draw_polyline(
				polygon + PackedVector2Array([polygon[0]]),
				Color.WHITE,
				2
			)


func get_targets() -> Array[CharacterBase]:
	match shape:
		Shape.CIRCLE:
			return get_targets_circle()

		Shape.RECTANGLE:
			return get_targets_rectangle()

		Shape.POLYGON:
			return get_targets_polygon()

	return []


func get_targets_circle() -> Array[CharacterBase]:
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
			targets.append(collider)

	return targets


func get_targets_rectangle() -> Array[CharacterBase]:
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
			targets.append(collider)

	return targets


func get_targets_polygon() -> Array[CharacterBase]:
	var shape_polygon: ConvexPolygonShape2D = ConvexPolygonShape2D.new()

	shape_polygon.points = polygon

	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

	query.shape = shape_polygon

	query.transform = Transform2D(
		global_rotation,
		global_position
	)

	query.collide_with_areas = true

	var result = (
		Ingame.current
		.get_world_2d()
		.direct_space_state
		.intersect_shape(query)
	)

	var targets: Array[CharacterBase]

	for hit in result:
		var collider = hit["collider"]

		if collider is CharacterBase:
			targets.append(collider)

	return targets


static func create_circle(
	position_: Vector2,
	radius_: float,
	visible_: bool = false,
	follow_target_: Node2D = null,
	follow_rotation_: bool = false,
	offset_: Vector2 = Vector2.ZERO
) -> Area:
	
	var area: Area = Area.new()

	area.shape = Shape.CIRCLE

	area.global_position = position_

	area.radius = radius_
	
	area.visible = visible_

	area.follow_target = follow_target_
	area.follow_rotation = follow_rotation_
	area.offset = offset_

	return area


static func create_rectangle(
	position_: Vector2,
	rotation_: float,
	width_: float,
	height_: float,
	visible_: bool = false,
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
	
	area.visible = visible_

	area.follow_target = follow_target_
	area.follow_rotation = follow_rotation_
	area.offset = offset_

	return area


static func create_polygon(
	position_: Vector2,
	rotation_: float,
	points_: PackedVector2Array,
	visible_: bool = false,
	follow_target_: Node2D = null,
	follow_rotation_: bool = false,
	offset_: Vector2 = Vector2.ZERO
) -> Area:

	var area: Area = Area.new()

	area.shape = Shape.POLYGON

	area.global_position = position_
	area.rotation = rotation_

	area.polygon = points_

	area.visible = visible_

	area.follow_target = follow_target_
	area.follow_rotation = follow_rotation_
	area.offset = offset_

	return area
