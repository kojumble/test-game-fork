@tool
class_name PortalIn
extends VisualShaderNodeCustom

const PORTAL_STYLE: StyleBoxFlat = preload("portal_stylebox.tres")
const PORTAL_SELECT_STYLE: StyleBoxFlat = preload("portal_select_stylebox.tres")

@export var name_portal: String = ""
var is_ready: bool = false
var option_select: int = -1
var type_shader: int = -1
var id_node: int = -1

static var editor_interface = Engine.get_singleton("EditorInterface")
static var shader_editor: Node
static var shader_graph: GraphEdit
static var current_vs: VisualShader
static var portals_in_id: Array[StringName]
static var count_node_added: int = 0


func set_shader_editor():
	if shader_editor != null:
		return
	
	var plugin = ClassDB.instantiate("EditorPlugin")
	var new_control: Control = Control.new()
	plugin.add_control_to_bottom_panel(new_control, "")
	
	shader_editor = new_control.get_parent().find_child("*WindowWrapper*", false, false)
	
	plugin.remove_control_from_bottom_panel(new_control)
	new_control.queue_free()
	plugin.queue_free()
	plugin = null
	
	if shader_editor == null:
		printerr("[Portal Plugin]: No found VisualShaderEditor")
		return
	
	editor_interface.get_base_control().get_tree().create_timer(2).timeout.connect(func(): set_shader_editor_2(), 4)

func set_shader_editor_2():
	var tab: TabContainer = shader_editor.get_child(1).get_child(1)
	if tab == null:
		printerr("[Portal Plugin]: No found ItemList in shader editor")
	else:
		if not tab.tab_selected.is_connected(shader_changed):
			tab.tab_selected.connect(shader_changed.unbind(1))
		if not tab.child_exiting_tree.is_connected(shader_changed):
			tab.child_exiting_tree.connect(shader_changed.unbind(1))
		if not tab.child_entered_tree.is_connected(shader_changed):
			tab.child_entered_tree.connect(shader_changed.bind(true).unbind(1))
	
	if shader_editor.get("visible"):
		shader_changed()
	else:
		shader_editor.connect("visibility_changed", shader_changed, 4)
	
	
	var item_list: ItemList = shader_editor.get_child(1).get_child(0).get_child(1)
	for item_i in item_list.item_count:
		var vs = load(item_list.get_item_tooltip(item_i))
		if vs is VisualShader:
			var graph: GraphEdit = shader_editor.get_child(1).get_child(1).get_child(item_i).get_child(0)
			var type: int = -1
			match vs.get_mode():
				Shader.MODE_SPATIAL, Shader.MODE_CANVAS_ITEM:
					type = graph.get_menu_hbox().get_child(4).selected
				Shader.MODE_PARTICLES:
					var particle_mode: int = graph.get_menu_hbox().get_child(3).selected
					if particle_mode == 2:
						type = VisualShader.TYPE_COLLIDE
					else:
						if graph.get_menu_hbox().get_child(5).button_pressed:
							type = particle_mode + 6
						else:
							type = particle_mode + 3
				Shader.MODE_SKY:
					type = VisualShader.TYPE_SKY
				Shader.MODE_FOG:
					type = VisualShader.TYPE_FOG
			
			if type == -1:
				continue
			
			for id in vs.get_node_list(type):
				var node: VisualShaderNode = vs.get_node(type, id)
				if node is PortalOut:
					var option_btn: OptionButton = graph.get_node(str(id)).get_child(1).get_child(0).get_child(1)
					var err = option_btn.emit_signal("item_selected", node.get_option_index(0))



func _get_name() -> String:
	if not Engine.is_editor_hint():
		return ""
	
	if shader_editor == null:
		set_shader_editor()
	
	var name: String = "PortalIn"
	get_my_type_and_id()
	if resource_path.is_empty():
		if is_ready:
			if name_portal.is_empty():
				await editor_interface.get_base_control().get_tree().process_frame
				var window: Window = preload("set_portal_name.tscn").instantiate()
				editor_interface.popup_dialog_centered(window, Vector2(300, 60))
				name_portal = await window.name_setted
				update_all_portal_out_in_current_shader()
				select_option_vs_node(id_node)
		else:
			if not name_portal.is_empty():
				name_portal = ""
	
	if not name_portal.is_empty():
		name = name + " " + name_portal
	
	is_ready = true
	return name

