@tool
extends Control

@export var texture: Texture2D:
	set(value):
		texture = value
		queue_redraw()

@export_range(2.0, 15.0, 0.5) var radius := 10.0:
	set(value):
		radius = value
		queue_redraw()

@export_range(1.0, 5.0, 0.5) var line_width := 2.0:
	set(value):
		line_width = value
		queue_redraw()

@export_range(0.0, 5.0, 0.5) var dot_radius := 1.5:
	set(value):
		dot_radius = value
		queue_redraw()

@export var normal_color := Color(1.0, 1.0, 1.0, 0.85)
@export var char_interaction_color := Color(0.906, 1.0, 0.302, 1.0)

var interaction_available := false

func set_interaction_available(available: bool) -> void:
	if interaction_available == available:
		return

	interaction_available = available
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5

	var current_color := (
		char_interaction_color
		if interaction_available
		else normal_color
	)

	if texture:
		var texture_size := texture.get_size()
		var scale_factor := minf(
			size.x / texture_size.x,
			size.y / texture_size.y
		)
		var draw_size := texture_size * scale_factor
		var draw_position := center - draw_size * 0.5

		draw_texture_rect(
			texture,
			Rect2(draw_position, draw_size),
			false,
			#TODO: this alters texture, implement texture frames
			current_color
		)
		return

	draw_arc(
		center,
		radius,
		0.0,
		TAU,
		64,
		current_color,
		line_width,
		true
	)

	if dot_radius > 0.0:
		draw_circle(center, dot_radius, current_color)
