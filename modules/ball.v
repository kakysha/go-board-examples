module ball #(parameter GAME_WIDTH = 40, parameter GAME_HEIGHT = 30) (
	input i_clk,
	input i_enabled,
	input [5:0] i_col,
	input [5:0] i_row,
	output reg o_draw = 1'b0
);

parameter BALL_SPEED = 25000000/5; // how many clock cycles for one ball move
reg [24:0] r_ticks_count = 0;

reg [5:0]  r_ball_pos_x = GAME_WIDTH/2;
reg [5:0]  r_ball_pos_y = GAME_HEIGHT/2;
reg [1:0] r_ball_direction = 2'b00; // 00-sw 01-se 10-nw 11-ne

always @(posedge i_clk)
begin
	case (i_enabled)
	1'b0:
		begin
			r_ball_pos_x <= GAME_WIDTH/2;
			r_ball_pos_y <= GAME_HEIGHT/2;
			r_ball_direction <= 2'b00;
		end
	1'b1:
		begin
			if (r_ticks_count < BALL_SPEED)
				r_ticks_count <= r_ticks_count + 1;
			else
			begin
				r_ticks_count <= 0;

				// (0,0) is top-left corner of the screen
				
				if (r_ball_pos_x == 0 && r_ball_direction[0:0] == 1'b0) // west
					r_ball_direction[0:0] <= 1'b1; // change to east
				if (r_ball_pos_x == GAME_WIDTH && r_ball_direction[0:0] == 1'b1) // east
					r_ball_direction[0:0] <= 1'b0; // change to west
				if (r_ball_pos_y == 0 && r_ball_direction[1:1] == 1'b1) // north
					r_ball_direction[1:1] <= 1'b0; // change to south
				if (r_ball_pos_y == GAME_HEIGHT && r_ball_direction[1:1] == 1'b0) // south
					r_ball_direction[1:1] <= 1'b1; // change to north

				r_ball_pos_x <= r_ball_pos_x - 1 + 2 * r_ball_direction[0:0]; // -1 is west, +1 is east
				r_ball_pos_y <= r_ball_pos_y + 1 - 2 * r_ball_direction[1:1]; // +1 is south, -1 is north
			end
		end
	endcase
end

always @(posedge i_clk)
begin
	if (i_col == r_ball_pos_x && i_row == r_ball_pos_y)
		o_draw <= 1'b1;
	else
		o_draw <= 1'b0;
end

endmodule