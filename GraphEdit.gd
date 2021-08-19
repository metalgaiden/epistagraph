extends GraphEdit

onready var GNode = load("res://GraphNode.tscn")
onready var NodeIO = load("res://NodeIO.tscn")
onready var TitlePopup = get_parent().find_node("TitlePopup")
onready var RenamePopup = get_parent().find_node("RenamePopup")
onready var DropDown = get_parent().find_node("PopupMenu")
var selected_node = null

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("add_node")):
		TitlePopup.popup()
	if(Input.is_action_just_pressed("add_input")):
		add_input()
	if(Input.is_action_just_pressed("add_output")):
		add_output()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			if event.pressed:
				DropDown.rect_position = event.position
				DropDown.popup()

func add_node(title) -> void:
	var g_node = GNode.instance()
	g_node.offset = get_viewport().get_mouse_position() + Vector2(-20,-40)
	g_node.title = title
	add_child(g_node)

func add_input() -> void:
	if(selected_node != null):
		if selected_node.is_slot_enabled_right(selected_node.i):
			selected_node.get_child(selected_node.i).get_child(0).visible = true
			selected_node.set_slot(selected_node.i, true, 0, Color(1,0,1,1), 
			true, 0, selected_node.get_slot_color_right(selected_node.i), null, null)
		else:
			var node_io = NodeIO.instance()
			node_io.get_child(0).visible = true
			selected_node.add_child(node_io)
			selected_node.set_slot(selected_node.i, true, 0, Color(1,0,1,1), 
			false, 0, Color(0,1,0,1), null, null)
		selected_node.i += 1

func add_output() -> void:
	if(selected_node != null):
		if selected_node.is_slot_enabled_left(selected_node.o):
			selected_node.get_child(selected_node.o).get_child(1).visible = true
			selected_node.set_slot(selected_node.o, true, 0, 
			selected_node.get_slot_color_left(selected_node.o), 
			true, 0, Color(0,1,0,1), null, null)
		else:
			var node_io = NodeIO.instance()
			node_io.get_child(1).visible = true
			selected_node.add_child(node_io)
			selected_node.set_slot(selected_node.o, false, 0, Color(1,0,1,1), 
			true, 0, Color(0,1,0,1), null, null)
		selected_node.o += 1

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	connect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_node_selected(node):
	selected_node = node

func _on_GraphEdit_node_unselected(_node):
	#selected_node = null
	pass

func _on_PopupMenu_id_pressed(id):
	match id:
		0:
			TitlePopup.rect_position = get_viewport().get_mouse_position() + Vector2(-10,-19)
			TitlePopup.popup()
			TitlePopup.find_node("TitleText").select()
		1:
			if selected_node != null:
				RenamePopup.rect_position = get_viewport().get_mouse_position() + Vector2(-10,-19)
				RenamePopup.popup()
		2:
			if selected_node != null:
				selected_node.queue_free()
				selected_node = null
		3:
			add_input()
		4:
			add_output()

func _on_TitleText_text_entered(title: String) -> void:
	TitlePopup.hide()
	TitlePopup.find_node("TitleText").clear()
	add_node(title)

func _on_RenameText_text_entered(rename: String) -> void:
	if selected_node != null:
		RenamePopup.hide()
		RenamePopup.find_node("RenameText").clear()
		selected_node.title = rename

func _on_PopupMenu_mouse_exited():
	DropDown.hide()
