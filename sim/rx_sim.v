`timescale 1 ns / 1 ps

module rx_sim
(   
	input            eth_rstn,
	input            eth_clkin,
	output reg       eth_crsdv,
	output reg       eth_rxerr,
	output reg [1:0] eth_rxd
	
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
	
	initial begin
		eth_crsdv = 0;
		eth_rxd   = 0;
		eth_rxerr = 0;
	end
	
	reg verbose = 1;
	task set_verbose;
		input verbose_;
		begin
			verbose = verbose_;
		end
	endtask
	
	task send;
		input [8 * 1500 - 1 : 0] data;
		input [10:0]             len;
		
		integer i;
		begin
			@(posedge eth_clkin); #0.001;
			eth_crsdv = 1;
			eth_rxd   = 0;
			eth_rxerr = 0;
			crc_rst   = 1;
			crc_vld   = 0;
			crc_dat   = 0;
			
			
			if(verbose)
				$display("RX SOF");
			for(i = 0; i < (8 * 4 - 1); i = i + 1) begin
				@(posedge eth_clkin); #0.001;
				eth_rxd = 2'b01;
			end
			
			@(posedge eth_clkin); #0.001;
				eth_rxd = 2'b11;
			
			if(verbose)
				$display("RX SOD");
			
			crc_rst = 0;
			for(i = 0; i < 8 * len; i = i + 2) begin
				@(posedge eth_clkin); #0.001;
				eth_rxd = data[i + 1 -: 2];
				if(i % 8 == 0) begin
					crc_vld = 1;
					crc_dat = data[i +: 8];
					if(verbose)
						$display("RX SENT DATA[%d] %02h", i / 8, data[i +: 8]);
				end else
					crc_vld = 0;
			end
			
			while(i < 8 * 64) begin
				@(posedge eth_clkin); #0.001;
				eth_rxd = 2'b0;
				if(i % 8 == 0) begin
					crc_vld = 1;
					crc_dat = 0;
					if(verbose)
						$display("RX SENT PAD");
				end else
					crc_vld = 0;
				i = i + 2;
			end
			
			
			for(i = 0; i < (4 * 8); i = i + 2) begin
				@(posedge eth_clkin); #0.001;
				eth_rxd = crc_bswap[i + 1 -: 2];
				crc_vld = 0;
			end
			
			if(verbose)
				$display("RX SENT CRC32 %08h", crc_code);
			
			@(posedge eth_clkin); #0.001;
			eth_crsdv = 0;
			eth_rxd   = 0;
			
			if(verbose)
				$display("RX EOF");
		end
	endtask
	
endmodule