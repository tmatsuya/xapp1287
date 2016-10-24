/******************************************************************************
*
* Copyright (C) 2014 - 2015 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* XILINX CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/
/*****************************************************************************/
/**
*
* @file xhdmi_example.c
*
* This file demonstrates how to use Xilinx HDMI TX Subsystem, HDMI RX Subsystem
* and Video PHY Controller drivers.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who    Date     Changes
* ----- ------ -------- --------------------------------------------------
* 1.00         25/11/15 Initial release.
* 1.10         05/02/16 Updated function RxAuxCallback.
* 2.00  MG     02/03/15 Added upgraded with HDCP driver and overlay
* </pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xiic.h"
#include "xil_io.h"
#if defined (XPAR_XUARTLITE_NUM_INSTANCES)
#include "xuartlite_l.h"
#else
#include "xuartps.h"
#endif
#include "xil_types.h"
#include "xil_exception.h"
#include "string.h"
#include "si5324drv.h"
#include "xvidc.h"
#include "xvidc_edid.h"
#include "dp159.h"
#include "audiogen_drv.h"
#if defined (__arm__)
#include "sleep.h"
#else
#include "microblaze_sleep.h"
#endif
#include "xhdmi_menu.h"
#ifdef XPAR_XV_HDMIRXSS_NUM_INSTANCES
#include "xv_hdmirxss.h"
#endif
#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
#include "xv_hdmitxss.h"
#endif
#include "xvphy.h"
#ifdef XPAR_XV_TPG_NUM_INSTANCES
#include "xv_tpg.h"
#endif
#ifdef XPAR_XGPIO_NUM_INSTANCES
#include "xgpio.h"
#endif
#if defined (__arm__)
#include "xscugic.h"
#else
#include "xintc.h"
#endif
#include "xhdmi_hdcp_keys.h"

/* Overlay */
#ifdef XPAR_V_OVERLAY_0_BASEADDR
#include "v_overlay/xv_overlay.h"
#endif

#define LOOPBACK_MODE_EN 0

#if defined (__arm__)
#define XPAR_CPU_CORE_CLOCK_FREQ_HZ 100000000
#endif

#if defined (XPAR_XUARTLITE_NUM_INSTANCES)
#define UART_BASEADDR XPAR_MICROBLAZE_SS_AXI_UARTLITE_0_BASEADDR
#else
#define UART_BASEADDR XPAR_XUARTPS_0_BASEADDR
#endif

/************************** Constant Definitions *****************************/
/*
  EDID
*/
// Xilinx EDID
static const u8 Edid[] = {
0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x61, 0x98, 0x34, 0x12, 0x78, 0x56, 0x34, 0x12,
0x1F, 0x19, 0x01, 0x03, 0x80, 0x59, 0x32, 0x78, 0x0A, 0xEE, 0x91, 0xA3, 0x54, 0x4C, 0x99, 0x26,
0x0F, 0x50, 0x54, 0x21, 0x08, 0x00, 0x71, 0x4F, 0x81, 0xC0, 0x81, 0x00, 0x81, 0x80, 0x95, 0x00,
0xA9, 0xC0, 0xB3, 0x00, 0x01, 0x01, 0x02, 0x3A, 0x80, 0x18, 0x71, 0x38, 0x2D, 0x40, 0x58, 0x2C,
0x45, 0x00, 0x20, 0xC2, 0x31, 0x00, 0x00, 0x1E, 0x00, 0x00, 0x00, 0xFC, 0x00, 0x58, 0x49, 0x4C,
0x49, 0x4E, 0x58, 0x20, 0x48, 0x44, 0x4D, 0x49, 0x0A, 0x20, 0x00, 0x00, 0x00, 0x11, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x0C,
0x02, 0x03, 0x34, 0x71, 0x57, 0x61, 0x10, 0x1F, 0x04, 0x13, 0x05, 0x14, 0x20, 0x21, 0x22, 0x5D,
0x5E, 0x5F, 0x60, 0x65, 0x66, 0x62, 0x63, 0x64, 0x07, 0x16, 0x03, 0x12, 0x23, 0x09, 0x07, 0x07,
0x67, 0x03, 0x0C, 0x00, 0x10, 0x00, 0x78, 0x3C, 0xE3, 0x0F, 0x01, 0xE0, 0x67, 0xD8, 0x5D, 0xC4,
0x01, 0x78, 0x80, 0x07, 0x02, 0x3A, 0x80, 0x18, 0x71, 0x38, 0x2D, 0x40, 0x58, 0x2C, 0x45, 0x00,
0x20, 0xC2, 0x31, 0x00, 0x00, 0x1E, 0x08, 0xE8, 0x00, 0x30, 0xF2, 0x70, 0x5A, 0x80, 0xB0, 0x58,
0x8A, 0x00, 0x20, 0xC2, 0x31, 0x00, 0x00, 0x1E, 0x04, 0x74, 0x00, 0x30, 0xF2, 0x70, 0x5A, 0x80,
0xB0, 0x58, 0x8A, 0x00, 0x20, 0x52, 0x31, 0x00, 0x00, 0x1E, 0x66, 0x21, 0x56, 0xAA, 0x51, 0x00,
0x1E, 0x30, 0x46, 0x8F, 0x33, 0x00, 0x50, 0x1D, 0x74, 0x00, 0x00, 0x1E, 0x00, 0x00, 0x00, 0x2E
};

//// CTS EDID
//static const u8 Edid[] = {
//0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x61, 0x98, 0x34, 0x12, 0x00, 0x53, 0x54, 0x43,
//0x1F, 0x19, 0x01, 0x03, 0x80, 0x50, 0x2D, 0x78, 0x1A, 0x0D, 0xC9, 0xA0, 0x57, 0x47, 0x98, 0x27,
//0x12, 0x48, 0x4C, 0x20, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
//0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x02, 0x3A, 0x80, 0x18, 0x71, 0x38, 0x2D, 0x40, 0x58, 0x2C,
//0x45, 0x00, 0x20, 0xC2, 0x31, 0x00, 0x00, 0x1E, 0x01, 0x1D, 0x80, 0x18, 0x71, 0x1C, 0x16, 0x20,
//0x58, 0x2C, 0x25, 0x00, 0xC4, 0x8E, 0x21, 0x00, 0x00, 0x9E, 0x00, 0x00, 0x00, 0xFC, 0x00, 0x58,
//0x69, 0x6C, 0x69, 0x6E, 0x78, 0x20, 0x43, 0x54, 0x53, 0x0A, 0x20, 0x20, 0x00, 0x00, 0x00, 0xFD,
//0x00, 0x17, 0xF1, 0x08, 0x8C, 0x1E, 0x00, 0x0A, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x01, 0x04,
//
//0x02, 0x03, 0x65, 0x71, 0x5F, 0x90, 0x1F, 0x22, 0x20, 0x05, 0x14, 0x04, 0x13, 0x3E, 0x3C, 0x11,
//0x02, 0x03, 0x15, 0x06, 0x01, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x12, 0x16,
//0x17, 0x18, 0x19, 0x1A, 0x5F, 0x1B, 0x1C, 0x1D, 0x1E, 0x21, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28,
//0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38,
//0x39, 0x3A, 0x3B, 0x3D, 0x42, 0x3F, 0x40, 0x23, 0x0F, 0x7F, 0x07, 0x83, 0x4F, 0x00, 0x00, 0x6E,
//0x03, 0x0C, 0x00, 0x10, 0x00, 0x78, 0x3C, 0x20, 0x00, 0x80, 0x01, 0x02, 0x03, 0x04, 0xE2, 0x00,
//0xFF, 0xE3, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x47,
//};

