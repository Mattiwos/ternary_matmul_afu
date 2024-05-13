create_clock -name clk -period 30.000 [get_ports clk_i]
set_output_delay -clock clk -max 2.0 [get_ports {*_o[*]}]
set_input_delay -clock clk -max 2.0 [get_ports {*_i[*]}]
