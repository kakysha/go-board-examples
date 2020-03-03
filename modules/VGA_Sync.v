// This module is designed for 640x480 with a 25 MHz input clock.

module VGA_Sync #(
	parameter TOTAL_COLS  = 800,
	parameter TOTAL_ROWS  = 525,
	parameter ACTIVE_COLS = 640,
	parameter ACTIVE_ROWS = 480
) (
	input            i_Clk,
	output           o_HSync,
	output           o_VSync,
	output [9:0] o_Col_Count,
	output [9:0] o_Row_Count
);

reg [9:0] r_Col_Count = 0;
reg [9:0] r_Row_Count = 0;

always @(posedge i_Clk) begin
	if (r_Col_Count == TOTAL_COLS-1) begin
		r_Col_Count <= 0;
		if (r_Row_Count == TOTAL_ROWS-1)
			r_Row_Count <= 0;
		else
			r_Row_Count <= r_Row_Count + 1;
	end else
		r_Col_Count <= r_Col_Count + 1;

end

assign o_HSync = o_Col_Count < ACTIVE_COLS ? 1'b1 : 1'b0;
assign o_VSync = o_Row_Count < ACTIVE_ROWS ? 1'b1 : 1'b0;
assign o_Col_Count = r_Col_Count;
assign o_Row_Count = r_Row_Count;

endmodule