u8 Hdcp22RxPrivateKey[] =
{
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

// LC128
u8 Hdcp22Lc128[] =
{
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

// HDCP 1.4 Key A
u8 Hdcp14KeyA[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

// HDCP 1.4 Key B
u8 Hdcp14KeyB[] = {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

#define I2C_MUX_ADDR    0x74  /**< I2C Mux Address */
#define I2C_CLK_ADDR    0x68  /**< I2C Clk Address */

#ifdef XPAR_AUDIO_SS_AUD_PAT_GEN_0_BASEADDR
/* This is only required for the audio over HDMI */
#define USE_HDMI_AUDGEN
#endif

/***************** Macros (Inline Functions) Definitions *********************/


/**************************** Type Definitions *******************************/


/************************** Function Prototypes ******************************/

//void print(char *str);
int I2cMux(void);
int I2cClk(u32 InFreq, u32 OutFreq);
#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
void EnableColorBar(XVphy *VphyPtr, XV_HdmiTxSs *HdmiTxSsPtr,
						XVidC_VideoMode VideoMode,
						XVidC_ColorFormat ColorFormat,
						XVidC_ColorDepth Bpc);
void UpdateFrameRate(XVphy *VphyPtr, XV_HdmiTxSs *HdmiTxSsPtr,
						XVidC_FrameRate FrameRate);
void Info(void);
void UpdateColorFormat(XVphy *VphyPtr, XV_HdmiTxSs *HdmiTxSsPtr,
						XVidC_ColorFormat ColorFormat);
void UpdateColorDepth(XVphy *VphyPtr, XV_HdmiTxSs *HdmiTxSsPtr,
						XVidC_ColorDepth ColorDepth);
void CloneTxEdid(void);
#endif
void SendVSInfoframe(void);

/************************** Variable Definitions *****************************/


XVphy Vphy;               	/* VPHY structure */
#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
XV_HdmiTxSs HdmiTxSs;       /* HDMI TX SS structure */
XV_HdmiTxSs_Config *XV_HdmiTxSs_ConfigPtr;
#endif
#ifdef XPAR_XV_HDMIRXSS_NUM_INSTANCES
XV_HdmiRxSs HdmiRxSs;       /* HDMI RX SS structure */
XV_HdmiRxSs_Config *XV_HdmiRxSs_ConfigPtr;
#endif
#if defined (__arm__)
static XScuGic Intc;
#else
static XIntc Intc;        	/* INTC structure */
#endif
#ifdef XPAR_XGPIO_NUM_INSTANCES
XGpio Gpio_Tpg_resetn;
XGpio_Config *Gpio_Tpg_resetn_ConfigPtr;
#endif
#ifdef XPAR_XV_TPG_NUM_INSTANCES
XV_tpg Tpg;
XV_tpg_Config *Tpg_ConfigPtr;
XTpg_PatternId      Pattern;      /**< Video pattern */
#endif
XhdmiAudioGen_t AudioGen; /* Audio Generator structure */
u8 IsPassThrough;         /**< Demo mode 0-colorbar 1-pass through */
u8 StartTxAfterRxFlag;        
u8 MuteAudio;
u8 TxBusy;                // TX busy flag. This flag is set while the TX is initialized
u8 TxRestartColorbar;     // TX restart colorbar. This flag is set when the TX cable has been reconnected and the TX colorbar was showing.
u32 Index;
XHdmi_Menu HdmiMenu;      // Menu structure

#ifdef XPAR_XV_OVERLAY_NUM_INSTANCES
  XV_Overlay      Overlay;      // Video overlay structure
  XV_Overlay_Config   *Overlay_ConfigPtr; // Video overlay pointer
#endif

/************************** Function Definitions *****************************/
#ifdef XPAR_XV_TPG_NUM_INSTANCES
void XV_ConfigTpg(XV_tpg *InstancePtr);
void ResetTpg(void);
#endif

#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
/*****************************************************************************/
/**
*
* This function clones the EDID of the connected sink device to the HDMI RX
* @return None.
*
* @note   None.
*
******************************************************************************/
void CloneTxEdid()
{
#ifdef XPAR_XV_HDMIRXSS_NUM_INSTANCES
	u8 Buffer[256];
	u32 Status;

	// Read TX edid
	Status = XV_HdmiTxSs_ReadEdid(&HdmiTxSs, (u8*)&Buffer);

	// Check if read was successful
	if (Status == (XST_SUCCESS)) {
		// Load new EDID
		XV_HdmiRxSs_LoadEdid(&HdmiRxSs, (u8*)&Buffer, sizeof(Buffer));

		print("\n\r");
		print("Successfully cloned EDID.\n\r");
	}
#else
	print("\r\nEdid Cloning no possible with HDMI RX SS.\n\r");
#endif
}

/*****************************************************************************/
/**
*
* This function generates video pattern.
*
* @param  IsPassThrough specifies either pass-through or colorbar mode.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void XV_ConfigTpg(XV_tpg *InstancePtr)
{
  XV_tpg *pTpg = InstancePtr;
  
  XVidC_VideoStream *HdmiTxSsVidStreamPtr;
  HdmiTxSsVidStreamPtr = XV_HdmiTxSs_GetVideoStream(&HdmiTxSs);  
  
  u32 width, height;
  XVidC_VideoMode VideoMode;
  VideoMode = HdmiTxSsVidStreamPtr->VmId;

  if ((VideoMode == XVIDC_VM_1440x480_60_I) ||
      (VideoMode == XVIDC_VM_1440x576_50_I) )
  {
	    //NTSC/PAL Support
	    width  = HdmiTxSsVidStreamPtr->Timing.HActive/2;
	    height = HdmiTxSsVidStreamPtr->Timing.VActive;
  }
  else {
	    width  = HdmiTxSsVidStreamPtr->Timing.HActive;
	    height = HdmiTxSsVidStreamPtr->Timing.VActive;
  }

  //Stop TPG
  XV_tpg_DisableAutoRestart(pTpg);

  XV_tpg_Set_height(pTpg, height);
  XV_tpg_Set_width(pTpg,  width);
  XV_tpg_Set_colorFormat(pTpg, HdmiTxSsVidStreamPtr->ColorFormatId);
  XV_tpg_Set_bckgndId(pTpg, Pattern);
  XV_tpg_Set_ovrlayId(pTpg, 0);

  XV_tpg_Set_enableInput(pTpg, IsPassThrough);

  if (IsPassThrough) {
  	  XV_tpg_Set_passthruStartX(pTpg,0);
	  XV_tpg_Set_passthruStartY(pTpg,0);
	  XV_tpg_Set_passthruEndX(pTpg,width);
	  XV_tpg_Set_passthruEndY(pTpg,height);
  }

  //Start TPG
  XV_tpg_EnableAutoRestart(pTpg);
  XV_tpg_Start(pTpg);
}

void ResetTpg(void) {
	XGpio_SetDataDirection(&Gpio_Tpg_resetn, 1, 0);
	XGpio_DiscreteWrite(&Gpio_Tpg_resetn, 1, 0);
#if defined (__arm__)
			usleep(1000);
#else
			MB_Sleep(1);
#endif
	XGpio_DiscreteWrite(&Gpio_Tpg_resetn, 1, 1);
#if defined (__arm__)
			usleep(1000);
#else
			MB_Sleep(1);
#endif
}
#endif
/*****************************************************************************/
/**
*
* This function setup SI5324 clock generator over IIC.
*
* @param  None.
*
* @return The number of bytes sent.
*
* @note   None.
*
******************************************************************************/
int I2cMux(void)
{
  u8 Buffer;
  int Status;

  xil_printf("Set i2c mux... \n\r");

  /* Select SI5324 clock generator */
  Buffer = 0x80;
  Status = XIic_Send((XPAR_IIC_0_BASEADDR), (I2C_MUX_ADDR),
		  	  	  	  	  	  	  (u8 *)&Buffer, 1, (XIIC_STOP));
  xil_printf("Set i2c mux done\n\r");

  return Status;
}

/*****************************************************************************/
/**
*
* This function setup SI5324 clock generator either in free or locked mode.
*
* @param  Index specifies an index for selecting mode frequency.
* @param  Mode specifies either free or locked mode.
*
* @return
*   - Zero if error in programming external clock.
*   - One if programmed external clock.
*
* @note   None.
*
******************************************************************************/
int I2cClk(u32 InFreq, u32 OutFreq)
{
  int Status;

  /* Free running mode */
  if (InFreq == 0) {

	  Status = Si5324_SetClock((XPAR_IIC_0_BASEADDR), (I2C_CLK_ADDR),
		  	  	  	  	   (SI5324_CLKSRC_XTAL), (SI5324_XTAL_FREQ), OutFreq);

	if (Status != (SI5324_SUCCESS)) {
		print("Error programming SI5324\n\r");
		return 0;
	}
  }

  /* Locked mode */
  else {
	  Status = Si5324_SetClock((XPAR_IIC_0_BASEADDR), (I2C_CLK_ADDR),
			  	  	  	   (SI5324_CLKSRC_CLK1), InFreq, OutFreq);

	if (Status != (SI5324_SUCCESS)) {
		print("Error programming SI5324\n\r");
		return 0;
	}
  }

  return 1;
}


#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
/*****************************************************************************/
/**
*
* This function reports the stream mode
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void ReportStreamMode(XV_HdmiTxSs *HdmiTxSsPtr, u8 IsPassThrough)
{
  XVidC_VideoStream *HdmiTxSsVidStreamPtr;
  HdmiTxSsVidStreamPtr = XV_HdmiTxSs_GetVideoStream(HdmiTxSsPtr);

    if (IsPassThrough) {
        print("--------\n\rPass-Through :\n\r");
    } else {
      print("--------\n\rColorbar :\n\r");
    }

    XVidC_ReportStreamInfo(HdmiTxSsVidStreamPtr);
    print("--------\n\r");
}
#endif

/*****************************************************************************/
/**
*
* This function outputs the video timing , Audio, Link Status, HDMI RX state of
* HDMI RX core. In addition, it also prints information about HDMI TX, and
* HDMI GT cores.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void Info(void)
{
  print("\n\r-----\n\r");
  print("Info\n\r");
  print("-----\n\r\n\r");

#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
  print("HDMI TX timing\n\r");
  print("------------\n\r");
  XV_HdmiTxSs_ReportTiming(&HdmiTxSs);
#endif
#ifdef XPAR_XV_HDMIRXSS_NUM_INSTANCES
  print("HDMI RX timing\n\r");
  print("------------\n\r");
  XV_HdmiRxSs_ReportTiming(&HdmiRxSs);
#endif
  print("GT status\n\r");
  print("---------\n\r");
  xil_printf("TX reference clock frequency %0d Hz\n\r",
		  	  	  XVphy_ClkDetGetRefClkFreqHz(&Vphy, XVPHY_DIR_TX));
  xil_printf("RX reference clock frequency %0d Hz\n\r",
		  	  	  XVphy_ClkDetGetRefClkFreqHz(&Vphy, XVPHY_DIR_RX));
  if(Vphy.Config.DruIsPresent == (TRUE)) {
    xil_printf("DRU reference clock frequency %0d Hz\n\r",
    				XVphy_DruGetRefClkFreqHz(&Vphy));
  }
  XVphy_HdmiDebugInfo(&Vphy, 0, XVPHY_CHANNEL_ID_CH1);
  
#ifdef XPAR_XV_HDMIRXSS_NUM_INSTANCES
  print("Link quality\n\r");
  print("---------\n\r");
  XV_HdmiRxSs_ReportLinkQuality(&HdmiRxSs);

  print("\n\r");

  print("Audio\n\r");
  print("---------\n\r");
  XV_HdmiRxSs_ReportAudio(&HdmiRxSs);

  print("Infoframe\n\r");
  print("---------\n\r");
  XV_HdmiRxSs_ReportInfoFrame(&HdmiRxSs);
  print("---------\r\n");
#endif
}

#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
/*****************************************************************************/
/**
*
* This function is called when a TX connect event has occurred.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void TxConnectCallback(void *CallbackRef)
{
	  XV_HdmiTxSs *HdmiTxSsPtr = (XV_HdmiTxSs *)CallbackRef;

	// Pass-through
	if (IsPassThrough) {
		StartTxAfterRxFlag = (TRUE);  // Restart stream
	}

	// Colorbar
	else {
#if(LOOPBACK_MODE_EN != 1)
		TxRestartColorbar = (TRUE);   // Restart colorbar
		TxBusy = (FALSE);
#endif
	}

	if(HdmiTxSsPtr->IsStreamConnected == (FALSE)) {
		XVphy_IBufDsEnable(&Vphy, 0, XVPHY_DIR_TX, (FALSE));
	}
	else {
		/* Check HDMI sink version */
		XV_HdmiTxSs_DetectHdmi20(HdmiTxSsPtr);
		XVphy_IBufDsEnable(&Vphy, 0, XVPHY_DIR_TX, (TRUE));
	}
}

/*****************************************************************************/
/**
*
* This function is called when the GT TX reference input clock has changed.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void VphyHdmiTxInitCallback(void *CallbackRef)
{
//xil_printf("VphyHdmiTxInitCallback\r\n");
	XV_HdmiTxSs_RefClockChangeInit(&HdmiTxSs);
}

/*****************************************************************************/
/**
*
* This function is called when the GT TX has been initialized
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void VphyHdmiTxReadyCallback(void *CallbackRef)
{  
//xil_printf("VphyHdmiTxReadyCallback\r\n");
}
#endif

#ifdef XPAR_XV_HDMIRXSS_NUM_INSTANCES
/*****************************************************************************/
/**
*
* This function is called when a RX connect event has occurred.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void RxConnectCallback(void *CallbackRef)
{
  XV_HdmiRxSs *HdmiRxSsPtr = (XV_HdmiRxSs *)CallbackRef;

	// RX cable is disconnected
	if(HdmiRxSsPtr->IsStreamConnected == (FALSE))
	{
		Vphy.HdmiRxTmdsClockRatio = 0; // Clear GT RX TMDS clock ratio
		IsPassThrough = (FALSE);   // Clear pass-through flag
#if(LOOPBACK_MODE_EN != 1)
		TxRestartColorbar = (TRUE);// Start colorbar with same video parameters
		TxBusy = (FALSE);
#endif
		XVphy_IBufDsEnable(&Vphy, 0, XVPHY_DIR_RX, (FALSE));
	}
	else
	{
		XVphy_IBufDsEnable(&Vphy, 0, XVPHY_DIR_RX, (TRUE));
	}

}

/*****************************************************************************/
/**
*
* This function is called when the GT RX reference input clock has changed.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void VphyHdmiRxInitCallback(void *CallbackRef)
{
	XVphy *VphyPtr = (XVphy *)CallbackRef;

	XV_HdmiRxSs_RefClockChangeInit(&HdmiRxSs);
	VphyPtr->HdmiRxTmdsClockRatio = HdmiRxSs.TMDSClockRatio;
}

/*****************************************************************************/
/**
*
* This function is called when the GT RX has been initialized.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void VphyHdmiRxReadyCallback(void *CallbackRef)
{
	XVphy *VphyPtr = (XVphy *)CallbackRef;
	XVphy_PllType RxPllType;

	// Enable pass-through
#if(LOOPBACK_MODE_EN != 1)
	IsPassThrough = (TRUE);
#endif
	/* Reset the menu to main */
	XHdmi_MenuReset(&HdmiMenu);

	RxPllType = XVphy_GetPllType(VphyPtr, 0, XVPHY_DIR_RX,
											XVPHY_CHANNEL_ID_CH1);
	if (!(RxPllType == XVPHY_PLL_TYPE_CPLL)) {
		XV_HdmiRxSs_SetStream(&HdmiRxSs, VphyPtr->HdmiRxRefClkHz,
				(VphyPtr->Quads[0].Plls[XVPHY_CHANNEL_ID_CMN0 -
			     XVPHY_CHANNEL_ID_CH1].LineRateHz / 1000000));
	}
	else {
		XV_HdmiRxSs_SetStream(&HdmiRxSs, VphyPtr->HdmiRxRefClkHz,
				(VphyPtr->Quads[0].Plls[0].LineRateHz/1000000));
	}
}
#endif
#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES

/*****************************************************************************/
/**
*
* This function is called when a TX vsync has occurred.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void TxVsCallback(void *CallbackRef)
{
#ifdef USE_HDMI_AUDGEN

  /* Audio Infoframe */
  /* Only when not in pass-through */
  if (!IsPassThrough) {
    XV_HdmiTxSs_SendAuxInfoframe(&HdmiTxSs, (NULL));
  }
#endif
}
#endif

