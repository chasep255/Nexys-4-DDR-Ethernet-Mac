`timescale 1 ns / 1 ps


module test_bench();

	reg clk_100 = 0;
	reg clk_50  = 0;
	always #5 clk_100 <= ~clk_100;
	
	integer i;
	reg rst_n = 0;
	initial begin
		for(i = 0; i < 4096; i = i + 1)
			@(posedge clk_100);
		rst_n = 1;
	end
	
	
	reg btnu = 0;
	reg btnd = 0;
	top top_inst
	(
		.clk_100  (clk_100),
		.cpu_rst_n(rst_n),
		.btnu     (btnu),
		.btnd     (btnd),
		.sw       (0)
	);
	
	eth_sim eth_sim_inst
	(   
		.eth_mdc  (top.eth_mdc),
		.eth_mdio (top.eth_mdio),
		.eth_rstn (top.eth_rstn),
		.eth_crsdv(top.eth_crsdv),
		.eth_rxerr(top.eth_rxerr),
		.eth_rxd  (top.eth_rxd),
		.eth_txen (top.eth_txen),
		.eth_txd  (top.eth_txd),
		.eth_clkin(top.eth_clkin),
		.eth_intn (top.eth_intn)
	);
	
	reg [1522 * 8 - 1 : 0] data;
	reg [10:0]             len;
	reg                    err;
	initial begin
		@(posedge top.eth_rstn);
		
		for(i = 0; i < 100; i = i + 1)
			@(posedge top.clk_mac);
		
		eth_sim_inst.rx_sim_inst.send({112'hebeb000000ffffff}, 14);
		
		btnd = 1;
		
		for(i = 0; i < 10000; i = i + 1)
			@(posedge top.clk_mac);
		
		btnu = 1;
		
		eth_sim_inst.tx_sim_inst.recv(data, len, err);
		$display("%h", data);
		
	end
	
	
endmodule