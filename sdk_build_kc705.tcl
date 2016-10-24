###############################################################################
# START FLOW
###############################################################################

#Set Workspace Directory
sdk setws ../sdk

sdk createhw -name hw_hdmi_example_kc705 -hwspec ../sdk/hdmi_example_kc705.hdf

#Set Software Repository
set current_folder [pwd]
cd ../repos
set sw_repo [pwd]
sdk set_user_repo_path $sw_repo
cd $current_folder

#Create BSP
sdk createbsp -name bsp_hdmi_example_kc705 -hwproject hw_hdmi_example_kc705 -proc microblaze_ss_microblaze_0 -os standalone

#Create Application Project
sdk createapp -name app_hdmi_example_kc705 -hwproject hw_hdmi_example_kc705 -proc microblaze_ss_microblaze_0 -os standalone -lang C -bsp bsp_hdmi_example_kc705
eval file delete -force [glob ../sdk/app_hdmi_example_kc705/src/*]
eval file copy [glob ../sdk/src/*] [list {../sdk/app_hdmi_example_kc705/src}]

#Build Project
sdk projects -build -type bsp -name bsp_hdmi_example_kc705
sdk projects -build -type app -name app_hdmi_example_kc705

#sdk projects -clean -type bsp -name bsp_hdmi_example_kc705
#sdk projects -clean -type all
#sdk projects -build -type all

#Exit XSDK
exit