#ifdef XPAR_XV_HDMIRXSS_NUM_INSTANCES
/*****************************************************************************/
/**
*
* This function is called when a RX aux irq has occurred.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void RxAuxCallback(void *CallbackRef)
{
//  XV_HdmiRxSs *HdmiRxSsPtr = (XV_HdmiRxSs *)CallbackRef;
  
#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
//	  if (HdmiRx.Aux.Header.Byte[0] == 0x81) {
//		  XHdmi_VSIF_ParsePacket(&HdmiRx.Aux, &VSIF);
//
//		  // Defaults
//		  HdmiRx.Stream.Video.Is3D = FALSE;
//		  HdmiRx.Stream.Video.Info_3D.Format = XVIDC_3D_UNKNOWN;
//
//		  if (VSIF.Format == XHDMI_VSIF_VF_3D) {
//			  HdmiRx.Stream.Video.Is3D = TRUE;
//			  HdmiRx.Stream.Video.Info_3D = VSIF.Info_3D.Stream;
//		  } else if (VSIF.Format == XHDMI_VSIF_VF_EXTRES) {
//			  switch(VSIF.HDMI_VIC) {
//			  	  case 1 :
//			  		  HdmiRx.Stream.Vic = 95;
//			  		  break;
//
//			  	  case 2 :
//			  		  HdmiRx.Stream.Vic = 94;
//			  		  break;
//
//			  	  case 3 :
//			  		  HdmiRx.Stream.Vic = 93;
//			  		  break;
//
//			  	  case 4 :
//			  		  HdmiRx.Stream.Vic = 98;
//			  		  break;
//
//			  	  default :
//			  		  break;
//			  }
//		  }
//	  }

// Org //  // In pass-through mode copy some aux packets 
// Org //  if (IsPassThrough) {
// Org //	  XV_HdmiTxSs_SendAuxInfoframe(&HdmiTxSs,
// Org //			  	  	  XV_HdmiRxSs_GetAuxiliary(&HdmiRxSs));
// Org //  }
  
  u8 AuxBuffer[36];

  // In pass-through mode copy some aux packets 
  if (IsPassThrough) {

    // First copy the RX packet into the local buffer
    memcpy(AuxBuffer, XV_HdmiRxSs_GetAuxiliary(&HdmiRxSs), sizeof(AuxBuffer));

    // Then re-send the aux packet
    XV_HdmiTxSs_SendAuxInfoframe(&HdmiTxSs, AuxBuffer);
  }
#endif
}

/*****************************************************************************/
/**
*
* This function is called when a RX audio irq has occurred.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void RxAudCallback(void *CallbackRef)
{
#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
  XV_HdmiRxSs *HdmiRxSsPtr = (XV_HdmiRxSs *)CallbackRef;

  if (IsPassThrough) {
    // Set TX Audio params
	  XV_HdmiTxSs_SetAudioChannels(&HdmiTxSs,
			  XV_HdmiRxSs_GetAudioChannels(HdmiRxSsPtr));
  }
#endif
}

/*****************************************************************************/
/**
*
* This function is called when a RX link status irq has occurred.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void RxLnkStaCallback(void *CallbackRef)
{
	XV_HdmiRxSs *HdmiRxSsPtr = (XV_HdmiRxSs *)CallbackRef;

	if (IsPassThrough) {
		/* Reset RX when the link error has reached its maximum */
		if ((HdmiRxSsPtr->IsLinkStatusErrMax) &&
			(Vphy.Quads[0].Plls[0].RxState == XVPHY_GT_STATE_READY)) {

			/* Pulse TX PLL reset */
			XVphy_ResetGtPll(&Vphy, 0, XVPHY_CHANNEL_ID_CHA,
							XVPHY_DIR_TX, (TRUE));
		}
	}
}

