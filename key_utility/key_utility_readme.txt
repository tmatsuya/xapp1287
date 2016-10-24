HDCP key programming utility
------------------------------

The following describes how you can program the HDCP keys into the HDMI 2.0 FMC card EEPROM using the key utility application. The keys only need to be programmed into the FMC EEPROM once.

1. Launch the Xilinx System Debugger by selecting Start > All Programs > Xilinx Design Tools > Vivado 2016.1 > Vivado 2016.1 Tcl Shell.

2. In the Xilinx command shell window, change to the ready_to_download directory:
cd <unzip_dir>/<hdcp_key_design>/ready_to_download

3. Launch Xilinx System Debugger (XSDB)
Vivado% xsdb

4. Establish connections to debug targets
xsdb% connect

5. Download the bitstream for programming the HDCP keys to the FPGA:
xsdb% fpga -file hdcp_key.bit

6. Exit the XSDB command prompt:
xsdb% exit

7. Open the file hdcp_key.c in the app_hdcp_key/src folder

8. The arrays Hdcp22Lc128, Hdcp22Key, Hdcp14Key1, and Hdcp14Key2 hold the HDCP keys and are empty. Fill these arrays with the acquired HDCP keys. The arrays are defined in big endian byte order.

9. Save the file and compile the design.

10. Run the design.

11. The terminal will display the following output:
HDCP Key EEPROM v1.0
This tool encrypts and stores the HDCP 2.2 certificate and
HDCP 1.4 keys into the EEPROM on the HDMI FMC board
Enter Password ->

12. The HDCP keys are encrypted using this password. The same password is used in the reference design to decrypt the HDCP keys.

13. The application is terminated after completing the programming of HDCP keys.
