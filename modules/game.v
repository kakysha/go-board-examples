`include "ball.v"
`include "paddle.v"

module game #(parameter GAME_WIDTH = 40, parameter GAME_HEIGHT = 30)(
	input i_clk,

	input [5:0] i_row,
	input [5:0] i_col,

	input button_p1_up,
	input button_p1_down,
	input button_p2_up,
	input button_p2_down,

	output o_draw
);

reg r_ball_draw, r_p1_draw, r_p2_draw = 1'b0;

ball #(.GAME_WIDTH(GAME_WIDTH), .GAME_HEIGHT(GAME_HEIGHT)) ball_inst (
	.i_clk    (i_clk),
	.i_enabled(1'b1),
	.i_col(i_col),
	.i_row(i_row),
	.o_draw(r_ball_draw)
);

paddle #(.GAME_WIDTH(GAME_WIDTH), .GAME_HEIGHT(GAME_HEIGHT), .SIDE(0)) p1 (
	.i_clk    (i_clk),
	.i_enabled(1'b1),
	.button_up(button_p1_up),
	.button_down(button_p1_down),
	.i_col(i_col),
	.i_row(i_row),
	.o_draw(r_p1_draw)
);

paddle #(.GAME_WIDTH(GAME_WIDTH), .GAME_HEIGHT(GAME_HEIGHT), .SIDE(1)) p2 (
	.i_clk    (i_clk),
	.i_enabled(1'b1),
	.button_up(button_p2_up),
	.button_down(button_p2_down),
	.i_col(i_col),
	.i_row(i_row),
	.o_draw(r_p2_draw)
);

assign o_draw = r_ball_draw | r_p1_draw | r_p2_draw;

endmodule