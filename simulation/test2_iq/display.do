add wave -position end  result:/top_tb/clk
add wave -position end  result:/top_tb/resetn

add wave -divider

add wave -radix hex -position end  result:/top_tb/dut/iq_full
add wave -radix hex -position end  result:/top_tb/dut/data
add wave -radix hex -position end  result:/top_tb/dut/data_addr
add wave -radix hex -position end  result:/top_tb/dut/data_vld
add wave -radix hex -position end  result:/top_tb/dut/entry_count
add wave -divider

add wave -radix hex -position end  result:/top_tb/dut/rd_en
add wave -radix hex -position end  result:/top_tb/dut/wr_en
add wave -radix hex -position end  result:/top_tb/dut/stall
add wave -radix hex -position end  result:/top_tb/dut/queue_empty
add wave -radix hex -position end  result:/top_tb/dut/inst_addr_f
add wave -radix hex -position end  result:/top_tb/dut/inst_f
add wave -radix hex -position end  result:/top_tb/dut/inst_vld

add wave -divider
add wave -radix hex -position end  result:/top_tb/flush