/*****************************************************************************/
/**
*
* This function is called when the RX DDC irq has occurred.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void RxDdcCallback(void *CallbackRef)
{
}

/*****************************************************************************/
/**
*
* This function is called when the RX HDCP irq has occurred.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void RxHdcpCallback(void *CallbackRef)
{
}

/*****************************************************************************/
/**
*
* This function is called when the RX stream is down.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void RxStreamDownCallback(void *CallbackRef)
{
  IsPassThrough = (FALSE);

//  // Clear VSIF instance
//  VSIF.Format = XHDMI_VSIF_VF_UNKNOWN;
}

/*****************************************************************************/
/**
*
* This function is called when the RX stream init
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void RxStreamInitCallback(void *CallbackRef)
{
  XV_HdmiRxSs *HdmiRxSsPtr = (XV_HdmiRxSs *)CallbackRef;
  XVidC_VideoStream *HdmiRxSsVidStreamPtr;
  u32 Status;
//xil_printf("RxStreamInitCallback\r\n");
	// Calculate RX MMCM parameters
	// In the application the YUV422 colordepth is 12 bits
	// However the HDMI transports YUV422 in 8 bits.
	// Therefore force the colordepth to 8 bits when the colorspace is YUV422

    HdmiRxSsVidStreamPtr = XV_HdmiRxSs_GetVideoStream(HdmiRxSsPtr);

    if (HdmiRxSsVidStreamPtr->ColorFormatId == XVIDC_CSF_YCRCB_422) {
    	Status = XVphy_HdmiCfgCalcMmcmParam(&Vphy, 0, XVPHY_CHANNEL_ID_CH1,
				XVPHY_DIR_RX,
				HdmiRxSsVidStreamPtr->PixPerClk,
				XVIDC_BPC_8);
	}

	// Other colorspaces
	else {
		Status = XVphy_HdmiCfgCalcMmcmParam(&Vphy, 0, XVPHY_CHANNEL_ID_CH1,
				XVPHY_DIR_RX,
				HdmiRxSsVidStreamPtr->PixPerClk,
				HdmiRxSsVidStreamPtr->ColorDepth);
	}

    if (Status == XST_FAILURE) {
    	return;
    }

	// Enable and configure RX MMCM
  	XVphy_MmcmStart(&Vphy, 0, XVPHY_DIR_RX);

#if defined (__arm__)
			usleep(10000);
#else
			MB_Sleep(10);
#endif
}

/*****************************************************************************/
/**
*
* This function is called when the RX stream is up.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void RxStreamUpCallback(void *CallbackRef)
{
	xil_printf("RX stream is up\n\r");
	XV_HdmiRxSs *HdmiRxSsPtr = (XV_HdmiRxSs *)CallbackRef;
#if(LOOPBACK_MODE_EN != 1 && XPAR_XV_HDMITXSS_NUM_INSTANCES > 0)
	u32 Status;
	u64 LineRate;
	XVphy_PllType RxPllType;
	XVidC_VideoStream *HdmiRxSsVidStreamPtr;
    XVidC_VideoStream *HdmiTxSsVidStreamPtr;

	HdmiRxSsVidStreamPtr = XV_HdmiRxSs_GetVideoStream(HdmiRxSsPtr);
    HdmiTxSsVidStreamPtr = XV_HdmiTxSs_GetVideoStream(&HdmiTxSs);

	// Copy video parameters
	*HdmiTxSsVidStreamPtr = *HdmiRxSsVidStreamPtr;
	XV_HdmiTxSs_SetVideoIDCode(&HdmiTxSs,
					XV_HdmiRxSs_GetVideoIDCode(HdmiRxSsPtr));
	XV_HdmiTxSs_SetVideoStreamType(&HdmiTxSs,
					XV_HdmiRxSs_GetVideoStreamType(HdmiRxSsPtr));
	XV_HdmiTxSs_SetVideoStreamScramblingFlag(&HdmiTxSs,
					XV_HdmiRxSs_GetVideoStreamScramblingFlag(HdmiRxSsPtr));

	RxPllType = XVphy_GetPllType(&Vphy, 0, XVPHY_DIR_RX, XVPHY_CHANNEL_ID_CH1);
	if (Vphy.Config.XcvrType != XVPHY_GT_TYPE_GTPE2) {
	if (!(RxPllType == XVPHY_PLL_TYPE_CPLL)) {
		LineRate = Vphy.Quads[0].Plls[XVPHY_CHANNEL_ID_CMN0 -
			XVPHY_CHANNEL_ID_CH1].LineRateHz;
	}
	else {
		LineRate = Vphy.Quads[0].Plls[0].LineRateHz;
		}
	}
	else { //GTP
		if (RxPllType == XVPHY_PLL_TYPE_PLL0) {
			LineRate = Vphy.Quads[0].Plls[XVPHY_CHANNEL_ID_CMN0 -
				XVPHY_CHANNEL_ID_CH1].LineRateHz;
		}
		else {
			LineRate = Vphy.Quads[0].Plls[XVPHY_CHANNEL_ID_CMN1 -
				XVPHY_CHANNEL_ID_CH1].LineRateHz;
		}
	}


	// Check GT line rate
	// For 4k60p the reference clock must be multiplied by four
	if ((LineRate / 1000000) > 3400) {
		// TX reference clock
		Vphy.HdmiTxRefClkHz = Vphy.HdmiRxRefClkHz * 4;
		XV_HdmiTxSs_SetTmdsClockRatio(&HdmiTxSs, 1);
	}

	// Other resolutions
	else {
		Vphy.HdmiTxRefClkHz = Vphy.HdmiRxRefClkHz;
		XV_HdmiTxSs_SetTmdsClockRatio(&HdmiTxSs, 0);
	}

	// Set GT TX parameters
	Status = XVphy_SetHdmiTxParam(&Vphy, 0, XVPHY_CHANNEL_ID_CHA,
					HdmiTxSsVidStreamPtr->PixPerClk,
					HdmiTxSsVidStreamPtr->ColorDepth,
					HdmiTxSsVidStreamPtr->ColorFormatId);

    if (Status == XST_FAILURE) {
    	return;
    }

	// When the GT TX and RX are coupled, then start the TXPLL
	if (XVphy_IsBonded(&Vphy, 0, XVPHY_CHANNEL_ID_CH1)){
		// Start TX MMCM
	  	XVphy_MmcmStart(&Vphy, 0, XVPHY_DIR_TX);
#if defined (__arm__)
			usleep(10000);
#else
			MB_Sleep(10);
#endif
	}

	// Start TX stream
	StartTxAfterRxFlag = (TRUE);
#else
	XVidC_ReportStreamInfo(&HdmiRxSsPtr->HdmiRxPtr->Stream.Video);
#endif
}

/*****************************************************************************/
/**
*
* This function is called when the RX HDCP is authenticated.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void RxHdcpAuthenticatedCallback(void *CallbackRef)
{
    XV_HdmiRxSs *HdmiRxSsPtr = (XV_HdmiRxSs *)CallbackRef;

    if (XV_HdmiRxSs_HdcpGetProtocol(HdmiRxSsPtr) == XV_HDMIRXSS_HDCP_22) {
        xil_printf("HDCP 2.2 RX authenticated\n\r");
    }

    else if (XV_HdmiRxSs_HdcpGetProtocol(HdmiRxSsPtr) == XV_HDMIRXSS_HDCP_14) {
        xil_printf("HDCP 1.4 RX authenticated\n\r");
    }
}

#endif

#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
/*****************************************************************************/
/**
*
* This function is called when the TX stream is up.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void TxStreamUpCallback(void *CallbackRef)
{
  xil_printf("TX stream is up\n\r");
  XV_HdmiTxSs *HdmiTxSsPtr = (XV_HdmiTxSs *)CallbackRef;
  XVphy_PllType TxPllType;
  u64 TxLineRate;
#ifdef XPAR_XV_HDMIRXSS_NUM_INSTANCES
  XVidC_VideoStream *HdmiRxSsVidStreamPtr;

  HdmiRxSsVidStreamPtr = XV_HdmiRxSs_GetVideoStream(&HdmiRxSs);

  /* In passthrough copy the RX stream parameters to the TX stream */
  if (IsPassThrough) {
	  XV_HdmiTxSs_SetVideoStream(HdmiTxSsPtr, *HdmiRxSsVidStreamPtr);
  }
#endif

  TxPllType = XVphy_GetPllType(&Vphy, 0, XVPHY_DIR_TX, XVPHY_CHANNEL_ID_CH1);
  if ((TxPllType == XVPHY_PLL_TYPE_CPLL)) {
	  TxLineRate = Vphy.Quads[0].Plls[0].LineRateHz;
  }
  else if((TxPllType == XVPHY_PLL_TYPE_QPLL) ||
	  (TxPllType == XVPHY_PLL_TYPE_QPLL0) ||
	  (TxPllType == XVPHY_PLL_TYPE_PLL0)) {
	  TxLineRate = Vphy.Quads[0].Plls[XVPHY_CHANNEL_ID_CMN0 -
		  XVPHY_CHANNEL_ID_CH1].LineRateHz;
  }
  else {
	  TxLineRate = Vphy.Quads[0].Plls[XVPHY_CHANNEL_ID_CMN1 -
		  XVPHY_CHANNEL_ID_CH1].LineRateHz;
  }

  i2c_dp159(&Vphy, 0, TxLineRate);

  /* Enable TX TMDS clock*/
  XVphy_Clkout1OBufTdsEnable(&Vphy, XVPHY_DIR_TX, (TRUE));

  /* Copy Sampling Rate */
  XV_HdmiTxSs_SetSamplingRate(HdmiTxSsPtr, Vphy.HdmiTxSampleRate);

  /* Run Video Pattern Generator */
  ResetTpg();

  /* Set colorbar pattern */
  Pattern = XTPG_BKGND_COLOR_BARS;

  XV_ConfigTpg(&Tpg);

#if defined(USE_HDMI_AUDGEN)
  /* Select the Audio source */
  if (IsPassThrough) {

    /* Disable audio generator */
    XhdmiAudGen_Start(&AudioGen, FALSE);

    /* Select ACR from RX */
    XhdmiACRCtrl_Sel(&AudioGen, ACR_SEL_IN);
    
    /* Re-program audio clock */
    XhdmiAudGen_SetAudClk(&AudioGen, XAUD_SRATE_192K);
  }
  else {

    /* Enable audio generator */
    XhdmiAudGen_Start(&AudioGen, TRUE);

    /* Select ACR from ACR Ctrl */
    XhdmiACRCtrl_Sel(&AudioGen, ACR_SEL_GEN);

    /* Enable 2-channel audio */
    XhdmiAudGen_SetEnabChannels(&AudioGen, 2);
    XhdmiAudGen_SetPattern(&AudioGen, 1, XAUD_PAT_PING);
    XhdmiAudGen_SetPattern(&AudioGen, 2, XAUD_PAT_PING);
    XhdmiAudGen_SetSampleRate(&AudioGen,
    				XV_HdmiTxSs_GetTmdsClockFreqHz(HdmiTxSsPtr),
    				XAUD_SRATE_48K);
  }

  /* HDMI TX unmute audio */
  XV_HdmiTxSs_AudioMute(HdmiTxSsPtr, FALSE);

#endif

  ReportStreamMode(HdmiTxSsPtr, IsPassThrough);

#ifdef XPAR_XV_OVERLAY_NUM_INSTANCES
  // Enable Overlay
  XV_Overlay_Start(&Overlay);
#endif

  // Clear TX busy flag
  TxBusy = (FALSE);

}

