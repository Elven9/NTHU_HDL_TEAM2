set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN W5 [get_ports clk]

set_property IOSTANDARD LVCMOS33 [get_ports {servo[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {servo[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {servo[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {servo[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports buttonMiddle]
set_property PACKAGE_PIN U18 [get_ports buttonMiddle]

##USB HID (PS/2)
set_property PACKAGE_PIN C17 [get_ports PS2_CLK]
set_property IOSTANDARD LVCMOS33 [get_ports PS2_CLK]
set_property PULLUP true [get_ports PS2_CLK]
set_property PACKAGE_PIN B17 [get_ports PS2_DATA]
set_property IOSTANDARD LVCMOS33 [get_ports PS2_DATA]
set_property PULLUP true [get_ports PS2_DATA]

set_property PACKAGE_PIN A14 [get_ports {servo[3]}]
set_property PACKAGE_PIN A16 [get_ports {servo[2]}]
set_property PACKAGE_PIN B15 [get_ports {servo[1]}]
set_property PACKAGE_PIN B16 [get_ports {servo[0]}]


set_property PACKAGE_PIN U16 [get_ports {rxData[0]}]
set_property PACKAGE_PIN E19 [get_ports {rxData[1]}]
set_property PACKAGE_PIN U19 [get_ports {rxData[2]}]
set_property PACKAGE_PIN V19 [get_ports {rxData[3]}]
set_property PACKAGE_PIN W18 [get_ports {rxData[4]}]
set_property PACKAGE_PIN U15 [get_ports {rxData[5]}]
set_property PACKAGE_PIN U14 [get_ports {rxData[6]}]
set_property PACKAGE_PIN V14 [get_ports {rxData[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rxData[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rxData[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rxData[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rxData[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rxData[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rxData[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rxData[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rxData[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports rx]
set_property PACKAGE_PIN K17 [get_ports rx]