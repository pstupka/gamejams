extends RigidBody2D

onready var sprite = $Sprite;

export var SPRITE_MODULATION_PEAK: float = 1.0;
export var SPRITE_MODULATION_FADE_SPEED: float = 2.0;
export var AUDIO_SAMPLE : AudioStreamSample;
export var INITIAL_SPRITE_MODULATION: Color = Color.white;

var _sprite_modulation: float = 1.0;
var _modulation_paused: bool = false;
var target;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize();
	$ModulationTimer.wait_time = rand_range(2.5, 3.5);
	target = Global.player;
	$AudioStreamPlayer.stream = AUDIO_SAMPLE;
	modulate = INITIAL_SPRITE_MODULATION;


func _process(delta: float) -> void:
	if target:
		$RayCast2D.cast_to = target.global_position-global_position;
	if not _modulation_paused:
		_sprite_modulation = lerp(_sprite_modulation, 0.0, SPRITE_MODULATION_FADE_SPEED * delta);
	sprite.self_modulate = Color(modulate.r, modulate.g, modulate.b, _sprite_modulation);


func play_tone() -> void:
	if $RayCast2D.get_collider() == Global.player:
		timer_pause(true)
		glow(1);
		$AudioStreamPlayer.play();


func _on_ModulationTimer_timeout() -> void:
	glow();


func _on_AudioStreamPlayer_finished() -> void:
	timer_pause(false);


func timer_pause(pause) -> void:
	$ModulationTimer.paused = pause;


func glow(scale = 1, pause_modulation = false) -> void:
	_sprite_modulation = SPRITE_MODULATION_PEAK * scale;
	_modulation_paused = pause_modulation;
