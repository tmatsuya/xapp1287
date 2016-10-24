
## UART
set_property IOSTANDARD LVCMOS25 [get_ports rs232_uart_rxd]
##USB_TX
set_property PACKAGE_PIN M19 [get_ports rs232_uart_rxd]
set_property IOSTANDARD LVCMOS25 [get_ports rs232_uart_txd]
##USB_RX
set_property PACKAGE_PIN K24 [get_ports rs232_uart_txd]


# I2C
set_property IOSTANDARD LVCMOS25 [get_ports iic_fmc_scl_io]
#FMC_HPC_LA06_P
set_property PACKAGE_PIN H30 [get_ports iic_fmc_scl_io]
set_property IOSTANDARD LVCMOS25 [get_ports iic_fmc_sda_io]
#FMC_HPC_LA06_N
set_property PACKAGE_PIN G30 [get_ports iic_fmc_sda_io]
