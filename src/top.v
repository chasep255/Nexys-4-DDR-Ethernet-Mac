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
	wire clk_eth;
	wire clk_fb;
	wire pll_locked;
	PLLE2_BASE#
	(
		.CLKFBOUT_MULT (10),
		.CLKOUT0_DIVIDE(20),
		.CLKOUT1_DIVIDE(20),
		.CLKOUT1_PHASE (45.0),
		.CLKIN1_PERIOD (10.0)
	)
	clk_gen 
	(
		.CLKOUT0 (clk_mac),
		.CLKOUT1 (clk_eth),
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
	
	eth_mac mac_inst
	(
		.clk_mac  (clk_mac),
		.clk_eth  (clk_eth),
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
		.eth_intn (eth_intn)
	);
	
	
endmodule
