# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AXIS_INTERFACES" -parent ${Page_0}


}

proc update_PARAM_VALUE.AXIS_INTERFACES { PARAM_VALUE.AXIS_INTERFACES } {
	# Procedure called to update AXIS_INTERFACES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIS_INTERFACES { PARAM_VALUE.AXIS_INTERFACES } {
	# Procedure called to validate AXIS_INTERFACES
	return true
}


proc update_MODELPARAM_VALUE.AXIS_INTERFACES { MODELPARAM_VALUE.AXIS_INTERFACES PARAM_VALUE.AXIS_INTERFACES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_INTERFACES}] ${MODELPARAM_VALUE.AXIS_INTERFACES}
}

