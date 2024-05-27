package require -exact qsys 18.0

# create the system "div"
proc do_create_div {} {
	# create the system
	create_system div
	set_project_property DEVICE {1SX280HN2F43E2VG}
	set_project_property DEVICE_FAMILY {Stratix 10}
	set_project_property HIDE_FROM_IP_CATALOG {true}
	set_use_testbench_naming_pattern 0 {}

	# add the components
	add_instance lpm_divide_0 lpm_divide 19.1
	set_instance_parameter_value lpm_divide_0 {GUI_LPM_PIPELINE} {0}
	set_instance_parameter_value lpm_divide_0 {GUI_LPM_REMAINDERPOSITIVE} {Yes}
	set_instance_parameter_value lpm_divide_0 {GUI_LPM_WIDTHd} {8}
	set_instance_parameter_value lpm_divide_0 {GUI_LPM_WIDTHn} {8}
	set_instance_parameter_value lpm_divide_0 {GUI_LPM_dREPRESENTATION} {Signed}
	set_instance_parameter_value lpm_divide_0 {GUI_LPM_nREPRESENTATION} {Unsigned}
	set_instance_parameter_value lpm_divide_0 {GUI_MAXIMIZE_SPEED} {Speed}
	set_instance_parameter_value lpm_divide_0 {GUI_USE_ACLR} {0}
	set_instance_parameter_value lpm_divide_0 {GUI_USE_CLKEN} {0}
	set_instance_property lpm_divide_0 AUTO_EXPORT true

	# add wirelevel expressions

	# add the exports
	set_interface_property lpm_divide_input EXPORT_OF lpm_divide_0.lpm_divide_input
	set_interface_property lpm_divide_output EXPORT_OF lpm_divide_0.lpm_divide_output

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="lpm_divide_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {div.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {div}

	# save the system
	sync_sysinfo_parameters
	save_system div
}

# create all the systems, from bottom up
do_create_div
