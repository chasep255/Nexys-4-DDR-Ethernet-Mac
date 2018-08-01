`timescale 1 ns / 1 ps

(* keep_hierarchy = "yes" *) 
module eth_smi
(
	input         clk_mac,
	input         rst_n,
	
	output        ready,
	input         valid,
	input         write,
	input  [4:0]  phyaddr,
	input  [4:0]  register,
	output [15:0] read_value,
	input  [15:0] write_value,
	
	output reg    eth_mdc,
	inout         eth_mdio
);
	
	reg  [3:0] counter;
	wire [3:0] next_counter = counter == 9 ? 0 : counter + 1;
	wire       next_mdc     = next_counter == 0 ? ~eth_mdc : eth_mdc;
	wire       toggle       = counter == 0 && !eth_mdc;
	always @(posedge clk_mac) begin
		if(rst_n) begin
			counter <= next_counter;
			eth_mdc <= next_mdc;
		end else begin
			counter <= 0;
			eth_mdc <= 1;
		end
	end
	
	reg        is_write,      next_is_write;
	reg [6:0]  write_counter, next_write_counter;      
	reg [6:0]  read_count,    next_read_count;      
	reg [64:0] send_buffer,   next_send_buffer;
	reg [15:0] recv_buffer,   next_recv_buffer;
	always @(posedge clk_mac) begin
		is_write      <= next_is_write;
		write_counter <= next_write_counter;
		read_count    <= next_read_count;
		send_buffer   <= rst_n ? next_send_buffer : 0;
		recv_buffer   <= next_recv_buffer;
	end
	
	localparam STATE_IDLE = 0;
	localparam STATE_SEND = 1;
	localparam STATE_READ = 2;
	
	reg [1:0] state, next_state;
	reg mdio_in_mode;
	always @(posedge clk_mac) begin
		if(rst_n) begin
			state        <= next_state;
			mdio_in_mode <= next_state == STATE_READ;
		end else begin
			state        <= STATE_IDLE;
			mdio_in_mode <= 0;
		end
	end
	
	wire eth_mdio_in;
	IOBUF mdio_buf 
	(
		.O (eth_mdio_in),
		.IO(eth_mdio),
		.I (send_buffer[64]),
		.T (mdio_in_mode)
	);
	
	assign ready      = state == STATE_IDLE;
	assign read_value = recv_buffer;
	
	always @* begin
		next_state        = state;
		next_send_buffer  = send_buffer;
		next_write_counter = write_counter;
		next_read_count   = read_count;
		next_recv_buffer  = recv_buffer;
		next_is_write     = is_write;
		
		case(state)
			STATE_IDLE: begin
				if(valid) begin
					next_state         = STATE_SEND;
					next_write_counter = 0;
					next_read_count    = 0;
					next_send_buffer   = {1'b0, {32{1'b1}}, 2'b01, (write ? 2'b01 : 2'b10), phyaddr, register, 2'b10, write_value};
					next_is_write      = write;
				end
			end STATE_SEND: begin
				if(toggle) begin
					next_send_buffer   = {send_buffer[63:0], 1'b0};
					next_write_counter = write_counter + 1;
					if(!is_write && next_write_counter == 47)
						next_state = STATE_READ;
					else if(is_write && next_write_counter == 65)
						next_state = STATE_IDLE;
				end
			end STATE_READ: begin
				if(toggle) begin
					next_read_count  = read_count + 1;
					next_recv_buffer = {recv_buffer[14:0], eth_mdio_in};
					if(next_read_count == 17)
						next_state = STATE_IDLE;
				end
			end
		endcase
		
		if(next_state != STATE_SEND)
			next_send_buffer = 0;
	end

endmodule