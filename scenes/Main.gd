
extends Node2D

@export var knight_scene: PackedScene

@onready var path_drawer = $PathDrawer
@onready var tile_map: TileMapLayer = $Layer1

var knight_instance: CharacterBody2D


func _ready():
	path_drawer.path_completed.connect(_on_path_completed)


func _on_path_completed(path: Array[Vector2i]):
	# Make sure the path is valid
	if path.size() < 2:
		return

	# Remove an existing enemy, if there is one
	if is_instance_valid(knight_instance):
		knight_instance.queue_free()

	# Create a new enemy
	knight_instance = knight_scene.instantiate()

	# Give enemy access to the tile map
	knight_instance.tile_map = tile_map

	# Add enemy to the game scene
	add_child(knight_instance)

	# Find the world position of the first tile
	var starting_position = tile_map.to_global(
		tile_map.map_to_local(path[0])
	)

	# Place enemy at the beginning of the path
	knight_instance.global_position = starting_position

	# Tell enemy to follow the path
	knight_instance.follow_path(path)
