#=============================
# User Options
#=============================
variable ENABLE_HDCP14 
variable ENABLE_HDCP22 
set ENABLE_HDCP14 1
set ENABLE_HDCP22 1

#=============================
# XGUI Settings
#=============================
variable PPC_SEL
variable BPC_SEL
variable ENABLE_REMAP_NTSC
variable ENABLE_REMAP_420
set PPC_SEL 2
set BPC_SEL 8
set ENABLE_REMAP_NTSC true
set ENABLE_REMAP_420 true

#=============================

###############################################################################
# START FLOW
###############################################################################
set current_path [pwd]

cd project 

#Create KC705 Vivado Project
create_project -force hdmi_example -part xc7k325tffg900-2
set_property board_part xilinx.com:kc705:part0:1.2 [current_project]

#Import Design Constraint File
import_files -fileset constrs_1 -force -norecurse ../design/hdmi_example_kc705.xdc

#Setup HW repo path
set_property ip_repo_paths  ../repos [current_fileset]
update_ip_catalog

#Construct IPI Design
source ../design/hdmi_example_kc705.tcl

if [expr $ENABLE_HDCP14 == 1] {
	source ../design/add_hdcp14.tcl
}

if [expr $ENABLE_HDCP22 == 1] {
	source ../design/add_hdcp22.tcl
}

regenerate_bd_layout
save_bd_design
make_wrapper -files [get_files ./hdmi_example.srcs/sources_1/bd/hdmi_example_kc705/hdmi_example_kc705.bd] -top
add_files -norecurse ./hdmi_example.srcs/sources_1/bd/hdmi_example_kc705/hdl/hdmi_example_kc705_wrapper.v

# Set write bitstream prehook
if [expr $ENABLE_HDCP22 == 1] {
	set_property STEPS.WRITE_BITSTREAM.TCL.PRE $current_path/design/write_bitstream_prehook.tcl [get_runs impl_1] 
}

#Compile Project
reset_run synth_1
launch_runs synth_1
wait_on_run synth_1

launch_runs impl_1
wait_on_run impl_1

#Create SDK HDF
write_hwdef -force  -file ../sdk/hdmi_example_kc705.hdf

#Build SDK Project
exec xsdk -batch -source ../sdk_build_kc705.tcl

#Associate ELF file to Microblaze
add_files -norecurse ../sdk/app_hdmi_example_kc705/Debug/app_hdmi_example_kc705.elf
set_property SCOPED_TO_REF hdmi_example_kc705 [get_files -all -of_objects [get_fileset sources_1] ../sdk/app_hdmi_example_kc705/Debug/app_hdmi_example_kc705.elf]
set_property SCOPED_TO_CELLS { microblaze_ss/microblaze_0 } [get_files -all -of_objects [get_fileset sources_1] ../sdk/app_hdmi_example_kc705/Debug/app_hdmi_example_kc705.elf]

#Generate Bitstream with ELF
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

cd ..
