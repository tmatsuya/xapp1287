
`timescale 1 ns / 1 ps

	module oddr_v1_0 #(
		parameter C_FAMILY             = "7series") //7series, kintexu
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		input wire  clk_in,
		output wire  clk_out
	);

generate
	if	(C_FAMILY == "kintexu" || C_FAMILY == "virtexu")
		begin
		   // ODDRE1: Dedicated Dual Data Rate (DDR) Output Register
		   //         Kintex UltraScale
		   // Xilinx HDL Language Template, version 2015.1

		   ODDRE1 #(
			  .IS_C_INVERTED(1'b0),  // Optional inversion for C
			  .IS_D1_INVERTED(1'b0), // Optional inversion for D1
			  .IS_D2_INVERTED(1'b0), // Optional inversion for D2
			  .SRVAL(1'b0)           // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
		   )
		   ODDRE1_inst (
			  .Q(clk_out),   // 1-bit output: Data output to IOB
			  .C(clk_in),   // 1-bit input: High-speed clock input
			  .D1(1'b1), // 1-bit input: Parallel data input 1
			  .D2(1'b0), // 1-bit input: Parallel data input 2
			  .SR(1'b0)  // 1-bit input: Active High Async Reset
		   );
		end
	else
		begin
		   // ODDR: Output Double Data Rate Output Register with Set, Reset
		   //       and Clock Enable.
		   //       Kintex-7
		   // Xilinx HDL Language Template, version 2014.2

		   ODDR #(
			  .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
			  .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
			  .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
		   ) ODDR_inst (
			  .Q(clk_out),   // 1-bit DDR output
			  .C(clk_in),   // 1-bit clock input
			  .CE(1'b1), // 1-bit clock enable input
			  .D1(1'b1), // 1-bit data input (positive edge)
			  .D2(1'b0), // 1-bit data input (negative edge)
			  .R(1'b0),   // 1-bit reset
			  .S(1'b0)    // 1-bit set
		   );
	   end
endgenerate					
				
	endmodule
