`timescale 1 ns / 1 ps

(* keep_hierarchy = "yes" *)
module eth_mac
(
	input         clk_mac,
	input         clk_eth,
	input         rst_n,
	
	output        eth_mdc,
	inout         eth_mdio,
	output        eth_rstn,
	inout         eth_crsdv,
	inout         eth_rxerr,
	inout  [1:0]  eth_rxd,
	output        eth_txen,
	output [1:0]  eth_txd,
	output        eth_clkin,
	inout         eth_intn,
	
	output        rx_vld,
	output [7:0]  rx_dat,
	output        rx_sof,
	output        rx_eof,
	output [10:0] rx_len,
	output        rx_err,
	
	input         tx_vld,
	input [7:0]   tx_dat,
	input         tx_sof,
	input         tx_eof,
	input         tx_err,
	output        tx_ack
);
	assign eth_crsdv = 1'bz;
	assign eth_rxerr = 1'bz;
	assign eth_rxd   = 2'bzz;
	assign eth_intn  = 1'bz;
	assign eth_rstn  = rst_n;
	assign eth_clkin = clk_eth;
	
	eth_config eth_config_inst
	(
		.clk_mac (clk_mac),
		.rst_n   (rst_n),
		
		.eth_intn(eth_intn),
		.eth_mdc (eth_mdc),
		.eth_mdio(eth_mdio)
	);
	
	eth_rx eth_rx_inst
	(
		.clk_mac  (clk_mac),
		.rst_n    (rst_n),
		
		.eth_crsdv(eth_crsdv),
		.eth_rxerr(eth_rxerr),
		.eth_rxd  (eth_rxd),
		
		.rx_vld   (rx_vld),
		.rx_dat   (rx_dat),
		.rx_sof   (rx_sof),
		.rx_eof   (rx_eof),
		.rx_err   (rx_err),
		.rx_len   (rx_len)
	);
	
	
	eth_tx eth_tx_inst
	(
		.clk_mac(clk_mac),
		.rst_n  (rst_n),
	
		.eth_txd(eth_txd),	
		.eth_txen(eth_txen),
	
		.tx_vld(tx_vld),
		.tx_dat(tx_dat),
		.tx_sof(tx_sof),
		.tx_eof(tx_eof),
		.tx_err(tx_err),
		.tx_ack(tx_ack)
	);

endmodule