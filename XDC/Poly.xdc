# Frequency 100MHz
# create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} [get_ports clk]
# Frequency 122MHz
# create_clock -period 8.200  -name sys_clk -waveform {0.000 4.100} [get_ports clk]
# Frequency 150MHz
create_clock -period 6.667  -name sys_clk -waveform {0.000 3.333} [get_ports clk]