@tool
extends Window


var portals_in: PackedStringArray

signal name_setted(name: String)


func _ready() -> void:
	grab_focus()
	$LineEdit.grab_focus()
	for node in PortalIn.shader_graph.get_children():
		if node is GraphNode:
			var name_portal: String = node.title
			if "PortalIn " in name_portal:
				name_portal = name_portal.split(" ", true, 1)[1]
				if not name_portal.is_empty():
					portals_in.append(name_portal.to_lower())


func _on_line_edit_text_submitted(new_text: String) -> void:
	var name: String = new_text.to_lower()
	if name.is_empty():
		$LineEdit.placeholder_text = "The name must not be blank"
		return
	if portals_in.has(name):
		$LineEdit.text = ""
		$LineEdit.placeholder_text = "That name is already taken"
		return
	
	queue_free()
	name_setted.emit($LineEdit.text)
