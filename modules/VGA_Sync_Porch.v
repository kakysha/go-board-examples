// The purpose of this module is to modify the input HSync and VSync signals to
// include some time for what is called the Front and Back porch.  The front
// and back porch of a VGA interface used to have more meaning when a monitor
// actually used a Cathode Ray Tube (CRT) to draw an image on the screen.  You
// can read more about the details of how old VGA monitors worked.  These
// days, the notion of a front and back porch is maintained, due more to
// convention than to the physics of the monitor.
// New standards like DVI and HDMI which are meant for digital signals have
// removed this notion of the front and back porches.  Remember that VGA is an
// analog interface.
// This module is designed for 640x480 with a 25 MHz input clock.

module VGA_Sync_Porch #(
	parameter VIDEO_WIDTH = 3,  // remember to
	parameter TOTAL_COLS  = 3,  // overwrite
	parameter TOTAL_ROWS  = 3,  // these defaults
	parameter ACTIVE_COLS = 2,
	parameter ACTIVE_ROWS = 2
) (
	input i_Clk,
	input i_HSync,
	input i_VSync,
	input [9:0] i_Col_Count,
	input [9:0] i_Row_Count,
	input [VIDEO_WIDTH-1:0] i_Red_Video,
	input [VIDEO_WIDTH-1:0] i_Grn_Video,
	input [VIDEO_WIDTH-1:0] i_Blu_Video,
	output reg o_HSync,
	output reg o_VSync,
	output reg [VIDEO_WIDTH-1:0] o_Red_Video,
	output reg [VIDEO_WIDTH-1:0] o_Grn_Video,
	output reg [VIDEO_WIDTH-1:0] o_Blu_Video
);

	parameter c_FRONT_PORCH_HORZ = 10;
	parameter c_BACK_PORCH_HORZ  = 58;
	parameter c_FRONT_PORCH_VERT = 4;
	parameter c_BACK_PORCH_VERT  = 39;

	reg [VIDEO_WIDTH-1:0] r_Red_Video = 0;
	reg [VIDEO_WIDTH-1:0] r_Grn_Video = 0;
	reg [VIDEO_WIDTH-1:0] r_Blu_Video = 0;

	// Purpose: Modifies the HSync and VSync signals to include Front/Back Porch
	always @(posedge i_Clk)
		begin
			if ((i_Col_Count < c_FRONT_PORCH_HORZ + ACTIVE_COLS) ||
				(i_Col_Count > TOTAL_COLS - c_BACK_PORCH_HORZ - 1))
			o_HSync <= 1'b1;
			else
				o_HSync <= i_HSync;

			if ((i_Row_Count < c_FRONT_PORCH_VERT + ACTIVE_ROWS) ||
				(i_Row_Count > TOTAL_ROWS - c_BACK_PORCH_VERT - 1))
			o_VSync <= 1'b1;
			else
				o_VSync <= i_VSync;
		end


	// Purpose: Align input video to modified Sync pulses.
	// Adds in 2 Clock Cycles of Delay
	always @(posedge i_Clk)
		begin
			r_Red_Video <= i_Red_Video;
			r_Grn_Video <= i_Grn_Video;
			r_Blu_Video <= i_Blu_Video;

			o_Red_Video <= r_Red_Video;
			o_Grn_Video <= r_Grn_Video;
			o_Blu_Video <= r_Blu_Video;
		end

endmodule

