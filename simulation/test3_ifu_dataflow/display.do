add wave -position end  result:/top_tb/clk
add wave -position end  result:/top_tb/resetn

add wave -divider

add wave -radix hex -position end  result:/top_tb/dut/iq_full
add wave -radix hex -position end  result:/top_tb/dut/ifu_icu_req_ic1
add wave -radix hex -position end  result:/top_tb/icu_ifu_ack_ic1
add wave -radix hex -position end  result:/top_tb/dut/icu_ifu_data_ic2
add wave -radix hex -position end  result:/top_tb/dut/icu_ifu_data_valid_ic2
add wave -radix hex -position end  result:/top_tb/dut/icu_data_vld

add wave -divider
add wave -radix hex -position end  result:/top_tb/dut/inst_addr_f
add wave -radix hex -position end  result:/top_tb/dut/inst_f
add wave -radix hex -position end  result:/top_tb/dut/inst_vld_f
add wave -radix hex -position end  result:/top_tb/dut/flush
add wave -radix hex -position end  result:/top_tb/dut/stall
add wave -divider
add wave -radix hex -position end  result:/top_tb/dut/exu_ifu_stall
add wave -radix hex -position end  result:/top_tb/dut/ifu_exu_vld_d
add wave -radix hex -position end  result:/top_tb/dut/ifu_exu_pc_d
add wave -divider
