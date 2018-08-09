`timescale 1 ns / 1 ps

(* keep_hierarchy = "yes" *)
module eth_mac_axis
(
	input         clk_mac,
	input         clk_phy,
	input         rst_n,
	input [2:0]   mode_straps,
	
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
	
	input  [7:0]  tx_axis_mac_tdata,
	input         tx_axis_mac_tvalid,
	input         tx_axis_mac_tlast,
	output        tx_axis_mac_tready,
	
	output [7:0]  rx_axis_mac_tdata,
	output        rx_axis_mac_tvalid,
	output        rx_axis_mac_tlast,
	output        rx_axis_mac_tuser,
	
	input         reg_vld,
	input  [4:0]  reg_addr,
	input         reg_write,
	input  [15:0] reg_wval,
	output [15:0] reg_rval,
	output        reg_ack,
	
	output        speed_100,
	output        full_duplex,
	output        link_up,
	output        remote_fault,
	output        auto_neg_done
);

	wire       mac_rx_vld;
	wire [7:0] mac_rx_dat;
	wire       mac_rx_sof;
	wire       mac_rx_eof;
	wire       mac_rx_err;
		
	wire       mac_tx_vld;
	wire [7:0] mac_tx_dat;
	wire       mac_tx_sof;
	wire       mac_tx_eof;
	wire       mac_tx_ack;

	eth_mac mac_inst
	(
		.clk_mac      (clk_mac),
		.clk_phy      (clk_phy),
		.rst_n        (rst_n),
		.mode_straps  (mode_straps),
		
		.eth_mdc      (eth_mdc),
		.eth_mdio     (eth_mdio),
		.eth_rstn     (eth_rstn),
		.eth_crsdv    (eth_crsdv),
		.eth_rxerr    (eth_rxerr),
		.eth_rxd      (eth_rxd),
		.eth_txen     (eth_txen),
		.eth_txd      (eth_txd),
		.eth_clkin    (eth_clkin),
		.eth_intn     (eth_intn),
		
		.rx_vld       (mac_rx_vld),
		.rx_dat       (mac_rx_dat),
		.rx_sof       (mac_rx_sof),
		.rx_eof       (mac_rx_eof),
		.rx_err       (mac_rx_err),
		
		.tx_vld       (mac_tx_vld),
		.tx_dat       (mac_tx_dat),
		.tx_sof       (mac_tx_sof),
		.tx_eof       (mac_tx_eof),
		.tx_ack       (mac_tx_ack),
		
		.reg_vld      (reg_vld),
		.reg_addr     (reg_addr),
		.reg_write    (reg_write),
		.reg_wval     (reg_wval),
		.reg_rval     (reg_rval),
		.reg_ack      (reg_ack),
		
		.speed_100    (speed_100),
		.full_duplex  (full_duplex),
		.link_up      (link_up),
		.remote_fault (remote_fault),
		.auto_neg_done(auto_neg_done)
	);
	
	tx_axis_adapter tx_axis_inst
	(
		.clk_mac           (clk_mac),
		.rst_n             (rst_n),
		
		.tx_vld            (mac_tx_vld),
		.tx_dat            (mac_tx_dat),
		.tx_sof            (mac_tx_sof),
		.tx_eof            (mac_tx_eof),
		.tx_ack            (mac_tx_ack),
		
		.tx_axis_mac_tdata (tx_axis_mac_tdata),
		.tx_axis_mac_tvalid(tx_axis_mac_tvalid),
		.tx_axis_mac_tlast (tx_axis_mac_tlast),
		.tx_axis_mac_tready(tx_axis_mac_tready)
	);
	
	rx_axis_adapter rx_axis_inst
	(
		.clk_mac           (clk_mac),
		.rst_n             (rst_n),
		
		.rx_vld            (mac_rx_vld),
		.rx_dat            (mac_rx_dat),
		.rx_sof            (mac_rx_sof),
		.rx_eof            (mac_rx_eof),
		.rx_err            (mac_rx_err),
		
		.rx_axis_mac_tdata (rx_axis_mac_tdata),
		.rx_axis_mac_tvalid(rx_axis_mac_tvalid),
		.rx_axis_mac_tlast (rx_axis_mac_tlast),
		.rx_axis_mac_tuser (rx_axis_mac_tuser)
	);
	

endmodule