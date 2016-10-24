
################################################################
# This is a generated script based on design: hdmi_example_kc705
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   common::send_msg_id "BD_TCL-1002" "WARNING" "This script was generated using Vivado <$scripts_vivado_version> without IP versions in the create_bd_cell commands, but is now being run in <$current_vivado_version> of Vivado. There may have been major IP version changes between Vivado <$scripts_vivado_version> and <$current_vivado_version>, which could impact the parameter settings of the IPs."

}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source hdmi_example_kc705_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7k325tffg900-2
   set_property BOARD_PART xilinx.com:kc705:part0:1.2 [current_project]
}


# CHANGE DESIGN NAME HERE
set design_name hdmi_example_kc705

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -from 0 -to 0 -type rst LMB_Rst

  # Create instance: dlmb_bram_if_cntlr_0, and set properties
  set dlmb_bram_if_cntlr_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr dlmb_bram_if_cntlr_0 ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr_0

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10 dlmb_v10 ]
  set_property -dict [ list \
CONFIG.C_LMB_NUM_SLAVES {1} \
 ] $dlmb_v10

  # Create instance: ilmb_bram_if_cntlr_0, and set properties
  set ilmb_bram_if_cntlr_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr ilmb_bram_if_cntlr_0 ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr_0

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10 ilmb_v10 ]
  set_property -dict [ list \
CONFIG.C_LMB_NUM_SLAVES {1} \
 ] $ilmb_v10

  # Create instance: lmb_bram_0, and set properties
  set lmb_bram_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen lmb_bram_0 ]
  set_property -dict [ list \
CONFIG.Memory_Type {True_Dual_Port_RAM} \
CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram_0

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr_0/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr_0/BRAM_PORT] [get_bd_intf_pins lmb_bram_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr_0/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr_0/BRAM_PORT] [get_bd_intf_pins lmb_bram_0/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr_0/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr_0/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]
  connect_bd_net -net microblaze_0_LMB_Rst [get_bd_pins LMB_Rst] [get_bd_pins dlmb_bram_if_cntlr_0/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr_0/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: tpg_ss
proc create_hier_cell_tpg_ss { parentCell nameHier } {

  variable script_folder
  variable PPC_SEL
  variable BPC_SEL

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_tpg_ss() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_GPIO
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_TPG
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_video
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_video

  # Create pins
  create_bd_pin -dir I -type clk ap_clk
  create_bd_pin -dir I -type rst m_axi_aresetn

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_0 ]
  set_property -dict [ list \
CONFIG.C_ALL_OUTPUTS {1} \
CONFIG.C_GPIO_WIDTH {1} \
 ] $axi_gpio_0

  # Create instance: v_tpg_0, and set properties
  set v_tpg_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_tpg v_tpg_0 ]
  set_property -dict [ list \
CONFIG.HAS_AXI4S_SLAVE {1} \
CONFIG.MAX_DATA_WIDTH $BPC_SEL \
CONFIG.SAMPLES_PER_CLOCK $PPC_SEL \
 ] $v_tpg_0

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI_TPG] [get_bd_intf_pins v_tpg_0/s_axi_CTRL]
  connect_bd_intf_net -intf_net microblaze_ss_M08_AXI [get_bd_intf_pins S_AXI_GPIO] [get_bd_intf_pins axi_gpio_0/S_AXI]
  connect_bd_intf_net -intf_net rx_video_axis_reg_slice_0_M_AXIS [get_bd_intf_pins s_axis_video] [get_bd_intf_pins v_tpg_0/s_axis_video]
  connect_bd_intf_net -intf_net v_tpg_0_m_axis_video [get_bd_intf_pins m_axis_video] [get_bd_intf_pins v_tpg_0/m_axis_video]

  # Create port connections
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins v_tpg_0/ap_rst_n]
  connect_bd_net -net clk_wiz_1_clk_out2 [get_bd_pins ap_clk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins v_tpg_0/ap_clk]
  connect_bd_net -net m_axi_aresetn_1 [get_bd_pins m_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: sma
proc create_hier_cell_sma { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_sma() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I sma_in0
  create_bd_pin -dir I sma_in1
  create_bd_pin -dir I sma_in2
  create_bd_pin -dir I sma_in3
  create_bd_pin -dir O sma_out0
  create_bd_pin -dir O sma_out1
  create_bd_pin -dir O sma_out2
  create_bd_pin -dir O sma_out3

  # Create instance: oddr_0, and set properties
  set oddr_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:oddr oddr_0 ]

  # Create instance: oddr_1, and set properties
  set oddr_1 [ create_bd_cell -type ip -vlnv xilinx.com:user:oddr oddr_1 ]

  # Create instance: oddr_2, and set properties
  set oddr_2 [ create_bd_cell -type ip -vlnv xilinx.com:user:oddr oddr_2 ]

  # Create instance: oddr_3, and set properties
  set oddr_3 [ create_bd_cell -type ip -vlnv xilinx.com:user:oddr oddr_3 ]

  # Create port connections
  connect_bd_net -net clk_in1_1 [get_bd_pins sma_in0] [get_bd_pins oddr_0/clk_in]
  connect_bd_net -net clk_in2_1 [get_bd_pins sma_in1] [get_bd_pins oddr_1/clk_in]
  connect_bd_net -net clk_in3_1 [get_bd_pins sma_in2] [get_bd_pins oddr_2/clk_in]
  connect_bd_net -net hdmi_gt_0_rx_video_clk [get_bd_pins sma_in3] [get_bd_pins oddr_3/clk_in]
  connect_bd_net -net oddr_0_clk_out [get_bd_pins sma_out0] [get_bd_pins oddr_0/clk_out]
  connect_bd_net -net oddr_1_clk_out [get_bd_pins sma_out1] [get_bd_pins oddr_1/clk_out]
  connect_bd_net -net oddr_2_clk_out [get_bd_pins sma_out2] [get_bd_pins oddr_2/clk_out]
  connect_bd_net -net oddr_3_clk_out [get_bd_pins sma_out3] [get_bd_pins oddr_3/clk_out]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: microblaze_ss
proc create_hier_cell_microblaze_ss { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_microblaze_ss() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 CLK_IN1_D
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 IIC
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M02_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M05_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M06_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M08_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 UART

  # Create pins
  create_bd_pin -dir O -type clk clk_out2
  create_bd_pin -dir O dcm_locked
  create_bd_pin -dir I -type rst ext_reset_in
  create_bd_pin -dir I -from 0 -to 0 hdmi_rx_irq
  create_bd_pin -dir I -from 0 -to 0 hdmi_tx_irq
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir O -type clk s_axi_aclk
  create_bd_pin -dir I -from 0 -to 0 vphy_irq

  # Create instance: axi_intc_0, and set properties
  set axi_intc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc axi_intc_0 ]

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite axi_uartlite_0 ]
  set_property -dict [ list \
CONFIG.C_BAUDRATE {115200} \
CONFIG.C_S_AXI_ACLK_FREQ_HZ {100000000} \
CONFIG.UARTLITE_BOARD_INTERFACE {rs232_uart} \
CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_uartlite_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.C_S_AXI_ACLK_FREQ_HZ.VALUE_SRC {DEFAULT} \
 ] $axi_uartlite_0

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_1 ]
  set_property -dict [ list \
CONFIG.CLKIN1_JITTER_PS {50.0} \
CONFIG.CLKIN2_JITTER_PS {83.33} \
CONFIG.CLKOUT1_JITTER {110.629} \
CONFIG.CLKOUT1_PHASE_ERROR {91.235} \
CONFIG.CLKOUT2_JITTER {89.301} \
CONFIG.CLKOUT2_PHASE_ERROR {91.235} \
CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {300.000} \
CONFIG.CLKOUT2_USED {true} \
CONFIG.CLK_IN1_BOARD_INTERFACE {sys_diff_clock} \
CONFIG.MMCM_CLKFBOUT_MULT_F {4.500} \
CONFIG.MMCM_CLKIN1_PERIOD {5.0} \
CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {9.000} \
CONFIG.MMCM_CLKOUT1_DIVIDE {3} \
CONFIG.MMCM_COMPENSATION {ZHOLD} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.NUM_OUT_CLKS {2} \
CONFIG.PRECISION {100.0} \
CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
CONFIG.RESET_BOARD_INTERFACE {reset} \
CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
CONFIG.USE_INCLK_SWITCHOVER {false} \
 ] $clk_wiz_1

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.MMCM_COMPENSATION.VALUE_SRC {DEFAULT} \
CONFIG.PRECISION.VALUE_SRC {DEFAULT} \
 ] $clk_wiz_1

  # Create instance: fmch_axi_iic_0, and set properties
  set fmch_axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic fmch_axi_iic_0 ]
  set_property -dict [ list \
CONFIG.IIC_BOARD_INTERFACE {Custom} \
CONFIG.USE_BOARD_FLOW {true} \
 ] $fmch_axi_iic_0

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm mdm_1 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze microblaze_0 ]
  set_property -dict [ list \
CONFIG.C_CACHE_BYTE_SIZE {32768} \
CONFIG.C_DCACHE_BYTE_SIZE {32768} \
CONFIG.C_DCACHE_LINE_LEN {8} \
CONFIG.C_DEBUG_ENABLED {1} \
CONFIG.C_D_AXI {1} \
CONFIG.C_D_LMB {1} \
CONFIG.C_ICACHE_LINE_LEN {8} \
CONFIG.C_I_AXI {0} \
CONFIG.C_I_LMB {1} \
CONFIG.C_USE_DCACHE {0} \
CONFIG.C_USE_ICACHE {0} \
 ] $microblaze_0

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect microblaze_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {9} \
 ] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory $hier_obj microblaze_0_local_memory

  # Create instance: rst_clk_wiz_1_100M, and set properties
  set rst_clk_wiz_1_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_clk_wiz_1_100M ]
  set_property -dict [ list \
CONFIG.RESET_BOARD_INTERFACE {reset} \
CONFIG.USE_BOARD_FLOW {true} \
 ] $rst_clk_wiz_1_100M

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_0 ]
  set_property -dict [ list \
CONFIG.NUM_PORTS {3} \
 ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins M08_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net axi_iic_0_IIC [get_bd_intf_pins IIC] [get_bd_intf_pins fmch_axi_iic_0/IIC]
  connect_bd_intf_net -intf_net axi_intc_0_interrupt [get_bd_intf_pins axi_intc_0/interrupt] [get_bd_intf_pins microblaze_0/INTERRUPT]
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_pins UART] [get_bd_intf_pins axi_uartlite_0/UART]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DP [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M00_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins M01_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins M02_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins fmch_axi_iic_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M05_AXI [get_bd_intf_pins M05_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M06_AXI [get_bd_intf_pins M06_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M07_AXI [get_bd_intf_pins axi_intc_0/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]
  connect_bd_intf_net -intf_net sys_diff_clock_1 [get_bd_intf_pins CLK_IN1_D] [get_bd_intf_pins clk_wiz_1/CLK_IN1_D]

  # Create port connections
  connect_bd_net -net In0_1 [get_bd_pins vphy_irq] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net In1_1 [get_bd_pins hdmi_rx_irq] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net In2_1 [get_bd_pins hdmi_tx_irq] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net clk_wiz_1_clk_out2 [get_bd_pins clk_out2] [get_bd_pins clk_wiz_1/clk_out2] [get_bd_pins microblaze_0_axi_periph/M05_ACLK] [get_bd_pins microblaze_0_axi_periph/M08_ACLK]
  connect_bd_net -net clk_wiz_1_locked [get_bd_pins dcm_locked] [get_bd_pins clk_wiz_1/locked] [get_bd_pins microblaze_0_axi_periph/M05_ARESETN] [get_bd_pins microblaze_0_axi_periph/M08_ARESETN] [get_bd_pins rst_clk_wiz_1_100M/dcm_locked]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst_clk_wiz_1_100M/mb_debug_sys_rst]
  connect_bd_net -net reset_1 [get_bd_pins ext_reset_in] [get_bd_pins clk_wiz_1/reset] [get_bd_pins rst_clk_wiz_1_100M/ext_reset_in]
  connect_bd_net -net rst_clk_wiz_1_100M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/LMB_Rst] [get_bd_pins rst_clk_wiz_1_100M/bus_struct_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_interconnect_aresetn [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins rst_clk_wiz_1_100M/interconnect_aresetn]
  connect_bd_net -net rst_clk_wiz_1_100M_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins rst_clk_wiz_1_100M/mb_reset]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_pins peripheral_aresetn] [get_bd_pins axi_intc_0/s_axi_aresetn] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins fmch_axi_iic_0/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins microblaze_0_axi_periph/M04_ARESETN] [get_bd_pins microblaze_0_axi_periph/M06_ARESETN] [get_bd_pins microblaze_0_axi_periph/M07_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins rst_clk_wiz_1_100M/peripheral_aresetn]
  connect_bd_net -net sys_clk [get_bd_pins s_axi_aclk] [get_bd_pins axi_intc_0/s_axi_aclk] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins fmch_axi_iic_0/s_axi_aclk] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins microblaze_0_axi_periph/M04_ACLK] [get_bd_pins microblaze_0_axi_periph/M06_ACLK] [get_bd_pins microblaze_0_axi_periph/M07_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins rst_clk_wiz_1_100M/slowest_sync_clk]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins axi_intc_0/intr] [get_bd_pins xlconcat_0/dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: audio_ss
proc create_hier_cell_audio_ss { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" create_hier_cell_audio_ss() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 axis_audio_in
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 axis_audio_out

  # Create pins
  create_bd_pin -dir I -type clk ACLK
  create_bd_pin -dir I -from 0 -to 0 -type rst ARESETN
  create_bd_pin -dir I -from 19 -to 0 aud_acr_cts_in
  create_bd_pin -dir O -from 19 -to 0 aud_acr_cts_out
  create_bd_pin -dir I -from 19 -to 0 aud_acr_n_in
  create_bd_pin -dir O -from 19 -to 0 aud_acr_n_out
  create_bd_pin -dir I aud_acr_valid_in
  create_bd_pin -dir O aud_acr_valid_out
  create_bd_pin -dir O aud_rstn
  create_bd_pin -dir O -type clk audio_clk
  create_bd_pin -dir I -type clk hdmi_clk

  # Create instance: aud_pat_gen_0, and set properties
  set aud_pat_gen_0 [ create_bd_cell -type ip -vlnv Xilinx:user:aud_pat_gen aud_pat_gen_0 ]

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_0 ]
  set_property -dict [ list \
CONFIG.NUM_MI {3} \
 ] $axi_interconnect_0

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_0 ]
  set_property -dict [ list \
CONFIG.CLKOUT1_DRIVES {BUFG} \
CONFIG.CLKOUT1_JITTER {130.958} \
CONFIG.CLKOUT1_PHASE_ERROR {98.575} \
CONFIG.CLKOUT2_DRIVES {BUFG} \
CONFIG.CLKOUT2_USED {false} \
CONFIG.CLKOUT3_DRIVES {BUFG} \
CONFIG.CLKOUT4_DRIVES {BUFG} \
CONFIG.CLKOUT5_DRIVES {BUFG} \
CONFIG.CLKOUT6_DRIVES {BUFG} \
CONFIG.CLKOUT7_DRIVES {BUFG} \
CONFIG.CLK_IN1_BOARD_INTERFACE {Custom} \
CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
CONFIG.MMCM_CLKIN1_PERIOD {10.0} \
CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.000} \
CONFIG.MMCM_CLKOUT1_DIVIDE {1} \
CONFIG.MMCM_COMPENSATION {ZHOLD} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.NUM_OUT_CLKS {1} \
CONFIG.PRECISION {100.0} \
CONFIG.PRIMITIVE {MMCM} \
CONFIG.PRIM_SOURCE {No_buffer} \
CONFIG.RESET_BOARD_INTERFACE {Custom} \
CONFIG.USE_DYN_RECONFIG {true} \
 ] $clk_wiz_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.MMCM_CLKIN1_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.MMCM_CLKIN2_PERIOD.VALUE_SRC {DEFAULT} \