/*****************************************************************************/
/**
*
* This function is called when the TX stream is down.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void TxStreamDownCallback(void *CallbackRef)
{
//  XV_HdmiTxSs *HdmiTxSsPtr = (XV_HdmiTxSs *)CallbackRef;
#ifdef XPAR_XV_OVERLAY_NUM_INSTANCES
  // Stop Overlay
  XV_Overlay_Stop(&Overlay);
#endif
}

/*****************************************************************************/
/**
*
* This function is called when the TX HDCP is authenticated.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void TxHdcpAuthenticatedCallback(void *CallbackRef)
{
    XV_HdmiTxSs *HdmiTxSsPtr = (XV_HdmiTxSs *)CallbackRef;
    
    if (XV_HdmiTxSs_HdcpGetProtocol(HdmiTxSsPtr) == XV_HDMITXSS_HDCP_22) {
        xil_printf("HDCP 2.2 TX authenticated\n\r");
    }

    else if (XV_HdmiTxSs_HdcpGetProtocol(HdmiTxSsPtr) == XV_HDMITXSS_HDCP_14) {
        xil_printf("HDCP 1.4 TX authenticated\n\r");      
    }

    // After authentication start encryption
    XV_HdmiTxSs_HdcpEnableEncryption(&HdmiTxSs);
}

/*****************************************************************************/
/**
*
* This function is called to start the TX stream after the RX stream
* was up and running.
*
* @param  None.
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void StartTxAfterRx(void)
{
  
  // clear start
  StartTxAfterRxFlag = (FALSE);

  // Disable TX TDMS clock
  XVphy_Clkout1OBufTdsEnable(&Vphy, XVPHY_DIR_TX, (FALSE));
  
  XV_HdmiTxSs_StreamStart(&HdmiTxSs);

  /* Enable RX clock forwarding */
  XVphy_Clkout1OBufTdsEnable(&Vphy, XVPHY_DIR_RX, (TRUE));

  // Program external clock generator in locked mode
  // Only when the GT TX and RX are not coupled
  if (!XVphy_IsBonded(&Vphy, 0, XVPHY_CHANNEL_ID_CH1)){
    I2cClk(Vphy.HdmiRxRefClkHz,Vphy.HdmiTxRefClkHz);
  }

  /* Video Pattern Generator */
  ResetTpg();
  XV_ConfigTpg(&Tpg);

  /* Enable TX TMDS Clock in bonded mode */
  if (XVphy_IsBonded(&Vphy, 0, XVPHY_CHANNEL_ID_CH1)){
	  XVphy_Clkout1OBufTdsEnable(&Vphy, XVPHY_DIR_TX, (TRUE));
  }
}
#endif
/*****************************************************************************/
/**
*
* This function setups the interrupt system so interrupts can occur for the
* HDMI cores. The function is application-specific since the actual system
* may or may not have an interrupt controller. The HDMI cores could be
* directly connected to a processor without an interrupt controller.
* The user should modify this function to fit the application.
*
* @param  None.
*
* @return
*   - XST_SUCCESS if interrupt setup was successful.
*   - A specific error code defined in "xstatus.h" if an error
*   occurs.
*
* @note   This function assumes a Microblaze system and no operating
*   system is used.
*
******************************************************************************/
int SetupInterruptSystem(void)
{
  int Status;
#if defined (__arm__)
  XScuGic *IntcInstPtr = &Intc;
#else
  XIntc *IntcInstPtr = &Intc;
#endif

  /*
   * Initialize the interrupt controller driver so that it's ready to
   * use, specify the device ID that was generated in xparameters.h
   */
#if defined(__arm__)
  XScuGic_Config *IntcCfgPtr;
  IntcCfgPtr = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
  if(IntcCfgPtr == NULL)
  {
	  print("ERR:: Interrupt Controller not found");
	  return (XST_DEVICE_NOT_FOUND);
  }
  Status = XScuGic_CfgInitialize(IntcInstPtr,
		  	  	  	  	  	  	 IntcCfgPtr,
		  	  	  	  	  	  	 IntcCfgPtr->CpuBaseAddress);
#else
  Status = XIntc_Initialize(IntcInstPtr, XPAR_INTC_0_DEVICE_ID);
#endif
  if (Status != XST_SUCCESS) {
    xil_printf("Intc initialization failed!\r\n");
    return XST_FAILURE;
  }


  /*
   * Start the interrupt controller such that interrupts are recognized
   * and handled by the processor
   */
#if defined (__MICROBLAZE__)
  Status = XIntc_Start(IntcInstPtr, XIN_REAL_MODE);
//  Status = XIntc_Start(IntcInstPtr, XIN_SIMULATION_MODE);
  if (Status != XST_SUCCESS) {
    return XST_FAILURE;
  }
#endif

  Xil_ExceptionInit();

  /*
   * Register the interrupt controller handler with the exception table.
   */
#if defined(__arm__)
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
	                		   (Xil_ExceptionHandler)XScuGic_InterruptHandler,
	                		   (XScuGic *)IntcInstPtr);
#else
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
	                		   (Xil_ExceptionHandler)XIntc_InterruptHandler,
	                		   (XIntc *)IntcInstPtr);
#endif

  return (XST_SUCCESS);
}

#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
/*****************************************************************************/
/**
*
* This function updates the ColorFormat for the current video stream
*
* @param VphyPtr is a pointer to the VPHY core instance.
* @param HdmiTxSsPtr is a pointer to the XV_HdmiTxSs instance.
* @param Requested ColorFormat
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void UpdateColorFormat(XVphy             *VphyPtr,
                       XV_HdmiTxSs       *HdmiTxSsPtr,
                       XVidC_ColorFormat ColorFormat) {
  
  XVidC_VideoStream *HdmiTxSsVidStreamPtr;
  HdmiTxSsVidStreamPtr = XV_HdmiTxSs_GetVideoStream(HdmiTxSsPtr);

  if (IsPassThrough) {
    print("Colorspace conversion is not supported!\n\r");
    return;
  }
  
  // Check if the TX isn't busy already
  if (!TxBusy) {
    
    if (((HdmiTxSsVidStreamPtr->VmId == XVIDC_VM_3840x2160_60_P) ||
    		(HdmiTxSsVidStreamPtr->VmId == XVIDC_VM_3840x2160_50_P)) &&
    	((ColorFormat == XVIDC_CSF_YCRCB_444) ||
    		(ColorFormat == XVIDC_CSF_YCRCB_422))) {
      xil_printf("The video pattern generator doesn't support YUV colorspace\r\n");
      xil_printf("in UHD mode. The colorbar may look incorrect.\n\r");
    }
      EnableColorBar(VphyPtr,
                     HdmiTxSsPtr,
                     HdmiTxSsVidStreamPtr->VmId,
                     ColorFormat,
                     HdmiTxSsVidStreamPtr->ColorDepth);
    }
}                       

/*****************************************************************************/
/**
*
* This function updates the ColorDepth for the current video stream
*
* @param VphyPtr is a pointer to the VPHY core instance.
* @param HdmiTxSsPtr is a pointer to the XV_HdmiTxSs instance.
* @param Requested ColorFormat
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void UpdateColorDepth(XVphy             *VphyPtr,
                       XV_HdmiTxSs      *HdmiTxSsPtr,
                       XVidC_ColorDepth ColorDepth) {

  XVidC_VideoStream *HdmiTxSsVidStreamPtr;
  HdmiTxSsVidStreamPtr = XV_HdmiTxSs_GetVideoStream(HdmiTxSsPtr);

  // Check passthrough
  if (IsPassThrough) {
    print("Colordepth conversion is not supported!\n\r");
    return;
  }

  // Check YUV420
  //else if ((HdmiTxSsVidStreamPtr->ColorFormatId == XVIDC_CSF_YCRCB_420) &&
  //                                           (ColorDepth != XVIDC_BPC_8)) {
  //  print("YUV420 only supports 24-bits colordepth!\n");
  //  return;
  //}    

  // Check YUV422
  else if ((HdmiTxSsVidStreamPtr->ColorFormatId == XVIDC_CSF_YCRCB_422) &&
		  	  	  	  	  	  	  	  	  	  (ColorDepth != XVIDC_BPC_12)) {
    print("YUV422 only supports 36-bits colordepth!\n\r");
    return;
  }    

  // Check UHD
  else if ( ((HdmiTxSsVidStreamPtr->VmId == XVIDC_VM_3840x2160_60_P) ||
		  	   (HdmiTxSsVidStreamPtr->VmId == XVIDC_VM_3840x2160_50_P)) &&
            ((HdmiTxSsVidStreamPtr->ColorFormatId == XVIDC_CSF_RGB) ||
              (HdmiTxSsVidStreamPtr->ColorFormatId == XVIDC_CSF_YCRCB_444)) &&
            (ColorDepth != XVIDC_BPC_8)) {
    print("UHD only supports 24-bits colordepth!\n\r");
    return;
  }    

  // Check if the TX isn't busy already
  if (!TxBusy) {
      EnableColorBar(VphyPtr,
                     HdmiTxSsPtr,
                     HdmiTxSsVidStreamPtr->VmId,
                     HdmiTxSsVidStreamPtr->ColorFormatId,
                     ColorDepth);
    }
}                       

/*****************************************************************************/
/**
*
* This function updates the FrameRate for the current video stream
*
* @param VphyPtr is a pointer to the VPHY core instance.
* @param HdmiTxSsPtr is a pointer to the XV_HdmiTxSs instance.
* @param Requested FrameRate
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void UpdateFrameRate(XVphy           *VphyPtr,
                     XV_HdmiTxSs     *HdmiTxSsPtr,
                     XVidC_FrameRate FrameRate) {

  XVidC_VideoStream *HdmiTxSsVidStreamPtr;
  HdmiTxSsVidStreamPtr = XV_HdmiTxSs_GetVideoStream(HdmiTxSsPtr);

  if (IsPassThrough){
    print("Frame rate conversion is not supported!\n\r");
    return;
  }
  
  // Check if the TX isn't busy already
  if (!TxBusy) {

    /* Check if requested video mode is available */
    XVidC_VideoMode VmId = XVidC_GetVideoModeId(
    					HdmiTxSsVidStreamPtr->Timing.HActive,
    					HdmiTxSsVidStreamPtr->Timing.VActive,
    					FrameRate,
    					HdmiTxSsVidStreamPtr->IsInterlaced);
    
    if (VmId != XVIDC_VM_NUM_SUPPORTED) {

    	HdmiTxSsVidStreamPtr->VmId = VmId;

      EnableColorBar(VphyPtr,
    		         HdmiTxSsPtr,
    		         HdmiTxSsVidStreamPtr->VmId,
    		         HdmiTxSsVidStreamPtr->ColorFormatId,
    		         HdmiTxSsVidStreamPtr->ColorDepth);
    }
    else {
      xil_printf("%s : %d Hz is not supported!\n\r",
    		  XVidC_GetVideoModeStr(HdmiTxSsVidStreamPtr->VmId), FrameRate);
    }
  }
}                     

