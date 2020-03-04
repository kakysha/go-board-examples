// This module is designed for 640x480 with a 25 MHz input clock.
// All test patterns are being generated all the time.  This makes use of one
// of the benefits of FPGAs, they are highly parallelizable.  Many different
// things can all be happening at the same time.  In this case, there are several
// test patterns that are being generated simulatenously.  The actual choice of
// which test pattern gets displayed is done via the i_Pattern signal, which is
// an input to a case statement.

// Available Patterns:
// Pattern 0: Disables the Test Pattern Generator
// Pattern 1: All Red
// Pattern 2: All Green
// Pattern 3: All Blue
// Pattern 4: Checkerboard white/black
// Pattern 5: Color Bars
// Pattern 6: White Box with Border (2 pixels)

module Test_Pattern_Gen
	#(parameter VIDEO_WIDTH = 3,
		parameter ACTIVE_COLS = 640,
		parameter ACTIVE_ROWS = 480)
	(input       i_Clk,
		input [3:0] i_Pattern,
		input [9:0] i_Col_Count,
		input [9:0] i_Row_Count,
		output [VIDEO_WIDTH-1:0] o_Red_Video,
		output [VIDEO_WIDTH-1:0] o_Grn_Video,
		output [VIDEO_WIDTH-1:0] o_Blu_Video);

reg [VIDEO_WIDTH-1:0] r_Red_Video = 0;
reg [VIDEO_WIDTH-1:0] r_Grn_Video = 0;
reg [VIDEO_WIDTH-1:0] r_Blu_Video = 0;

// Patterns have 16 indexes (0 to 15) and can be g_Video_Width bits wide
wire [VIDEO_WIDTH-1:0] Pattern_Red[0:15];
wire [VIDEO_WIDTH-1:0] Pattern_Grn[0:15];
wire [VIDEO_WIDTH-1:0] Pattern_Blu[0:15];

wire [6:0] w_Bar_Width;
wire [2:0] w_Bar_Select;

/////////////////////////////////////////////////////////////////////////////
// Pattern 0: Disables the Test Pattern Generator
/////////////////////////////////////////////////////////////////////////////
assign Pattern_Red[0] = 0;
assign Pattern_Grn[0] = 0;
assign Pattern_Blu[0] = 0;

