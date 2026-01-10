add wave -position end  result:/top_tb/clk
add wave -position end  result:/top_tb/resetn

add wave -divider
add wave -radix hex -position end  result:/top_tb/uut/flush
add wave -radix hex -position end  result:/top_tb/uut/stall
add wave -radix hex -position end  result:/top_tb/uut/exu_ifu_stall
add wave -divider
add wave -radix hex -position end  result:/top_tb/uut/inst_addr_f
add wave -radix hex -position end  result:/top_tb/uut/inst_f
add wave -radix hex -position end  result:/top_tb/uut/inst_vld_f
add wave -radix hex -position end  result:/top_tb/uut/ifu_exu_pc_d
add wave -radix hex -position end  result:/top_tb/uut/ifu_exu_vld_d
add wave -radix hex -position end  result:/top_tb/uut/u_dec/inst_d
add wave -divider
add wave -radix hex -position end  result:/top_tb/uut/u_dec/inst_vld_d
add wave -radix hex -position end  result:/top_tb/uut/ifu_exu_alu_vld_d
add wave -radix hex -position end  result:/top_tb/uut/ifu_exu_bru_vld_d
add wave -radix hex -position end  result:/top_tb/uut/ifu_exu_csr_vld_d
add wave -radix hex -position end  result:/top_tb/uut/ifu_exu_lsu_vld_d
add wave -radix hex -position end  result:/top_tb/uut/ifu_exu_ertn_vld_d
add wave -radix hex -position end  result:/top_tb/uut/ifu_exu_exc_vld_d
add wave -divider
add wave -radix hex -position end  result:/top_tb/uut/ifu_exu_exc_code_d
add wave -radix hex -position end  result:/top_tb/uut/u_dec/op_d
add wave -divider
add wave -radix hex -position end  result:/top_tb/ifu_icu_addr_ic1
add wave -radix hex -position end  result:/top_tb/ifu_icu_req_ic1
add wave -radix hex -position end  result:/top_tb/icu_ifu_ack_ic1
add wave -radix hex -position end  result:/top_tb/icu_ifu_data_valid_ic2
add wave -divider
add wave -radix hex -position end  result:/top_tb/ifu_icu_addr_ic1
add wave -radix hex -position end  result:/top_tb/ifu_icu_req_ic1
add wave -radix hex -position end  result:/top_tb/icu_ifu_ack_ic1
add wave -divider