/*****************************************************************************/
/**
*
* This function enables the ColorBar
*
* @param VphyPtr is a pointer to the VPHY core instance.
* @param HdmiTxSsPtr is a pointer to the XV_HdmiTxSs instance.
* @param Requested Video mode
* @param Requested ColorFormat
* @param Requested ColorDepth
* @param Requested Pixels per clock
*
* @return None.
*
* @note   None.
*
******************************************************************************/
void EnableColorBar(XVphy                *VphyPtr,
                    XV_HdmiTxSs          *HdmiTxSsPtr,
                    XVidC_VideoMode      VideoMode,
                    XVidC_ColorFormat    ColorFormat,
                    XVidC_ColorDepth     Bpc)
{

  u32 TmdsClock = 0;
//  u32 Loop;
  u32 Result;
  u32 PixelClock;
//  XVidC_VideoMode CurrentVideoMode;
//  XVidC_ColorFormat CurrentColorFormat;
//  XVidC_ColorDepth CurrentBpc;
  XVidC_VideoStream *HdmiTxSsVidStreamPtr;

  HdmiTxSsVidStreamPtr = XV_HdmiTxSs_GetVideoStream(HdmiTxSsPtr);

  // If the RX is master, 
  // then the TX has to follow the RX reference clock
  // In this case the TX only color bar can't be displayed
  if (XVphy_IsBonded(VphyPtr, 0, XVPHY_CHANNEL_ID_CH1)) {
    xil_printf("Both the GT RX and GT TX are clocked by the RX reference clock.\n\r");
    xil_printf("Please connect a source to the RX input\n\r");
  }

  // Independent TX reference clock
  else {
    // Check if the TX isn't busy already
    if (!TxBusy) {
      TxBusy = (TRUE);    // Set TX busy flag

      if (VideoMode < XVIDC_VM_NUM_SUPPORTED) {
        xil_printf("Starting colorbar\n\r");
        IsPassThrough = 0;

        // First store the current stream parameters, 
        // so we can always go back in case the new parameters are not supported
//        CurrentVideoMode = HdmiTxSsVidStreamPtr->VmId;
//        CurrentColorFormat = HdmiTxSsVidStreamPtr->ColorFormatId;
//        CurrentBpc = HdmiTxSsVidStreamPtr->ColorDepth;

        // Disable TX TDMS clock
        XVphy_Clkout1OBufTdsEnable(VphyPtr, XVPHY_DIR_TX, (FALSE));

        // Get pixel clock
        PixelClock = XVidC_GetPixelClockHzByVmId(VideoMode);
     
        // In YUV420 the pixel clock is actually the half of the
        // reported pixel clock
        if (ColorFormat == XVIDC_CSF_YCRCB_420) {
          PixelClock = PixelClock / 2;        
        }
      }

      TmdsClock = XV_HdmiTxSs_SetStream(HdmiTxSsPtr, VideoMode,
    		                                      ColorFormat, Bpc, NULL);


      // Set TX reference clock
  	  VphyPtr->HdmiTxRefClkHz = TmdsClock;

  	  // Set GT TX parameters
  	  Result = XVphy_SetHdmiTxParam(VphyPtr, 0, XVPHY_CHANNEL_ID_CHA,
  					HdmiTxSsVidStreamPtr->PixPerClk,
  					HdmiTxSsVidStreamPtr->ColorDepth,
  					HdmiTxSsVidStreamPtr->ColorFormatId);

      if (Result == (XST_FAILURE)) {
          xil_printf("Unable to set requested TX video resolution.\n\r");
          xil_printf("Returning to previously TX video resolution.\n\r");
      }

      /* Disable RX clock forwarding */
      XVphy_Clkout1OBufTdsEnable(VphyPtr, XVPHY_DIR_RX, (FALSE));

      // Program external clock generator in free running mode
      I2cClk(0, VphyPtr->HdmiTxRefClkHz);
    }
  }
}
#endif

void Xil_AssertCallbackRoutine(u8 *File, s32 Line)
{
	  xil_printf("Assertion in File %s, on line %0d\n\r", File, Line);
}

