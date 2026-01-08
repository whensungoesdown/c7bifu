module c7bifu (
   input              clk,
   input              resetn,

   output [31:0]      ifu_icu_addr_ic1,
   output             ifu_icu_req_ic1,
   input              icu_ifu_ack_ic1,
   input              icu_ifu_data_valid_ic2,
   input  [63:0]      icu_ifu_data_ic2,
   input              exu_ifu_except,
   input  [31:0]      exu_ifu_isr_addr,
   input              exu_ifu_branch,
   input  [31:0]      exu_ifu_brn_addr,
   input              exu_ifu_ertn,
   input  [31:0]      exu_ifu_ert_addr,
   input              exu_ifu_stall,

   //output             ifu_exu_valid_e,
   output             ifu_exu_vld_d,

   //output [31:0]      ifu_exu_pc_w,
   //output [31:0]      ifu_exu_pc_e,
   output [31:0]      ifu_exu_pc_d,

   output [4:0]       ifu_exu_rs1_d,
   output [4:0]       ifu_exu_rs2_d,
   //output [4:0]       ifu_exu_rs1_e,
   //output [4:0]       ifu_exu_rs2_e,

   //input  [31:0]      exu_ifu_rs1_data_d,
   //input  [31:0]      exu_ifu_rs2_data_d,
   
   output             ifu_exu_double_read_d,
   output [31:0]      ifu_exu_imm_shifted_d,
   output [4:0]       ifu_exu_rd_d,
   output             ifu_exu_wen_d,
   
   // alu
   output             ifu_exu_alu_vld_d,
   //output [31:0]      ifu_exu_alu_a_e,
   //output [31:0]      ifu_exu_alu_b_e,
   //output [5:0]       ifu_exu_alu_op_e, // ALU_CODE_BIT 6
   //output [31:0]      ifu_exu_alu_c_e,
   //output             ifu_exu_alu_double_word_e,
   //output             ifu_exu_alu_b_imm_e,
   output [5:0]       ifu_exu_alu_op_d, // ALU_CODE_BIT 6
   output [31:0]      ifu_exu_alu_c_d,
   output             ifu_exu_alu_double_word_d,
   output             ifu_exu_alu_b_imm_d,
   //output [4:0]       ifu_exu_rf_target_e,
   //output             ifu_exu_alu_wen_e,

   // lsu
   //output             ifu_exu_lsu_valid_e,
   //output [6:0]       ifu_exu_lsu_op_e, // LSU_CODE_BIT 7
   //output             ifu_exu_double_read_e,
   //output [31:0]      ifu_exu_imm_shifted_e,
   //output [4:0]       ifu_exu_lsu_rd_e,
   //output             ifu_exu_lsu_wen_e,
   output             ifu_exu_lsu_vld_d,
   output [6:0]       ifu_exu_lsu_op_d, // LSU_CODE_BIT 7
   //output [4:0]       ifu_exu_lsu_rd_d,
   //output             ifu_exu_lsu_wen_d,


   // bru
   //output             ifu_exu_bru_valid_e,
   //output [3:0]       ifu_exu_bru_op_e, // BRU_CODE_BIT 4
   //output [31:0]      ifu_exu_bru_offset_e,
   output             ifu_exu_bru_vld_d,
   output [3:0]       ifu_exu_bru_op_d, // BRU_CODE_BIT 4
   output [31:0]      ifu_exu_bru_offset_d,
   //output             ifu_exu_bru_wen,

   // mul
   //output             ifu_exu_mul_valid_e,
   //output             ifu_exu_mul_wen_e,
   //output             ifu_exu_mul_signed_e,
   //output             ifu_exu_mul_double_e,
   //output             ifu_exu_mul_hi_e,
   //output             ifu_exu_mul_short_e,
   output             ifu_exu_mul_vld_d,
   //output [4:0]       ifu_exu_mul_rd_d,
   //output             ifu_exu_mul_wen_d,
   output             ifu_exu_mul_signed_d,
   output             ifu_exu_mul_double_d,
   output             ifu_exu_mul_hi_d,
   output             ifu_exu_mul_short_d,

   // csr
   //output             ifu_exu_csr_valid_e,
   //output [13:0]      ifu_exu_csr_raddr_d, // CSR_BIT 14
   //output             ifu_exu_csr_rdwen_e,
   //output             ifu_exu_csr_xchg_e,
   //output             ifu_exu_csr_wen_e,
   //output [13:0]      ifu_exu_csr_waddr_e, // CSR_BIT 14
   output             ifu_exu_csr_vld_d,
   output [13:0]      ifu_exu_csr_raddr_d, // CSR_BIT 14
   //output             ifu_exu_csr_rdwen_d,
   output             ifu_exu_csr_xchg_d,
   output             ifu_exu_csr_wen_d,
   output [13:0]      ifu_exu_csr_waddr_d, // CSR_BIT 14

   // ertn
   //output             ifu_exu_ertn_valid_e,
   output             ifu_exu_ertn_vld_d,

   // exc
//   output             ifu_exu_illinst_e,
   //output             ifu_exu_exception_e,
   //output [5:0]       ifu_exu_exccode_e,
   output             ifu_exu_exc_vld_d,
   output [5:0]       ifu_exu_exc_code_d
);

   wire [31:0] pf_addr_in;
   wire [31:0] pf_addr_q;
   wire [31:0] pf_addr_inc;

   // addrs do not need a flush
   wire pf_addr_sel_init;
   wire pf_addr_sel_old;
   wire pf_addr_sel_inc;

   // addrs need flush
   wire pf_addr_sel_brn;
   wire pf_addr_sel_isr;
   wire pf_addr_sel_ert;

   wire pf_addr_en;
   wire icu_data_vld;

   wire [31:0] inst_addr_f;
   wire [31:0] inst_f;
   wire        inst_vld_f;

   wire stall;
   wire flush;
   wire iq_full;

   wire dec_exc_vld_d;
   wire dec_exc_code_d;
   

   c7bifu_fcl u_fcl (
      .clk                             (clk),
      .resetn                          (resetn),
      .ifu_icu_req_ic1                 (ifu_icu_req_ic1),
      .icu_ifu_ack_ic1                 (icu_ifu_ack_ic1),
      .icu_ifu_data_valid_ic2          (icu_ifu_data_valid_ic2),
      .exu_ifu_except                  (exu_ifu_except),
      .exu_ifu_branch                  (exu_ifu_branch),
      .exu_ifu_ertn                    (exu_ifu_ertn),
      .exu_ifu_stall                   (exu_ifu_stall),
      .pf_addr_sel_init                (pf_addr_sel_init),
      .pf_addr_sel_old                 (pf_addr_sel_old),
      .pf_addr_sel_inc                 (pf_addr_sel_inc),
      .pf_addr_sel_brn                 (pf_addr_sel_brn),
      .pf_addr_sel_isr                 (pf_addr_sel_isr),
      .pf_addr_sel_ert                 (pf_addr_sel_ert),
      .pf_addr_en                      (pf_addr_en),
      .icu_data_vld                    (icu_data_vld),
      .stall                           (stall),
      .flush                           (flush),
      .iq_full                         (iq_full)
   );

   assign pf_addr_inc = pf_addr_q + 4'h8;

   assign pf_addr_in = {32{pf_addr_sel_init}} & 32'h1c000000     |
                       {32{pf_addr_sel_old}}  & pf_addr_q        |
                       {32{pf_addr_sel_inc}}  & pf_addr_inc      |      
                       {32{pf_addr_sel_brn}}  & exu_ifu_brn_addr |
                       {32{pf_addr_sel_isr}}  & exu_ifu_isr_addr |
                       {32{pf_addr_sel_ert}}  & exu_ifu_ert_addr;		      

   assign ifu_icu_addr_ic1 = pf_addr_in;


   c7bifu_iq u_iq (
      .clk                             (clk),
      .resetn                          (resetn),
      .data_addr                       (ifu_icu_addr_ic1),
      .data                            (icu_ifu_data_ic2),
      .data_vld                        (icu_data_vld),
      .stall                           (stall),
      .flush                           (flush),
      .iq_full                         (iq_full),
      .inst_addr                       (inst_addr_f),
      .inst                            (inst_f),
      .inst_vld                        (inst_vld_f)
   );


   c7bifu_dec u_dec (
      .clk                             (clk),
      .resetn                          (resetn),
      
      .stall                           (stall),
      .flush                           (flush),

      .inst_vld_f                      (inst_vld_f),
      .inst_addr_f                     (inst_addr_f),
      .inst_f                          (inst_f),

      .ifu_exu_vld_d                   (ifu_exu_vld_d),
      .ifu_exu_pc_d                    (ifu_exu_pc_d),
      .ifu_exu_rs1_d                   (ifu_exu_rs1_d),
      .ifu_exu_rs2_d                   (ifu_exu_rs2_d),
      .ifu_exu_double_read_d           (ifu_exu_double_read_d),
      .ifu_exu_imm_shifted_d           (ifu_exu_imm_shifted_d),
      .ifu_exu_rd_d                    (ifu_exurd_d),
      .ifu_exu_wen_d                   (ifu_exuwen_d),

      // alu
      .ifu_exu_alu_vld_d               (ifu_exu_alu_vld_d),
      .ifu_exu_alu_op_d                (ifu_exu_alu_op_d),
      .ifu_exu_alu_c_d                 (ifu_exu_alu_c_d),
      .ifu_exu_alu_double_word_d       (ifu_exu_alu_double_word_d),
      .ifu_exu_alu_b_imm_d             (ifu_exu_alu_b_imm_d),

      // lsu
      .ifu_exu_lsu_vld_d               (ifu_exu_lsu_vld_d),
      .ifu_exu_lsu_op_d                (ifu_exu_lsu_op_d),
      //.ifu_exu_lsu_rd_d                (ifu_exu_lsu_rd_d),
      //.ifu_exu_lsu_wen_d               (ifu_exu_lsu_wen_d),

      // bru
      .ifu_exu_bru_vld_d               (ifu_exu_bru_vld_d),
      .ifu_exu_bru_op_d                (ifu_exu_bru_op_d),
      .ifu_exu_bru_offset_d            (ifu_exu_bru_offset_d),
      //.ifu_exu_bru_wen_d               (ifu_exu_bru_wen_d),

      // mul
      .ifu_exu_mul_vld_d               (ifu_exu_mul_vld_d),
      //.ifu_exu_mul_rd_d                (ifu_exu_mul_rd_d),
      //.ifu_exu_mul_wen_d               (ifu_exu_mul_wen_d),
      .ifu_exu_mul_signed_d            (ifu_exu_mul_signed_d),
      .ifu_exu_mul_double_d            (ifu_exu_mul_double_d),
      .ifu_exu_mul_hi_d                (ifu_exu_mul_hi_d),
      .ifu_exu_mul_short_d             (ifu_exu_mul_short_d),

      // csr
      .ifu_exu_csr_vld_d               (ifu_exu_csr_vld_d),
      .ifu_exu_csr_raddr_d             (ifu_exu_csr_raddr_d),
      //.ifu_exu_csr_rdwen_d             (ifu_exu_csr_rdwen_d),
      .ifu_exu_csr_xchg_d              (ifu_exu_csr_xchg_d),
      .ifu_exu_csr_wen_d               (ifu_exu_csr_wen_d),
      .ifu_exu_csr_waddr_d             (ifu_exu_csr_waddr_d),

      // ertn
      .ifu_exu_ertn_vld_d              (ifu_exu_ertn_vld_d),

      // exc
      .dec_exc_vld_d                   (dec_exc_vld_d),
      .dec_exc_code_d                  (dec_exc_code_d)
   );

   assign ifu_exu_exc_vld_d = dec_exc_vld_d; // | other front exceptions
   assign ifu_exu_exc_code_d = dec_exc_code_d;


   //
   // Registers
   //

   dffe_ns #(32) pf_addr_reg (
      .din (pf_addr_in),
      .en  (pf_addr_en),
      .clk (clk),
      .q   (pf_addr_q));

endmodule
