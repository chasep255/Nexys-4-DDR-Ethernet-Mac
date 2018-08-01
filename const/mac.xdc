set_input_delay -clock clk_mac 5.000 [get_ports {eth_crsdv eth_rxd eth_rxerr}]
set_output_delay -clock clk_mac 5.000 [get_ports {eth_txd eth_txen}]