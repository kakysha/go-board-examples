`include "modules/Binary_To_7Segment.v"
`include "modules/UART_RX.v"
`include "modules/UART_TX.v"
`include "modules/VGA_Sync.v"
`include "modules/VGA_Sync_Porch.v"
`include "modules/Test_Pattern_Gen.v"

module main (
	input i_Clk,     // Main Clock
	input i_UART_RX, // UART RX Data
	output o_UART_TX,   // UART TX Data
	// Segment1 is upper digit, Segment2 is lower digit
	output o_Segment1_A,
	output o_Segment1_B,
	output o_Segment1_C,
	output o_Segment1_D,
	output o_Segment1_E,
	output o_Segment1_F,
	output o_Segment1_G,
	//
	output o_Segment2_A,
	output o_Segment2_B,
	output o_Segment2_C,
	output o_Segment2_D,
	output o_Segment2_E,
	output o_Segment2_F,
	output o_Segment2_G,

	// VGA
	output o_VGA_HSync,
	output o_VGA_VSync,
	output o_VGA_Red_0,
	output o_VGA_Red_1,
	output o_VGA_Red_2,
	output o_VGA_Grn_0,
	output o_VGA_Grn_1,
	output o_VGA_Grn_2,
	output o_VGA_Blu_0,
	output o_VGA_Blu_1,
	output o_VGA_Blu_2
);

wire w_DV;
wire [7:0] w_RX_Byte;

// VGA Constants to set Frame Size
parameter c_VIDEO_WIDTH = 3;
parameter c_TOTAL_COLS  = 800;
parameter c_TOTAL_ROWS  = 525;
parameter c_ACTIVE_COLS = 640;
parameter c_ACTIVE_ROWS = 480;

// Common VGA Signals
wire w_VGA_HSync, w_VGA_VSync;
wire [c_VIDEO_WIDTH-1:0] w_Red_Video_TP, w_Grn_Video_TP, w_Blu_Video_TP, w_Red_Video_Porch, w_Grn_Video_Porch, w_Blu_Video_Porch;
wire [9:0] w_Row_Count, w_Col_Count;

// 25,000,000 / 115,200 = 217
UART_RX #(.CLKS_PER_BIT(217)) UART_RX_Inst
	(.i_Clock(i_Clk),
		.i_RX_Serial(i_UART_RX),
		.o_RX_Byte(w_RX_Byte),
		.o_DV(w_DV));

UART_TX #(.CLKS_PER_BIT(217)) UART_TX_Inst
	(.i_Clock(i_Clk),
		.i_DV(w_DV),
		.i_TX_Byte(w_RX_Byte),  // Pass RX to TX module for loopback
		.o_TX_Serial(o_UART_TX));

// Binary to 7-Segment Converter for Upper Digit
Binary_To_7Segment SevenSeg1_Inst
	(.i_Clk(i_Clk),
		.i_Binary_Num(w_RX_Byte[7:4]),
		.o_Segment_A(o_Segment1_A),
		.o_Segment_B(o_Segment1_B),
		.o_Segment_C(o_Segment1_C),
		.o_Segment_D(o_Segment1_D),
		.o_Segment_E(o_Segment1_E),
		.o_Segment_F(o_Segment1_F),
		.o_Segment_G(o_Segment1_G));

// Binary to 7-Segment Converter for Lower Digit
Binary_To_7Segment SevenSeg2_Inst
	(.i_Clk(i_Clk),
		.i_Binary_Num(w_RX_Byte[3:0]),
		.o_Segment_A(o_Segment2_A),
		.o_Segment_B(o_Segment2_B),
		.o_Segment_C(o_Segment2_C),
		.o_Segment_D(o_Segment2_D),
		.o_Segment_E(o_Segment2_E),
		.o_Segment_F(o_Segment2_F),
		.o_Segment_G(o_Segment2_G));

// Generates Sync Pulses to run VGA
VGA_Sync #(.TOTAL_COLS(c_TOTAL_COLS),
	.TOTAL_ROWS(c_TOTAL_ROWS),
	.ACTIVE_COLS(c_ACTIVE_COLS),
	.ACTIVE_ROWS(c_ACTIVE_ROWS)) VGA_Sync_Inst
(.i_Clk(i_Clk),
	.o_HSync(w_VGA_HSync),
	.o_VSync(w_VGA_VSync),
	.o_Col_Count(w_Col_Count),
	.o_Row_Count(w_Row_Count)
);

Test_Pattern_Gen  #(.VIDEO_WIDTH(c_VIDEO_WIDTH),
	.ACTIVE_COLS(c_ACTIVE_COLS),
	.ACTIVE_ROWS(c_ACTIVE_ROWS))
Test_Pattern_Gen_Inst
	(.i_Clk(i_Clk),
		.i_Pattern(w_RX_Byte[3:0]),
		.i_Col_Count(w_Col_Count),
		.i_Row_Count(w_Row_Count),
		.o_Red_Video(w_Red_Video_TP),
		.o_Grn_Video(w_Grn_Video_TP),
		.o_Blu_Video(w_Blu_Video_TP));

VGA_Sync_Porch  #(.VIDEO_WIDTH(c_VIDEO_WIDTH),
	.TOTAL_COLS(c_TOTAL_COLS),
	.TOTAL_ROWS(c_TOTAL_ROWS),
	.ACTIVE_COLS(c_ACTIVE_COLS),
	.ACTIVE_ROWS(c_ACTIVE_ROWS))
VGA_Sync_Porch_Inst
	(.i_Clk(i_Clk),
		.i_HSync(w_VGA_HSync),
		.i_VSync(w_VGA_VSync),
		.i_Col_Count(w_Col_Count),
		.i_Row_Count(w_Row_Count),
		.i_Red_Video(w_Red_Video_TP),
		.i_Grn_Video(w_Grn_Video_TP),
		.i_Blu_Video(w_Blu_Video_TP),
		.o_HSync(o_VGA_HSync),
		.o_VSync(o_VGA_VSync),
		.o_Red_Video(w_Red_Video_Porch),
		.o_Grn_Video(w_Grn_Video_Porch),
		.o_Blu_Video(w_Blu_Video_Porch));

assign o_VGA_Red_0 = w_Red_Video_Porch[0];
assign o_VGA_Red_1 = w_Red_Video_Porch[1];
assign o_VGA_Red_2 = w_Red_Video_Porch[2];

assign o_VGA_Grn_0 = w_Grn_Video_Porch[0];
assign o_VGA_Grn_1 = w_Grn_Video_Porch[1];
assign o_VGA_Grn_2 = w_Grn_Video_Porch[2];

assign o_VGA_Blu_0 = w_Blu_Video_Porch[0];
assign o_VGA_Blu_1 = w_Blu_Video_Porch[1];
assign o_VGA_Blu_2 = w_Blu_Video_Porch[2];

endmodule