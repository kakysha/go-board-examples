// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 25 MHz Clock, 115200 baud UART
// (25000000)/(115200) = 217

module UART_RX #(parameter CLKS_PER_BIT = 217) (
	input        i_Clock,
	input        i_RX_Serial,
	output [7:0] o_RX_Byte
);

parameter STATE_IDLE = 1'b0;
parameter STATE_READING = 1'b1;

reg [0:0] r_SM_State = 0;
reg [7:0] r_Clock_Count = 0;
reg [7:0] r_RX_Byte = 0;
reg [3:0] r_Bits_Count = 0;

always @(posedge i_Clock) begin
	case (r_SM_State)
		STATE_IDLE:
			begin
				if (i_RX_Serial == 1'b0) begin
					if (r_Clock_Count == (CLKS_PER_BIT - 1)/2) begin
						r_Clock_Count <= 0;
						r_RX_Byte <= 0;
						r_SM_State <= STATE_READING;
					end else
						r_Clock_Count <= r_Clock_Count + 1;
				end else
					r_Clock_Count <= 0;

			end
		STATE_READING:
			begin
				if (r_Bits_Count < 8) begin
					if (r_Clock_Count < CLKS_PER_BIT) // forward to next bit
						r_Clock_Count <= r_Clock_Count + 1;
					else begin
						r_RX_Byte[r_Bits_Count] <= i_RX_Serial;
						r_Bits_Count <= r_Bits_Count + 1;
						r_Clock_Count <= 0;
					end
				end else begin // done reading 8 bits, skip to STOP bit
					if (r_Clock_Count < CLKS_PER_BIT)
						r_Clock_Count <= r_Clock_Count + 1;
					else begin
						r_Clock_Count <= 0;
						r_Bits_Count <= 0;
						r_SM_State <= STATE_IDLE;
					end
				end
			end

		default:
			r_SM_State <= STATE_IDLE;
	endcase // r_SM_State
end

assign o_RX_Byte = r_RX_Byte;

endmodule // UART_RX