CONFIG.PRECISION.VALUE_SRC {DEFAULT} \
 ] $clk_wiz_0

  # Create instance: hdmi_acr_ctrl_0, and set properties
  set hdmi_acr_ctrl_0 [ create_bd_cell -type ip -vlnv Xilinx:user:hdmi_acr_ctrl hdmi_acr_ctrl_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins axis_audio_in] [get_bd_intf_pins aud_pat_gen_0/axis_audio_in]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins axis_audio_out] [get_bd_intf_pins aud_pat_gen_0/axis_audio_out]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins aud_pat_gen_0/axi_lite] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins hdmi_acr_ctrl_0/axi]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins clk_wiz_0/s_axi_lite]

  # Create port connections
  connect_bd_net -net ACLK_1 [get_bd_pins ACLK] [get_bd_pins aud_pat_gen_0/axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins clk_wiz_0/s_axi_aclk] [get_bd_pins hdmi_acr_ctrl_0/axi_aclk]
  connect_bd_net -net ARESETN_1 [get_bd_pins ARESETN] [get_bd_pins aud_pat_gen_0/axi_aresetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins clk_wiz_0/s_axi_aresetn] [get_bd_pins hdmi_acr_ctrl_0/axi_aresetn]
  connect_bd_net -net aud_acr_cts_in_1 [get_bd_pins aud_acr_cts_in] [get_bd_pins hdmi_acr_ctrl_0/aud_acr_cts_in]
  connect_bd_net -net aud_acr_n_in_1 [get_bd_pins aud_acr_n_in] [get_bd_pins hdmi_acr_ctrl_0/aud_acr_n_in]
  connect_bd_net -net aud_acr_valid_in_1 [get_bd_pins aud_acr_valid_in] [get_bd_pins hdmi_acr_ctrl_0/aud_acr_valid_in]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_pins audio_clk] [get_bd_pins aud_pat_gen_0/aud_clk] [get_bd_pins aud_pat_gen_0/axis_clk] [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins hdmi_acr_ctrl_0/aud_clk]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins hdmi_acr_ctrl_0/pll_lock_in]
  connect_bd_net -net hdmi_acr_ctrl_0_aud_acr_cts_out [get_bd_pins aud_acr_cts_out] [get_bd_pins hdmi_acr_ctrl_0/aud_acr_cts_out]
  connect_bd_net -net hdmi_acr_ctrl_0_aud_acr_n_out [get_bd_pins aud_acr_n_out] [get_bd_pins hdmi_acr_ctrl_0/aud_acr_n_out]
  connect_bd_net -net hdmi_acr_ctrl_0_aud_acr_valid_out [get_bd_pins aud_acr_valid_out] [get_bd_pins hdmi_acr_ctrl_0/aud_acr_valid_out]
  connect_bd_net -net hdmi_acr_ctrl_0_aud_rstn [get_bd_pins aud_rstn] [get_bd_pins aud_pat_gen_0/axis_resetn] [get_bd_pins hdmi_acr_ctrl_0/aud_resetn_out]
  connect_bd_net -net hdmi_clk_1 [get_bd_pins hdmi_clk] [get_bd_pins hdmi_acr_ctrl_0/hdmi_clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable PPC_SEL
  variable BPC_SEL
  variable ENABLE_REMAP_NTSC
  variable ENABLE_REMAP_420    

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DRU_CLK_IN [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 DRU_CLK_IN ]
  set RX_DDC_OUT [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 RX_DDC_OUT ]
  set TX_DDC_OUT [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 TX_DDC_OUT ]
  set fmch_iic [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 fmch_iic ]
  set rs232_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 rs232_uart ]
  set sys_diff_clock [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_diff_clock ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {300000000} \
 ] $sys_diff_clock

  # Create ports
  set HDMI_RX_CLK_N_IN [ create_bd_port -dir I HDMI_RX_CLK_N_IN ]
  set HDMI_RX_CLK_P_IN [ create_bd_port -dir I HDMI_RX_CLK_P_IN ]
  set HDMI_RX_DAT_N_IN [ create_bd_port -dir I -from 2 -to 0 HDMI_RX_DAT_N_IN ]
  set HDMI_RX_DAT_P_IN [ create_bd_port -dir I -from 2 -to 0 HDMI_RX_DAT_P_IN ]
  set HDMI_TX_CLK_N_OUT [ create_bd_port -dir O HDMI_TX_CLK_N_OUT ]
  set HDMI_TX_CLK_P_OUT [ create_bd_port -dir O HDMI_TX_CLK_P_OUT ]
  set HDMI_TX_DAT_N_OUT [ create_bd_port -dir O -from 2 -to 0 HDMI_TX_DAT_N_OUT ]
  set HDMI_TX_DAT_P_OUT [ create_bd_port -dir O -from 2 -to 0 HDMI_TX_DAT_P_OUT ]
  set LED0 [ create_bd_port -dir O LED0 ]
  set LED1 [ create_bd_port -dir O -from 0 -to 0 LED1 ]
  set LED2 [ create_bd_port -dir O -from 0 -to 0 LED2 ]
  set LED3 [ create_bd_port -dir O -from 0 -to 0 LED3 ]
  set LED4 [ create_bd_port -dir O -from 0 -to 0 LED4 ]
  set LED5 [ create_bd_port -dir O -from 0 -to 0 LED5 ]
  set LED6 [ create_bd_port -dir O LED6 ]
  set LED7 [ create_bd_port -dir O LED7 ]
  set RX_DET_IN [ create_bd_port -dir I RX_DET_IN ]
  set RX_HPD_OUT [ create_bd_port -dir O RX_HPD_OUT ]
  set RX_I2C_EN_N_OUT [ create_bd_port -dir O -from 0 -to 0 RX_I2C_EN_N_OUT ]
  set RX_REFCLK_N_OUT [ create_bd_port -dir O RX_REFCLK_N_OUT ]
  set RX_REFCLK_P_OUT [ create_bd_port -dir O RX_REFCLK_P_OUT ]
  set SI5324_LOL_IN [ create_bd_port -dir I SI5324_LOL_IN ]
  set SI5324_RST_OUT [ create_bd_port -dir O -from 0 -to 0 SI5324_RST_OUT ]
  set SMA0 [ create_bd_port -dir O SMA0 ]
  set SMA1 [ create_bd_port -dir O SMA1 ]
  set SMA2 [ create_bd_port -dir O SMA2 ]
  set SMA3 [ create_bd_port -dir O SMA3 ]
  set TX_CLKSEL_OUT [ create_bd_port -dir O -from 0 -to 0 TX_CLKSEL_OUT ]
  set TX_EN_OUT [ create_bd_port -dir O -from 0 -to 0 TX_EN_OUT ]
  set TX_HPD_IN [ create_bd_port -dir I TX_HPD_IN ]
  set TX_REFCLK_N_IN [ create_bd_port -dir I TX_REFCLK_N_IN ]
  set TX_REFCLK_P_IN [ create_bd_port -dir I TX_REFCLK_P_IN ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset

  # Create instance: audio_ss
  create_hier_cell_audio_ss [current_bd_instance .] audio_ss

  # Create instance: gnd_const, and set properties
  set gnd_const [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant gnd_const ]
  set_property -dict [ list \
CONFIG.CONST_VAL {0} \
 ] $gnd_const

  # Create instance: gtnorthrefclk_buf, and set properties
  set gtnorthrefclk_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf gtnorthrefclk_buf ]
  set_property -dict [ list \
CONFIG.C_BUF_TYPE {IBUFDSGTE} \
 ] $gtnorthrefclk_buf

  # Create instance: microblaze_ss
  create_hier_cell_microblaze_ss [current_bd_instance .] microblaze_ss

  # Create instance: rx_hdmi_hb_0, and set properties
  set rx_hdmi_hb_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:hdmi_hb rx_hdmi_hb_0 ]

  # Create instance: rx_video_axis_reg_slice_0, and set properties
  set rx_video_axis_reg_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice rx_video_axis_reg_slice_0 ]

  # Create instance: sma
  create_hier_cell_sma [current_bd_instance .] sma

  # Create instance: tpg_ss
  create_hier_cell_tpg_ss [current_bd_instance .] tpg_ss

  # Create instance: tx_hdmi_hb_0, and set properties
  set tx_hdmi_hb_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:hdmi_hb tx_hdmi_hb_0 ]

  # Create instance: tx_refclk_lol_n, and set properties
  set tx_refclk_lol_n [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic tx_refclk_lol_n ]
  set_property -dict [ list \
CONFIG.C_OPERATION {not} \
CONFIG.C_SIZE {1} \
 ] $tx_refclk_lol_n

  # Create instance: tx_video_axis_reg_slice_0, and set properties
  set tx_video_axis_reg_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice tx_video_axis_reg_slice_0 ]

  # Create instance: v_hdmi_rx_ss_0, and set properties
  set v_hdmi_rx_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_hdmi_rx_ss v_hdmi_rx_ss_0 ]
  set_property -dict [ list \
CONFIG.C_INCLUDE_HDCP_1_4 {false} \
CONFIG.C_INCLUDE_HDCP_2_2 {false} \
CONFIG.C_INCLUDE_LOW_RESO_VID $ENABLE_REMAP_NTSC \
CONFIG.C_INCLUDE_YUV420_SUP $ENABLE_REMAP_420 \
CONFIG.C_INPUT_PIXELS_PER_CLOCK $PPC_SEL \
CONFIG.C_MAX_BITS_PER_COMPONENT $BPC_SEL \
 ] $v_hdmi_rx_ss_0

  # Create instance: v_hdmi_tx_ss_0, and set properties
  set v_hdmi_tx_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_hdmi_tx_ss v_hdmi_tx_ss_0 ]
  set_property -dict [ list \
CONFIG.C_INCLUDE_HDCP_1_4 {false} \
CONFIG.C_INCLUDE_HDCP_2_2 {false} \
CONFIG.C_INCLUDE_LOW_RESO_VID $ENABLE_REMAP_NTSC \
CONFIG.C_INCLUDE_YUV420_SUP $ENABLE_REMAP_420 \
CONFIG.C_INPUT_PIXELS_PER_CLOCK $PPC_SEL \
CONFIG.C_MAX_BITS_PER_COMPONENT $BPC_SEL \
CONFIG.C_VID_INTERFACE {0} \
 ] $v_hdmi_tx_ss_0

  # Create instance: vcc_const, and set properties
  set vcc_const [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant vcc_const ]

  # Create instance: vid_phy_controller_0, and set properties
  set vid_phy_controller_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vid_phy_controller vid_phy_controller_0 ]
  set_property -dict [ list \
CONFIG.C_INPUT_PIXELS_PER_CLOCK $PPC_SEL \
CONFIG.C_NIDRU {true} \
CONFIG.C_NIDRU_REFCLK_SEL {2} \
CONFIG.C_RX_PLL_SELECTION {3} \
CONFIG.C_Rx_No_Of_Channels {3} \
CONFIG.C_Rx_Protocol {HDMI} \
CONFIG.C_TX_PLL_SELECTION {0} \
CONFIG.C_Tx_No_Of_Channels {3} \
CONFIG.C_Tx_Protocol {HDMI} \
CONFIG.DRPCLK_FREQ {100.0} \
CONFIG.Rx_GT_Line_Rate {5.94} \
CONFIG.Rx_GT_Ref_Clock_Freq {148.500} \
CONFIG.Rx_Max_GT_Line_Rate {5.94} \
CONFIG.Tx_Buffer_Bypass {true} \
CONFIG.Tx_GT_Line_Rate {5.94} \
CONFIG.Tx_GT_Ref_Clock_Freq {148.500} \
CONFIG.Tx_Max_GT_Line_Rate {5.94} \
 ] $vid_phy_controller_0

  # Create interface connections
  connect_bd_intf_net -intf_net CLK_IN_D_1 [get_bd_intf_ports DRU_CLK_IN] [get_bd_intf_pins gtnorthrefclk_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net audio_ss_axis_audio_out [get_bd_intf_pins audio_ss/axis_audio_out] [get_bd_intf_pins v_hdmi_tx_ss_0/AUDIO_IN]
  connect_bd_intf_net -intf_net axi_iic_0_IIC [get_bd_intf_ports fmch_iic] [get_bd_intf_pins microblaze_ss/IIC]
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports rs232_uart] [get_bd_intf_pins microblaze_ss/UART]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M00_AXI [get_bd_intf_pins microblaze_ss/M00_AXI] [get_bd_intf_pins vid_phy_controller_0/vid_phy_axi4lite]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_pins microblaze_ss/M01_AXI] [get_bd_intf_pins v_hdmi_rx_ss_0/S_AXI_CPU_IN]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins microblaze_ss/M02_AXI] [get_bd_intf_pins v_hdmi_tx_ss_0/S_AXI_CPU_IN]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M06_AXI [get_bd_intf_pins audio_ss/S00_AXI] [get_bd_intf_pins microblaze_ss/M06_AXI]
  connect_bd_intf_net -intf_net microblaze_ss_M05_AXI [get_bd_intf_pins microblaze_ss/M05_AXI] [get_bd_intf_pins tpg_ss/S_AXI_TPG]
  connect_bd_intf_net -intf_net microblaze_ss_M08_AXI [get_bd_intf_pins microblaze_ss/M08_AXI] [get_bd_intf_pins tpg_ss/S_AXI_GPIO]
  connect_bd_intf_net -intf_net rx_video_axis_reg_slice_0_M_AXIS [get_bd_intf_pins rx_video_axis_reg_slice_0/M_AXIS] [get_bd_intf_pins tpg_ss/s_axis_video]
  connect_bd_intf_net -intf_net sys_diff_clock_1 [get_bd_intf_ports sys_diff_clock] [get_bd_intf_pins microblaze_ss/CLK_IN1_D]
  connect_bd_intf_net -intf_net tpg_ss_m_axis_video [get_bd_intf_pins tpg_ss/m_axis_video] [get_bd_intf_pins tx_video_axis_reg_slice_0/S_AXIS]
  connect_bd_intf_net -intf_net tx_video_axis_reg_slice_0_M_AXIS [get_bd_intf_pins tx_video_axis_reg_slice_0/M_AXIS] [get_bd_intf_pins v_hdmi_tx_ss_0/VIDEO_IN]
  connect_bd_intf_net -intf_net v_hdmi_rx_ss_0_AUDIO_OUT [get_bd_intf_pins audio_ss/axis_audio_in] [get_bd_intf_pins v_hdmi_rx_ss_0/AUDIO_OUT]
  connect_bd_intf_net -intf_net v_hdmi_rx_ss_0_DDC_OUT [get_bd_intf_ports RX_DDC_OUT] [get_bd_intf_pins v_hdmi_rx_ss_0/DDC_OUT]
  connect_bd_intf_net -intf_net v_hdmi_rx_ss_0_VIDEO_OUT [get_bd_intf_pins rx_video_axis_reg_slice_0/S_AXIS] [get_bd_intf_pins v_hdmi_rx_ss_0/VIDEO_OUT]
  connect_bd_intf_net -intf_net v_hdmi_tx_ss_0_DDC_OUT [get_bd_intf_ports TX_DDC_OUT] [get_bd_intf_pins v_hdmi_tx_ss_0/DDC_OUT]
  connect_bd_intf_net -intf_net v_hdmi_tx_ss_0_LINK_DATA0_OUT [get_bd_intf_pins v_hdmi_tx_ss_0/LINK_DATA0_OUT] [get_bd_intf_pins vid_phy_controller_0/vid_phy_tx_axi4s_ch0]
  connect_bd_intf_net -intf_net v_hdmi_tx_ss_0_LINK_DATA1_OUT [get_bd_intf_pins v_hdmi_tx_ss_0/LINK_DATA1_OUT] [get_bd_intf_pins vid_phy_controller_0/vid_phy_tx_axi4s_ch1]
  connect_bd_intf_net -intf_net v_hdmi_tx_ss_0_LINK_DATA2_OUT [get_bd_intf_pins v_hdmi_tx_ss_0/LINK_DATA2_OUT] [get_bd_intf_pins vid_phy_controller_0/vid_phy_tx_axi4s_ch2]
  connect_bd_intf_net -intf_net vid_phy_controller_0_vid_phy_rx_axi4s_ch0 [get_bd_intf_pins v_hdmi_rx_ss_0/LINK_DATA0_IN] [get_bd_intf_pins vid_phy_controller_0/vid_phy_rx_axi4s_ch0]
  connect_bd_intf_net -intf_net vid_phy_controller_0_vid_phy_rx_axi4s_ch1 [get_bd_intf_pins v_hdmi_rx_ss_0/LINK_DATA1_IN] [get_bd_intf_pins vid_phy_controller_0/vid_phy_rx_axi4s_ch1]
  connect_bd_intf_net -intf_net vid_phy_controller_0_vid_phy_rx_axi4s_ch2 [get_bd_intf_pins v_hdmi_rx_ss_0/LINK_DATA2_IN] [get_bd_intf_pins vid_phy_controller_0/vid_phy_rx_axi4s_ch2]
  connect_bd_intf_net -intf_net vid_phy_controller_0_vid_phy_status_sb_rx [get_bd_intf_pins v_hdmi_rx_ss_0/SB_STATUS_IN] [get_bd_intf_pins vid_phy_controller_0/vid_phy_status_sb_rx]
