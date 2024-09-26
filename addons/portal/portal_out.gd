@tool
class_name PortalOut
extends VisualShaderNodeCustom

@export var port_type: int

var is_valid: bool = false
var portals_in: Dictionary
var is_ready: bool = false
var option_select: int = -1
var type_shader: int = -1
var id_node: int = -1



func _get_name() -> String:
	is_ready = true
	return "PortalOut"

func _get_category() -> String:
	return "Portal"

func _get_description() -> String:
	return ""


func _get_input_port_count() -> int:
	return 1

func _get_input_port_name(port: int) -> String:
	return ""

func _get_input_port_type(port: int) -> PortType:
	return _get_output_port_type(port)


func _get_output_port_count() -> int:
	if is_ready:
		if portals_in.is_empty():
			return 0
		if option_select == -1:
			return 0
	return 1

func _get_output_port_name(port: int) -> String:
	return "output"

func _get_output_port_type(port: int) -> PortType:
	if not Engine.is_editor_hint():
		return port_type
	
	if option_select == -1:
		return 0
	if option_select >= portals_in.size():
		return 0
	
	port_type = portals_in.values()[option_select]
	return port_type



func _get_property_count() -> int:
	return 1

func _get_property_name(index: int) -> String:
	return "Portal"

func _get_property_default_index(index: int) -> int:
	return -1

func _get_property_options(index: int) -> PackedStringArray:
	var old_portals: Array = portals_in.keys().duplicate()
	get_portals_in()
	
	if (option_select != get_option_index(0) and is_ready):
		connect_portal()
	option_select = get_option_index(0)
	
	if get_option_index(0) != -1:
		if old_portals.size() > portals_in.size():
			var name_portal: String = old_portals[get_option_index(0)]
			if portals_in.has(name_portal):
				if not (portals_in.keys().find(name_portal) == old_portals.find(name_portal)):
					option_select = get_option_index(0) - (old_portals.size() - portals_in.size())
					PortalIn.select_option_vs_node(id_node, option_select)
			else:
				option_select = -1
				PortalIn.select_option_vs_node(id_node, -1)
				disconnect_all()
	
	var option_index: int = int(String(get("properties")).get_slice(",", 1))
	
	if option_index >= portals_in.size():
		var list: PackedStringArray = portals_in.keys()
		list.resize(option_index + 1)
		return list
	
	return portals_in.keys()




func _get_code(input_vars: Array[String], output_vars: Array[String], mode: Shader.Mode, type: VisualShader.Type) -> String:
	if input_vars[0].is_empty():
		return ""
	if output_vars.is_empty():
		return ""
	return output_vars[0] + " = " + input_vars[0] + ";"



func get_portals_in():
	portals_in.clear()
	
	var vs: VisualShader
	if resource_path.is_empty():
		vs = PortalIn.current_vs
	else:
		vs = load(resource_path.split("::", true, 1)[0])
	
	if vs == null:
		return
	
	var is_update_node: bool = false
	if (resource_path.is_empty() and type_shader == -1) or vs == null:
		await PortalIn.editor_interface.get_edited_scene_root().get_tree().process_frame
		is_update_node = true
	
	if type_shader == -1:
		for i in VisualShader.TYPE_MAX:
			for id in vs.get_node_list(i):
				if vs.get_node(i, id) == self:
					id_node = id
					break
			
			if id_node != -1:
				type_shader = i
				break
		
		if id_node == -1:
			printerr("[Portal Plugin]: No found shader node")
			return
	
	for id in vs.get_node_list(type_shader):
		if vs.get_node(type_shader, id) is PortalIn:
			var name_portal: String = vs.get_node(type_shader, id).get("name_portal")
			if not name_portal.is_empty():
				portals_in[name_portal] = vs.get_node(type_shader, id).get_option_index(0)
	
	if is_update_node:
		PortalIn.select_option_vs_node(id_node, get_option_index(0))



func connect_portal():
	var vs: VisualShader = PortalIn.current_vs
	if vs == null and is_ready:
		#printerr("[Portal Plugin]: connect_portal: VisualShader - null")
		return
	for i in vs.get_node_list(type_shader):
		var node = vs.get_node(type_shader, i)
		if node is PortalIn:
			if node.name_portal == portals_in.keys()[get_option_index(0)]:
				if not vs.is_node_connection(type_shader, i, 0, id_node, 0):
					vs.connect_nodes(type_shader, i, 0, id_node, 0)
				if PortalIn.shader_graph.is_node_connected(str(i), 0, str(id_node), 0):
					PortalIn.shader_graph.disconnect_node(str(i), 0, str(id_node), 0)
			else:
				if vs.is_node_connection(type_shader, i, 0, id_node, 0):
					vs.disconnect_nodes(type_shader, i, 0, id_node, 0)


func disconnect_all():
	var vs: VisualShader = PortalIn.current_vs
	for data in vs.get_node_connections(type_shader):
		if data["from_node"] == id_node:
			vs.disconnect_nodes(type_shader, id_node, data["from_port"], data["to_node"], data["to_port"])
			if PortalIn.shader_graph.is_node_connected(str(id_node), data["from_port"], str(data["to_node"]), data["to_port"]):
				PortalIn.shader_graph.disconnect_node(str(id_node), data["from_port"], str(data["to_node"]), data["to_port"])








#