func _get_category() -> String:
	return "Portal"

func _get_description() -> String:
	return "Portals"



func _get_input_port_count() -> int:
	return 1

func _get_input_port_name(port: int) -> String:
	return "input"

func _get_input_port_type(port: int) -> PortType:
	if not Engine.is_editor_hint():
		return get_option_index(0)
	
	if (option_select != get_option_index(0) and is_ready):
		update_my_portal_out()
	option_select = get_option_index(0)
	return get_option_index(0)


func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(port: int) -> String:
	return ""

func _get_output_port_type(port: int) -> PortType:
	return _get_input_port_type(port)



func _get_property_count() -> int:
	return 1

func _get_property_name(index: int) -> String:
	return "Type"

func _get_property_options(index: int) -> PackedStringArray:
	return ["Float", "Int", "UInt", "Vector2", "Vector3", "Vector4", "Boolean", "Transform", "Sampler"]



func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	if input_vars[0].is_empty():
		return ""
	return output_vars[0] + " = " + input_vars[0] + ";"




func get_portals_in() -> PackedStringArray:
	var portals_in: PackedStringArray
	for id in current_vs.get_node_list(type_shader):
		if current_vs.get_node(type_shader, id) is PortalIn:
			var name_portal: String = current_vs.get_node(type_shader, id).get("name_portal")
			if not name_portal.is_empty():
				portals_in.append(name_portal.to_lower())
	return portals_in


func update_my_portal_out():
	if not resource_path.is_empty():
		if current_vs.resource_path != resource_path.split("::", true, 1)[0]:
			return
	
	get_my_type_and_id()
	
	for i in current_vs.get_node_list(type_shader):
		var node = current_vs.get_node(type_shader, i)
		if node is PortalOut:
			if node.portals_in.keys()[node.get_option_index(0)] == name_portal:
				select_option_vs_node(i)


func get_my_type_and_id():
	if type_shader != -1:
		return
	
	var vs: VisualShader
	if resource_path.is_empty():
		vs = current_vs
	else:
		vs = load(resource_path.split("::", true, 1)[0])
	
	if vs == null:
		return
	
	for type in VisualShader.TYPE_MAX:
		for i in vs.get_node_list(type):
			if vs.get_node(type, i) == self:
				type_shader = type
				id_node = i
				break
		
		if type_shader != -1:
			break











static func update_all_portal_out_in_current_shader():
	for node in shader_graph.get_children():
		if (node is GraphNode) and ("PortalOut" in node.title):
			select_option_vs_node(int(String(node.name)))


static func select_option_vs_node(id: int, option: int = -3):
	if shader_graph == null:
		printerr("[Portal Plugin]: shader graph - null")
		return
	if not shader_graph.has_node(str(id)):
		printerr("[Portal Plugin]: No found GraphNode " + str(id))
		return
	var option_btn: OptionButton = shader_graph.get_node(str(id)).get_child(1).get_child(0).get_child(1)
	if option_btn == null:
		printerr("[Portal Plugin]: OptionButton in option node shader - null")
		return
	if option == -3:
		option = option_btn.selected
	elif option == -2:
		option = option_btn.selected - 1
	var error: int = option_btn.emit_signal("item_selected", option)
	if error != OK:
		printerr("[Portal Plugin]: Emit select option node - " + str(error))


