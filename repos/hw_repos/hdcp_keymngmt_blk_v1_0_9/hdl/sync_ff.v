`timescale 1ns/10ps

module       sync_ff  
(
   input  wire                         clk   ,
   input  wire                         resetn,
   input  wire                         d ,
   output wire                         q  //?
);

reg meta_ff_1 = 1'b0;
reg meta_ff_2 = 1'b0;

always @ (posedge clk) begin
   if (!resetn) begin
      meta_ff_1 <= 1'b0;
      meta_ff_2 <= 1'b0;
   end
   else begin
      meta_ff_1 <= d;
      meta_ff_2 <= meta_ff_1;
   end
end
assign q = meta_ff_2;

endmodule
