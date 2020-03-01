module Debounce_Project_Top (
	input  i_Clk       ,
	input  i_Switch_1  ,
	output o_Segment1_A,
	output o_Segment1_B,
	output o_Segment1_C,
	output o_Segment1_D,
	output o_Segment1_E,
	output o_Segment1_F,
	output o_Segment1_G,
	output o_Segment2_A,
	output o_Segment2_B,
	output o_Segment2_C,
	output o_Segment2_D,
	output o_Segment2_E,
	output o_Segment2_F,
	output o_Segment2_G
);
	reg [6:0] r_Counter = 0;
	reg [7:0] r_BCD;
	reg  r_Switch_1 = 1'b0;
	wire w_Switch_1;

	Debounce_Switch Debounce_Inst (
		.i_Clk(i_Clk),
		.i_Switch(i_Switch_1),
		.o_Switch(w_Switch_1)
	);

	Binary_to_BCD BtBCD_Inst (
		.i_Clock(i_Clk),
		.i_Binary(r_Counter),
		.o_BCD(r_BCD)
	);

	Binary_To_7Segment Bt7Inst1 (
		.i_Clk       (i_Clk),
		.i_Binary_Num(r_BCD[6:4]),
		.o_Segment_A (o_Segment1_A),
		.o_Segment_B (o_Segment1_B),
		.o_Segment_C (o_Segment1_C),
		.o_Segment_D (o_Segment1_D),
		.o_Segment_E (o_Segment1_E),
		.o_Segment_F (o_Segment1_F),
		.o_Segment_G (o_Segment1_G)
	);

	Binary_To_7Segment Bt7Inst2 (
		.i_Clk       (i_Clk),
		.i_Binary_Num(r_BCD[3:0]),
		.o_Segment_A (o_Segment2_A),
		.o_Segment_B (o_Segment2_B),
		.o_Segment_C (o_Segment2_C),
		.o_Segment_D (o_Segment2_D),
		.o_Segment_E (o_Segment2_E),
		.o_Segment_F (o_Segment2_F),
		.o_Segment_G (o_Segment2_G)
	);

	always @(posedge i_Clk)
	begin
		r_Switch_1 <= w_Switch_1;

		if (w_Switch_1 == 1'b0 && r_Switch_1 == 1'b1)
		begin
			if (r_Counter == 99)
				r_Counter <= 0;
			else
				r_Counter <= r_Counter + 1;
		end
	end


endmodule