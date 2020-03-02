`timescale 1ns/10ps // time-unit = 1 ns, precision = 10 ps

module BtBCD_TB;

// duration for each bit = 20 * timescale = 20 * 1 ns  = 20ns
localparam period = 20, INPUT_WIDTH = 7, DECIMAL_DIGITS = 2;

reg clk = 1'b0;
reg [INPUT_WIDTH-1:0] i_Binary;
wire [DECIMAL_DIGITS*4-1:0] o_BCD;

Binary_to_BCD #(.INPUT_WIDTH(INPUT_WIDTH), .DECIMAL_DIGITS(DECIMAL_DIGITS)) UUT (.i_Clock (clk), .i_Binary(i_Binary), .o_BCD(o_BCD));

always
	#1 clk <= !clk;

initial begin
	i_Binary <= 10;
	#period;
	if (o_BCD == 8'h10)
		$display("Test Passed - Correct Byte Received");
	else
		$display("Test Failed - Incorrect Byte Received");

	i_Binary <= 11;
	#period;
	if (o_BCD == 8'h11)
		$display("Test Passed - Correct Byte Received");
	else
		$display("Test Failed - Incorrect Byte Received");

	i_Binary <= 99;
	#period;
	if (o_BCD == 8'h99)
		$display("Test Passed - Correct Byte Received");
	else
		$display("Test Failed - Incorrect Byte Received");

	#period
	$finish;
end

initial begin
	// Required to dump signals to EPWave
	$dumpfile("leds_tb.vcd");
	$dumpvars(0);
end

endmodule