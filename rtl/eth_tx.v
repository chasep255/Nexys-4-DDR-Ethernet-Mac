`timescale 1 ns / 1 ps

module eth_tx
(
	input            clk_mac,
	input            rst_n,
	
	output reg       eth_txen,
	output reg [1:0] eth_txd,
	
	input            tx_vld,
	input [7:0]      tx_dat,
	input            tx_sof,
	input            tx_eof,
	output reg       tx_ack
);

	localparam STATE_IDLE     = 0;
	localparam STATE_PREAMBLE = 1;
	localparam STATE_BODY     = 2;
	localparam STATE_PAD      = 3;
	localparam STATE_CRC1     = 4;
	localparam STATE_CRC2     = 5;
	localparam STATE_CRC3     = 6;
	localparam STATE_GAP      = 7;
	reg [2:0] state, next_state;
	always @(posedge clk_mac) begin
		if(rst_n)
			state <= next_state;
		else
			state <= STATE_IDLE;
	end
	
	reg [1:0] byte_idx = 0;
	wire      toggle_byte = &byte_idx;
	reg [7:0] current_byte, next_byte;
	reg       current_vld,  next_vld;
	always @(posedge clk_mac) begin
		byte_idx <= byte_idx + 1;
		if(byte_idx == 3) begin
			current_byte <= next_byte;
			current_vld  <= next_vld;
		end
		
		eth_txen <= current_vld && rst_n;
		case(byte_idx)
			0: eth_txd <= current_byte[1:0];
			1: eth_txd <= current_byte[3:2];
			2: eth_txd <= current_byte[5:4];
			3: eth_txd <= current_byte[7:6];
		endcase
	end
	
	reg [10:0] frame_idx;
	reg [3:0]  gap_count;
	always @(posedge clk_mac) begin
		if(state == STATE_IDLE)
			frame_idx <= 0;
		else
			frame_idx <= frame_idx + toggle_byte;
			
		if(state == STATE_GAP)
			gap_count <= gap_count + toggle_byte;
		else
			gap_count <= 0;
	end
	
	wire [31:0] crc32_code;
	reg         push_crc;
	crc32 crc32_inst
	(
		.clk (clk_mac),
		.rst (state == STATE_IDLE),
		.vld (toggle_byte && push_crc),
		.data(next_byte),
		.crc (crc32_code)
	);
	
	always @* begin
		next_state  = state;
		next_byte   = 0;
		next_vld    = 0;
		tx_ack      = 0;
		push_crc    = 0;
		
		case(state)
			STATE_IDLE: begin
				if(tx_vld && tx_sof) 
					next_state  = STATE_PREAMBLE;
			end STATE_PREAMBLE: begin
				if(toggle_byte) begin
					next_vld = 1;
					if(frame_idx < 7) begin
						next_byte = 8'h55;
					end else begin
						next_byte   = 8'hd5;
						next_state  = STATE_BODY;
					end
				end
			end STATE_BODY: begin
				if(toggle_byte) begin
					tx_ack = 1;
					if(tx_eof && tx_vld) begin
						if(frame_idx < 72) begin
							next_state = STATE_PAD;
							next_byte  = 0;
							next_vld   = 1;
							push_crc   = 1;
						end else begin
							next_state = STATE_CRC1;
							next_byte  = crc32_code[31:24];
							next_vld   = 1;
						end
					end else if(tx_vld) begin
						next_byte = tx_dat;
						next_vld  = 1;
						push_crc  = 1;
					end else begin
						next_state = STATE_GAP;
					end
				end
			end STATE_PAD: begin
				if(toggle_byte) begin
					if(frame_idx < 72) begin
						next_vld  = 1;
						next_byte = 0;
						push_crc  = 1;
					end else begin
						next_vld  = 1;
						next_byte = crc32_code[31:24];
						next_state = STATE_CRC1;
					end
				end
			end STATE_CRC1: begin
				if(toggle_byte) begin
					next_vld   = 1;
					next_byte  = crc32_code[23:16];
					next_state = STATE_CRC2;
				end
			end STATE_CRC2: begin
				if(toggle_byte) begin
					next_vld   = 1;
					next_byte  = crc32_code[15:8];
					next_state = STATE_CRC3;
				end
			end STATE_CRC3: begin
				if(toggle_byte) begin
					next_vld   = 1;
					next_byte  = crc32_code[7:0];
					next_state = STATE_GAP;
				end
			end STATE_GAP: begin
				if(gap_count >= 12)
					next_state = STATE_IDLE;
			end
		endcase
	end

endmodule