/*****************************************************************************/
/**
*
* Main function to call example with HDMI TX, HDMI RX and HDMI GT drivers.
*
* @param  None.
*
* @return
*   - XST_SUCCESS if HDMI example was successfully.
*   - XST_FAILURE if HDMI example failed.
*
* @note   None.
*
******************************************************************************/
int main()
{
  u32 Status;
  XVphy_Config *XVphyCfgPtr;
  XVidC_VideoStream *HdmiTxSsVidStreamPtr;

  print("\n\r\n\r");
  print("--------------------------------------\r\n");
  print("---  HDMI SS + VPhy Example v1.0   ---\r\n");
  print("---  (c) 2015 by Xilinx, Inc.      ---\r\n");
  print("--------------------------------------\r\n");
  xil_printf("Build %s - %s\r\n", __DATE__, __TIME__);
  print("--------------------------------------\r\n");


  MuteAudio = 0;
  StartTxAfterRxFlag = (FALSE);
  TxBusy = (FALSE);
  TxRestartColorbar = (FALSE);    

  /* Start in color bar */
  IsPassThrough = 0;

  /* Initialize platform */
  init_platform();

  /* Load HDCP keys from EEPROM */
#if defined (XPAR_XHDCP_NUM_INSTANCES) || defined (XPAR_XHDCP22_RX_NUM_INSTANCES) || defined (XPAR_XHDCP22_TX_NUM_INSTANCES)
  if (XHdcp_LoadKeys( Hdcp22Lc128, sizeof(Hdcp22Lc128), 
                  Hdcp22RxPrivateKey, sizeof(Hdcp22RxPrivateKey), 
                  Hdcp14KeyA, sizeof(Hdcp14KeyA), 
                  Hdcp14KeyB, sizeof(Hdcp14KeyB)) == XST_SUCCESS) {
   
    /* Set pointer to HDCP 2.2 LC128 */
    XV_HdmiTxSs_HdcpSetKey(&HdmiTxSs, XV_HDMITXSS_KEY_HDCP22_LC128, Hdcp22Lc128); 
    
    /* Set pointer to HDCP 2.2 LC128 */
    XV_HdmiRxSs_HdcpSetKey(&HdmiRxSs, XV_HDMIRXSS_KEY_HDCP22_LC128, Hdcp22Lc128); 

    /* Set pointer to HDCP 2.2 private key */
    XV_HdmiRxSs_HdcpSetKey(&HdmiRxSs, XV_HDMIRXSS_KEY_HDCP22_PRIVATE, Hdcp22RxPrivateKey); 

#if XPAR_XHDCP_NUM_INSTANCES
    /* Set pointer to HDCP 1.4 key */
    XV_HdmiTxSs_HdcpSetKey(&HdmiTxSs, XV_HDMITXSS_KEY_HDCP14, Hdcp14KeyA);
    
    /* Set pointer to HDCP 1.4 key */
    XV_HdmiRxSs_HdcpSetKey(&HdmiRxSs, XV_HDMIRXSS_KEY_HDCP14, Hdcp14KeyB); 
    
    /* Key manager Init */
    Status = XHdcp_KeyManagerInit(XPAR_HDCP_KEYMNGMT_BLK_0_BASEADDR, HdmiTxSs.Hdcp14KeyPtr);
    if (Status != XST_SUCCESS) {
      print("HDCP 1.4 TX Key Manager Initialization error\n\r");
      return XST_FAILURE;
    }

    Status = XHdcp_KeyManagerInit(XPAR_HDCP_KEYMNGMT_BLK_1_BASEADDR, HdmiRxSs.Hdcp14KeyPtr);
    if (Status != XST_SUCCESS) {
      print("HDCP 1.4 RX Key Manager Initialization error\n\r");
      return XST_FAILURE;
    }
#endif

  }

  /* Clear pointers */
  else {
    /* Set pointer to NULL */
    XV_HdmiTxSs_HdcpSetKey(&HdmiTxSs, XV_HDMITXSS_KEY_HDCP22_LC128, (NULL)); 
    
    /* Set pointer to NULL */
    XV_HdmiTxSs_HdcpSetKey(&HdmiTxSs, XV_HDMITXSS_KEY_HDCP14, (NULL)); 

    /* Set pointer to NULL */
    XV_HdmiRxSs_HdcpSetKey(&HdmiRxSs, XV_HDMIRXSS_KEY_HDCP22_LC128, (NULL)); 

    /* Set pointer to NULL */
    XV_HdmiRxSs_HdcpSetKey(&HdmiRxSs, XV_HDMIRXSS_KEY_HDCP22_PRIVATE, (NULL)); 
    
    /* Set pointer to NULL */
    XV_HdmiRxSs_HdcpSetKey(&HdmiRxSs, XV_HDMIRXSS_KEY_HDCP14, (NULL));    
  }
#endif

#if defined(USE_HDMI_AUDGEN)
  /* Initialize the Audio Generator */
  XhdmiAudGen_Init(&AudioGen, 
                   XPAR_AUDIO_SS_AUD_PAT_GEN_0_BASEADDR,
                   XPAR_AUDIO_SS_HDMI_ACR_CTRL_0_BASEADDR,
                   XPAR_AUDIO_SS_CLK_WIZ_0_BASEADDR);
#endif

  /* Initialize external clock generator */
  Si5324_Init(XPAR_IIC_0_BASEADDR, I2C_CLK_ADDR);

  /* Initialize IRQ */
  Status = SetupInterruptSystem();
  if (Status == XST_FAILURE) {
    print("IRQ init failed.\n\r\r");
    return XST_FAILURE;
  }


#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
  /////
  // Initialize HDMI TX Subsystem
  /////
  XV_HdmiTxSs_ConfigPtr =
		  XV_HdmiTxSs_LookupConfig(XPAR_V_HDMI_TX_SS_0_V_HDMI_TX_DEVICE_ID);

  if(XV_HdmiTxSs_ConfigPtr == NULL)
  {
      HdmiTxSs.IsReady = 0;
  }

  //Initialize top level and all included sub-cores
  Status = XV_HdmiTxSs_CfgInitialize(&HdmiTxSs, XV_HdmiTxSs_ConfigPtr,
		  	  	  	  	  	  	  	  XV_HdmiTxSs_ConfigPtr->BaseAddress);
  if(Status != XST_SUCCESS)
  {
    xil_printf("ERR:: HDMI TX Subsystem Initialization failed %d\r\n", Status);
  }

  //Register HDMI TX SS Interrupt Handler with Interrupt Controller
#if defined(__arm__)
  Status |= XScuGic_Connect(&Intc,
		  	  XPAR_FABRIC_V_HDMI_TX_SS_0_IRQ_INTR,
		  	  (XInterruptHandler)XV_HdmiTxSS_HdmiTxIntrHandler,
		  	  (void *)&HdmiTxSs);

// HDCP 1.4
#ifdef XPAR_XHDCP_NUM_INSTANCES
  // HDCP 1.4 Cipher interrupt
  Status |= XScuGic_Connect(&Intc,
		  	  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP14_IRQ_INTR,
		  	  (XInterruptHandler)XV_HdmiTxSS_HdcpIntrHandler,
		  	  (void *)&HdmiTxSs);

  // HDCP 1.4 Timer interrupt
  Status |= XScuGic_Connect(&Intc,
		  	  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP14_TIMER_IRQ_INTR,
		  	  (XInterruptHandler)XV_HdmiRxSS_HdcpTimerIntrHandler,
		  	  (void *)&HdmiTxSs);
#endif

// HDCP 2.2
#if (XPAR_XHDCP22_TX_NUM_INSTANCES)
  Status |= XScuGic_Connect(&Intc,
		  	  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP22_TIMER_IRQ_INTR,
		  	  (XInterruptHandler)XV_HdmiTxSS_Hdcp22TimerIntrHandler,
		  	  (void *)&HdmiTxSs);
#endif

#else
  //Register HDMI TX SS Interrupt Handler with Interrupt Controller
  Status |= XIntc_Connect(&Intc,
		  	  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_IRQ_INTR,
		  	  (XInterruptHandler)XV_HdmiTxSS_HdmiTxIntrHandler,
		  	  (void *)&HdmiTxSs);

// HDCP 1.4
#ifdef XPAR_XHDCP_NUM_INSTANCES
  // HDCP 1.4 Cipher interrupt
  Status |= XIntc_Connect(&Intc,
		  	  //XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP_IRQ_INTR,
		  	  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP14_IRQ_INTR,
		  	  (XInterruptHandler)XV_HdmiTxSS_HdcpIntrHandler,
		  	  (void *)&HdmiTxSs);

  // HDCP 1.4 Timer interrupt
  Status |= XIntc_Connect(&Intc,
		  	  //XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP_INTERRUPT_INTR,
		  	  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP14_TIMER_IRQ_INTR,
		  	  (XInterruptHandler)XV_HdmiTxSS_HdcpTimerIntrHandler,
		  	  (void *)&HdmiTxSs);
#endif

// HDCP 2.2
#if (XPAR_XHDCP22_TX_NUM_INSTANCES)
  Status |= XIntc_Connect(&Intc,
          XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP22_TIMER_IRQ_INTR,
          (XInterruptHandler)XV_HdmiTxSS_Hdcp22TimerIntrHandler,
          (void *)&HdmiTxSs);
#endif

#endif

  if (Status == XST_SUCCESS){
#if defined(__arm__)
	  XScuGic_Enable(&Intc,
			  XPAR_FABRIC_V_HDMI_TX_SS_0_IRQ_INTR);
// HDCP 1.4
#ifdef XPAR_XHDCP_NUM_INSTANCES
    // HDCP 1.4 Cipher interrupt
	  XScuGic_Enable(&Intc,
			  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP14_IRQ_INTR);

    // HDCP 1.4 Timer interrupt
    XScuGic_Enable(&Intc,
			  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP14_TIMER_IRQ_INTR);
#endif

// HDCP 2.2
#if (XPAR_XHDCP22_TX_NUM_INSTANCES)
    XScuGic_Enable(&Intc,
        XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP22_TIMER_IRQ_INTR
        );
#endif

#else
	  XIntc_Enable(&Intc,
			  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_IRQ_INTR);

// HDCP 1.4
#ifdef XPAR_XHDCP_NUM_INSTANCES
    // HDCP 1.4 Cipher interrupt
	  XIntc_Enable(&Intc,
			  //XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP_IRQ_INTR
      XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP14_IRQ_INTR);

    // HDCP 1.4 Timer interrupt
    XIntc_Enable(&Intc,
			  //XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP_INTERRUPT_INTR
      XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP14_TIMER_IRQ_INTR);
#endif

// HDCP 2.2
#if (XPAR_XHDCP22_TX_NUM_INSTANCES)
    XIntc_Enable(&Intc,
        XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_TX_SS_0_HDCP22_TIMER_IRQ_INTR
        );
#endif

#endif
  }
  else {
	  xil_printf("ERR:: Unable to register HDMI TX interrupt handler");
      print("HDMI TX SS initialization error\n\r");
	  return XST_FAILURE;
  }

  /* HDMI TX SS callback setup */
  XV_HdmiTxSs_SetCallback(&HdmiTxSs,
		  	  	  	  	  	  XV_HDMITXSS_HANDLER_CONNECT,
		  	  	  	  	  	  TxConnectCallback,
		  	  	  	  	  	  (void *)&HdmiTxSs);
  XV_HdmiTxSs_SetCallback(&HdmiTxSs,
		  	  	  	  	  	  XV_HDMITXSS_HANDLER_VS,
		  	  	  	  	  	  TxVsCallback,
		  	  	  	  	  	  (void *)&HdmiTxSs);
  
  XV_HdmiTxSs_SetCallback(&HdmiTxSs,
		  	  	  	  	  	  XV_HDMITXSS_HANDLER_STREAM_UP,
		  	  	  	  	  	  TxStreamUpCallback,
		  	  	  	  	  	  (void *)&HdmiTxSs);

  // HDCP authentication
  XV_HdmiTxSs_SetCallback(&HdmiTxSs,
                          XV_HDMITXSS_HANDLER_HDCP_AUTHENTICATE,
                          TxHdcpAuthenticatedCallback,
                          (void *)&HdmiTxSs);

  //XV_HdmiTxSs_SetCallback(&HdmiTxSs,
  //	  	  	  	  	  	  	  XV_HDMITXSS_HANDLER_STREAM_DOWN,
  //	  	  	  	  	  	  	  TxStreamDownCallback,
  //	  	  	  	  	  	  	  (void *)&HdmiTxSs);
#endif

#ifdef XPAR_XV_HDMIRXSS_NUM_INSTANCES
  /////
  // Initialize HDMI RX Subsystem
  /////
  /* Get User Edid Info */
  XV_HdmiRxSs_SetEdidParam(&HdmiRxSs, (u8*)&Edid, sizeof(Edid));
  XV_HdmiRxSs_ConfigPtr =
		  XV_HdmiRxSs_LookupConfig(XPAR_V_HDMI_RX_SS_0_V_HDMI_RX_DEVICE_ID);

  if(XV_HdmiRxSs_ConfigPtr == NULL)
  {
	  HdmiRxSs.IsReady = 0;
      return (XST_DEVICE_NOT_FOUND);
  }

  //Initialize top level and all included sub-cores
  Status = XV_HdmiRxSs_CfgInitialize(&HdmiRxSs, XV_HdmiRxSs_ConfigPtr,
		  	  	  	  	  	  	  	  XV_HdmiRxSs_ConfigPtr->BaseAddress);
  if(Status != XST_SUCCESS)
  {
    xil_printf("ERR:: HDMI RX Subsystem Initialization failed %d\r\n", Status);
    return(XST_FAILURE);
  }

  //Register HDMI RX SS Interrupt Handler with Interrupt Controller
#if defined(__arm__)
  Status |= XScuGic_Connect(&Intc,
		  	  XPAR_FABRIC_V_HDMI_RX_SS_0_IRQ_INTR,
		  	  (XInterruptHandler)XV_HdmiRxSS_HdmiRxIntrHandler,
		  	  (void *)&HdmiRxSs);

#ifdef XPAR_XHDCP_NUM_INSTANCES
  // HDCP 1.4 Cipher interrupt
  Status |= XScuGic_Connect(&Intc,
		  	  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP14_IRQ_INTR,
		  	  (XInterruptHandler)XV_HdmiRxSS_HdcpIntrHandler,
		  	  (void *)&HdmiRxSs);

  Status |= XScuGic_Connect(&Intc,
		  	  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP14_TIMER_IRQ_INTR,
		  	  (XInterruptHandler)XV_HdmiRxSS_HdcpTimerIntrHandler,
		  	  (void *)&HdmiRxSs);
#endif
#else
  Status |= XIntc_Connect(&Intc,
		  	  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_IRQ_INTR,
	  		  (XInterruptHandler)XV_HdmiRxSS_HdmiRxIntrHandler,
	  		  (void *)&HdmiRxSs);
#ifdef XPAR_XHDCP_NUM_INSTANCES
  // HDCP 1.4 Cipher interrupt
  Status |= XIntc_Connect(&Intc,
		  	  //XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP_IRQ_INTR,
          XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP14_IRQ_INTR,
	  		  (XInterruptHandler)XV_HdmiRxSS_HdcpIntrHandler,
	  		  (void *)&HdmiRxSs);

  // HDCP 1.4 Timer interrupt
  Status |= XIntc_Connect(&Intc,
		  	  //XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP_INTERRUPT_INTR,
          XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP14_TIMER_IRQ_INTR,
	  		  (XInterruptHandler)XV_HdmiRxSS_HdcpTimerIntrHandler,
	  		  (void *)&HdmiRxSs);
#endif
#endif


  if (Status == XST_SUCCESS){
#if defined(__arm__)
	  XScuGic_Enable(&Intc,
			  XPAR_FABRIC_V_HDMI_RX_SS_0_IRQ_INTR);
#ifdef XPAR_XHDCP_NUM_INSTANCES
	  XScuGic_Enable(&Intc,
			  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP14_IRQ_INTR);
	  XScuGic_Enable(&Intc,
			  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP14_TIMER_IRQ_INTR);
#endif
#else
	  XIntc_Enable(&Intc,
			  XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_IRQ_INTR);
#ifdef XPAR_XHDCP_NUM_INSTANCES
	  // HDCP 1.4 Cipher interrupt
    XIntc_Enable(&Intc,
			  //XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP_IRQ_INTR
        XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP14_IRQ_INTR);

    // HDCP 1.4 Timer interrupt
    XIntc_Enable(&Intc,
			  //XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP_INTERRUPT_INTR
      XPAR_MICROBLAZE_SS_AXI_INTC_0_V_HDMI_RX_SS_0_HDCP14_TIMER_IRQ_INTR);
#endif
#endif
  }
  else {
	  xil_printf("ERR:: Unable to register HDMI RX interrupt handler");
      print("HDMI RX SS initialization error\n\r");
	  return XST_FAILURE;
  }

  /* RX callback setup */
  XV_HdmiRxSs_SetCallback(&HdmiRxSs,
		  	  	  	  	  	  XV_HDMIRXSS_HANDLER_CONNECT,
		  	  	  	  	  	  RxConnectCallback,
		  	  	  	  	  	  (void *)&HdmiRxSs);
  XV_HdmiRxSs_SetCallback(&HdmiRxSs,
		  	  	  	  	  	  XV_HDMIRXSS_HANDLER_AUX,
		  	  	  	  	  	  RxAuxCallback,
		  	  	  	  	  	  (void *)&HdmiRxSs);
  XV_HdmiRxSs_SetCallback(&HdmiRxSs,
		  	  	  	  	  	  XV_HDMIRXSS_HANDLER_AUD,
		  	  	  	  	  	  RxAudCallback,
		  	  	  	  	  	  (void *)&HdmiRxSs);
  XV_HdmiRxSs_SetCallback(&HdmiRxSs,
		  	  	  	  	  	  XV_HDMIRXSS_HANDLER_LNKSTA,
		  	  	  	  	  	  RxLnkStaCallback,
		  	  	  	  	  	  (void *)&HdmiRxSs);
  //XV_HdmiRxSs_SetCallback(&HdmiRxSs,
  //	  	  	  	  	  	  	  XV_HDMIRXSS_HANDLER_DDC,
  //	  	  	  	  	  	  	  RxDdcCallback,
  //	  	  	  	  	  	  	  (void *)&HdmiRxSs);
  XV_HdmiRxSs_SetCallback(&HdmiRxSs,
		  	  	  	  	  	  XV_HDMIRXSS_HANDLER_STREAM_DOWN,
		  	  	  	  	  	  RxStreamDownCallback,
		  	  	  	  	  	  (void *)&HdmiRxSs);
  XV_HdmiRxSs_SetCallback(&HdmiRxSs,
		  	  	  	  	  	  XV_HDMIRXSS_HANDLER_STREAM_INIT,
		  	  	  	  	  	  RxStreamInitCallback,
		  	  	  	  	  	  (void *)&HdmiRxSs);
  XV_HdmiRxSs_SetCallback(&HdmiRxSs,
		  	  	  	  	  	  XV_HDMIRXSS_HANDLER_STREAM_UP,
		  	  	  	  	  	  RxStreamUpCallback,
		  	  	  	  	  	  (void *)&HdmiRxSs);
  // YH -- Is it for HDCP2.2 only?
  // HDCP authentication
  XV_HdmiRxSs_SetCallback(&HdmiRxSs,
		                  XV_HDMIRXSS_HANDLER_HDCP_AUTHENTICATE,
                          RxHdcpAuthenticatedCallback,
                          (void *)&HdmiRxSs);							  
#endif

    /////
    // Initialize Video PHY
    // The GT needs to be initialized after the HDMI RX and TX.
    // The reason for this is the GtRxInitStartCallback
    // calls the RX stream down callback.
    /////

    XVphyCfgPtr = XVphy_LookupConfig(XPAR_VID_PHY_CONTROLLER_0_DEVICE_ID);
    if (XVphyCfgPtr == NULL) {
      print("Video PHY device not found\n\r\r");
      return XST_FAILURE;
    }

    /* Register VPHY Interrupt Handler */
#if defined(__arm__)
    Status = XScuGic_Connect(&Intc,
    			XPAR_FABRIC_VID_PHY_CONTROLLER_0_IRQ_INTR,
    			(XInterruptHandler)XVphy_InterruptHandler,
    			(void *)&Vphy);
#else
  Status = XIntc_Connect(&Intc,
		                 XPAR_MICROBLAZE_SS_AXI_INTC_0_VID_PHY_CONTROLLER_0_IRQ_INTR,
  	  		             (XInterruptHandler)XVphy_InterruptHandler,
  	  		             (void *)&Vphy);
#endif
    if (Status != XST_SUCCESS) {
      print("HDMI VPHY Interrupt Vec ID not found!\n\r");
      return XST_FAILURE;
    }

    /* Initialize HDMI VPHY */
    Status = XVphy_HdmiInitialize(&Vphy, 0,
    			XVphyCfgPtr, XPAR_CPU_CORE_CLOCK_FREQ_HZ);
    if (Status != XST_SUCCESS) {
      print("HDMI VPHY initialization error\n\r");
      return XST_FAILURE;
    }

    /* Enable VPHY Interrupt */
#if defined(__arm__)
  XScuGic_Enable(&Intc,
    		XPAR_FABRIC_VID_PHY_CONTROLLER_0_IRQ_INTR);
#else
    XIntc_Enable(&Intc,
    		XPAR_MICROBLAZE_SS_AXI_INTC_0_VID_PHY_CONTROLLER_0_IRQ_INTR);
#endif

#ifdef XPAR_XV_HDMITXSS_NUM_INSTANCES
    /* VPHY callback setup */
    XVphy_SetHdmiCallback(&Vphy,
    						XVPHY_HDMI_HANDLER_TXINIT,
    						VphyHdmiTxInitCallback,
    						(void *)&Vphy);
    XVphy_SetHdmiCallback(&Vphy,
    						XVPHY_HDMI_HANDLER_TXREADY,
    						VphyHdmiTxReadyCallback,
    						(void *)&Vphy);
#endif
#ifdef XPAR_XV_HDMIRXSS_NUM_INSTANCES
    XVphy_SetHdmiCallback(&Vphy,
    						XVPHY_HDMI_HANDLER_RXINIT,
    						VphyHdmiRxInitCallback,
    						(void *)&Vphy);
    XVphy_SetHdmiCallback(&Vphy,
    						XVPHY_HDMI_HANDLER_RXREADY,
    						VphyHdmiRxReadyCallback,
    						(void *)&Vphy);
#endif

#ifdef XPAR_XV_TPG_NUM_INSTANCES
    /* Initialize GPIO for Tpg Reset */
    Gpio_Tpg_resetn_ConfigPtr =
    		XGpio_LookupConfig(XPAR_TPG_SS_AXI_GPIO_0_DEVICE_ID);

    if(Gpio_Tpg_resetn_ConfigPtr == NULL)
    {
    	Gpio_Tpg_resetn.IsReady = 0;
        return (XST_DEVICE_NOT_FOUND);
    }

    Status = XGpio_CfgInitialize(&Gpio_Tpg_resetn,
    					Gpio_Tpg_resetn_ConfigPtr,
    					Gpio_Tpg_resetn_ConfigPtr->BaseAddress);
    if(Status != XST_SUCCESS)
    {
        xil_printf("ERR:: GPIO for TPG Reset ");
        xil_printf("Initialization failed %d\r\n", Status);
        return(XST_FAILURE);
    }

    ResetTpg();

    Tpg_ConfigPtr = XV_tpg_LookupConfig(XPAR_TPG_SS_V_TPG_0_DEVICE_ID);
    if(Tpg_ConfigPtr == NULL)
    {
    	Tpg.IsReady = 0;
        return (XST_DEVICE_NOT_FOUND);
    }

    Status = XV_tpg_CfgInitialize(&Tpg,
    				Tpg_ConfigPtr, Tpg_ConfigPtr->BaseAddress);
    if(Status != XST_SUCCESS)
    {
        xil_printf("ERR:: TPG Initialization failed %d\r\n", Status);
        return(XST_FAILURE);
    }
#endif

/* Video Overlay */
#ifdef XPAR_XV_OVERLAY_NUM_INSTANCES
    // Initialize Video Overlay
    Overlay_ConfigPtr = XV_Overlay_LookupConfig(XPAR_XV_OVERLAY_SS_V_OVERLAY_0_DEVICE_ID);
    if(Overlay_ConfigPtr == NULL)
    {
      Overlay.IsReady = 0;
        return (XST_DEVICE_NOT_FOUND);
    }

    Status = XV_Overlay_CfgInitialize(&Overlay, Overlay_ConfigPtr, Overlay_ConfigPtr->BaseAddress);
    if (Status != XST_SUCCESS)
    {
        xil_printf("ERR:: Overlay Initialization failed %d\r\n", Status);
        return(XST_FAILURE);
    }
#endif

  print("---------------------------------\r\n");

  /* Enable exceptions. */
  Xil_AssertSetCallback((Xil_AssertCallback) Xil_AssertCallbackRoutine);
  Xil_ExceptionEnable();


  /* Start with 1080p colorbar */
  EnableColorBar(&Vphy,
                &HdmiTxSs,
                XVIDC_VM_1920x1080_60_P,
                XVIDC_CSF_RGB,
                XVIDC_BPC_8);

  // Initialize menu
  XHdmi_MenuInitialize(&HdmiMenu, UART_BASEADDR);

  /* Main loop */
  do {

#if defined (XPAR_XHDCP_NUM_INSTANCES) || defined (XPAR_XHDCP22_RX_NUM_INSTANCES) || defined (XPAR_XHDCP22_TX_NUM_INSTANCES)
    /* Poll HDCP */
    XV_HdmiTxSs_HdcpPoll(&HdmiTxSs);
    XV_HdmiRxSs_HdcpPoll(&HdmiRxSs);
#endif

    if (StartTxAfterRxFlag) {
      StartTxAfterRx();
    }

    else if (TxRestartColorbar) {
      TxRestartColorbar = (FALSE);    // Clear flag
      HdmiTxSsVidStreamPtr = XV_HdmiTxSs_GetVideoStream(&HdmiTxSs);
      EnableColorBar(&Vphy,
                     &HdmiTxSs,
                     HdmiTxSsVidStreamPtr->VmId,
                     HdmiTxSsVidStreamPtr->ColorFormatId,
                     HdmiTxSsVidStreamPtr->ColorDepth);
    }

    // Overlay
  #ifdef XPAR_XV_OVERLAY_NUM_INSTANCES
    XV_Overlay_SetDisplay(&Overlay, &HdmiTxSs, &HdmiRxSs);
  #endif
    
    // HDMI menu
    XHdmi_MenuProcess(&HdmiMenu);
  
  } while (1);

  return 0;
}