connect_bd_intf_net -intf_net [get_bd_intf_nets vid_phy_controller_0_vid_phy_status_sb_rx] [get_bd_intf_pins rx_hdmi_hb_0/status_sb] [get_bd_intf_pins v_hdmi_rx_ss_0/SB_STATUS_IN]
  connect_bd_intf_net -intf_net vid_phy_controller_0_vid_phy_status_sb_tx [get_bd_intf_pins v_hdmi_tx_ss_0/SB_STATUS_IN] [get_bd_intf_pins vid_phy_controller_0/vid_phy_status_sb_tx]
connect_bd_intf_net -intf_net [get_bd_intf_nets vid_phy_controller_0_vid_phy_status_sb_tx] [get_bd_intf_pins tx_hdmi_hb_0/status_sb] [get_bd_intf_pins v_hdmi_tx_ss_0/SB_STATUS_IN]

  # Create port connections
  connect_bd_net -net RX_DET_IN_1 [get_bd_ports RX_DET_IN] [get_bd_pins v_hdmi_rx_ss_0/cable_detect]
  connect_bd_net -net RX_REFCLK_N_IN_1 [get_bd_ports HDMI_RX_CLK_N_IN] [get_bd_pins vid_phy_controller_0/mgtrefclk0_pad_n_in]
  connect_bd_net -net RX_REFCLK_P_IN_1 [get_bd_ports HDMI_RX_CLK_P_IN] [get_bd_pins vid_phy_controller_0/mgtrefclk0_pad_p_in]
  connect_bd_net -net SI5324_LOL_IN_1 [get_bd_ports SI5324_LOL_IN] [get_bd_pins tx_refclk_lol_n/Op1]
  connect_bd_net -net TMDS_RX_N_IN_1 [get_bd_ports HDMI_RX_DAT_N_IN] [get_bd_pins vid_phy_controller_0/phy_rxn_in]
  connect_bd_net -net TMDS_RX_P_IN_1 [get_bd_ports HDMI_RX_DAT_P_IN] [get_bd_pins vid_phy_controller_0/phy_rxp_in]
  connect_bd_net -net TX_HPD_IN_1 [get_bd_ports TX_HPD_IN] [get_bd_pins v_hdmi_tx_ss_0/hpd]
  connect_bd_net -net TX_REFCLK_N_IN_1 [get_bd_ports TX_REFCLK_N_IN] [get_bd_pins vid_phy_controller_0/mgtrefclk1_pad_n_in]
  connect_bd_net -net TX_REFCLK_P_IN_1 [get_bd_ports TX_REFCLK_P_IN] [get_bd_pins vid_phy_controller_0/mgtrefclk1_pad_p_in]
  connect_bd_net -net acr_cts_1 [get_bd_pins audio_ss/aud_acr_cts_out] [get_bd_pins v_hdmi_tx_ss_0/acr_cts]
  connect_bd_net -net acr_n_1 [get_bd_pins audio_ss/aud_acr_n_out] [get_bd_pins v_hdmi_tx_ss_0/acr_n]
  connect_bd_net -net acr_valid_1 [get_bd_pins audio_ss/aud_acr_valid_out] [get_bd_pins v_hdmi_tx_ss_0/acr_valid]
  connect_bd_net -net clk_wiz_1_clk_out2 [get_bd_pins microblaze_ss/clk_out2] [get_bd_pins rx_video_axis_reg_slice_0/aclk] [get_bd_pins tpg_ss/ap_clk] [get_bd_pins tx_video_axis_reg_slice_0/aclk] [get_bd_pins v_hdmi_rx_ss_0/s_axis_video_aclk] [get_bd_pins v_hdmi_tx_ss_0/s_axis_video_aclk]
  connect_bd_net -net clk_wiz_1_locked [get_bd_pins microblaze_ss/dcm_locked] [get_bd_pins rx_video_axis_reg_slice_0/aresetn] [get_bd_pins tpg_ss/m_axi_aresetn] [get_bd_pins tx_video_axis_reg_slice_0/aresetn] [get_bd_pins v_hdmi_rx_ss_0/s_axis_video_aresetn] [get_bd_pins v_hdmi_tx_ss_0/s_axis_video_aresetn]
  connect_bd_net -net fid_1 [get_bd_pins v_hdmi_rx_ss_0/fid] [get_bd_pins v_hdmi_tx_ss_0/fid]
  connect_bd_net -net gnd_const_dout [get_bd_ports LED1] [get_bd_ports LED2] [get_bd_ports LED3] [get_bd_ports LED4] [get_bd_ports LED5] [get_bd_ports RX_I2C_EN_N_OUT] [get_bd_pins gnd_const/dout]
  connect_bd_net -net gtnorthrefclk_buf_IBUF_OUT [get_bd_pins gtnorthrefclk_buf/IBUF_OUT] [get_bd_pins vid_phy_controller_0/gtnorthrefclk0_in]
  connect_bd_net -net hdmi_gt_0_rx_video_clk [get_bd_pins sma/sma_in1] [get_bd_pins v_hdmi_rx_ss_0/video_clk] [get_bd_pins vid_phy_controller_0/rx_video_clk]
  connect_bd_net -net hdmi_gt_0_tx_link_clk [get_bd_pins sma/sma_in2] [get_bd_pins tx_hdmi_hb_0/link_clk] [get_bd_pins v_hdmi_tx_ss_0/link_clk] [get_bd_pins vid_phy_controller_0/txoutclk] [get_bd_pins vid_phy_controller_0/vid_phy_tx_axi4s_aclk]
  connect_bd_net -net hdmi_gt_0_tx_video_clk [get_bd_pins sma/sma_in3] [get_bd_pins v_hdmi_tx_ss_0/video_clk] [get_bd_pins vid_phy_controller_0/tx_video_clk]
  connect_bd_net -net hdmi_rx_0_HPD_OUT [get_bd_ports RX_HPD_OUT] [get_bd_pins v_hdmi_rx_ss_0/hpd]
  connect_bd_net -net link_clk_1 [get_bd_pins rx_hdmi_hb_0/link_clk] [get_bd_pins sma/sma_in0] [get_bd_pins v_hdmi_rx_ss_0/link_clk] [get_bd_pins vid_phy_controller_0/rxoutclk] [get_bd_pins vid_phy_controller_0/vid_phy_rx_axi4s_aclk]
  connect_bd_net -net m_axis_audio_aresetn_1 [get_bd_pins audio_ss/aud_rstn] [get_bd_pins v_hdmi_rx_ss_0/s_axis_audio_aresetn] [get_bd_pins v_hdmi_tx_ss_0/s_axis_audio_aresetn]
  connect_bd_net -net oddr_3_clk_out [get_bd_ports SMA3] [get_bd_pins sma/sma_out3]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins microblaze_ss/ext_reset_in]
  connect_bd_net -net rst_clk_wiz_1_100M_peripheral_aresetn [get_bd_ports SI5324_RST_OUT] [get_bd_pins audio_ss/ARESETN] [get_bd_pins microblaze_ss/peripheral_aresetn] [get_bd_pins v_hdmi_rx_ss_0/s_axi_cpu_aresetn] [get_bd_pins v_hdmi_tx_ss_0/s_axi_cpu_aresetn] [get_bd_pins vid_phy_controller_0/vid_phy_axi4lite_aresetn] [get_bd_pins vid_phy_controller_0/vid_phy_sb_aresetn]
  connect_bd_net -net rx_hdmi_hb_0_hdmi_hb [get_bd_ports LED7] [get_bd_pins rx_hdmi_hb_0/hdmi_hb]
  connect_bd_net -net s_axis_audio_aclk_1 [get_bd_pins audio_ss/audio_clk] [get_bd_pins v_hdmi_rx_ss_0/s_axis_audio_aclk] [get_bd_pins v_hdmi_tx_ss_0/s_axis_audio_aclk]
  connect_bd_net -net sma_clk_out1 [get_bd_ports SMA0] [get_bd_pins sma/sma_out0]
  connect_bd_net -net sma_clk_out2 [get_bd_ports SMA1] [get_bd_pins sma/sma_out1]
  connect_bd_net -net sma_clk_out3 [get_bd_ports SMA2] [get_bd_pins sma/sma_out2]
  connect_bd_net -net sys_clk [get_bd_pins audio_ss/ACLK] [get_bd_pins microblaze_ss/s_axi_aclk] [get_bd_pins rx_hdmi_hb_0/status_sb_aclk] [get_bd_pins tx_hdmi_hb_0/status_sb_aclk] [get_bd_pins v_hdmi_rx_ss_0/s_axi_cpu_aclk] [get_bd_pins v_hdmi_tx_ss_0/s_axi_cpu_aclk] [get_bd_pins vid_phy_controller_0/vid_phy_axi4lite_aclk] [get_bd_pins vid_phy_controller_0/vid_phy_sb_aclk]
  connect_bd_net -net tx_hdmi_hb_0_hdmi_hb [get_bd_ports LED6] [get_bd_pins tx_hdmi_hb_0/hdmi_hb]
  connect_bd_net -net tx_refclk_lol_n_Res [get_bd_pins tx_refclk_lol_n/Res] [get_bd_pins vid_phy_controller_0/tx_refclk_rdy]
  connect_bd_net -net v_hdmi_rx_ss_0_acr_cts [get_bd_pins audio_ss/aud_acr_cts_in] [get_bd_pins v_hdmi_rx_ss_0/acr_cts]
  connect_bd_net -net v_hdmi_rx_ss_0_acr_n [get_bd_pins audio_ss/aud_acr_n_in] [get_bd_pins v_hdmi_rx_ss_0/acr_n]
  connect_bd_net -net v_hdmi_rx_ss_0_acr_valid [get_bd_pins audio_ss/aud_acr_valid_in] [get_bd_pins v_hdmi_rx_ss_0/acr_valid]
  connect_bd_net -net v_hdmi_rx_ss_0_irq [get_bd_pins microblaze_ss/hdmi_rx_irq] [get_bd_pins v_hdmi_rx_ss_0/irq]
  connect_bd_net -net v_hdmi_tx_ss_0_irq [get_bd_pins microblaze_ss/hdmi_tx_irq] [get_bd_pins v_hdmi_tx_ss_0/irq]
  connect_bd_net -net v_hdmi_tx_ss_0_locked [get_bd_ports LED0] [get_bd_pins v_hdmi_tx_ss_0/locked]
  connect_bd_net -net vcc_const_dout [get_bd_ports TX_CLKSEL_OUT] [get_bd_ports TX_EN_OUT] [get_bd_pins vcc_const/dout]
  connect_bd_net -net vid_phy_controller_0_irq [get_bd_pins microblaze_ss/vphy_irq] [get_bd_pins vid_phy_controller_0/irq]
  connect_bd_net -net vid_phy_controller_0_phy_txn_out [get_bd_ports HDMI_TX_DAT_N_OUT] [get_bd_pins vid_phy_controller_0/phy_txn_out]
  connect_bd_net -net vid_phy_controller_0_phy_txp_out [get_bd_ports HDMI_TX_DAT_P_OUT] [get_bd_pins vid_phy_controller_0/phy_txp_out]
  connect_bd_net -net vid_phy_controller_0_rx_tmds_clk_n [get_bd_ports RX_REFCLK_N_OUT] [get_bd_pins vid_phy_controller_0/rx_tmds_clk_n]
  connect_bd_net -net vid_phy_controller_0_rx_tmds_clk_p [get_bd_ports RX_REFCLK_P_OUT] [get_bd_pins vid_phy_controller_0/rx_tmds_clk_p]
  connect_bd_net -net vid_phy_controller_0_tx_tmds_clk [get_bd_pins audio_ss/hdmi_clk] [get_bd_pins vid_phy_controller_0/tx_tmds_clk]
  connect_bd_net -net vid_phy_controller_0_tx_tmds_clk_n [get_bd_ports HDMI_TX_CLK_N_OUT] [get_bd_pins vid_phy_controller_0/tx_tmds_clk_n]
  connect_bd_net -net vid_phy_controller_0_tx_tmds_clk_p [get_bd_ports HDMI_TX_CLK_P_OUT] [get_bd_pins vid_phy_controller_0/tx_tmds_clk_p]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x44A80000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs audio_ss/aud_pat_gen_0/AudioPatternGenerator/aud_pat_gen] SEG_aud_pat_gen_0_aud_pat_gen
  create_bd_addr_seg -range 0x00010000 -offset 0x40000000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs tpg_ss/axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs microblaze_ss/axi_intc_0/s_axi/Reg] SEG_axi_intc_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40600000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs microblaze_ss/axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A90000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs audio_ss/clk_wiz_0/s_axi_lite/Reg] SEG_clk_wiz_0_Reg
  create_bd_addr_seg -range 0x00100000 -offset 0x00000000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs microblaze_ss/microblaze_0_local_memory/dlmb_bram_if_cntlr_0/SLMB/Mem] SEG_dlmb_bram_if_cntlr_0_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x40800000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs microblaze_ss/fmch_axi_iic_0/S_AXI/Reg] SEG_fmch_axi_iic_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44AA0000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs audio_ss/hdmi_acr_ctrl_0/axi/Reg] SEG_hdmi_acr_ctrl_0_Reg
  create_bd_addr_seg -range 0x00100000 -offset 0x00000000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Instruction] [get_bd_addr_segs microblaze_ss/microblaze_0_local_memory/ilmb_bram_if_cntlr_0/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x44B00000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs v_hdmi_rx_ss_0/S_AXI_CPU_IN/Reg] SEG_v_hdmi_rx_ss_0_Reg
  create_bd_addr_seg -range 0x00020000 -offset 0x44C00000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs v_hdmi_tx_ss_0/S_AXI_CPU_IN/Reg] SEG_v_hdmi_tx_ss_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44AB0000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs tpg_ss/v_tpg_0/s_axi_CTRL/Reg] SEG_v_tpg_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44AC0000 [get_bd_addr_spaces microblaze_ss/microblaze_0/Data] [get_bd_addr_segs vid_phy_controller_0/vid_phy_axi4lite/Reg] SEG_vid_phy_controller_0_Reg


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

