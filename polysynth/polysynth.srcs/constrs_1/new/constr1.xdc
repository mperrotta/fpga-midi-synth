set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk_100MHz]

#set_property PACKAGE_PIN H14 [get_ports dac_LRCK]
#set_property IOSTANDARD LVCMOS33 [get_ports dac_LRCK]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports dac_LRCK]

#set_property PACKAGE_PIN G16 [get_ports dac_SDIN]
#set_property IOSTANDARD LVCMOS33 [get_ports dac_SDIN]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports dac_SDIN]

#set_property PACKAGE_PIN D14 [get_ports dac_MCLK]
#set_property IOSTANDARD LVCMOS33 [get_ports dac_MCLK]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports dac_MCLK]

#set_property PACKAGE_PIN F16 [get_ports dac_SCLK]
#set_property IOSTANDARD LVCMOS33 [get_ports dac_SCLK]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports dac_SCLK]

#set_property -dict { PACKAGE_PIN F4    IOSTANDARD LVCMOS33 } [get_ports { PS2_CLK }]; #IO_L13P_T2_MRCC_35 Sch=ps2_clk
#set_property -dict { PACKAGE_PIN B2    IOSTANDARD LVCMOS33 } [get_ports { PS2_DATA }]; #IO_L10N_T1_AD15N_35 Sch=ps2_data


set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports o_clk31250]



##7 segment display

set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {SEG[0]}]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {SEG[1]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {SEG[2]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {SEG[3]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {SEG[4]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {SEG[5]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {SEG[6]}]

set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports DP]

set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {AN[0]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {AN[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {AN[2]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {AN[3]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {AN[4]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {AN[5]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {AN[6]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {AN[7]}]

#set_property PACKAGE_PIN C17 [get_ports midi_data_bit]
#set_property IOSTANDARD LVCMOS33 [get_ports midi_data_bit]
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports midi_data_bit]


create_generated_clock -name clk31250 -source [get_ports clk_100MHz] -divide_by 3200 [get_pins clk31250_reg/Q]

create_clock -period 10.000 -name clk_100MHz -waveform {0.000 5.000} -add [get_ports clk_100MHz]

