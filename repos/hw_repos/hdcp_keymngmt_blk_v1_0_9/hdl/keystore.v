`timescale 1ns/10ps

module       keystore  
#(   
   parameter   BRAM_NO        = 8,
//   parameter   INIT_FILE      = "dev_keys.dat",
//   parameter   INIT_FILE      = "",
   parameter   TABLE_NO       = 64,
   parameter   RAM_DEPTH      = TABLE_NO*BRAM_NO,
   parameter   TABLE_ADD_SIZE = $clog2(BRAM_NO),
   parameter   TABLE_ROW_SIZE = $clog2(TABLE_NO),   
   parameter   VERSION        = 32'h00010007,
   parameter   AXIS_ADD_LSB   = 2,
   parameter   AXIS_ADD_SIZE  = 4
)
(
    // AXI4-Lite interface
   input  wire                         s_axi_aclk   ,
   input  wire                         s_axi_aresetn,
   input  wire [31:0]                  s_axi_awaddr ,
   input  wire [2:0]                   s_axi_awprot , 
   input  wire                         s_axi_awvalid,
   output wire                         s_axi_awready,
   input  wire [31:0]                  s_axi_wdata  ,
   input  wire [3:0]                   s_axi_wstrb  , 
   input  wire                         s_axi_wvalid ,
   output wire                         s_axi_wready ,
   output wire [1:0]                   s_axi_bresp  ,
   output wire                         s_axi_bvalid ,
   input  wire                         s_axi_bready ,
   input  wire [31:0]                  s_axi_araddr ,
   input  wire [2:0]                   s_axi_arprot ,
   input  wire                         s_axi_arvalid,
   output wire                         s_axi_arready,
   output reg  [31:0]                  s_axi_rdata  ,
   output wire [1:0]                   s_axi_rresp  ,
   output wire                         s_axi_rvalid ,
   input  wire                         s_axi_rready ,

   input wire                          m_axis_aclk,            //AXI ACLK
   input wire                          m_axis_aresetn,         // AXI Reset
   
   output  wire [63:0]                 m_axis_keys_tdata,
   output  wire                        m_axis_keys_tlast,
   output  wire [7:0]                  m_axis_keys_tuser,
   output  wire                        m_axis_keys_tvalid,
   input   wire                        m_axis_keys_tready,
   
   input   wire                        start_key_transmit,
    // Key Selection register 
   input  wire [2:0]                   reg_key_sel
  );


   reg   [TABLE_ROW_SIZE-1:0]          dev_addr;
   reg                                 ena;
   wire                                lastkey;
   reg   [7:0]                         dev_addr_clkd;
   wire  [$clog2(RAM_DEPTH-1)-1:0]     w_addr2mem_a;
   wire  [$clog2(RAM_DEPTH-1)-1:0]     w_addr2mem_b;
   wire  [63:0]                        w_key_data_a_out;
   wire                                w_s2m_axis_keys_tvalid;
   
   assign lastkey                = ((dev_addr == 41) && !start_key_transmit) ? 1'd1 : 1'd0;
   assign m_axis_keys_tuser      = dev_addr_clkd;
   assign m_axis_keys_tvalid     = (dev_addr_clkd >= 0) && (dev_addr_clkd <= 40) && 
                                    !start_key_transmit && w_s2m_axis_keys_tvalid;
   assign m_axis_keys_tlast      = lastkey;
   assign w_addr2mem_b           = m_axis_keys_tready ? {reg_key_sel,dev_addr} : {reg_key_sel,dev_addr_clkd[TABLE_ROW_SIZE-1:0]};
   
   
   // AXI4-Lite interface
   //Registers parameters
   localparam CONTROL_ENABLE                 = 0;
   localparam TABLE_CONTROL_WRITE_ENABLE     = 0;
   localparam TABLE_CONTROL_READ_ENABLE      = 1;
   localparam TABLE_CONTROL_READ_LOCKOUT     = 31;
   localparam TABLE_ADD_LSB                  = 8;
   localparam TABLE_ADD_MSB                  = TABLE_ADD_SIZE+TABLE_ADD_LSB-1;
   localparam TABLE_ROW_LSB                  = 0;
   localparam TABLE_ROW_MSB                  = TABLE_ROW_SIZE+TABLE_ROW_LSB-1;
   

   genvar i;  
   //Registers
   reg  [31 : 0]  r_Version = VERSION;
   wire [31 : 0]  r_Type; 
   reg  [31 : 0]  r_Scratch_Pad;
   reg  [31 : 0]  r_Control;   
   reg  [31 : 0]  r_Table_Control;
   wire [31 : 0]  r_Table_Status;               //"Bit 0 - Write In Progress (0-Complete, 1-In Progress)
   reg  [31 : 0]  r_Table_Row_Address;
   reg  [31 : 0]  r_Table_Data_H;
   reg  [31 : 0]  r_Table_Data_L;

   
   reg  [31:0]    reg_data_out;   
   wire           slv_reg_wren;
   wire           slv_reg_rden;
   reg  [31 : 0]  axi_awaddr;
   reg  	      axi_awready;   
   reg            axi_wready;
   reg  [1 : 0]   axi_bresp;
   reg            axi_bvalid;
   reg  [31 : 0]  axi_araddr;
   reg            axi_arready;
   reg  [31 : 0]  axi_rdata;
   reg  [1 : 0]   axi_rresp;
   reg            axi_rvalid;
   
   assign r_Type[31:16] = 0;
   assign r_Type[7:0]   = TABLE_NO;
   assign r_Type[15:8]  = BRAM_NO;
   assign slv_reg_rden  = axi_arready & s_axi_arvalid & ~axi_rvalid;
   assign slv_reg_wren  = axi_wready && s_axi_wvalid && axi_awready && s_axi_awvalid;
   
   assign s_axi_awready = axi_awready;
   assign s_axi_wready  = axi_wready;
   assign s_axi_bresp   = axi_bresp;
   assign s_axi_bvalid  = axi_bvalid;
   assign s_axi_arready = axi_arready;
   assign s_axi_rresp   = axi_rresp;
   assign s_axi_rvalid  = axi_rvalid;
   
   assign w_addr2mem_a  = {r_Table_Row_Address[TABLE_ADD_MSB:TABLE_ADD_LSB],r_Table_Row_Address[TABLE_ROW_MSB:TABLE_ROW_LSB]};
   assign r_Table_Status = {29'b0, r_Table_Control[TABLE_CONTROL_READ_ENABLE]&ena&~r_Table_Control[TABLE_CONTROL_READ_LOCKOUT], r_Table_Control[TABLE_CONTROL_WRITE_ENABLE]&ena&~r_Table_Control[TABLE_CONTROL_READ_LOCKOUT]};
   
   // Implement axi_awready generation
   // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
   // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
   // de-asserted when reset is low.

   always @( posedge s_axi_aclk ) begin
      if ( s_axi_aresetn == 1'b0 )
            axi_awready <= 1'b0;
      else begin    
         if (~axi_awready && s_axi_awvalid && s_axi_wvalid)
            // slave is ready to accept write address when 
            // there is a valid write address and write data
            // on the write address and data bus. This design 
            // expects no outstanding transactions. 
            axi_awready <= 1'b1;
         else           
            axi_awready <= 1'b0;
      end 
   end        

   // Implement memory mapped register select and write logic generation
   // The write data is accepted and written to memory mapped registers when
   // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
   // select byte enables of slave registers while writing.
   // These registers are cleared when reset (active low) is applied.
   // Slave register write enable is asserted when valid address and data are available
   // and the slave is ready to accept the write address and write data.
   
   always @( posedge s_axi_aclk ) begin
      if ( s_axi_aresetn == 1'b0 ) begin         
         r_Scratch_Pad        <= 0;       //0x008 scratch pad register
         r_Control            <= 0;       //Bit 0 - Enable (0-Disabled 1-Enabled)
                                          //Bit 1 - Register Update (0-Disabled, 1-Update Immediately)
                                          //Bit 30 - Read Lockout (0-Disabled, 1-Enabled)  Once set to 1 cannot be cleared
                                          //Bit 31 - Reset
         r_Table_Control      <= 0;       //"Bit 0 - Write Enable (0-Disabled, 1-Enabled)
                                          //Bit 1 - Read Enable (0-Disabled, 1-Enabled)"
                                          //Bit 1 - Read In Progress (0-Complete, 1-In Progress)"
         r_Table_Row_Address  <= 0;       //Bits 7:0 - Row  Writes to this register initiate read/write transaction
                                          //Bits 15:8 - Table"
         r_Table_Data_H       <= 0;       //Data (H) to write/read
         r_Table_Data_L       <= 0;       //Data (L) to write/read
         ena                  <= 0;
      end 
      else begin   
         ena <= 0;
         if (slv_reg_wren) begin
            case ( axi_awaddr[AXIS_ADD_SIZE+AXIS_ADD_LSB-1:AXIS_ADD_LSB] )
            'h2: r_Scratch_Pad            <= s_axi_wdata;
            'h3: begin
               r_Control[CONTROL_ENABLE]  <= s_axi_wdata[CONTROL_ENABLE];
            end
            'h8: begin
               r_Table_Control[TABLE_CONTROL_WRITE_ENABLE]  <= s_axi_wdata[TABLE_CONTROL_WRITE_ENABLE];
               r_Table_Control[TABLE_CONTROL_READ_ENABLE]   <= s_axi_wdata[TABLE_CONTROL_READ_ENABLE];
               r_Table_Control[TABLE_CONTROL_READ_LOCKOUT]  <= s_axi_wdata[TABLE_CONTROL_READ_LOCKOUT] | r_Table_Control[TABLE_CONTROL_READ_LOCKOUT];
            end    
            'ha: begin
               r_Table_Row_Address[TABLE_ADD_MSB:TABLE_ADD_LSB]  
               <= s_axi_wdata[TABLE_ADD_MSB:TABLE_ADD_LSB];
               r_Table_Row_Address[TABLE_ROW_MSB:TABLE_ROW_LSB]   
               <= s_axi_wdata[TABLE_ROW_MSB:TABLE_ROW_LSB];
               ena <= 1'b1;
            end

            'hb: r_Table_Data_H           <= s_axi_wdata;
            'hc: r_Table_Data_L           <= s_axi_wdata;
            default : begin
               r_Scratch_Pad              <= r_Scratch_Pad;
               r_Control                  <= r_Control;
               r_Table_Control            <= r_Table_Control;
               r_Table_Row_Address        <= r_Table_Row_Address;
               r_Table_Data_H             <= r_Table_Data_H;
               r_Table_Data_L             <= r_Table_Data_L;
            end
            endcase
         end
      end
   end    
   
   
   
   // Implement axi_awaddr latching
   // This process is used to latch the address when both 
   // S_AXI_AWVALID and S_AXI_WVALID are valid. 

   always @( posedge s_axi_aclk ) begin
      if ( s_axi_aresetn == 1'b0 )
            axi_awaddr <= 0;
      else begin    
         if (~axi_awready && s_axi_awvalid && s_axi_wvalid)
            // Write Address latching 
            axi_awaddr <= s_axi_awaddr;
      end 
   end       

   // Implement axi_wready generation
   // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
   // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
   // de-asserted when reset is low. 

   always @( posedge s_axi_aclk ) begin
      if ( s_axi_aresetn == 1'b0 )
         axi_wready <= 1'b0;
      else begin    
         if (~axi_wready && s_axi_wvalid && s_axi_awvalid)
            // slave is ready to accept write data when 
            // there is a valid write address and write data
            // on the write address and data bus. This design 
            // expects no outstanding transactions. 
            axi_wready <= 1'b1;
         else
            axi_wready <= 1'b0;
      end 
   end       
   
   
   
   
   // Implement write response logic generation
   // The write response and response valid signals are asserted by the slave 
   // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
   // This marks the acceptance of address and indicates the status of 
   // write transaction.

   always @( posedge s_axi_aclk ) begin
      if ( s_axi_aresetn == 1'b0 ) begin
         axi_bvalid  <= 0;
         axi_bresp   <= 2'b0;
      end 
      else begin    
         if (axi_awready && s_axi_awvalid && ~axi_bvalid && axi_wready && s_axi_wvalid) begin
            // indicates a valid write response is available
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b0; // 'OKAY' response 
         end                   // work error responses in future
         else begin
            if (s_axi_bready && axi_bvalid) 
               //check if bready is asserted while bvalid is high) 
               //(there is a possibility that bready is always asserted high)   
               axi_bvalid <= 1'b0; 
         end
      end
   end   

   // Implement axi_arready generation
   // axi_arready is asserted for one S_AXI_ACLK clock cycle when
   // S_AXI_ARVALID is asserted. axi_awready is 
   // de-asserted when reset (active low) is asserted. 
   // The read address is also latched when S_AXI_ARVALID is 
   // asserted. axi_araddr is reset to zero on reset assertion.
   
   always @( posedge s_axi_aclk ) begin
      if ( s_axi_aresetn == 1'b0 ) begin
            axi_arready <= 1'b0;
            axi_araddr  <= 32'b0;
      end 
      else begin    
         if (~axi_arready && s_axi_arvalid) begin
            // indicates that the slave has acceped the valid read address
            axi_arready <= 1'b1;
            // Read address latching
            axi_araddr  <= s_axi_araddr;
         end
         else 
            axi_arready <= 1'b0;
      end 
   end     
   
   // Implement axi_arvalid generation
   // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
   // S_AXI_ARVALID and axi_arready are asserted. The slave registers 
   // data are available on the axi_rdata bus at this instance. The 
   // assertion of axi_rvalid marks the validity of read data on the 
   // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
   // is deasserted on reset (active low). axi_rresp and axi_rdata are 
   // cleared to zero on reset (active low).  
   always @( posedge s_axi_aclk ) begin
      if ( s_axi_aresetn == 1'b0 ) begin
         axi_rvalid <= 0;
         axi_rresp  <= 0;
      end 
      else begin    
         if (axi_arready && s_axi_arvalid && ~axi_rvalid) begin
            // Valid read data is available at the read data bus
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b0; // 'OKAY' response
         end   
         else if (axi_rvalid && s_axi_rready) 
            // Read data is accepted by the master
            axi_rvalid <= 1'b0;
      end
   end    


   // Implement memory mapped register select and read logic generation
   // Slave register read enable is asserted when valid address is available
   // and the slave is ready to accept the read address.
   always @ (*) begin
      if ( s_axi_aresetn == 1'b0 ) 
            reg_data_out <= 0; 
      else begin    
         // Address decoding for reading registers
         case ( axi_araddr[AXIS_ADD_SIZE+AXIS_ADD_LSB-1:AXIS_ADD_LSB] )
         'h0: reg_data_out <= r_Version;
         'h1: reg_data_out <= r_Type;     //Bits 7:0 - Number of rows per table (64)
                                          //Bits 15:8 - Number of tables (8)
         'h2: reg_data_out <= r_Scratch_Pad;
         'h3: reg_data_out <= r_Control;
         'h8: reg_data_out <= r_Table_Control;
         'h9: reg_data_out <= r_Table_Status;
         'ha: reg_data_out <= r_Table_Row_Address;
         'hb: reg_data_out <= r_Table_Control[TABLE_CONTROL_READ_LOCKOUT] ? 'h0 : w_key_data_a_out[63:32];
         'hc: reg_data_out <= r_Table_Control[TABLE_CONTROL_READ_LOCKOUT] ? 'h0 : w_key_data_a_out[31:0];
         default : reg_data_out <= 0;
         endcase
      end   
   end

   
   // Output register or memory read data
   always @( posedge s_axi_aclk ) begin
      if ( s_axi_aresetn == 1'b0 ) 
         s_axi_rdata  <= 0; 
      else begin    
         // When there is a valid read address (S_AXI_ARVALID) with 
         // acceptance of read address by the slave (axi_arready), 
         // output the read dada 
         s_axi_rdata <= 0;
         if (slv_reg_rden)
            s_axi_rdata <= reg_data_out;     // register read data
      end
   end    
   
// AXI4-Lite interface




   wire  [63:0]   w_key_data_b_out;
   wire  [63:0]   w_key_data_a_in         = {r_Table_Data_H,r_Table_Data_L};
   wire           w_wea                   = r_Table_Control[TABLE_CONTROL_WRITE_ENABLE]&~r_Table_Control[TABLE_CONTROL_READ_ENABLE];
   wire           w_ena                   = (r_Table_Control[TABLE_CONTROL_WRITE_ENABLE]|r_Table_Control[TABLE_CONTROL_READ_ENABLE]) & ena & ~r_Table_Control[TABLE_CONTROL_READ_LOCKOUT];

   
   dpram_2clk    
   #(
      .RAM_WIDTH       (64),
      .RAM_DEPTH       (RAM_DEPTH),
      .RAM_PERFORMANCE ("LOW_LATENCY"),
//      .INIT_FILE       (INIT_FILE)
      .INIT_FILE       ("")
   )
   keys 
   (
      .addra           (w_addr2mem_a),    // TO DO when axi4-lite is connected
      .addrb           (w_addr2mem_b),
      .dina            (w_key_data_a_in), // TO DO from axi4-lite
      .dinb            (),
      .clka            (s_axi_aclk),      // TO DO later axi4-lite clk
      .clkb            (m_axis_aclk),
      .wea             (w_wea),           // TO DOfrom axi4-lite
      .web             (1'd0),
      .ena             (w_ena),           // to come from AXI4-lite later
      .enb             (1'd1),
      .rsta            (!s_axi_aresetn),  // AXI4-lite
      .rstb            (!m_axis_aresetn),
      .regcea          (1'd1),
      .regceb          (1'd1),
      .douta           (w_key_data_a_out),
      .doutb           (w_key_data_b_out)
   );
 
   sync_ff sync_ff_inst
   (
      .clk     (m_axis_aclk),
      .resetn  (m_axis_aresetn),
      .d       (r_Control[CONTROL_ENABLE]),
      .q       (w_s2m_axis_keys_tvalid)
   );
   
   assign m_axis_keys_tdata = w_key_data_b_out;
   
   // To do - is resetn - async or sync - confirm from Vamsi (fpgas use sync reset)
   always @(posedge m_axis_aclk) begin
      if (!m_axis_aresetn || start_key_transmit) begin
         dev_addr      <= 6'd0; //6'd63;
         dev_addr_clkd <= 8'd63;
      end
      else begin
         if (m_axis_keys_tready&w_s2m_axis_keys_tvalid) begin
            dev_addr_clkd <= {2'd0,dev_addr};
            dev_addr      <= dev_addr + 1'd1;  
            if (dev_addr == 41) 
               dev_addr <= 6'd0; // 6'd63;
         end
      end
   end

endmodule
