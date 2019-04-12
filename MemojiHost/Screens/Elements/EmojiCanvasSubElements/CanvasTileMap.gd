extends TileMap

signal canvas_clicked(row, column)


func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		var grid_loc = world_to_map(get_local_mouse_position())
		#print(grid_loc)
		emit_signal("canvas_clicked", grid_loc.y, grid_loc.x)

func _draw():
	pass
"""
	draw_set_transform(Vector2(), 0, cell_size)
    for y in range(0, 400):
        draw_line(Vector2(0, y), Vector2(400, y), Color(0,0,0), 1)

    for x in range(0, 400):
        draw_line(Vector2(x, 0), Vector2(x, 400), Color(0,0,0), 1)
"""
