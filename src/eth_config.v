`timescale 1 ns / 1 ps

module eth_config
(
	input    clk_mac,
	input    rst_n,
	
	input    eth_intn,
	output   eth_mdc,
	inout    eth_mdio
);

	reg         smi_vld;
	reg  [4:0]  smi_reg;
	reg         smi_write;
	reg  [15:0] smi_write_val;
	wire [15:0] smi_read_val;
	wire        smi_ready;
	smi smi_inst
	( 
		.clk_mac    (clk_mac),
		.rst_n      (rst_n),
	
		.valid      (smi_vld),
		.ready      (smi_ready),
		.write      (smi_write),
		.write_value(smi_write_val),
		.phyaddr    (5'b1),
		.register   (smi_reg),
		.read_value (smi_read_val),
	
		.eth_mdc    (eth_mdc),
		.eth_mdio   (eth_mdio)
	);
	
	localparam STATE_RST     = 0;
	localparam STATE_MONITOR = 1;
	localparam STATE_READ    = 2;
	
	reg [2:0] state, next_state;
	always @(posedge clk_mac) begin
		if(rst_n)
			state <= next_state;
		else
			state <= STATE_RST;
	end
		
	reg [15:0] next_led;
	always @(posedge clk_mac)
		led <= next_led; 
		
	always @* begin
		next_state    = state;
		smi_vld       = 0;
		smi_reg       = 0;
		smi_write     = 0;
		smi_write_val = 0;
		next_led      = led;
		
		case(state)
			STATE_RST: begin
				next_state = STATE_MONITOR;
			end STATE_MONITOR: begin
				if(btnc) begin
					if(smi_ready) begin
						next_state = STATE_READ;
						smi_vld = 1;
						smi_reg = sw;
					end
				end else if(btnd) begin
					next_state = STATE_ENABLE_LOOPBACK;
				end
			end STATE_READ: begin
				if(smi_ready) begin
					next_state = STATE_MONITOR;
					next_led   = smi_read_val;
				end
			end
		endcase
	end

endmodule