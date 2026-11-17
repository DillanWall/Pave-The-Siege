extends CharacterBody2D

@export var move_speed: float = 150.0

var current_path: Array[Vector2i] = []
var is_moving := false
var tile_map: TileMapLayer


func follow_path(path: Array[Vector2i]):
	if is_moving:
		return

	if path.is_empty():
		return

	current_path = path.duplicate()
	is_moving = true

	for tile in current_path:
		var target_position = tile_map.to_global(
			tile_map.map_to_local(tile)
		)

		var tween = create_tween()

		var distance = global_position.distance_to(target_position)
		var duration = distance / move_speed

		tween.tween_property(
			self,
			"global_position",
			target_position,
			duration
		)

		await tween.finished

	is_moving = false
