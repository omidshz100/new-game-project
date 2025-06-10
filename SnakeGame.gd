extends Control

# Game constants
const GRID_SIZE = 20
const GAME_SPEED = 0.15
const SWIPE_THRESHOLD = 50

# Game variables
var snake_body = []
var snake_direction = Vector2.RIGHT
var food_position = Vector2.ZERO
var score = 0
var game_over = false
var game_started = false

# Input handling
var touch_start_position = Vector2.ZERO
var is_touching = false

# UI nodes
@onready var score_label = $UI/ScoreLabel
@onready var game_over_panel = $UI/GameOverPanel
@onready var final_score_label = $UI/GameOverPanel/FinalScoreLabel
@onready var restart_button = $UI/GameOverPanel/RestartButton
@onready var start_panel = $UI/StartPanel
@onready var start_button = $UI/StartPanel/StartButton

# Game area
var game_area_rect: Rect2

func _ready():
	# Initialize game area based on screen size
	var screen_size = get_viewport().get_visible_rect().size
	var margin = 40
	game_area_rect = Rect2(margin, margin + 100, screen_size.x - margin * 2, screen_size.y - margin * 2 - 100)
	
	# Connect UI signals
	restart_button.pressed.connect(_on_restart_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)
	
	# Setup initial UI state
	show_start_screen()
	
	# Start game timer
	var timer = Timer.new()
	timer.wait_time = GAME_SPEED
	timer.timeout.connect(_game_step)
	timer.autostart = false
	add_child(timer)
	timer.name = "GameTimer"

func show_start_screen():
	"""Display the start screen"""
	start_panel.visible = true
	game_over_panel.visible = false
	score_label.visible = false
	game_started = false

func _on_start_button_pressed():
	"""Start a new game"""
	start_panel.visible = false
	score_label.visible = true
	init_game()

func init_game():
	"""Initialize game state"""
	# Reset game variables
	score = 0
	game_over = false
	game_started = true
	snake_direction = Vector2.RIGHT
	
	# Initialize snake at center of game area
	var center_x = int((game_area_rect.position.x + game_area_rect.size.x / 2.0) / GRID_SIZE)
	var center_y = int((game_area_rect.position.y + game_area_rect.size.y / 2.0) / GRID_SIZE)
	snake_body = [
		Vector2(center_x, center_y),
		Vector2(center_x - 1, center_y),
		Vector2(center_x - 2, center_y)
	]
	
	# Spawn initial food
	spawn_food()
	
	# Update UI
	update_score_display()
	
	# Start game timer
	get_node("GameTimer").start()

func spawn_food():
	"""Spawn food at random location not occupied by snake"""
	var max_attempts = 100
	var attempts = 0
	
	while attempts < max_attempts:
		var x = randi() % int(game_area_rect.size.x / GRID_SIZE)
		var y = randi() % int(game_area_rect.size.y / GRID_SIZE)
		food_position = Vector2(x + int(game_area_rect.position.x / GRID_SIZE), y + int(game_area_rect.position.y / GRID_SIZE))
		
		# Check if food position conflicts with snake
		if not food_position in snake_body:
			break
		
		attempts += 1

func _game_step():
	"""Main game loop step"""
	if game_over or not game_started:
		return
	
	# Move snake
	move_snake()
	
	# Check collisions
	check_collisions()
	
	# Redraw game
	queue_redraw()

func move_snake():
	"""Move snake in current direction"""
	var head = snake_body[0]
	var new_head = head + snake_direction
	
	# Add new head
	snake_body.insert(0, new_head)
	
	# Check if food eaten
	if new_head == food_position:
		score += 10
		update_score_display()
		spawn_food()
	else:
		# Remove tail if no food eaten
		snake_body.pop_back()

func check_collisions():
	"""Check for wall and self collisions"""
	var head = snake_body[0]
	
	# Check wall collision
	var grid_bounds = Rect2(
		int(game_area_rect.position.x / GRID_SIZE),
		int(game_area_rect.position.y / GRID_SIZE),
		int(game_area_rect.size.x / GRID_SIZE),
		int(game_area_rect.size.y / GRID_SIZE)
	)
	
	if head.x < grid_bounds.position.x or head.x >= grid_bounds.position.x + grid_bounds.size.x or \
	   head.y < grid_bounds.position.y or head.y >= grid_bounds.position.y + grid_bounds.size.y:
		end_game()
		return
	
	# Check self collision
	for i in range(1, snake_body.size()):
		if head == snake_body[i]:
			end_game()
			return

func end_game():
	"""Handle game over"""
	game_over = true
	get_node("GameTimer").stop()
	
	# Show game over UI
	final_score_label.text = "Final Score: " + str(score)
	game_over_panel.visible = true

func update_score_display():
	"""Update score label"""
	score_label.text = "Score: " + str(score)

func _on_restart_button_pressed():
	"""Restart the game"""
	game_over_panel.visible = false
	init_game()

# Input handling for mobile swipe controls
func _input(event):
	if not game_started or game_over:
		return
	
	# Handle touch input for mobile
	if event is InputEventScreenTouch:
		if event.pressed:
			is_touching = true
			touch_start_position = event.position
		else:
			if is_touching:
				process_swipe(event.position)
			is_touching = false
	
	# Handle mouse input for testing on desktop
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_touching = true
				touch_start_position = event.position
			else:
				if is_touching:
					process_swipe(event.position)
				is_touching = false
	
	# Handle keyboard input for testing
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				change_direction(Vector2.UP)
			KEY_DOWN:
				change_direction(Vector2.DOWN)
			KEY_LEFT:
				change_direction(Vector2.LEFT)
			KEY_RIGHT:
				change_direction(Vector2.RIGHT)

func process_swipe(end_position: Vector2):
	"""Process swipe gesture and change snake direction"""
	var swipe_vector = end_position - touch_start_position
	
	# Check if swipe is long enough
	if swipe_vector.length() < SWIPE_THRESHOLD:
		return
	
	# Determine swipe direction
	var abs_x = abs(swipe_vector.x)
	var abs_y = abs(swipe_vector.y)
	
	if abs_x > abs_y:
		# Horizontal swipe
		if swipe_vector.x > 0:
			change_direction(Vector2.RIGHT)
		else:
			change_direction(Vector2.LEFT)
	else:
		# Vertical swipe
		if swipe_vector.y > 0:
			change_direction(Vector2.DOWN)
		else:
			change_direction(Vector2.UP)

func change_direction(new_direction: Vector2):
	"""Change snake direction if valid"""
	# Prevent reversing into self
	if new_direction == -snake_direction:
		return
	
	snake_direction = new_direction

# Drawing function
func _draw():
	if not game_started:
		return
	
	# Draw game area border
	draw_rect(game_area_rect, Color.WHITE, false, 2)
	
	# Draw snake
	for i in range(snake_body.size()):
		var segment = snake_body[i]
		var rect = Rect2(
			segment.x * GRID_SIZE,
			segment.y * GRID_SIZE,
			GRID_SIZE - 1,
			GRID_SIZE - 1
		)
		
		# Head is brighter green
		var color = Color.LIME_GREEN if i == 0 else Color.GREEN
		draw_rect(rect, color)
	
	# Draw food
	var food_rect = Rect2(
		food_position.x * GRID_SIZE,
		food_position.y * GRID_SIZE,
		GRID_SIZE - 1,
		GRID_SIZE - 1
	)
	draw_rect(food_rect, Color.RED)
