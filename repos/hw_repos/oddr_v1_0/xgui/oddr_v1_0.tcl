# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"

}

proc update_PARAM_VALUE.C_FAMILY { PARAM_VALUE.C_FAMILY } {
	# Procedure called to update C_FAMILY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FAMILY { PARAM_VALUE.C_FAMILY } {
	# Procedure called to validate C_FAMILY
	return true
}


