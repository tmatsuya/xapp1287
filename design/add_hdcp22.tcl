update_ip_catalog -rebuild

if [expr $ENABLE_HDCP14 == 1] {
	# Add Interrupt Ports
	startgroup
	set_property -dict [list CONFIG.NUM_PORTS {11}] [get_bd_cells microblaze_ss/xlconcat_0]
	endgroup
	
	# Enable HDCP2.2 in HDMI_RX_SS 
	startgroup
	set_property -dict [list CONFIG.C_INCLUDE_HDCP_2_2 {true}] [get_bd_cells v_hdmi_rx_ss_0] 
	endgroup
	# Connect interrupts to MB
	connect_bd_net [get_bd_pins v_hdmi_rx_ss_0/hdcp22_irq] [get_bd_pins microblaze_ss/xlconcat_0/In7]
	connect_bd_net [get_bd_pins v_hdmi_rx_ss_0/hdcp22_timer_irq] [get_bd_pins microblaze_ss/xlconcat_0/In8]
	
	# Enable HDCP2.2 in HDMI_TX_SS 
	startgroup
	set_property -dict [list CONFIG.C_INCLUDE_HDCP_2_2 {true}] [get_bd_cells v_hdmi_tx_ss_0] 
	endgroup
	# Connect interrupts to MB
	connect_bd_net [get_bd_pins v_hdmi_tx_ss_0/hdcp22_irq] [get_bd_pins microblaze_ss/xlconcat_0/In9]
	connect_bd_net [get_bd_pins v_hdmi_tx_ss_0/hdcp22_timer_irq] [get_bd_pins microblaze_ss/xlconcat_0/In10]
}

if [expr $ENABLE_HDCP14 != 1] {
	# Add Interrupt Ports
	startgroup
	set_property -dict [list CONFIG.NUM_PORTS {7}] [get_bd_cells microblaze_ss/xlconcat_0]
	endgroup
	
	# Enable HDCP2.2 in HDMI_RX_SS 
	startgroup
	set_property -dict [list CONFIG.C_INCLUDE_HDCP_2_2 {true}] [get_bd_cells v_hdmi_rx_ss_0] 
	endgroup
	# Connect interrupts to MB
	connect_bd_net [get_bd_pins v_hdmi_rx_ss_0/hdcp22_irq] [get_bd_pins microblaze_ss/xlconcat_0/In3]
	connect_bd_net [get_bd_pins v_hdmi_rx_ss_0/hdcp22_timer_irq] [get_bd_pins microblaze_ss/xlconcat_0/In4]
	
	# Enable HDCP2.2 in HDMI_TX_SS 
	startgroup
	set_property -dict [list CONFIG.C_INCLUDE_HDCP_2_2 {true}] [get_bd_cells v_hdmi_tx_ss_0] 
	endgroup
	# Connect interrupts to MB
	connect_bd_net [get_bd_pins v_hdmi_tx_ss_0/hdcp22_irq] [get_bd_pins microblaze_ss/xlconcat_0/In5]
	connect_bd_net [get_bd_pins v_hdmi_tx_ss_0/hdcp22_timer_irq] [get_bd_pins microblaze_ss/xlconcat_0/In6]
}

delete_bd_objs [get_bd_addr_segs microblaze_ss/microblaze_0/Data/SEG_v_hdmi_tx_ss_0_Reg] [get_bd_addr_segs microblaze_ss/microblaze_0/Data/SEG_v_hdmi_rx_ss_0_Reg]
assign_bd_address [get_bd_addr_segs {v_hdmi_rx_ss_0/S_AXI_CPU_IN/Reg v_hdmi_tx_ss_0/S_AXI_CPU_IN/Reg }]
