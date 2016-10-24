update_ip_catalog -rebuild

# Add Interrupt Ports
startgroup
set_property -dict [list CONFIG.NUM_PORTS {7}] [get_bd_cells microblaze_ss/xlconcat_0]
endgroup

# Enable HDCP2.2 in HDMI_RX_SS 
startgroup
set_property -dict [list CONFIG.C_INCLUDE_HDCP_1_4 {true}] [get_bd_cells v_hdmi_rx_ss_0] 
endgroup
# Connect interrupts to MB
connect_bd_net [get_bd_pins v_hdmi_rx_ss_0/hdcp14_irq] [get_bd_pins microblaze_ss/xlconcat_0/In3]
connect_bd_net [get_bd_pins v_hdmi_rx_ss_0/hdcp14_timer_irq] [get_bd_pins microblaze_ss/xlconcat_0/In4]

# Enable HDCP2.2 in HDMI_TX_SS 
startgroup
set_property -dict [list CONFIG.C_INCLUDE_HDCP_1_4 {true}] [get_bd_cells v_hdmi_tx_ss_0] 
endgroup
# Connect interrupts to MB
connect_bd_net [get_bd_pins v_hdmi_tx_ss_0/hdcp14_irq] [get_bd_pins microblaze_ss/xlconcat_0/In5]
connect_bd_net [get_bd_pins v_hdmi_tx_ss_0/hdcp14_timer_irq] [get_bd_pins microblaze_ss/xlconcat_0/In6]

# Create instance: hdcp_keymngmt_blk_0, and set properties
set hdcp_keymngmt_blk_0 [ create_bd_cell -type ip -vlnv Xilinx:IP:hdcp_keymngmt_blk hdcp_keymngmt_blk_0 ]

# Create instance: hdcp_keymngmt_blk_1, and set properties
set hdcp_keymngmt_blk_1 [ create_bd_cell -type ip -vlnv Xilinx:IP:hdcp_keymngmt_blk hdcp_keymngmt_blk_1 ]

# Add slave ports to the axi_periph and connect aclk and aresetn of these slave ports
startgroup
set_property -dict [list CONFIG.NUM_MI {11}] [get_bd_cells microblaze_ss/microblaze_0_axi_periph]
endgroup
connect_bd_net [get_bd_pins microblaze_ss/microblaze_0_axi_periph/M09_ACLK] [get_bd_pins microblaze_ss/clk_wiz_1/clk_out1]
connect_bd_net [get_bd_pins microblaze_ss/microblaze_0_axi_periph/M10_ACLK] [get_bd_pins microblaze_ss/clk_wiz_1/clk_out1]
connect_bd_net [get_bd_nets rst_clk_wiz_1_100M_peripheral_aresetn] [get_bd_pins microblaze_ss/microblaze_0_axi_periph/M09_ARESETN] [get_bd_pins microblaze_ss/rst_clk_wiz_1_100M/peripheral_aresetn]
connect_bd_net [get_bd_nets rst_clk_wiz_1_100M_peripheral_aresetn] [get_bd_pins microblaze_ss/microblaze_0_axi_periph/M10_ARESETN] [get_bd_pins microblaze_ss/rst_clk_wiz_1_100M/peripheral_aresetn]
connect_bd_intf_net [get_bd_intf_pins hdcp_keymngmt_blk_0/s_axi] -boundary_type upper [get_bd_intf_pins microblaze_ss/microblaze_0_axi_periph/M09_AXI]
connect_bd_intf_net [get_bd_intf_pins hdcp_keymngmt_blk_1/s_axi] -boundary_type upper [get_bd_intf_pins microblaze_ss/microblaze_0_axi_periph/M10_AXI]
 
connect_bd_intf_net [get_bd_intf_pins hdcp_keymngmt_blk_0/m_axis_keys] [get_bd_intf_pins v_hdmi_tx_ss_0/HDCP14_KEY_IN]
connect_bd_intf_net [get_bd_intf_pins hdcp_keymngmt_blk_1/m_axis_keys] [get_bd_intf_pins v_hdmi_rx_ss_0/HDCP14_KEY_IN]

connect_bd_net [get_bd_pins hdcp_keymngmt_blk_0/s_axi_aresetn] [get_bd_pins hdcp_keymngmt_blk_1/s_axi_aresetn] [get_bd_pins microblaze_ss/peripheral_aresetn] 
connect_bd_net [get_bd_pins hdcp_keymngmt_blk_0/s_axi_aclk] [get_bd_pins hdcp_keymngmt_blk_1/s_axi_aclk] [get_bd_pins microblaze_ss/s_axi_aclk]

connect_bd_net [get_bd_pins hdcp_keymngmt_blk_1/m_axis_aclk] [get_bd_pins v_hdmi_rx_ss_0/hdcp14_key_aclk]
connect_bd_net [get_bd_pins hdcp_keymngmt_blk_1/m_axis_aresetn] [get_bd_pins v_hdmi_rx_ss_0/hdcp14_key_aresetn]
connect_bd_net [get_bd_pins hdcp_keymngmt_blk_1/reg_key_sel] [get_bd_pins v_hdmi_rx_ss_0/hdcp14_reg_key_sel]
connect_bd_net [get_bd_pins hdcp_keymngmt_blk_1/start_key_transmit] [get_bd_pins v_hdmi_rx_ss_0/hdcp14_start_key_transmit]

connect_bd_net [get_bd_pins hdcp_keymngmt_blk_0/m_axis_aclk] [get_bd_pins v_hdmi_tx_ss_0/hdcp14_key_aclk]
connect_bd_net [get_bd_pins hdcp_keymngmt_blk_0/m_axis_aresetn] [get_bd_pins v_hdmi_tx_ss_0/hdcp14_key_aresetn]
connect_bd_net [get_bd_pins hdcp_keymngmt_blk_0/reg_key_sel] [get_bd_pins v_hdmi_tx_ss_0/hdcp14_reg_key_sel]
connect_bd_net [get_bd_pins hdcp_keymngmt_blk_0/start_key_transmit] [get_bd_pins v_hdmi_tx_ss_0/hdcp14_start_key_transmit]
  
assign_bd_address [get_bd_addr_segs {hdcp_keymngmt_blk_1/s_axi/reg0 hdcp_keymngmt_blk_0/s_axi/reg0 }]

delete_bd_objs [get_bd_addr_segs microblaze_ss/microblaze_0/Data/SEG_v_hdmi_tx_ss_0_Reg] [get_bd_addr_segs microblaze_ss/microblaze_0/Data/SEG_v_hdmi_rx_ss_0_Reg]
assign_bd_address [get_bd_addr_segs {v_hdmi_rx_ss_0/S_AXI_CPU_IN/Reg v_hdmi_tx_ss_0/S_AXI_CPU_IN/Reg }]

  