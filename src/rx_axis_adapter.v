`timescale 1 ns / 1 ps

module rx_axis_adapter
(
	input            clk_mac,
	input            rst_n,
	
	input            rx_vld,
	input [7:0]      rx_dat,
	input            rx_sof,
	input            rx_eof,
	input            rx_err,
	
	output reg [7:0] rx_axis_mac_tdata,
	output reg       rx_axis_mac_tvalid,
	output           rx_axis_mac_tlast,
	output           rx_axis_mac_tuser
);

	always @(posedge clk_mac) begin
		rx_axis_mac_tvalid <= rst_n && rx_vld && !rx_eof;
		rx_axis_mac_tdata  <= rx_dat;
	end
	
	assign rx_axis_mac_tlast = rx_eof || rx_err;
	assign rx_axis_mac_tuser = rx_err;

endmodule