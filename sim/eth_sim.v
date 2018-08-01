`timescale 1 ns / 1 ps

module eth_sim
(   
	input        eth_mdc,
	inout        eth_mdio,
	input        eth_rstn,
	inout        eth_crsdv,
	inout        eth_rxerr,
	inout  [1:0] eth_rxd,
	input        eth_txen,
	input  [1:0] eth_txd,
	input        eth_clkin,
	inout        eth_intn
);
	wire       eth_rxerr_out;
	wire       eth_crsdv_out;
	wire [1:0] eth_rxd_out;
	
	assign eth_crsdv = eth_rstn ? eth_crsdv_out : 1'bz;
	assign eth_rxerr = eth_rstn ? eth_rxerr_out : 1'bz;
	assign eth_rxd   = eth_rstn ? eth_rxd_out   : 2'bzz;
	assign eth_intn  = eth_rstn ? 1'b0          : 1'bz;
	
	always @(posedge eth_rstn) begin
		$display("Got mode straps %b", {eth_crsdv, eth_rxd});
	end
	
	rx_sim rx_sim_inst
	(   
		.eth_clkin(eth_clkin),
		.eth_rstn (eth_rstn),
		.eth_crsdv(eth_crsdv_out),
		.eth_rxerr(eth_rxerr_out),
		.eth_rxd  (eth_rxd_out)
	);
	
	tx_sim tx_sim_inst
	(   
		.eth_rstn (eth_rstn),
		.eth_clkin(eth_clkin),
		.eth_txen (eth_txen),
		.eth_txd  (eth_txd)
	);
	
endmodule