//
//void SendVSInfoframe(void)
//{
//	XHdmi_VSIF VSIF;
//
//	VSIF.Version = 0x1;
//	VSIF.IEEE_ID = 0xC03;
//
//	if (XVidC_IsStream3D(&HdmiTx.Stream.Video)) {
//		VSIF.Format = XHDMI_VSIF_VF_3D;
//		VSIF.Info_3D.Stream = HdmiTx.Stream.Video.Info_3D;
//		VSIF.Info_3D.MetaData.IsPresent = FALSE;
//	}
//	else if (HdmiTx.Stream.Video.VmId == XVIDC_VM_3840x2160_24_P ||
//			 HdmiTx.Stream.Video.VmId == XVIDC_VM_3840x2160_25_P ||
//			 HdmiTx.Stream.Video.VmId == XVIDC_VM_3840x2160_30_P ||
//			 HdmiTx.Stream.Video.VmId == XVIDC_VM_4096x2160_24_P) {
//		VSIF.Format = XHDMI_VSIF_VF_EXTRES;
//
//		/* Set HDMI VIC */
//		switch(HdmiTx.Stream.Video.VmId) {
//			case XVIDC_VM_4096x2160_24_P :
//				VSIF.HDMI_VIC = 4;
//				break;
//			case XVIDC_VM_3840x2160_24_P :
//				VSIF.HDMI_VIC = 3;
//				break;
//			case XVIDC_VM_3840x2160_25_P :
//				VSIF.HDMI_VIC = 2;
//				break;
//			case XVIDC_VM_3840x2160_30_P :
//				VSIF.HDMI_VIC = 1;
//				break;
//			default :
//				break;
//		}
//	}
//	else {
//		VSIF.Format = XHDMI_VSIF_VF_NOINFO;
//	}
//
//	XHdmi_VSIF_GeneratePacket(&VSIF,(XV_Hdmitx_Aux *)&HdmiTx.Aux);
//
//	XHdmiTx_AuxSend(&HdmiTx);
//}

