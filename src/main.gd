extends Node2D

@onready var Points: Label = $UI/Points
@onready var Icon = $Icon
@onready var GameTimer: Timer = $UI/Timer
@onready var GameOverLabel: Label = $UI/GameOver
@onready var Music: AudioStreamPlayer = $Sound/Music
@onready var GameOverMusic: AudioStreamPlayer = $Sound/MusicGameOver
@onready var ErrorAudio: AudioStreamPlayer = $Sound/Error
@onready var PointAudio: AudioStreamPlayer = $Sound/Point
@onready var Explosion: GPUParticles2D = $Explosion

const LIMIT_WINDOW: int = 100
const COLOURS = [Color.AQUAMARINE, Color.DARK_ORANGE, Color.CRIMSON]
const MULT_ROTATION: int = 1000
const MAX_FAILS: int = 3
const WAIT_TIME: float = 0.995
const PITCH_SCALE: float = 1.005

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var viewport_size: Vector2
var points: int = 0
var is_clicked: bool = false
var fail_count: int = 0


func _ready() -> void:
	viewport_size = get_viewport_rect().size
	Points.text = '%s' % points
	Points.position.x = viewport_size.x / 2
	Icon.position = viewport_size / 2
	Icon.connect('clicked', Callable(self, '_on_click'))
	Points.set_modulate(COLOURS[0])
	Music.play()
	Icon.modulate = COLOURS[0]

func _process(delta: float) -> void:
	Icon.rotate(delta * MULT_ROTATION)


func _on_timer_timeout() -> void:
	fail_count_update()
	Icon.modulate = COLOURS[fail_count % COLOURS.size()]
	Explosion.emitting = false
	
	check_fail_count()
	is_clicked = false
	
	move_icon_random_position()
	Music.pitch_scale *= PITCH_SCALE


@warning_ignore('narrowing_conversion')
func move_icon_random_position() -> void:
	Icon.position.x = rng.randi_range(
		LIMIT_WINDOW, 
		viewport_size.x - LIMIT_WINDOW
	)
		
	Icon.position.y = rng.randi_range(
		Points.position.y + LIMIT_WINDOW, 
		viewport_size.y - LIMIT_WINDOW
	)


func fail_count_update() -> void:
	if not is_clicked:
		fail_count += 1
		if fail_count < MAX_FAILS:
			ErrorAudio.play()


func game_over() -> void:
	Icon.hide()
	GameTimer.stop()
	GameOverLabel.text += '\nTotal points: ' + str(points)
	GameOverLabel.show()
	Points.hide()
	Music.stop()
	GameOverMusic.play()


func check_fail_count() -> void:
	if fail_count < MAX_FAILS:
		Points.set_modulate(COLOURS[fail_count])
	else:
		game_over()


func _on_click() -> void:
	if not is_clicked:
		points += 1
		Points.text = '%s' % points
		GameTimer.wait_time *= WAIT_TIME
		is_clicked = true
		PointAudio.play()
		Icon.modulate = Color.DIM_GRAY
		Explosion.position = Icon.position
		Explosion.emitting = true
