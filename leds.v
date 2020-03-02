module UART_RX_To_7_Seg_Top (
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
	output o_Segment2_G
);

	wire w_DV;
	wire [7:0] w_RX_Byte;

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

endmodule