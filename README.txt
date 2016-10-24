*************************************************************************
   ____  ____ 
  /   /\/   / 
 /___/  \  /   
 \   \   \/    © Copyright 2016 Xilinx, Inc. All rights reserved.
  \   \        This file contains confidential and proprietary 
  /   /        information of Xilinx, Inc. and is protected under U.S. 
 /___/   /\    and international copyright and other intellectual 
 \   \  /  \   property laws. 
  \___\/\___\ 
 
*************************************************************************

Vendor: Xilinx 

Supported Device(s): Kintex 7-Series FPGA
   
*************************************************************************

Disclaimer: 

      This disclaimer is not a license and does not grant any rights to 
      the materials distributed herewith. Except as otherwise provided in 
      a valid license issued to you by Xilinx, and to the maximum extent 
      permitted by applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE 
      "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL 
      WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
      INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, 
      NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and 
      (2) Xilinx shall not be liable (whether in contract or tort, 
      including negligence, or under any other theory of liability) for 
      any loss or damage of any kind or nature related to, arising under 
      or in connection with these materials, including for any direct, or 
      any indirect, special, incidental, or consequential loss or damage 
      (including loss of data, profits, goodwill, or any type of loss or 
      damage suffered as a result of any action brought by a third party) 
      even if such damage or loss was reasonably foreseeable or Xilinx 
      had been advised of the possibility of the same.

Critical Applications:

      Xilinx products are not designed or intended to be fail-safe, or 
      for use in any application requiring fail-safe performance, such as 
      life-support or safety devices or systems, Class III medical 
      devices, nuclear facilities, applications related to the deployment 
      of airbags, or any other applications that could lead to death, 
      personal injury, or severe property or environmental damage 
      (individually and collectively, "Critical Applications"). Customer 
      assumes the sole risk and liability of any use of Xilinx products 
      in Critical Applications, subject only to applicable laws and 
      regulations governing limitations on product liability.

THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS 
FILE AT ALL TIMES.

*************************************************************************

This readme file contains these sections:

1. REVISION HISTORY
2. OVERVIEW
3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS
4. INSTALLATION AND OPERATING INSTRUCTIONS


1. REVISION HISTORY 

            Readme  
Date        Version      Revision Description
=========================================================================
2016-20-05  1.0          Initial Xilinx release.
2016-31-05  1.1          Added HDCP Key Utility Application (No changes in the Application Note).
2016-18-07  1.2		 Updated the version to support Vivado 2016.2
                         Fixed the following known issues:
                         1. QPLL cannot be used to transmit 2160p60.
                         2. Wrong luma and chroma on 720p60 at 10 BPC.
                         3. Wrong luma and chroma on WXGA+ (1366x768p60) 
						 at 10 BPC.
                         4. No video display on 2160p24/25/30 at 16 BPC.
                         5. Wrong video output when video is in YUV420 color space, this is due to AXI4-Stream Video compatibility issues between the TPG and 			    HDMI_TX_SS.
                         6. PAL and NTSC video formats to and from HDMI_SS are not compatible with Video Processing Subsystem IP due to AXI4-Stream Video 			    	    compatibility issues between them.

=========================================================================


2. OVERVIEW
This ZIP contains:
 - design directory contains supporting project files
 - project directory contains TCL scripts for building the project
 - ready_for_download directory contains pre-built bitstream (with elf embedded)
 - repos contains source
 --- hw_repos - contains IP-XACT packaged HDL
 --- sw_repos - contains drivers
 - sdk directory contains SW application - SDK Workspace


3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS
* Xilinx Vivado 2016.2
HW Requirements:
1. KC705 development board 
2. HDMI FMC board - TB-FMCH-HDMI 4K
3. HDMI 1.4 or 2.0 Sink (HDCP 1.4 or 2.2 Capable)
4. HDMI 1.4 or 2.0 Source (HDCP 1.4 or 2.2 Capable) (Optional)

4. INSTALLATION AND OPERATING INSTRUCTIONS

