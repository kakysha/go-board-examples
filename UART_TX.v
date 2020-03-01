// This file contains the UART Transmitter.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 25 MHz Clock, 115200 baud UART
// (25000000)/(115200) = 217

module UART_TX #(parameter CLKS_PER_BIT = 217) (
	input        i_Clock,
	input [7:0]  i_TX_Byte,
	output reg      o_TX_Serial
);

parameter STATE_IDLE = 1'b0;
parameter STATE_SENDING = 1'b1;

reg r_SM_State = 0;
reg [7:0] r_TX_Byte = 0;
reg [7:0] r_Clock_Count = 0;
reg [3:0] r_Bits_Count = 0;

always @(posedge i_Clock) begin
	case (r_SM_State)
		STATE_IDLE:
			begin
				if (i_TX_Byte != r_TX_Byte) begin // new byte received
					if (r_Clock_Count == CLKS_PER_BIT) begin
						r_Clock_Count <= 0;
						r_SM_State <= STATE_SENDING;
					end else begin // send START bit
						o_TX_Serial <= 1'b0;
						r_Clock_Count <= r_Clock_Count + 1;
					end
				end else
					o_TX_Serial <= 1'b1;

			end
		STATE_SENDING:
			begin
				if (r_Bits_Count < 8) begin
					if (r_Clock_Count < CLKS_PER_BIT) begin // send current bit
						o_TX_Serial <= i_TX_Byte[r_Bits_Count];
						r_Clock_Count <= r_Clock_Count + 1;
					end else begin // done sending current bit
						r_Bits_Count <= r_Bits_Count + 1;
						r_Clock_Count <= 0;
					end
				end else begin // done sending 8 bits, send STOP bit
					if (r_Clock_Count < CLKS_PER_BIT) begin
						o_TX_Serial <= 1'b1;
						r_Clock_Count <= r_Clock_Count + 1;
					end else begin
						r_TX_Byte <= i_TX_Byte;
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

endmodule // UART_TX

