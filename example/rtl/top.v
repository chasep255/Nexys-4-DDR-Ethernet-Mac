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
	output reg [15:0] led,
	input             btnu
);
	integer i;
	
	wire clk_mac;
	wire clk_phy;
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
		.CLKOUT1 (clk_phy),
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
	
	wire btnu_d;
	debounce#(1) btnu_debounce
	(
		.clk(clk_mac),
		.in (btnu),
		.out(btnu_d)
	);
	
	(* mark_debug = "true" *)
	wire [7:0]  rx_axis_mac_tdata;
	(* mark_debug = "true" *)
	wire        rx_axis_mac_tvalid;
	(* mark_debug = "true" *)
	wire        rx_axis_mac_tlast;
	(* mark_debug = "true" *)
	wire        rx_axis_mac_tuser;
	(* mark_debug = "true" *)
	reg [7:0]   tx_axis_mac_tdata;
	(* mark_debug = "true" *)
	reg         tx_axis_mac_tvalid;
	(* mark_debug = "true" *)
	reg         tx_axis_mac_tlast;
	(* mark_debug = "true" *)
	wire        tx_axis_mac_tready;
	reg         reg_vld = 0;
	reg  [4:0]  reg_addr;
	reg         reg_write;
	reg  [15:0] reg_wval;
	wire [15:0] reg_rval;
	wire        reg_ack;
	eth_mac#(1) mac_inst
	(
		.clk_mac    (clk_mac),
		.clk_phy    (clk_phy),
		.rst_n      (rst_n),
		.mode_straps(3'b111),
	
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
		
		.rx_axis_mac_tdata (rx_axis_mac_tdata),
		.rx_axis_mac_tvalid(rx_axis_mac_tvalid),
		.rx_axis_mac_tlast (rx_axis_mac_tlast),
		.rx_axis_mac_tuser (rx_axis_mac_tuser),
		.tx_axis_mac_tdata (tx_axis_mac_tdata),
		.tx_axis_mac_tvalid(tx_axis_mac_tvalid),
		.tx_axis_mac_tlast (tx_axis_mac_tlast),
		.tx_axis_mac_tready(tx_axis_mac_tready),
		
		.reg_vld  (reg_vld),
		.reg_addr (reg_addr),
		.reg_write(reg_write),
		.reg_wval (reg_wval),
		.reg_rval (reg_rval),
		.reg_ack  (reg_ack)
	);
	
	reg [7:0] tx_pkt [63:0];
	reg [7:0] tx_idx = 65;
	initial begin
		tx_pkt[0]  = 8'hff;
		tx_pkt[1]  = 8'hff;
		tx_pkt[2]  = 8'hff;
		tx_pkt[3]  = 8'hff;
		tx_pkt[4]  = 8'hff;
		tx_pkt[5]  = 8'hff;
		tx_pkt[6]  = 8'h0;
		tx_pkt[7]  = 8'h0;
		tx_pkt[8]  = 8'h0;
		tx_pkt[9]  = 8'h0;
		tx_pkt[10] = 8'h0;
		tx_pkt[11] = 8'h0;
		tx_pkt[12] = 8'heb;
		tx_pkt[13] = 8'heb;
		for(i = 14; i < 64; i = i + 1)
			tx_pkt[i] = i;
	end
	
	always @(posedge clk_mac) begin
		if(btnu_d) begin
			tx_idx             <= 0;
			tx_axis_mac_tdata  <= tx_pkt[0];
			tx_axis_mac_tvalid <= 1;
			tx_axis_mac_tlast  <= 0;
		end else if(tx_idx < 64) begin
			tx_axis_mac_tvalid <= 1;
			tx_axis_mac_tdata  <= tx_pkt[tx_idx + tx_axis_mac_tready];
			tx_axis_mac_tlast  <= (tx_idx + tx_axis_mac_tready) == 63;
			tx_idx             <= tx_idx + tx_axis_mac_tready;
		end else
			tx_axis_mac_tvalid <= 0;
	end
	
	localparam STATE_RST       = 0;
	localparam STATE_IDLE      = 1;
	localparam STATE_CHECK_REG = 2;
	
	reg [2:0]  state, next_state;
	reg [15:0]        next_led;
	reg [20:0] count = 0;
	always @(posedge clk_mac) begin
		state <= rst_n ? next_state : STATE_RST;
		led   <= next_led;
		count <= count + 1;
	end
	
	always @* begin
		next_state = state;
		next_led   = led;
		reg_vld    = 0;
		reg_write  = 0;
		reg_addr   = 0;
		reg_wval   = 0;
		
		case(state)
			STATE_RST: begin
				next_state = STATE_IDLE;
			end STATE_IDLE: begin
				if(&count)
					next_state = STATE_CHECK_REG;
			end STATE_CHECK_REG: begin
				reg_vld  = 1;
				reg_addr = sw;
				if(reg_ack) begin
					next_state = STATE_IDLE;
					next_led   = reg_rval;
				end
			end
		endcase
	end
	
endmodule
