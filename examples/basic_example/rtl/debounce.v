`timescale 1 ns / 1 ps

module debounce#
(
	parameter PULSE_LENGTH = 0,
	parameter INVERT       = 0
)
(
	input      clk,
	input      in,
	output     out
);

	reg pulse_sig = 0;
	wire eff_in   = INVERT ? ~in        : in;
	assign out    = INVERT ? ~pulse_sig : pulse_sig;
	

	reg [9:0] hold_counter = 0;
	always @(posedge clk) begin
		if(hold_counter != 0 && !eff_in)
			hold_counter <= hold_counter - 1;
		else if(hold_counter != 1023 && eff_in)
			hold_counter <= hold_counter + 1;
	end
	
	
	localparam PULSE_STATE_WAITING  = 0;
	localparam PULSE_STATE_SIGNAL   = 1;
	localparam PULSE_STATE_DEASSERT = 2;
	
	generate if(PULSE_LENGTH > 0) begin
		reg [$clog2(PULSE_LENGTH) : 0] pulse_counter;
		reg [1:0]                      pulse_state = PULSE_STATE_WAITING;
		always @(posedge clk) begin
			case(pulse_state)
				PULSE_STATE_WAITING: begin
					if(&hold_counter) begin
						pulse_state   <= PULSE_STATE_SIGNAL;
						pulse_sig     <= 1;
						pulse_counter <= 1;
					end
				end PULSE_STATE_SIGNAL: begin
					if(pulse_counter == PULSE_LENGTH) begin
						pulse_state   <= PULSE_STATE_DEASSERT;
						pulse_sig     <= 0;
						pulse_counter <= 0;
					end else
						pulse_counter <= pulse_counter + 1;
				end PULSE_STATE_DEASSERT: begin
					if(hold_counter == 0)
						pulse_state <= PULSE_STATE_WAITING;
				end
			endcase
		end
	end else begin
		always @(posedge clk) begin
			if(&hold_counter)
				pulse_sig <= 1;
			else if(hold_counter == 0)
				pulse_sig <= 0;
		end
	end endgenerate
	

	

endmodule