extends GraphEdit

onready var GNode = load("res://GraphNode.tscn")
onready var NodeIO = load("res://NodeIO.tscn")
onready var TextPopup = get_parent().find_node("TextPopup")
onready var EnterText = TextPopup.find_node("EnterText")
onready var DropDown = get_parent().find_node("PopupMenu")
var selected_node = null
var save_name = "graph.res"

func save_graph(file_name):
	var graph_data = GraphData.new()
	graph_data.connections = get_connection_list()
	for node in get_children():
		if node is GraphNode:
			var node_data = NodeData.new()
			node_data.name = node.name
			node_data.title = node.title
			node_data.offset = node.offset
			node_data.data = node.get_data()
			graph_data.nodes.append(node_data)
	if ResourceSaver.save(file_name, graph_data) == OK:
		print("saved")
	else:
		print("Error saving graph_data")

func load_data(file_name):
	selected_node = null
	if ResourceLoader.exists(file_name):
		var graph_data = ResourceLoader.load(file_name)
		if graph_data is GraphData:
			init_graph(graph_data)
			print("loaded")
		else:
			print("error loading graph")
	else:
		print("error loading graph")

func init_graph(graph_data: GraphData):
	clear_graph()
	var name_changes = {}
	for node in graph_data.nodes:
		# Get new node from factory autoload (singleton)
		var gnode = GNode.instance()
		gnode.offset = node.offset
		gnode.name = node.name
		name_changes[node.name] = gnode.name
		gnode.title = node.title
		gnode.set_data(node.data, NodeIO)
		add_child(gnode)
	for con in graph_data.connections:
		con.from = name_changes[con.from]
		con.to = name_changes[con.to]
		var _e = connect_node(con.from, con.from_port, con.to, con.to_port)

func clear_graph():
	clear_connections()
	var nodes = get_children()
	for node in nodes:
		if node is GraphNode:
			node.queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			if event.pressed:
				DropDown.rect_position = event.position + Vector2(-12,-12)
				DropDown.popup()
	if event is InputEventKey:
		if Input.is_action_just_pressed("add_node"):
			text_popup("Add Node:")
		if Input.is_action_just_pressed("rename_node"):
			text_popup("Rename Node:")
		if Input.is_action_just_pressed("add_input"):
			add_input()
		if Input.is_action_just_pressed("add_output"):
			add_output()
		if Input.is_action_just_pressed("save"):
			save_graph(save_name)
		if Input.is_action_just_pressed("save_as"):
			text_popup("Save As:")
		if Input.is_action_just_pressed("open_graph"):
			text_popup("Open File:")

func add_node(title) -> void:
	var g_node = GNode.instance()
	g_node.offset = get_viewport().get_mouse_position() + Vector2(-12,-12)
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

func _on_PopupMenu_id_pressed(id):
	match id:
		0:
			text_popup("Add Node:")
		1:
			if selected_node != null:
				text_popup("Rename Node:")
		2:
			if selected_node != null:
				selected_node.queue_free()
				selected_node = null
		3:
			add_input()
		4:
			add_output()
		5:
			save_graph(save_name)
		6:
			text_popup("Save As:")
		7:
			save_graph(save_name)
			clear_graph()
		8:
			save_graph(save_name)
			text_popup("Open File:")

func _on_PopupMenu_mouse_exited():
	DropDown.hide()

func text_popup(title: String) -> void:
	TextPopup.rect_position = get_viewport().get_mouse_position()
	TextPopup.window_title = title
	TextPopup.popup()
	EnterText.grab_focus()

func _on_EnterText_text_entered(new_text: String) -> void:
	TextPopup.hide()
	EnterText.clear()
	match TextPopup.window_title:
		"Add Node:":
			add_node(new_text)
		"Rename Node:":
			if selected_node != null:
				selected_node.title = new_text
		"Save As:":
			save_name = new_text + ".res"
			save_graph(save_name)
		"Open File:":
			save_name = new_text + ".res"
			load_data(save_name)
