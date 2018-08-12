`timescale 1 ns / 1 ps

(* keep_hierarchy = "yes" *)
module eth_config
(
	input             clk_mac,
	input             rst_n,
	
	input             eth_intn,
	output            eth_mdc,
	inout             eth_mdio,
	
	input             reg_vld,
	input      [4:0]  reg_addr,
	input             reg_write,
	input      [15:0] reg_wval,
	output reg [15:0] reg_rval,
	output reg        reg_ack,
	
	output reg        speed_100,
	output reg        full_duplex,
	output reg        link_up,
	output reg        remote_fault,
	output reg        auto_neg_done
);

	reg         smi_vld;
	reg  [4:0]  smi_reg;
	reg         smi_write;
	reg  [15:0] smi_write_val;
	wire [15:0] smi_read_val;
	wire        smi_ready;
	eth_smi eth_smi_inst
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
	
	localparam STATE_RST        = 0;
	localparam STATE_IDLE       = 1;
	localparam STATE_CHECK_REQ  = 2;
	localparam STATE_CHECK_READ = 3;
	localparam STATE_USER_REQ   = 4;
	localparam STATE_USER_READ  = 5;
	
	reg [2:0] state, next_state;
	always @(posedge clk_mac) begin
		if(rst_n)
			state <= next_state;
		else
			state <= STATE_RST;
	end
	
	reg [21:0] check_counter = 0;
	always @(posedge clk_mac)
		check_counter <= check_counter + 1;
		
	always @(posedge clk_mac) begin
		if(rst_n) begin
			if(state == STATE_CHECK_READ && smi_ready) begin
				speed_100     <= |{smi_read_val[15:14],smi_read_val[10:9]};
				full_duplex   <= |{smi_read_val[14], smi_read_val[12], smi_read_val[10]};
				link_up       <= smi_read_val[2];
				remote_fault  <= smi_read_val[4];
				auto_neg_done <= smi_read_val[5];
			end
		end else begin
			speed_100     <= 0;
			full_duplex   <= 0;
			link_up       <= 0;
			remote_fault  <= 0;
			auto_neg_done <= 0;
		end
	end
	
	reg [15:0] next_reg_rval;
	reg        next_reg_ack;
	always @(posedge clk_mac) begin
		reg_ack  <= rst_n && next_reg_ack;
		reg_rval <= next_reg_rval;
	end
		
	always @* begin
		next_state    = state;
		smi_vld       = 0;
		smi_reg       = 0;
		smi_write     = 0;
		smi_write_val = 0;
		next_reg_ack  = 0;
		next_reg_rval = 0;
		
		case(state)
			STATE_RST: begin
				next_state = STATE_IDLE;
			end STATE_IDLE: begin
				if(&check_counter)
					next_state = STATE_CHECK_REQ;
				else if(reg_vld && !reg_ack) 
					next_state = STATE_USER_REQ;
			end STATE_CHECK_REQ: begin
				smi_reg = 1;
				smi_vld = 1;
				if(smi_ready)
					next_state = STATE_CHECK_READ;
			end STATE_CHECK_READ: begin
				if(smi_ready)
					next_state = STATE_IDLE;
			end STATE_USER_REQ: begin
				if(smi_ready) begin
					smi_vld       = 1;
					smi_reg       = reg_addr;
					smi_write     = reg_write;
					smi_write_val = reg_wval;
					next_state    = STATE_USER_READ;
				end
			end STATE_USER_READ: begin
				if(smi_ready) begin
					next_state    = STATE_IDLE;
					next_reg_ack  = 1;
					next_reg_rval = smi_read_val;
				end
			end
		endcase
		
	end

endmodule