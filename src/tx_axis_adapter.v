`timescale 1 ns / 1 ps

module tx_axis_adapter
(
	input            clk_mac,
	input            rst_n,
	
	output reg       tx_vld,
	output reg [7:0] tx_dat,
	output reg       tx_sof,
	output reg       tx_eof,
	input            tx_ack,
	
	input      [7:0] tx_axis_mac_tdata,
	input            tx_axis_mac_tvalid,
	input            tx_axis_mac_tlast,
	output           tx_axis_mac_tready
);
	reg       buffer_used;
	reg       buffer_vld;
	reg [7:0] buffer_data;
	reg       buffer_last;
	
	assign tx_axis_mac_tready = buffer_used || !buffer_vld;
	always @(posedge clk_mac) begin
		if(!rst_n) begin
			buffer_vld  <= 0;
		end if(tx_axis_mac_tready) begin
			buffer_vld  <= tx_axis_mac_tvalid;
			buffer_data <= tx_axis_mac_tdata;
			buffer_last <= tx_axis_mac_tlast;
		end
	end
	
	localparam STATE_IDLE    = 0;
	localparam STATE_DATA    = 1;
	localparam STATE_EOF     = 2;
	localparam STATE_ACK_EOF = 3;
	
	reg [1:0] state, next_state;
	always @(posedge clk_mac) begin
		if(rst_n)
			state <= next_state;
		else
			state <= STATE_IDLE;
	end
	
	reg       next_tx_vld;
	reg [7:0] next_tx_dat;
	reg       next_tx_sof;
	reg       next_tx_eof;
	always @(posedge clk_mac) begin
		tx_vld <= rst_n && next_tx_vld;
		tx_dat <= next_tx_dat;
		tx_sof <= next_tx_sof;
		tx_eof <= next_tx_eof;
	end
	
	always @* begin
		next_state  = state;
		buffer_used = 0;
		next_tx_vld = tx_vld;
		next_tx_dat = tx_dat;
		next_tx_sof = tx_sof;
		next_tx_eof = tx_eof;
		
		case(state)
			STATE_IDLE: begin
				next_tx_vld = 0;
				next_tx_eof = 0;
				next_tx_sof = 0;
				if(buffer_vld) begin
					next_state  = buffer_last ? STATE_EOF : STATE_DATA;
					next_tx_vld = 1;
					next_tx_dat = buffer_data;
					next_tx_sof = 1;
					buffer_used = 1;
				end
			end STATE_DATA: begin
				if(tx_ack) begin
					if(buffer_vld) begin
						next_state  = buffer_last ? STATE_EOF : STATE_DATA;
						next_tx_vld = 1;
						next_tx_dat = buffer_data;
						next_tx_sof = 0;
						next_tx_eof = 0;
						buffer_used = 1;
					end else
						next_state = STATE_IDLE;
				end
			end STATE_EOF: begin
				if(tx_ack) begin
					next_tx_vld = 1;
					next_tx_sof = 0;
					next_tx_eof = 1;
					next_state  = STATE_ACK_EOF;
				end
			end STATE_ACK_EOF: begin
				if(tx_ack) begin
					next_tx_vld = 0;
					next_tx_eof = 0;
					next_state  = STATE_IDLE;
				end
			end
		endcase
	end

endmodule