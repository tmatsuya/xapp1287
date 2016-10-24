# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Component_Name [ipgui::add_param $IPINST -name Component_Name]
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set INIT_FILE [ipgui::add_param $IPINST -parent $Page0 -name INIT_FILE -widget textEdit]
	set BRAM_NO [ipgui::add_param $IPINST -parent $Page0 -name BRAM_NO]
}

proc update_PARAM_VALUE.INIT_FILE { PARAM_VALUE.INIT_FILE } {
	# Procedure called to update INIT_FILE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INIT_FILE { PARAM_VALUE.INIT_FILE } {
	# Procedure called to validate INIT_FILE
	return true
}

proc update_PARAM_VALUE.BRAM_NO { PARAM_VALUE.BRAM_NO } {
	# Procedure called to update BRAM_NO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BRAM_NO { PARAM_VALUE.BRAM_NO } {
	# Procedure called to validate BRAM_NO
	return true
}


proc update_MODELPARAM_VALUE.BRAM_NO { MODELPARAM_VALUE.BRAM_NO PARAM_VALUE.BRAM_NO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BRAM_NO}] ${MODELPARAM_VALUE.BRAM_NO}
}

proc update_MODELPARAM_VALUE.INIT_FILE { MODELPARAM_VALUE.INIT_FILE PARAM_VALUE.INIT_FILE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INIT_FILE}] ${MODELPARAM_VALUE.INIT_FILE}
}

