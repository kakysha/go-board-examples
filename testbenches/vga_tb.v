// Testbench for VGA_Sync_Pulses module
`include "../modules/VGA_Sync.v"
`include "../modules/Test_Pattern_Gen.v"

module VGA_Test_Pattterns_TB;

parameter c_VIDEO_WIDTH = 3; // 3 bits per pixel
parameter c_TOTAL_COLS  = 10;
parameter c_TOTAL_ROWS  = 6;
parameter c_ACTIVE_COLS = 8;
parameter c_ACTIVE_ROWS = 4;

reg r_Clk = 1'b0;

wire [c_VIDEO_WIDTH-1:0] w_Red_Video_TP, w_Grn_Video_TP, w_Blu_Video_TP;
wire [9:0] w_Row_Count, w_Col_Count;

always #20 r_Clk <= ~r_Clk;

// Generates Sync Pulses to run VGA
VGA_Sync #(.TOTAL_COLS(c_TOTAL_COLS),
	.TOTAL_ROWS(c_TOTAL_ROWS),
	.ACTIVE_COLS(c_ACTIVE_COLS),
	.ACTIVE_ROWS(c_ACTIVE_ROWS)) VGA_Sync_Inst
(.i_Clk(r_Clk),
	.o_HSync(w_HSync_Start),
	.o_VSync(w_VSync_Start),
	.o_Col_Count(w_Row_Count),
	.o_Row_Count(w_Col_Count)
);


// Drives Red/Grn/Blue video - Test Pattern 5 (Color Bars)
Test_Pattern_Gen  #(.VIDEO_WIDTH(c_VIDEO_WIDTH),
	.ACTIVE_COLS(c_ACTIVE_COLS),
	.ACTIVE_ROWS(c_ACTIVE_ROWS))
Test_Pattern_Gen_Inst
	(.i_Clk(r_Clk),
		.i_Pattern(4'h63), // color bars
		.i_Col_Count(w_Col_Count),
		.i_Row_Count(w_Row_Count),
		.o_Red_Video(w_Red_Video_TP),
		.o_Grn_Video(w_Grn_Video_TP),
		.o_Blu_Video(w_Blu_Video_TP));

initial
	begin
		#5000;
		$finish();
	end

initial
	begin
		$dumpfile("vga_tb.vcd");
		$dumpvars(0);
	end

endmodule 