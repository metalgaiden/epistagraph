extends GraphEdit

onready var GNode = load("res://GraphNode.tscn")
onready var NodeIO = load("res://NodeIO.tscn")
onready var PopupText = get_parent().find_node("Popup").find_node("LineEdit")
onready var DropDown = get_parent().get_child(2)
var initial_position = Vector2(40,40)
var node_index = 0
var selected_node = null
var __

func _process(_delta):
	if(Input.is_action_just_pressed("add_node")):
		PopupText.get_parent().popup()
	if(Input.is_action_just_pressed("add_input")):
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
	if(Input.is_action_just_pressed("add_output")):
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

func add_node(title) -> void:
	var g_node = GNode.instance()
	g_node.offset += initial_position + (node_index * Vector2(20,20))
	g_node.title = title
	add_child(g_node)
	node_index += 1

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	__ = connect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_node_selected(node):
	selected_node = node

func _on_GraphEdit_node_unselected(_node):
	selected_node = null

func _on_PopupMenu_id_pressed(id):
	pass # Replace with function body.

func _on_Popup_confirmed():
	var title = PopupText.text
	PopupText.clear()
	add_node(title)
