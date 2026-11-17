
extends Node2D

@export var tile_map: TileMapLayer

var drawn_path: Array[Vector2i] = []
var is_drawing := false

signal path_completed(path: Array[Vector2i])


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_drawing = true
				drawn_path.clear()
				add_tile_under_mouse()
			else:
				is_drawing = false
				if drawn_path.size() > 1:
					path_completed.emit(drawn_path.duplicate())

			queue_redraw()

	elif event is InputEventMouseMotion and is_drawing:
		add_tile_under_mouse()


func add_tile_under_mouse():
	if tile_map == null:
		return

	var mouse_position = get_global_mouse_position()

	var tile_position = tile_map.local_to_map(
		tile_map.to_local(mouse_position)
	)

	if drawn_path.is_empty():
		drawn_path.append(tile_position)
		queue_redraw()
		return

	var previous_tile = drawn_path[-1]

	if tile_position == previous_tile:
		return

	# Only allow adjacent tiles
	var difference = tile_position - previous_tile

	if abs(difference.x) + abs(difference.y) != 1:
		return

	# Prevent revisiting previously visited tiles
	if drawn_path.has(tile_position):
		return

	drawn_path.append(tile_position)

	queue_redraw()


func _draw():
	if tile_map == null:
		return

	if drawn_path.is_empty():
		return

	var positions: Array[Vector2] = []

	# Convert all tile positions to local drawing positions
	for tile in drawn_path:
		var world_pos = tile_map.to_global(
			tile_map.map_to_local(tile)
		)

		positions.append(to_local(world_pos))

	# Draw continuous connecting lines
	for i in range(positions.size() - 1):
		draw_line(positions[i],positions[i + 1],Color.YELLOW,3.0)

	# Draw final destination arrow
	if positions.size() >= 2:
		var previous_pos = positions[-2]
		var final_pos = positions[-1]

		var direction = (final_pos - previous_pos).normalized()

		draw_final_arrow(final_pos, direction)

	# Draw tile markers
	for pos in positions:
		draw_circle(pos, 3, Color.GREEN)

func draw_directional_arrow(start: Vector2, finish: Vector2):
	var direction = (finish - start).normalized()

	var perpendicular = Vector2(
		-direction.y,
		direction.x
	)

	var arrow_length = 10.0
	var arrow_width = 5.0

	var arrow_base = finish - direction * arrow_length

	# Draw continuous connecting line
	draw_line(
		start,
		arrow_base,
		Color.YELLOW,
		3.0
	)

	# Arrowhead
	var points = PackedVector2Array([
		finish,
		arrow_base + perpendicular * arrow_width,
		arrow_base - perpendicular * arrow_width
	])

	draw_colored_polygon(points, Color.YELLOW)
	
func draw_final_arrow(position: Vector2, direction: Vector2):
	var perpendicular = Vector2(
		-direction.y,
		direction.x
	)

	var arrow_length = 13.0
	var arrow_width = 7.0

	var arrow_base = position - direction * arrow_length

	var points = PackedVector2Array([
		position + direction * 5.0,
		arrow_base + perpendicular * arrow_width,
		arrow_base - perpendicular * arrow_width
	])

	draw_colored_polygon(points,Color.ORANGE)
