`timescale 1 ns / 1 ps

module tx_sim
(   
	input       eth_rstn,
	input       eth_clkin,
	input       eth_txen,
	input [1:0] eth_txd
);

	`include "../rtl/util.vh"
	
	reg         crc_rst;
	reg         crc_vld;
	reg  [7:0]  crc_dat;
	wire [31:0] crc_code;
	wire [31:0] crc_bswap = bswap32(crc_code);
	crc32 crc32_inst
	(
		.clk (eth_clkin),
		.rst (crc_rst),
		.vld (crc_vld),
		.data(crc_dat),
		.crc (crc_code)
	);
	
	reg verbose = 1;
	task set_verbose;
		input verbose_;
		begin
			verbose = verbose_;
		end
	endtask
	
	reg [31:0] test;
	
	task recv;
		output [1522 * 8 - 1 : 0] data;
		output [10:0]             len;
		output                    err;
		integer i, b;
		reg [7:0]  byte_buf;
		reg [63:0] preamble_buffer;
		begin
			preamble_buffer = 0;
			while(preamble_buffer != 64'hd555555555555555) begin
				preamble_buffer = eth_txen ? {eth_txd, preamble_buffer[63:2]} : 0;
				@(posedge eth_clkin); #0.001;
			end
			
			if(verbose)
				$display("TX SOF");
			
			crc_rst = 1;
			crc_vld = 0;
			i       = 0;
			b       = 0;
			while(eth_txen) begin
				byte_buf = {eth_txd, byte_buf[7:2]};
				b = b + 1;
				
				if(b == 4) begin
					if(i >= 4) begin
						crc_vld = 1;
						crc_dat = data[(i - 4) * 8 +: 8];
					end
					data[i * 8 +: 8] = byte_buf;
					b = 0;
					if(verbose)
						$display("TX DATA[%d] = %h", i, byte_buf);
					i = i + 1;
				end
				
				@(posedge eth_clkin); #0.001;
				crc_rst = 0;
				crc_vld = 0;
			end
			
			len = i;
			err = 0;
			
			if(verbose) begin
				$display("TX CRC          = %h", data[(i - 4) * 8 +: 32]);
				$display("TX EXPECTED CRC = %h", crc_bswap);
			end
			
			if(b != 0) begin
				if(verbose) 
					$display("TX INCOMPLETE TRANSMIT");
				err = 1;
			end else if(i < 68) begin
				if(verbose)
					$display("TX FRAME TOO SHORT");
				err = 1;
			end else if(crc_bswap != data[(i - 4) * 8 +: 32]) begin
				if(verbose)
					$display("TX CRC FAIL");
				err = 1;
			end else begin
				if(verbose)
					$display("TX EOF");
			end
		end
	endtask
	
endmodule