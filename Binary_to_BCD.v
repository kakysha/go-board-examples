module Binary_to_BCD #(parameter INPUT_WIDTH = 7, parameter DECIMAL_DIGITS = 2)
	(
		input                         i_Clock,
		input [INPUT_WIDTH-1:0]       i_Binary,
		output [DECIMAL_DIGITS*4-1:0] o_BCD
	);
	// copy of original input
	reg [INPUT_WIDTH-1:0] r_Input = 0;
	// The vector that contains the output BCD
	reg [DECIMAL_DIGITS*4-1:0] r_BCD = 0;

	integer i_Counter = INPUT_WIDTH-1;
	wire [3:0] w_LSD;

	always @(posedge i_Clock)
	begin
		if (r_Input != i_Binary) begin
			if (i_Counter == INPUT_WIDTH-1)
				r_BCD <= 0;
			if (i_Counter >= 0) begin
				if (w_LSD > 1)
					r_BCD[3:0] <= w_LSD + 3;

				// shift all bits by one and append MSB from original binary
				r_BCD <= r_BCD << 1;
				r_BCD[0] <= i_Binary[i_Counter];
				i_Counter <= i_Counter - 1;
			end 
			if (i_Counter < 0) begin
				r_Input <= i_Binary;
				i_Counter <= INPUT_WIDTH-1;
			end
		end
	end

	assign w_LSD = r_BCD[3:0];
	assign o_BCD = r_BCD;

endmodule // Binary_to_BCD