`timescale 1 ns / 1 ps

module top
(
	input             clk_100,
	input             cpu_rst_n,
	
	output            eth_mdc,
	inout             eth_mdio,
	output            eth_rstn,
	inout             eth_crsdv,
	inout             eth_rxerr,
	inout  [1:0]      eth_rxd,
	output            eth_txen,
	output [1:0]      eth_txd,
	output            eth_clkin,
	inout             eth_intn,
	input      [15:0] sw,
	output     [15:0] led,
	input             btnc,
	input             btnu,
	input             btnd
);
	
	wire clk_mac;
	wire clk_fb;
	wire pll_locked;
	PLLE2_BASE#
	(
		.CLKFBOUT_MULT (10),
		.CLKOUT0_DIVIDE(20),
		.CLKIN1_PERIOD (10.0)
	)
	clk_gen 
	(
		.CLKOUT0 (clk_mac),
		.CLKFBOUT(clk_fb),
		.LOCKED  (pll_locked),
		.CLKIN1  (clk_100),
		.RST     (1'b0),
		.CLKFBIN (clk_fb)
	);
	
	reg        rst_n         = 0;
	reg [15:0] rst_n_counter = 0;
	always @(posedge clk_mac) begin
		rst_n         <= (rst_n || &rst_n_counter) && pll_locked && cpu_rst_n;
		rst_n_counter <= rst_n ? 0 : rst_n_counter + 1;
	end
	
	wire btnc_d;
	debounce#(1) btnc_debounce
	(
		.clk(clk_mac),
		.in (btnc),
		.out(btnc_d)
	);
	
	wire btnu_d;
	debounce#(1) btnu_debounce
	(
		.clk(clk_mac),
		.in (btnu),
		.out(btnu_d)
	);
	
	wire btnd_d;
	debounce#(1) btnd_debounce
	(
		.clk(clk_mac),
		.in (btnd),
		.out(btnd_d)
	);
	
	wire        rx_vld;
	wire [7:0]  rx_dat;
	wire        rx_sof;
	wire        rx_eof;
	wire [10:0] rx_len;
	wire        rx_err;
	reg         tx_vld;
	reg  [7:0]  tx_dat;
	reg         tx_sof;
	reg         tx_eof;
	reg         tx_err = 0;
	wire        tx_ack;
	eth_mac mac_inst
	(
		.clk_mac  (clk_mac),
		.rst_n    (rst_n),
	
		.eth_mdc  (eth_mdc),
		.eth_mdio (eth_mdio),
		.eth_rstn (eth_rstn),
		.eth_crsdv(eth_crsdv),
		.eth_rxerr(eth_rxerr),
		.eth_rxd  (eth_rxd),
		.eth_txen (eth_txen),
		.eth_txd  (eth_txd),
		.eth_clkin(eth_clkin),
		.eth_intn (eth_intn),
		
		.rx_vld   (rx_vld),
		.rx_dat   (rx_dat),
		.rx_sof   (rx_sof),
		.rx_eof   (rx_eof),
		.rx_len   (rx_len),
		.rx_err   (rx_err),
	
		.tx_vld   (tx_vld),
		.tx_dat   (tx_dat),
		.tx_sof   (tx_sof),
		.tx_eof   (tx_eof),
		.tx_err   (tx_err),
		.tx_ack   (tx_ack)
	);
	
	reg [7:0] tx_pkt [63:0];
	reg [7:0] tx_idx = 65;
	initial begin
		tx_pkt[0] = 8'hff;
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
		tx_pkt[12] = 8'heb;
		tx_pkt[13] = 8'heb;
		tx_pkt[14] = 8'h0;
		tx_pkt[15] = 8'h0;
		tx_pkt[16] = 8'h0;
		tx_pkt[17] = 8'h0;
		tx_pkt[18] = 8'hde;
		tx_pkt[19] = 8'had;
		tx_pkt[20] = 8'hbe;
		tx_pkt[21] = 8'hef;
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
		tx_pkt[57] = 8'h1;
		tx_pkt[58] = 8'h2;
		tx_pkt[59] = 8'h3;
		tx_pkt[60] = 8'h4;
		tx_pkt[61] = 8'h5;
		tx_pkt[62] = 8'h6;
		tx_pkt[63] = 8'h7;
	end
	
	always @(posedge clk_mac) begin
		if(btnu_d)
			tx_idx <= 0;
		
		if(tx_idx < 65) begin
			tx_vld <= 1;
			tx_dat <= tx_pkt[tx_idx];
			tx_sof <= tx_idx == 0;
			tx_eof <= tx_idx == 64;
			tx_idx <= tx_idx + tx_ack;
		end else
			tx_vld <= 0;
	end
	
	
endmodule
