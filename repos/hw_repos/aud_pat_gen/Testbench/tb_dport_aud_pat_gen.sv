/*
 * Copyright (c) 2014 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 *
 * This file contains the testbench of the audio generator.
 *
 * MODIFICATION HISTORY:
 *
 * Ver   Who Date         Changes
 * ----- --- ----------   -----------------------------------------------
 * 1.00  hf  2014/10/21   First release
 * 1.03  hf  2015/01/06   Added audio input interface (not tested)
 *
 *****************************************************************************/

`timescale 1 ps / 1 ps

`define AUD_PAT_PING     2'b10
`define AUD_PAT_SILENCE  2'b00

`define AUD_RATE_32k0    4'h0
`define AUD_RATE_44k1    4'h1
`define AUD_RATE_48k0    4'h2
`define AUD_RATE_88k2    4'h3
`define AUD_RATE_96k0    4'h4
`define AUD_RATE_176k4   4'h5
`define AUD_RATE_192k0   4'h6

`define SAMPLE_RATE      44100
`define FS512            (`SAMPLE_RATE * 512)
`define FS512_PERIOD     44288 // ps
`define OFFSET_CNTR_44k1 (`SAMPLE_RATE / 4)

`define AXI4_RESP_OKAY   2'b00
`define AXI4_RESP_EXOKAY 2'b01
`define AXI4_RESP_SLVERR 2'b10
`define AXI4_RESP_DECERR 2'b11

