`timescale 1 ns / 1 ps

module eth_sim
(   
	input         eth_mdc,
	inout         eth_mdio,
	input         eth_rstn,
	output        eth_crsdv,
	output        eth_rxerr,
	output [1:0]  eth_rxd,
	input         eth_txen,
	input  [1:0]  eth_txd,
	input         eth_clkin,
	output        eth_intn
);
	rx_sim rx_sim_inst
	(   
		.eth_clkin(eth_clkin),
		.eth_rstn (eth_rstn),
		.eth_crsdv(eth_crsdv),
		.eth_rxerr(eth_rxerr),
		.eth_rxd  (eth_rxd)
	);
	
	tx_sim tx_sim_inst
	(   
		.eth_rstn (eth_rstn),
		.eth_clkin(eth_clkin),
		.eth_txen (eth_txen),
		.eth_txd  (eth_txd)
	);
	
endmodule