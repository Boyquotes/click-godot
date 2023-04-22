extends Node2D

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var viewport_size: Vector2
var points: int = 0
var is_clicked: bool = false
var fail_count: int = 0

@onready var label: Label = $UI/Points
@onready var icon = $Icon
@onready var timer: Timer = $UI/Timer
@onready var game_over_label: Label = $UI/GameOver
@onready var music: AudioStreamPlayer = $Sound/Music
@onready var music_game_over: AudioStreamPlayer = $Sound/MusicGameOver
@onready var error_audio: AudioStreamPlayer = $Sound/Error
@onready var point_audio: AudioStreamPlayer = $Sound/Point
@onready var explosion: GPUParticles2D = $Explosion

const LIMIT_WINDOW: int = 100
const COLOURS = [Color.AQUAMARINE, Color.DARK_ORANGE, Color.CRIMSON]
const MULT_ROTATION : int = 1000


func _ready() -> void:
	viewport_size = get_viewport_rect().size
	label.text = '%s' % points
	label.position.x = viewport_size.x / 2
	icon.position = viewport_size / 2
	icon.connect('clicked', Callable(self, '_on_click'))
	label.set_modulate(COLOURS[0])
	music.play()
	icon.modulate = COLOURS[0]

func _process(delta: float) -> void:
	icon.rotate(delta * MULT_ROTATION)


func _on_timer_timeout() -> void:
	fail_count_update()
	icon.modulate = COLOURS[fail_count % COLOURS.size()]
	explosion.emitting = false
	
	check_fail_count()
	is_clicked = false
	
	move_icon_random_position()
	music.pitch_scale *= 1.005


@warning_ignore('narrowing_conversion')
func move_icon_random_position() -> void:
	icon.position.x = rng.randi_range(
		LIMIT_WINDOW, 
		viewport_size.x - LIMIT_WINDOW
	)
		
	icon.position.y = rng.randi_range(
		label.position.y + LIMIT_WINDOW, 
		viewport_size.y - LIMIT_WINDOW
	)


func fail_count_update() -> void:
	if not is_clicked:
		fail_count += 1
		if fail_count < 3:
			error_audio.play()


func game_over() -> void:
	icon.hide()
	timer.stop()
	game_over_label.text += '\nTotal points: ' + str(points)
	game_over_label.show()
	label.hide()
	music.stop()
	music_game_over.play()


func check_fail_count() -> void:
	if fail_count < 3:
		label.set_modulate(COLOURS[fail_count])
	else:
		game_over()


func _on_click() -> void:
	if not is_clicked:
		points += 1
		label.text = '%s' % points
		timer.wait_time *= 0.995
		is_clicked = true
		point_audio.play()
		icon.modulate = Color.DIM_GRAY #Color(0.745098, 0.745098, 0.745098, 1)
		explosion.position = icon.position
		explosion.emitting = true