Steps to run Demo:
The following section describes the steps to run the design on Kintex board setup.
	HW Setup:
		1. Connect a USB cable from the host PC to the USB JTAG port. Ensure the appropriate device 
		   drivers are installed.
		2. Connect a second USB cable from the host PCto the USB UART port. Ensure that USB UART 
		   drivers described in the section Hardware Requirements have been installed.
		3. Connect TB-FMCH-HDMI4K board to the HPC-FMC of KC705.
		4. Connect the HDMI TX port to an HDMI 1.4/2.0 sink or monitor (i.e. Ultra HD TV set).
		5. Connect the HDMI RX port to an HDMI 1.4/2.0 source (i.e. DVD Player).
		6. Connect the KC705 board to a power supply slot J49.
		7. Switch on the KC705 board.
		8. Start a terminal program (e.g. HyperTerminal) on the host PC with these settings:
				Baud Rate: 115200
				Data Bits: 8
				Parity: None
				Stop Bits: 1
				Flow Control: None
				
	Programming the HDCP Keys
		1. Launch the Xilinx System Debugger by selecting Start> All Programs> Xilinx Design
				Tools> Vivado 2016.2> SDK.
		2. In the Xilinx command shell window, change to the ready_to_download directory:
				cd <unzip_dir>/<hdcp_key_design>/ready_to_download
		3. Launch Xilinx System Debugger (XSDB)
				Vivado% xsdb
		4. Establish connectionsto debug targets
				xsdb% connect
		5. Download the bitstream for programming the HDCP keys to the FPGA:
				xsdb% fpga -file hdcp_key.bit 
		6. Exit the XMD command prompt:
				xsdb% exit
		7. Open the file hdcp_key.cin the app_hdcp_key/src folder
		8. The arrays Hdcp22Lc128, Hdcp22Key, Hdcp14Key1, and Hdcp14Key2hold the HDCP 
		   keys and are empty. Fill these arrays with the acquired HDCP keys. The arrays 
		   are defined in big endian byte order.
		9. Save the file and compile the design.
		10. Run the design.
		11. The terminal will display the following output: 
				HDCP Key EEPROM v1.0
				This tool encrypts and stores the HDCP 2.2 certificate and
				HDCP 1.4 keys into the EEPROM on the HDMI FMC board
		Enter Password ->
		12. The HDCP keys are encrypted using this password. The same password is used in the 
			reference design to decrypt the HDCP keys.
		13. The application is terminated after completing the programming of HDCP keys.
		
	Running the Reference Design
		1. Launch the Xilinx Microprocessor Debugger by selecting Start > All Programs > Xilinx 
				Design Tools > Vivado 2016.2 > SDK.
		2. In the Xilinx command shell window, change to the ready_for_download directory:
				Vivado% cd <unzip_dir>/kc705_hdmiss_..../ready_for_download
		3. Invoke Xilinx System Debugger (xsdb)
				Vivado% xsdb
		4. Establish connectionsto debug targets
				xsdb% connect
		5. Download the bitstream to the FPGA:
				xsdb% fpga -file hdmi_example_kc705_wrapper.bit 
		6. Exit the XSDB command prompt:
				xsdb% exit
				
	Generating Programming File inVivado Design Suite 2016.2
		1. Open Vivado Design Suite.
		2. At the Tcl Console, change to the workspace directory by typing:
				> cd <unzip dir>\xapp1287
		3. Run the all.tcl script to create, compile and generate the project bitstream
				> source all.tcl

5. XAPP1287 Directory Structure
	all.tcl								Main TCL file to be executed in Vivado TCL command prompt
	design								Contains the kc705 specific design files such as IPI TCL, top level wrapper and XDC
	| hdmi_example_kcu105.tcl:        	TCL for constructing the HDMI IPI design
	| hdmi_example_kcu105.xdc:			HDMI Reference Design top level constraint file
	project								Vivado project and generated files container folder
	ready_to_download					Contains the bitfile and the ELF of the system
	| hdmi_example_kcu105_wrapper.bit	Reference design precompiled bitfile
	repos								Contains the HW and SW repositories
	|
	\hw_repos							HW repository for custom IPs
	\sw_repos							SW repository (empty)
	sdk									Contains the SW application and SDK Workspace
	key_utility                         HDCP Key Programming Utility
	| key_utility_readme.txt            Description on how to use the HDCP Key Programming Utility
	\hdcp_key_dist                      HDCP Key Programming Utility Projects (Vivado+SDK)
	            
	
 