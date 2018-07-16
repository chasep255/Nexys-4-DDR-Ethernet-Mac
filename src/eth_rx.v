`timescale 1 ns / 1 ps

module eth_rx
(
	input             clk_mac,
	input             rst_n,
	
	input             eth_crsdv,
	input             eth_rxerr,
	input  [1:0]      eth_rxd,
	
	output reg        rx_vld,
	output reg [7:0]  rx_dat,
	output reg        rx_sof,
	output reg        rx_eof,
	output reg [10:0] rx_len,
	output reg        rx_err
);
	
	`include "util.vh"

	reg [63:0] data_buffer, next_data_buffer;
	always @(posedge clk_mac) begin
		if(rst_n)
			data_buffer <= next_data_buffer;
		else
			data_buffer <= 0;
	end
	
	reg [10:0] frame_idx, next_frame_idx;
	reg [1:0]  dibit_cnt, next_dibit_cnt;
	always @(posedge clk_mac) begin
		dibit_cnt <= next_dibit_cnt;
		frame_idx <= next_frame_idx;
	end
	
	reg        next_rx_vld;
	reg        next_rx_sof;
	reg        next_rx_eof;
	reg [10:0] next_rx_len;
	reg [7:0]  next_rx_dat;
	reg        next_rx_err;
	always @(posedge clk_mac) begin
		rx_vld <= next_rx_vld;
		rx_dat <= next_rx_dat;
		rx_sof <= next_rx_sof;
		rx_eof <= next_rx_eof;
		rx_len <= next_rx_len;
		rx_err <= next_rx_err;
	end
		
	localparam STATE_PREAMBLE = 0;
	localparam STATE_SOF      = 1;
	localparam STATE_RECV     = 2;
	
	reg [2:0] state, next_state;
	always @(posedge clk_mac) begin
		if(rst_n)
			state <= next_state; 
		else
			state <= STATE_PREAMBLE;
	end
	
	wire [31:0] crc32_code;
	crc32 crc32_inst
	(
		.clk (clk_mac),
		.rst (next_rx_sof && next_rx_vld),
		.vld (next_rx_vld && !next_rx_eof),
		.data(next_rx_dat),
		.crc (crc32_code)
	);
	
	always @* begin
		next_state  = state;
		next_rx_vld = 0;
		next_rx_eof = 0;
		next_rx_sof = 0;
		next_rx_err = 0; 
		next_rx_len = rx_len;
		next_rx_dat = rx_dat;
		
		next_frame_idx = frame_idx;
		next_dibit_cnt = dibit_cnt + 1;
		
		if(eth_crsdv && !eth_rxerr) 
			next_data_buffer = {eth_rxd, data_buffer[63:2]};
		else
			next_data_buffer = 0;
		
		case(state)
			STATE_PREAMBLE: begin
				next_dibit_cnt = 0;
				next_frame_idx = 0;
				if(data_buffer == 64'hd555555555555555) begin
					next_state  = STATE_SOF;
				end
			end STATE_RECV, STATE_SOF: begin
				if(eth_rxerr) begin
					next_rx_vld = 1;
					next_rx_eof = 1;
					next_rx_vld = 1;
					next_state  = STATE_PREAMBLE; 
				end else if(eth_crsdv) begin
					if(&next_dibit_cnt) begin
						next_frame_idx = frame_idx + 1;
						if(frame_idx >= 4) begin
							next_rx_len = frame_idx - 3;
							next_rx_vld = 1;
							next_rx_dat = next_data_buffer[31:24];
							next_rx_sof = state == STATE_SOF;
							next_state  = STATE_RECV;
						end
					end
				end else begin
					next_state  = STATE_PREAMBLE;
					next_rx_eof = 1;
					next_rx_vld = 1;
					next_rx_err = crc32_code != bswap32(data_buffer[63:32]);
				end
			end
		endcase
	end

endmodule