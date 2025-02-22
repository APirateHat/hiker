extends Node2D

enum type {EMPTY, EVENT, BONUS, HAZARD}

@export var square : PackedScene
@onready var squares = $Squares
@export var event_resources : Array[EventResource]
var all_squares = []
var event_squares = []
var bonus_squares = []
var hazard_squares = []

var assigned_indexes = []

@export var terrain_tiles : Dictionary
var terrain_types = ["terrain", "trees", "sticks", "rocks", "foliage", "mushrooms"]

var event_amount : int = 10

@export var image : Texture2D
@export var godot : Texture2D

var pixel_data = []

func _ready() -> void:
	for i in create_map():
		all_squares.append(i)
		squares.add_child(i)
	SignalBus.map_information.emit(all_squares.size())
	assign_squares(event_squares, all_squares.size()/4)
	assign_squares(bonus_squares, all_squares.size()/8)
	assign_squares(hazard_squares, 2)
	assign_start_and_end()

	for i in event_squares.size():
		event_squares[i].resource = event_resources.pick_random()
		event_squares[i].square_type = type.EVENT
		event_squares[i].icon.texture = load("res://graphics/tiles/event_tile.svg")
	for i in bonus_squares.size():
		bonus_squares[i].square_type = type.BONUS
		bonus_squares[i].icon.texture = load("res://graphics/tiles/bonus_tile.svg")
	for i in hazard_squares.size():
		hazard_squares[i].square_type = type.HAZARD
		hazard_squares[i].icon.texture = load("res://graphics/tiles/hazard_tile.svg")
	
	get_pixels(Color.BLACK, assign_terrain_tiles)
				

func assign_squares(array:Array, square_amount:int):
	var num = 0
	while num < square_amount:
		var random_number = randi_range(0, all_squares.size()-1)
		if !assigned_indexes.has(random_number) && random_number != 0 && random_number !=  all_squares.size()-1:
			num += 1
			assigned_indexes.append(random_number)
			array.append(all_squares[random_number])
		if num == square_amount:
			print("Event finished")

func assign_start_and_end():
	all_squares[0].icon.texture = load("res://graphics/tiles/start_tile.svg")
	all_squares[all_squares.size()-1].icon.texture = load("res://graphics/tiles/end_tile.svg")

func assign_terrain_tiles(pixel_pos:Vector2):
	var sprite = Sprite2D.new()
	var type : String
	type = terrain_types.pick_random()
	sprite.texture = terrain_tiles[type].pick_random()
	sprite.position = Vector2(pixel_pos.x + randf_range(0, 0.5), pixel_pos.y+ randf_range(0, 0.5)) * 128
	sprite.rotation = randf_range(0, deg_to_rad(360))
	$Terrain.add_child(sprite)
	match type:
		"terrain":
			sprite.z_index = -10
		"trees":
			sprite.z_index = 5
		"sticks":
			sprite.z_index = -2
		"rocks":
			sprite.z_index = -2
		"foliage":
			sprite.z_index = -2
		"mushrooms":
			sprite.z_index = -2

func get_pixels(color, callable:Callable):
	var img = image.get_image()
	for i in 32:
		for j in 32:
			if img.get_pixel(i,j) == color:
				callable.call(Vector2(i, j))

func find_start_pixel():
	var img = image.get_image()
	for i in 32:
		for j in 32:
			if img.get_pixel(i,j) == Color.YELLOW:
				return Vector2(i,j)

func create_map():
	var img = image.get_image()
	var array : Array
	var start_pos = find_start_pixel()
	var s = square.instantiate()
	s.position = start_pos * 128
	array.append(s)
	var previous_pixel : Array
	while true:
		var top = img.get_pixel(start_pos.x, start_pos.y-1)
		var left = img.get_pixel(start_pos.x-1, start_pos.y)
		var right = img.get_pixel(start_pos.x+1, start_pos.y)
		var bottom = img.get_pixel(start_pos.x, start_pos.y+1)
		if top == Color.WHITE && !previous_pixel.has(Vector2(start_pos.x, start_pos.y - 1)):#previous_pixel != Vector2(start_pos.x, start_pos.y - 1):
				s = square.instantiate()
				start_pos.y -= 1
				s.position = start_pos * 128
				array.append(s)
		elif left == Color.WHITE && !previous_pixel.has(Vector2(start_pos.x-1, start_pos.y)):#previous_pixel != Vector2(start_pos.x-1, start_pos.y):
				s = square.instantiate()
				start_pos.x -= 1
				s.position = start_pos * 128
				array.append(s)
		elif right == Color.WHITE && !previous_pixel.has(Vector2(start_pos.x+1, start_pos.y)):#previous_pixel != Vector2(start_pos.x+1, start_pos.y):
				s = square.instantiate()
				start_pos.x += 1
				s.position = start_pos * 128
				array.append(s)
		elif bottom == Color.WHITE && !previous_pixel.has(Vector2(start_pos.x, start_pos.y + 1)):#previous_pixel != Vector2(start_pos.x, start_pos.y+1):
				s = square.instantiate()
				start_pos.y += 1
				s.position = start_pos * 128
				array.append(s)
		else:
			break
		previous_pixel.append(start_pos)
	return array