/////////////////////////////////////////////////////////////////////////////
// Pattern 1: All Red
/////////////////////////////////////////////////////////////////////////////
assign Pattern_Red[1] = (i_Col_Count < ACTIVE_COLS && i_Row_Count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;
assign Pattern_Grn[1] = 0;
assign Pattern_Blu[1] = 0;

/////////////////////////////////////////////////////////////////////////////
// Pattern 2: All Green
/////////////////////////////////////////////////////////////////////////////
assign Pattern_Red[2] = 0;
assign Pattern_Grn[2] = (i_Col_Count < ACTIVE_COLS && i_Row_Count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;
assign Pattern_Blu[2] = 0;

/////////////////////////////////////////////////////////////////////////////
// Pattern 3: All Blue
/////////////////////////////////////////////////////////////////////////////
assign Pattern_Red[3] = 0;
assign Pattern_Grn[3] = 0;
assign Pattern_Blu[3] = (i_Col_Count < ACTIVE_COLS && i_Row_Count < ACTIVE_ROWS) ? {VIDEO_WIDTH{1'b1}} : 0;

/////////////////////////////////////////////////////////////////////////////
// Pattern 4: Checkerboard white/black
/////////////////////////////////////////////////////////////////////////////
assign Pattern_Red[4] = i_Col_Count[5] ^ i_Row_Count[5] ? {VIDEO_WIDTH{1'b1}} : 0;
assign Pattern_Grn[4] = Pattern_Red[4];
assign Pattern_Blu[4] = Pattern_Red[4];


/////////////////////////////////////////////////////////////////////////////
// Pattern 5: Color Bars
// Divides active area into 8 Equal Bars and colors them accordingly
// Colors Each According to this Truth Table:
// R G B  w_Bar_Select  Ouput Color
// 0 0 0       0        Black
// 0 0 1       1        Blue
// 0 1 0       2        Green
// 0 1 1       3        Turquoise
// 1 0 0       4        Red
// 1 0 1       5        Purple
// 1 1 0       6        Yellow
// 1 1 1       7        White
/////////////////////////////////////////////////////////////////////////////
localparam BAR_WIDTH = ACTIVE_COLS/8;
assign w_Bar_Width = BAR_WIDTH[6:0];

assign w_Bar_Select = i_Col_Count < w_Bar_Width*1 ? 0 :
	i_Col_Count < w_Bar_Width*2 ? 1 :
	i_Col_Count < w_Bar_Width*3 ? 2 :
	i_Col_Count < w_Bar_Width*4 ? 3 :
	i_Col_Count < w_Bar_Width*5 ? 4 :
	i_Col_Count < w_Bar_Width*6 ? 5 :
	i_Col_Count < w_Bar_Width*7 ? 6 : 7;

// Implement Truth Table above with Conditional Assignments
assign Pattern_Red[5] = (w_Bar_Select == 4 || w_Bar_Select == 5 ||
	w_Bar_Select == 6 || w_Bar_Select == 7) ?
{VIDEO_WIDTH{1'b1}} : 0;

assign Pattern_Grn[5] = (w_Bar_Select == 2 || w_Bar_Select == 3 ||
	w_Bar_Select == 6 || w_Bar_Select == 7) ?
{VIDEO_WIDTH{1'b1}} : 0;

assign Pattern_Blu[5] = (w_Bar_Select == 1 || w_Bar_Select == 3 ||
	w_Bar_Select == 5 || w_Bar_Select == 7) ?
{VIDEO_WIDTH{1'b1}} : 0;


/////////////////////////////////////////////////////////////////////////////
// Pattern 6: Black With White Border
// Creates a black screen with a white border 2 pixels wide around outside.
/////////////////////////////////////////////////////////////////////////////
assign Pattern_Red[6] = (i_Row_Count <= 1 || i_Row_Count >= ACTIVE_ROWS-1-1 ||
	i_Col_Count <= 1 || i_Col_Count >= ACTIVE_COLS-1-1) ?
{VIDEO_WIDTH{1'b1}} : 0;
assign Pattern_Grn[6] = Pattern_Red[6];
assign Pattern_Blu[6] = Pattern_Red[6];

/////////////////////////////////////////////////////////////////////////////
// Select between different test patterns
/////////////////////////////////////////////////////////////////////////////
always @(posedge i_Clk)
	begin
		case (i_Pattern)
			4'h0 :
				begin
					r_Red_Video <= Pattern_Red[0];
					r_Grn_Video <= Pattern_Grn[0];
					r_Blu_Video <= Pattern_Blu[0];
				end
			4'h1 :
				begin
					r_Red_Video <= Pattern_Red[1];
					r_Grn_Video <= Pattern_Grn[1];
					r_Blu_Video <= Pattern_Blu[1];
				end
			4'h2 :
				begin
					r_Red_Video <= Pattern_Red[2];
					r_Grn_Video <= Pattern_Grn[2];
					r_Blu_Video <= Pattern_Blu[2];
				end
			4'h3 :
				begin
					r_Red_Video <= Pattern_Red[3];
					r_Grn_Video <= Pattern_Grn[3];
					r_Blu_Video <= Pattern_Blu[3];
				end
			4'h4 :
				begin
					r_Red_Video <= Pattern_Red[4];
					r_Grn_Video <= Pattern_Grn[4];
					r_Blu_Video <= Pattern_Blu[4];
				end
			4'h5 :
				begin
					r_Red_Video <= Pattern_Red[5];
					r_Grn_Video <= Pattern_Grn[5];
					r_Blu_Video <= Pattern_Blu[5];
				end
			4'h6 :
				begin
					r_Red_Video <= Pattern_Red[6];
					r_Grn_Video <= Pattern_Grn[6];
					r_Blu_Video <= Pattern_Blu[6];
				end
			default:
				begin
					r_Red_Video <= Pattern_Red[0];
					r_Grn_Video <= Pattern_Grn[0];
					r_Blu_Video <= Pattern_Blu[0];
				end
		endcase
	end


assign o_Red_Video = r_Red_Video;
assign o_Grn_Video = r_Grn_Video;
assign o_Blu_Video = r_Blu_Video;

endmodule