module tb_dport_aud_pat_gen (
);

  reg          aud_aclk;
  reg          aud_aresetn;

  // AXI4 lite control bus 
  // - Write address
  wire         m_axil_awvalid;
  wire         m_axil_awready;
  wire  [31:0] m_axil_awaddr;
  wire  [ 2:0] m_axil_awprot;
  // - Write data
  wire         m_axil_wvalid;
  wire         m_axil_wready;
  wire  [31:0] m_axil_wdata;
  wire  [ 3:0] m_axil_wstrb;
  // - Write response
  wire         m_axil_bvalid;
  wire         m_axil_bready;
  wire  [ 1:0] m_axil_bresp;
  // - Read address   
  wire         m_axil_arvalid;
  wire         m_axil_arready;
  wire  [31:0] m_axil_araddr;
  wire  [ 2:0] m_axil_arprot;
  // - Read data/response
  wire         m_axil_rvalid;
  wire         m_axil_rready; 
  wire  [31:0] m_axil_rdata;
  wire  [ 1:0] m_axil_rresp;

  // AXI4 streaming bus with audio data
  wire  [31:0] s_axis_aud_pattern_tdata;
  wire  [ 2:0] s_axis_aud_pattern_tid;
  wire         s_axis_aud_pattern_tvalid;
  wire         s_axis_aud_pattern_tready;

  // Received audio stream by the AXI-S BFM
  reg   [ 3:0] rcvd_id;
  reg   [ 0:0] rcvd_dest;
  reg   [31:0] rcvd_data;
  reg   [ 3:0] rcvd_strb;
  reg   [ 3:0] rcvd_keep;
  reg          rcvd_last;
  reg   [ 0:0] rcvd_user;

  // Decoded audio data as received by the AXI-S BFM
  reg          par;
  int          cnt_frame;
  int          cnt_subframe;
  int          dec_chan;
  reg  [ 23:0] dec_audio       [1:8];
  reg          dec_audio_valid [1:8];
  reg  [0:191] dec_userdata    [1:8];
  reg  [0:191] dec_chanstat    [1:8];
  
  
  //////////////////////////////////////////////////////////////////////////////
  // Device Under Test
  //////////////////////////////////////////////////////////////////////////////
  aud_pat_gen_top aud_pat_gen_inst (
       // AXI4-Lite bus (cpu control)
       .axi_aclk                    (aud_aclk),
       .axi_aresetn                 (aud_aresetn),
       // Write address             
       .axi_awvalid                 (m_axil_awvalid),
       .axi_awready                 (m_axil_awready),
       .axi_awaddr                  (m_axil_awaddr),
       .axi_awprot                  (m_axil_awprot),
       // Write data                
       .axi_wvalid                  (m_axil_wvalid),
       .axi_wready                  (m_axil_wready),
       .axi_wdata                   (m_axil_wdata),
       .axi_wstrb                   (m_axil_wstrb),
       // Write response            
       .axi_bvalid                  (m_axil_bvalid),
       .axi_bready                  (m_axil_bready),
       .axi_bresp                   (m_axil_bresp),
       // Read address              
       .axi_arvalid                 (m_axil_arvalid),
       .axi_arready                 (m_axil_arready),
       .axi_araddr                  (m_axil_araddr),
       .axi_arprot                  (m_axil_arprot),
       // Read data/response        
       .axi_rvalid                  (m_axil_rvalid),
       .axi_rready                  (m_axil_rready),
       .axi_rdata                   (m_axil_rdata),
       .axi_rresp                   (m_axil_rresp),
       // Audio clock (must be 512 times audio sample rate)
       .aud_clk                     (aud_aclk),
      
       // Audio In
       .axis_aud_pattern_tdata_in   (32'b0),
       .axis_aud_pattern_tid_in     (3'b0),    
       .axis_aud_pattern_tvalid_in  (1'b0),
       .axis_aud_pattern_tready_out (),
                                    
       // AXI-Streaming bus (audio data)
       .axis_clk                    (aud_aclk),
       .axis_resetn                 (aud_aresetn),
       .axis_aud_pattern_tdata_out  (s_axis_aud_pattern_tdata),
       .axis_aud_pattern_tid_out    (s_axis_aud_pattern_tid),
       .axis_aud_pattern_tvalid_out (s_axis_aud_pattern_tvalid),
       .axis_aud_pattern_tready_in  (s_axis_aud_pattern_tready)
       );

  
  //////////////////////////////////////////////////////////////////////////////
  // AXI-Lite Master Bus Functional Model
  //////////////////////////////////////////////////////////////////////////////
  m_axi_lite_bfm axil_master_bfm (
       .m_axi_lite_aclk             (aud_aclk),
       .m_axi_lite_aresetn          (aud_aresetn),
       // Write address             
       .m_axi_lite_awvalid          (m_axil_awvalid),
       .m_axi_lite_awready          (m_axil_awready),
       .m_axi_lite_awaddr           (m_axil_awaddr),
       .m_axi_lite_awprot           (m_axil_awprot),
       // Write data                
       .m_axi_lite_wvalid           (m_axil_wvalid),
       .m_axi_lite_wready           (m_axil_wready),
       .m_axi_lite_wdata            (m_axil_wdata),
       .m_axi_lite_wstrb            (m_axil_wstrb),
       // Write response            
       .m_axi_lite_bvalid           (m_axil_bvalid),
       .m_axi_lite_bready           (m_axil_bready),
       .m_axi_lite_bresp            (m_axil_bresp),
       // Read address              
       .m_axi_lite_arvalid          (m_axil_arvalid),
       .m_axi_lite_arready          (m_axil_arready),
       .m_axi_lite_araddr           (m_axil_araddr),
       .m_axi_lite_arprot           (m_axil_arprot),
       // Read data/response        
       .m_axi_lite_rvalid           (m_axil_rvalid),
       .m_axi_lite_rready           (m_axil_rready),
       .m_axi_lite_rdata            (m_axil_rdata),
       .m_axi_lite_rresp            (m_axil_rresp)
       );

  
  //////////////////////////////////////////////////////////////////////////////
  // AXI-Streaming Slave Bus Functional Model
  //////////////////////////////////////////////////////////////////////////////
  s_axi_streaming_bfm aud_axis_slave_bfm (
       .s_axis_aclk                 (aud_aclk),
       .s_axis_aresetn              (aud_aresetn),
       .s_axis_tvalid               (s_axis_aud_pattern_tvalid),
       .s_axis_tready               (s_axis_aud_pattern_tready),
       .s_axis_tdata                (s_axis_aud_pattern_tdata),
       .s_axis_tstrb                (4'hF),                 // Not used
       .s_axis_tkeep                (4'hF),                 // Not used
       .s_axis_tlast                (1'b0),                 // Not used
       .s_axis_tid                  (s_axis_aud_pattern_tid)
       );

  
  //////////////////////////////////////////////////////////////////////////////
  // Audio and stream clock generation
  //////////////////////////////////////////////////////////////////////////////
  initial begin
    aud_aclk = 1'b0;
    forever #(`FS512_PERIOD / 2)
      aud_aclk = ~aud_aclk;
  end

  
  //////////////////////////////////////////////////////////////////////////////
  // Helper tasks for register reads and writes
  //////////////////////////////////////////////////////////////////////////////
  task check_wr_response(input [1:0] response);
    assert (response == `AXI4_RESP_OKAY)
      begin
      end
    else
      begin
        $error("Register write failed: incorrect AXI4 response received: %b, expected %b.\n", 
               response, `AXI4_RESP_OKAY);
      end
  endtask // check_wr_response

  task write_reg(input [7:0] address, input [31:0] data);
    reg response;
    axil_master_bfm.cdn_axi4_lite_master_bfm_inst.WRITE_BURST(
        address,      // input  ADDR     (audio control)
        3'b010,       // input  PROT     (normal non-secure data)
        data,         // input  DATA     (audio reset)
        4,            // input  DATASIZE (4 bytes)
        response      // output RESPONSE
        );
    check_wr_response(response);
  endtask // write_reg

  task write_reg_concurrent(input [7:0] address, input [31:0] data);
    reg response;
    axil_master_bfm.cdn_axi4_lite_master_bfm_inst.WRITE_BURST_CONCURRENT(
        address,      // input  ADDR     (audio control)
        3'b010,       // input  PROT     (normal non-secure data)
        data,         // input  DATA     (audio reset)
        4,            // input  DATASIZE (4 bytes)
        response      // output RESPONSE
        );
    check_wr_response(response);
  endtask // write_reg_concurrent

  task write_reg_datafirst(input [7:0] address, input [31:0] data);
    reg response;
    fork
      axil_master_bfm.cdn_axi4_lite_master_bfm_inst.SEND_WRITE_DATA(
        4'b1111,      // input STROBE
        data          // input  DATA
        );
      begin
        #(10*`FS512_PERIOD);
        @(posedge(aud_aclk));
        axil_master_bfm.cdn_axi4_lite_master_bfm_inst.SEND_WRITE_ADDRESS(
          address,    // input  ADDR     (channel status 0)
          3'b010      // input  PROT     (normal non-secure data)
          );
      end
    join
    axil_master_bfm.cdn_axi4_lite_master_bfm_inst.RECEIVE_WRITE_RESPONSE(
        response      // output RESPONSE
        );
    check_wr_response(response);
  endtask // write_reg_strb
  
  task write_reg_strobe(input [7:0] address, input [31:0] data, input [3:0] strobe);
    reg response;
    axil_master_bfm.cdn_axi4_lite_master_bfm_inst.SEND_WRITE_ADDRESS(
        address,      // input  ADDR     (channel status 0)
        3'b010        // input  PROT     (normal non-secure data)
        );
    axil_master_bfm.cdn_axi4_lite_master_bfm_inst.SEND_WRITE_DATA(
        strobe,       // input STROBE
        data          // input  DATA
        );  
    axil_master_bfm.cdn_axi4_lite_master_bfm_inst.RECEIVE_WRITE_RESPONSE(
        response      // output RESPONSE
        );
    check_wr_response(response);
  endtask // write_reg_strb

  task check_rd_response(input [1:0] response);
    assert (response == `AXI4_RESP_OKAY)
      begin
      end
    else
      begin
        $error("Register read failed: incorrect AXI4 response received: %b, expected %b.\n", 
               response, `AXI4_RESP_OKAY);
      end
  endtask // check_rd_response

  task check_rd_data(input [31:0] data, input [31:0] expected);
    assert (data == expected)
      begin
      end
    else
      begin
        $error("Incorrect data read from register: %h, expected %h.\n",
               data, expected);
      end
  endtask // checkdata

  task read_reg_check(input [7:0] address, input [31:0] expected);
    reg [31:0] data;
    reg [ 1:0] response;
    axil_master_bfm.cdn_axi4_lite_master_bfm_inst.READ_BURST(
        address,      // input  ADDR     (channel status 0)
        3'b010,       // input  PROT     (normal non-secure data)
        data,         // output DATA
        response      // output RESPONSE
        );
    check_rd_response(response);
    check_rd_data(data, expected);
  endtask // read_reg_check
  
  
  //////////////////////////////////////////////////////////////////////////////
  // Control of the test
  //////////////////////////////////////////////////////////////////////////////
  initial begin
    aud_aresetn       = 1'b0;
    #100_000;
    @(posedge aud_aclk)
      aud_aresetn     = 1'b1;
    #100_000;
    @(posedge aud_aclk);
    // Disable printing of info messages
    axil_master_bfm.cdn_axi4_lite_master_bfm_inst.set_channel_level_info(0);
    axil_master_bfm.cdn_axi4_lite_master_bfm_inst.set_function_level_info(0);
    // Reset the audio generator (will auto clear)
    $display("%t: Resetting the audio generator.\n", $time);
    write_reg(8'h00,                    // address  (audio control)
              32'h00000001              // data     (audio reset)
              );
    
    // Test register reads and writes
    $display("%t: Testing register write and read.\n", $time);
    write_reg(8'hA0,                    // address  (channel status 0)
              32'h01234567              // data
              );
    read_reg_check(8'hA0,               // address  (channel status 0)
                   32'h01234567         // expected
                   );
    write_reg_concurrent(8'hA0,         // address  (channel status 0)
                         32'h89ABCDEF   // data
                         );
    read_reg_check(8'hA0,               // address  (channel status 0)
                   32'h89ABCDEF         // expected
                   );
    write_reg_datafirst(8'hA0,          // address  (channel status 0)
                        32'h11223344    // data
                        );
    read_reg_check(8'hA0,               // address  (channel status 0)
                   32'h11223344         // expected
                   );
    
    // Test byte enables
    $display("%t: Testing byte enables.\n", $time);
    write_reg_strobe(8'hA0,             // address  (channel status 0)
                     32'hAABBCCDD,      // data
                     4'b0001            // strobe
                     );
    read_reg_check(8'hA0,               // address  (channel status 0)
                   32'h112233DD         // expected
                   );
    write_reg_strobe(8'hA0,             // address  (channel status 0)
                     32'hAABBCCEE,      // data
                     4'b0010            // strobe
                     );  
    read_reg_check(8'hA0,               // address  (channel status 0)
                   32'h1122CCDD         // expected
                   );
    write_reg_strobe(8'hA0,             // address  (channel status 0)
                     32'hAABBDDEE,      // data
                     4'b0100            // strobe
                     );  
    read_reg_check(8'hA0,               // address  (channel status 0)
                   32'h11BBCCDD         // expected
                   );
    write_reg_strobe(8'hA0,             // address  (channel status 0)
                     32'hAACCDDEE,      // data
                     4'b1000            // strobe
                     );  
    read_reg_check(8'hA0,               // address  (channel status 0)
                   32'hAABBCCDD         // expected
                   );

    // Set the audio configuration
    $display("%t: Starting audio.\n", $time);
    // Start must be before setting audio configuration!
    write_reg(8'h00,                    // address  (audio control)
              32'h00000002              // data     (audio start)
              );
    $display("%t: Setting audio configuration.\n", $time);
    write_reg(8'h04,                    // address  (audio config)
              32'h00000801              // data     (8 channels, 
                                        //           44k1 sample rate)
              );
    write_reg(8'h10,                    // address  (channel 1 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h20,                    // address  (channel 2 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h30,                    // address  (channel 3 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h40,                    // address  (channel 4 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h50,                    // address  (channel 5 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h60,                    // address  (channel 6 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h70,                    // address  (channel 7 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h80,                    // address  (channel 8 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h10,                    // address  (channel 1 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h20,                    // address  (channel 2 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h30,                    // address  (channel 3 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h40,                    // address  (channel 4 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h50,                    // address  (channel 5 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h60,                    // address  (channel 6 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h70,                    // address  (channel 7 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h80,                    // address  (channel 8 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    $display("%t: Changing audio configuration.\n", $time);
    write_reg(8'h04,                    // address  (audio config)
              32'h00000401              // data     (4 channels, 
                                        //           44k1 sample rate)
              );
    #10_000_000;
    write_reg(8'h10,                    // address  (channel 1 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h20,                    // address  (channel 2 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h30,                    // address  (channel 3 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h40,                    // address  (channel 4 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h50,                    // address  (channel 5 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h60,                    // address  (channel 6 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h70,                    // address  (channel 7 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h80,                    // address  (channel 8 control)
              32'h00000002              // data     (ping audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h10,                    // address  (channel 1 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h20,                    // address  (channel 2 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h30,                    // address  (channel 3 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h40,                    // address  (channel 4 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h50,                    // address  (channel 5 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h60,                    // address  (channel 6 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h70,                    // address  (channel 7 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    write_reg(8'h80,                    // address  (channel 8 control)
              32'h00000000              // data     (silence audio pattern)
              );
    #1_000_000_000;
    $stop;
  end // initial begin

  
  //////////////////////////////////////////////////////////////////////////////
  // Receiving data from the AXI-streaming bus
  //////////////////////////////////////////////////////////////////////////////
  initial begin
    $timeformat(-9, 0, "ns", 5);
    // Initialize captures audio data
    par             =   1'b0;
    cnt_frame       =      0;
    cnt_subframe    =    191;
    dec_audio       = '{8{24'b0}};
    dec_audio_valid = '{8{1'b0}};
    dec_userdata    = '{8{192'b0}};
    dec_chanstat    = '{8{192'b0}};
    
    
    // Disable timeout (this is a slow stream)
    aud_axis_slave_bfm.cdn_axi4_streaming_slave_bfm_inst.set_response_timeout(0);
    // Disable printing of info messages
    aud_axis_slave_bfm.cdn_axi4_streaming_slave_bfm_inst.set_channel_level_info(0);
    // Disable messages about reset value of tvalid
    aud_axis_slave_bfm.cdn_axi4_streaming_slave_bfm_inst.set_disable_reset_value_checks(1);
    
    forever
      begin
        // Capture data from the DUT
        aud_axis_slave_bfm.cdn_axi4_streaming_slave_bfm_inst.RECEIVE_TRANSFER(
             0,          // input  ID
             1'b0,       // input  IDValid
             0,          // input  DEST
             1'b0,       // input  DESTValid
             rcvd_id,    // output ID   : audio channel
             rcvd_dest,  // output DEST : ignore
             rcvd_data,  // output DATA : AES3 or S/PDIF formatted audio data
             rcvd_strb,  // output STRB : ignore
             rcvd_keep,  // output KEEP : ignore
             rcvd_last,  // output LAST : ignore
             rcvd_user   // output USER : ignore
            );
        // Check the parity bit, should be even parity over bits 31:4
        par = ^rcvd_data[31:4];
        assert (par == 0)
          begin
          end
        else
          begin
            $error("Parity error in audio data for channel %d\n", rcvd_id);
          end

        // Check subframe preamble
        case (rcvd_data[3:0])
          4'h1 : // Z
            begin
              // Start of audio frame
              if (rcvd_id == 4'h0) 
                begin
                  $info("Start of audio frame (Z) #%d\n", cnt_frame + 1);
                  //$display("Channel status 1 = %h\n", dec_chanstat[1]);
                  //$display("Channel status 2 = %h\n", dec_chanstat[2]);
                  //$display("Channel status 3 = %h\n", dec_chanstat[3]);
                  //$display("Channel status 4 = %h\n", dec_chanstat[4]);
                  //$display("Channel status 5 = %h\n", dec_chanstat[5]);
                  //$display("Channel status 6 = %h\n", dec_chanstat[6]);
                  //$display("Channel status 7 = %h\n", dec_chanstat[7]);
                  //$display("Channel status 8 = %h\n", dec_chanstat[8]);
                  assert (cnt_subframe == 191)
                    begin
                    end
                  else
                    begin
                      $error("Start of audio frame before the end of the last frame\n");
                    end
                  cnt_frame++;
                  cnt_subframe = 0;
                  // Reset user data and channel status for easier viewing
                  dec_userdata = '{8{192'b0}};
                  dec_chanstat = '{8{192'b0}};
                end
              assert (rcvd_id[0] == 1'b0)
                begin
                end
              else
                begin
                  $error("Start of audio frame (Z) for incorrect audio channel %d\n", rcvd_id);
                end
            end
          4'h2 : // X
            begin
              assert (rcvd_id[0] == 1'b0)
                begin
                  if (rcvd_id == 4'h0)
                    begin
                      cnt_subframe++;
                      assert (cnt_subframe <= 191)
                        begin
                        end
                      else
                        begin
                          $error("Expected start of audio frame (Z) here, but got start of subframe (X)\n");
                          cnt_subframe = 0;
                        end
                    end
                end
              else
                begin
                  $error("Audio subframe (X) for incorrect audio channel %d\n", rcvd_id);
                end
            end
          4'h3 : // Y
            begin
              assert (rcvd_id[0] == 1'b1)
                begin
                end
              else
                begin
                  $error("Audio subframe (Y) for incorrect audio channel %d\n", rcvd_id);
                end
            end
          default:
            begin
              $error("Incorrect audio subframe 0x%h\n", rcvd_data[3:0]);
            end
        endcase // case (rcvd_data[3:0])
        
        // Capture audio data
        dec_chan                          = rcvd_id + 1;
        dec_audio_valid[dec_chan]         = rcvd_data[28];
        if (rcvd_data[28] == 1'b0) // Validity (0 == valid)
          begin
            dec_audio[dec_chan]           = rcvd_data[27:4];
          end
        else
          begin
            // Audio data not valid : mute audio
            dec_audio[dec_chan]           = 24'b0;
          end
        dec_userdata[dec_chan][cnt_subframe] = rcvd_data[29]; // User data
        dec_chanstat[dec_chan][cnt_subframe] = rcvd_data[30]; // Channel status

      end // forever begin
  end // initial begin
  
endmodule // tb_dport_aud_pat_gen
