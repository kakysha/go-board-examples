module paddle #(parameter GAME_WIDTH = 40, parameter GAME_HEIGHT = 30, parameter PADDLE_HEIGHT = 6, parameter SIDE = 0) (
	input i_clk,
	input i_enabled,
	input button_up,
	input button_down,
	input [5:0] i_col,
	input [5:0] i_row,
	output reg o_draw = 1'b0
);

parameter PADDLE_SPEED = 25000000/40; // how many clock cycles for one paddle move
reg [24:0] r_ticks_count = 0;

reg [5:0]  r_paddle_pos_y = GAME_HEIGHT/2 - PADDLE_HEIGHT/2;

always @(posedge i_clk)
begin
	case (i_enabled)
	1'b0:
		begin
			r_paddle_pos_y <= GAME_HEIGHT/2 - PADDLE_HEIGHT/2;
		end
	1'b1:
		begin
			if (r_ticks_count > 0) begin
				if (r_ticks_count < PADDLE_SPEED)
					r_ticks_count <= r_ticks_count + 1;
				else
					r_ticks_count <= 0;
			end else begin
				r_ticks_count <= 1;

				// (0,0) is top-left corner of the screen
				if (button_up && r_paddle_pos_y > 0)
					r_paddle_pos_y <= r_paddle_pos_y - 1;
				if (button_down && r_paddle_pos_y < GAME_HEIGHT - PADDLE_HEIGHT)
					r_paddle_pos_y <= r_paddle_pos_y + 1;
			end
		end
	endcase
end

always @(posedge i_clk)
begin
	if (((SIDE == 0 && i_col == 0) || (SIDE == 1 && i_col == GAME_WIDTH-1)) && i_row >= r_paddle_pos_y && i_row < r_paddle_pos_y+PADDLE_HEIGHT)
		o_draw <= 1'b1;
	else
		o_draw <= 1'b0;
end

endmodule