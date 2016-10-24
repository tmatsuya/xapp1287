###
# HDCP key setup script 
###

#Create KC705 Vivado Project
create_project hdcp_key -part xc7k325tffg900-2 -force
set_property board_part xilinx.com:kc705:part0:1.2 [current_project]

#Import Design Constraint File
import_files -fileset constrs_1 -force -norecurse ../design/hdcp_key.xdc

#Construct IPI Design
source ../design/hdcp_key.tcl
regenerate_bd_layout
make_wrapper -files [get_files ./hdcp_key.srcs/sources_1/bd/hdcp_key/hdcp_key.bd] -top
add_files -norecurse ./hdcp_key.srcs/sources_1/bd/hdcp_key/hdl/hdcp_key_wrapper.v

#Compile Project
launch_runs impl_1 -to_step write_bitstream