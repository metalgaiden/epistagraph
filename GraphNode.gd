extends GraphNode

var i = 2
var o = 2

func get_data() -> Dictionary:
	var data = {
		"text": $TextEdit.text,
		"io_nodes": []
	}
	for node in get_children():
		if node.name.begins_with("NodeIO") or node.name.begins_with("@NodeIO"):
			var io_text = ["_","_"]
			if node.get_child(0).visible:
				io_text[0] = node.get_child(0).text
			if node.get_child(1).visible:
				io_text[1] = node.get_child(1).text
			data["io_nodes"].append(io_text)
	return data

func set_data(data: Dictionary, NodeIO) -> void:
	$TextEdit.text = data["text"]
	var j = i
	for pair in data["io_nodes"]:
		var e_left = false
		var e_right = false
		var node_io = NodeIO.instance()
		if pair[0] != "_":
			e_left = true
			node_io.get_child(0).visible = true
			node_io.get_child(0).text = pair[0]
		if pair[1] != "_":
			e_right = true
			node_io.get_child(1).visible = true
			node_io.get_child(1).text = pair[1]
		set_slot(j, e_left, 0, Color(1,0,1,1), 
			e_right, 0, Color(0,1,0,1), null, null)
		j += 1
		add_child(node_io)

func _on_GraphNode_close_request():
	get_parent().selected_node = null
	queue_free()

func _on_GraphNode_resize_request(new_minsize):
	rect_size = new_minsize
