add wave -position end  result:/top_tb/clk
add wave -position end  result:/top_tb/resetn

add wave -divider

add wave -position end  result:/top_tb/ifu_icu_req_ic1
add wave -position end  result:/top_tb/icu_ifu_ack_ic1
add wave -position end  result:/top_tb/icu_ifu_data_valid_ic2

add wave -divider
add wave -position end  result:/top_tb/uut/icu_req
add wave -position end  result:/top_tb/uut/icu_req_q

