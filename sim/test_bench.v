`timescale 1 ns / 1 ps


module test_bench();

	reg clk_100 = 0;
	reg clk_50 = 0;
	always #5 clk_100 <= ~clk_100;
	always #10 clk_50 <= ~clk_50;
	
	integer i;
	reg rst_n = 0;
	initial begin
		for(i = 0; i < 4096; i = i + 1)
			@(posedge clk_100);
		rst_n = 1;
	end
	
//	top top_inst
//	(
//		.clk_100(clk_100),
//		.cpu_rst_n(rst_n),
//		.sw(5'd5),
//		.btnc(1'b0),
//		.btnu(1'b1)
//	);
	
	
	reg        tx_vld;	
	reg [7:0]  tx_dat;
	reg        tx_sof;
	reg        tx_eof;
	wire       tx_ack;
	wire [1:0] eth_txd;
	wire       eth_txen;
	eth_tx eth_tx_inst
	(
		.clk_mac(clk_50),
		.rst_n  (rst_n),
	
		.eth_txd(eth_txd),	
		.eth_txen(eth_txen),
	
		.tx_vld(tx_vld),
		.tx_dat(tx_dat),
		.tx_sof(tx_sof),
		.tx_eof(tx_eof),
		.tx_err(1'b0),
		.tx_ack(tx_ack)
	);
	
	reg [7:0] tx_pkt [63:0];
	reg [7:0] tx_idx = 0;
	initial begin
		tx_pkt[0] = 8'b0;
		tx_pkt[1] = 8'hff;
		tx_pkt[2] = 8'hff;
		tx_pkt[3] = 8'hff;
		tx_pkt[4] = 8'hff;
		tx_pkt[5] = 8'hff;
		tx_pkt[6] = 8'h0;
		tx_pkt[7] = 8'h0;
		tx_pkt[8] = 8'h0;
		tx_pkt[9] = 8'h0;
		tx_pkt[10] = 8'h0;
		tx_pkt[11] = 8'h0;
		tx_pkt[12] = 8'hde;
		tx_pkt[13] = 8'had;
		tx_pkt[14] = 8'hbe;
		tx_pkt[15] = 8'hef;
		tx_pkt[16] = 8'h0;
		tx_pkt[17] = 8'h0;
		tx_pkt[18] = 8'h0;
		tx_pkt[19] = 8'h0;
		tx_pkt[20] = 8'h0;
		tx_pkt[21] = 8'h0;
		tx_pkt[22] = 8'h0;
		tx_pkt[23] = 8'h0;
		tx_pkt[24] = 8'h0;
		tx_pkt[25] = 8'h0;
		tx_pkt[26] = 8'h0;
		tx_pkt[27] = 8'h0;
		tx_pkt[28] = 8'h0;
		tx_pkt[29] = 8'h0;
		tx_pkt[30] = 8'h0;
		tx_pkt[31] = 8'h0;
		tx_pkt[32] = 8'h0;
		tx_pkt[33] = 8'h0;
		tx_pkt[34] = 8'h0;
		tx_pkt[35] = 8'h0;
		tx_pkt[36] = 8'h0;
		tx_pkt[37] = 8'h0;
		tx_pkt[38] = 8'h0;
		tx_pkt[39] = 8'h0;
		tx_pkt[40] = 8'h0;
		tx_pkt[41] = 8'h0;
		tx_pkt[42] = 8'h0;
		tx_pkt[43] = 8'h0;
		tx_pkt[44] = 8'h0;
		tx_pkt[45] = 8'h0;
		tx_pkt[46] = 8'h0;
		tx_pkt[47] = 8'h0;
		tx_pkt[48] = 8'h0;
		tx_pkt[49] = 8'h0;
		tx_pkt[50] = 8'h0;
		tx_pkt[51] = 8'h0;
		tx_pkt[52] = 8'h0;
		tx_pkt[53] = 8'h0;
		tx_pkt[54] = 8'h0;
		tx_pkt[55] = 8'h0;
		tx_pkt[56] = 8'h0;
		tx_pkt[57] = 8'h0;
		tx_pkt[58] = 8'h0;
		tx_pkt[59] = 8'h0;
		tx_pkt[60] = 8'h0;
		tx_pkt[61] = 8'h0;
		tx_pkt[62] = 8'h0;
		tx_pkt[63] = 8'hff;
	end
	wire cond = rst_n && tx_idx < 65;
	always @(posedge clk_50) begin
		if(rst_n && tx_idx < 65) begin
			tx_vld <= 1;
			tx_dat <= tx_pkt[tx_idx];
			tx_sof <= tx_idx == 0;
			tx_eof <= tx_idx == 64;
			tx_idx <= tx_idx + tx_ack;
		end else
			tx_vld <= 0;
	end
	
	wire       rx_vld;
	wire [7:0] rx_dat;
	wire       rx_sof;
	wire       rx_eof;
	eth_rx eth_rx_inst
	(
		.clk_mac  (clk_50),
		.rst_n    (rst_n),
		
		.eth_crsdv(eth_txen),
		.eth_rxerr(1'b0),
		.eth_rxd  (eth_txd),
		
		.rx_vld   (rx_vld),
		.rx_dat   (rx_dat),
		.rx_sof   (rx_sof),
		.rx_eof   (rx_eof)
	);
	
	
endmodule