static func hide_connection_line():
	var type: int = -1
	match current_vs.get_mode():
		Shader.MODE_SPATIAL, Shader.MODE_CANVAS_ITEM:
			type = shader_graph.get_menu_hbox().get_child(4).selected
		Shader.MODE_PARTICLES:
			var particle_mode: int = shader_graph.get_menu_hbox().get_child(3).selected
			if particle_mode == 2:
				type = VisualShader.TYPE_COLLIDE
			else:
				if shader_graph.get_menu_hbox().get_child(5).button_pressed:
					type = particle_mode + 6
				else:
					type = particle_mode + 3
		Shader.MODE_SKY:
			type = VisualShader.TYPE_SKY
		Shader.MODE_FOG:
			type = VisualShader.TYPE_FOG
	
	for data in shader_graph.get_connection_list():
		if "PortalIn" in shader_graph.get_node(str(data["from_node"])).title:
			if not "PortalOut" in shader_graph.get_node(str(data["to_node"])).title:
				current_vs.disconnect_nodes(type, int(str(data["from_node"])), 0, int(str(data["to_node"])), 0)
			shader_graph.disconnect_node(data["from_node"], 0, data["to_node"], 0)
		if "PortalOut" in shader_graph.get_node(str(data["to_node"])).title:
			if not "PortalIn" in shader_graph.get_node(str(data["from_node"])).title:
				current_vs.disconnect_nodes(type, int(str(data["from_node"])), 0, int(str(data["to_node"])), 0)
				select_option_vs_node(int(str(data["to_node"])))
			shader_graph.disconnect_node(data["from_node"], 0, data["to_node"], 0)





static func shader_changed(update_portals_out: bool = false):
	await editor_interface.get_base_control().get_tree().process_frame
	
	var item_list: ItemList = shader_editor.get_child(1).get_child(0).get_child(1)
	if item_list.item_count == 0:
		printerr("[Portal Plugin]: ItemList shaders empty")
		return
	
	var index: int = item_list.get_selected_items()[0]
	var vs = load(item_list.get_item_tooltip(index))
	#print("[Test] shader_changed: " + str(item_list.get_item_tooltip(index)) + ", is VisualShader: " + str(vs is VisualShader))
	if vs is VisualShader:
		current_vs = vs
	else:
		#print("[Portal Plugin]: Select shader is not VisualShader, shader: " + str(vs))
		return
	
	var new_shader_graph = shader_editor.get_child(1).get_child(1).get_child(index).get_child(0)
	if shader_graph == new_shader_graph:
		return
	
	if shader_graph != null:
		if shader_graph.child_entered_tree.is_connected(graph_node_added):
			shader_graph.child_entered_tree.disconnect(graph_node_added)
		if shader_graph.delete_nodes_request.is_connected(graph_node_deleted):
			shader_graph.delete_nodes_request.disconnect(graph_node_deleted)
	
	shader_graph = new_shader_graph
	
	if shader_graph == null:
		printerr("[Portal Plugin]: shader graph is null")
		return
	
	
	shader_graph.child_entered_tree.connect(graph_node_added)
	shader_graph.delete_nodes_request.connect(graph_node_deleted)
	
	portals_in_id.clear()
	for node in shader_graph.get_children():
		graph_node_added(node, false)
	hide_connection_line()
	
	if update_portals_out:
		print("Update Portal out")
		update_all_portal_out_in_current_shader()



static func graph_node_added(node: Node, delay: bool = true):
	if delay:
		await editor_interface.get_base_control().get_tree().process_frame
	if not is_instance_valid(node):
		return
	
	if node is GraphNode:
		if "PortalIn" in node.title:
			if not portals_in_id.has(node.name):
				portals_in_id.append(node.name)
			for i in 8:
				node.set_slot_enabled_right(i, false)
			node.add_theme_stylebox_override("titlebar", PORTAL_STYLE)
			node.add_theme_stylebox_override("titlebar_selected", PORTAL_SELECT_STYLE)
		elif "PortalOut" in node.title:
			node.set_slot_enabled_left(2, false)
			node.add_theme_stylebox_override("titlebar", PORTAL_STYLE)
			node.add_theme_stylebox_override("titlebar_selected", PORTAL_SELECT_STYLE)
			
	count_node_added += 1
	if count_node_added == (shader_graph.get_child_count() - 1):
		hide_connection_line()
	await editor_interface.get_base_control().get_tree().process_frame
	count_node_added = 0


static func graph_node_deleted(nodes: Array[StringName]):
	for id in nodes:
		if portals_in_id.has(id):
			update_all_portal_out_in_current_shader()
			break



#
