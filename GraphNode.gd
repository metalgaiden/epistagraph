extends GraphNode

var i = 2
var o = 2

func _ready():
	pass

func _on_GraphNode_close_request():
	get_parent().selected_node = null
	queue_free()

func _on_GraphNode_resize_request(new_minsize):
	rect_size = new_minsize
