RSRC                    VisualShader            ��������                                            K      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame 	   constant    script    initialized    properties    name_portal 
   port_type    code    graph_offset    mode    modes/blend    modes/depth_draw    modes/cull    modes/diffuse    modes/specular    flags/depth_prepass_alpha    flags/depth_test_disabled    flags/sss_mode_skin    flags/unshaded    flags/wireframe    flags/skip_vertex_transform    flags/world_vertex_coords    flags/ensure_correct_normals    flags/shadows_disabled    flags/ambient_light_disabled    flags/shadow_to_opacity    flags/vertex_lighting    flags/particle_trails    flags/alpha_to_coverage     flags/alpha_to_coverage_and_one    flags/debug_shadow_splits    flags/fog_disabled    nodes/vertex/0/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/6/node    nodes/fragment/6/position    nodes/fragment/7/node    nodes/fragment/7/position    nodes/fragment/8/node    nodes/fragment/8/position    nodes/fragment/9/node    nodes/fragment/9/position    nodes/fragment/10/node    nodes/fragment/10/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections       Script !   res://addons/portal/portal_in.gd ��������   Script "   res://addons/portal/portal_out.gd ��������
   ,   local://VisualShaderNodeColorConstant_okldm q
      %   local://VisualShaderNodeCustom_gt0cc �
      ,   local://VisualShaderNodeFloatConstant_b81gp       ,   local://VisualShaderNodeFloatConstant_fmmjx O      %   local://VisualShaderNodeCustom_fwahm �      %   local://VisualShaderNodeCustom_co0ke �      %   local://VisualShaderNodeCustom_koeeb )      %   local://VisualShaderNodeCustom_dnn66 p      %   local://VisualShaderNodeCustom_7dw5a �      "   res://example/example_shader.tres           VisualShaderNodeColorConstant            �?          �?         VisualShaderNodeCustom             	         0,4;              
         Color    VisualShaderNodeFloatConstant          D�l>         VisualShaderNodeFloatConstant          D�l>         VisualShaderNodeCustom                          
         Metalic    VisualShaderNodeCustom                          
      
   Roughness    VisualShaderNodeCustom                                     VisualShaderNodeCustom             	         0,1;                          VisualShaderNodeCustom             	         0,2;                          VisualShader          3  shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;




void fragment() {
// ColorConstant:2
	vec4 n_out2p0 = vec4(1.000000, 0.000000, 0.000000, 1.000000);


	vec3 n_out3p0;
// PortalIn Color:3
	{
		n_out3p0 = vec3(n_out2p0.xyz);
	}


	float n_out8p0;
// PortalOut:8
	{
		n_out8p0 = n_out3p0.x;
	}


// FloatConstant:4
	float n_out4p0 = 0.231000;


	float n_out6p0;
// PortalIn Metalic:6
	{
		n_out6p0 = n_out4p0;
	}


	float n_out9p0;
// PortalOut:9
	{
		n_out9p0 = n_out6p0;
	}


// FloatConstant:5
	float n_out5p0 = 0.231000;


	float n_out7p0;
// PortalIn Roughness:7
	{
		n_out7p0 = n_out5p0;
	}


	float n_out10p0;
// PortalOut:10
	{
		n_out10p0 = n_out7p0;
	}


// Output:0
	ALBEDO = vec3(n_out8p0);
	METALLIC = n_out9p0;
	ROUGHNESS = n_out10p0;


}
    
   �Gļ�5�(             )   
     R�  �B*            +   
     �  �B,            -   
     R�  �C.            /   
     R�  �C0            1   
     �  pC2            3   
     �  �C4            5   
     p�  �B6            7   
     p�  pC8            9   
     p�  �C:       $                                                                  	              
                      	              
                    RSRC