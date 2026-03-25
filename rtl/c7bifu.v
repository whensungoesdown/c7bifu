module c7bifu (
   input              clk,
   input              resetn,

   input              csr_ifu_ic_en,
   input              csr_ifu_ic_en_pls,

   // icu interface
   output [31:0]      ifu_icu_addr_ic1,
   output             ifu_icu_req_ic1,
   input              icu_ifu_ack_ic1,
   input              icu_ifu_data_valid_ic2,
   input  [63:0]      icu_ifu_data_ic2,

   // biu interface
   output [31:0]      ifu_biu_rd_addr,
   output             ifu_biu_rd_req,
   input              biu_ifu_rd_ack,
   input              biu_ifu_data_valid,
   input  [63:0]      biu_ifu_data,

   input              exu_ifu_except,
   input  [31:0]      exu_ifu_isr_addr,
   input              exu_ifu_branch,
   input  [31:0]      exu_ifu_brn_addr,
   input              exu_ifu_ertn,
   input  [31:0]      exu_ifu_ert_addr,
   input              exu_ifu_stall,

   output             ifu_exu_vld_d,
   output [31:0]      ifu_exu_pc_d,
   output [4:0]       ifu_exu_rs1_d,
   output [4:0]       ifu_exu_rs2_d,
   output [4:0]       ifu_exu_rd_d,
   output             ifu_exu_wen_d,
   output [31:0]      ifu_exu_imm_shifted_d,
   
   // alu
   output             ifu_exu_alu_vld_d,
   output [5:0]       ifu_exu_alu_op_d, // ALU_CODE_BIT 6
   output             ifu_exu_alu_a_pc_d, 
   output [31:0]      ifu_exu_alu_c_d,
   output             ifu_exu_alu_double_word_d,
   output             ifu_exu_alu_b_imm_d,

   // lsu
   output             ifu_exu_lsu_vld_d,
   output [6:0]       ifu_exu_lsu_op_d, // LSU_CODE_BIT 7
   output             ifu_exu_lsu_double_read_d,

   // bru
   output             ifu_exu_bru_vld_d,
   output [3:0]       ifu_exu_bru_op_d, // BRU_CODE_BIT 4
   output [31:0]      ifu_exu_bru_offset_d,

   // mul
   output             ifu_exu_mul_vld_d,
   output             ifu_exu_mul_signed_d,
   output             ifu_exu_mul_double_d,
   output             ifu_exu_mul_hi_d,
   output             ifu_exu_mul_short_d,

   // div
   output             ifu_exu_div_vld_d,
   output             ifu_exu_div_signed_d,
   output             ifu_exu_div_mod_d,

   // csr
   output             ifu_exu_csr_vld_d,
   output [13:0]      ifu_exu_csr_raddr_d, // CSR_BIT 14
   output             ifu_exu_csr_xchg_d,
   output             ifu_exu_csr_wen_d,
   output [13:0]      ifu_exu_csr_waddr_d, // CSR_BIT 14

   // ertn
   output             ifu_exu_ertn_vld_d,

   // exc
   output             ifu_exu_exc_vld_d,
   output [5:0]       ifu_exu_exc_code_d
);

   wire [63:0] data;
   wire data_vld;
   wire ack;

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
   //wire icu_data_vld;
   wire fcl_data_vld;

   wire [31:0] inst_addr_f;
   wire [31:0] inst_f;
   wire        inst_vld_f;

   wire stall;
   wire stall_iq;
   wire stall_dec;
   wire flush;
   wire flush_dly1;
   wire iq_full;
   wire wait_bus_clr;

   wire ic_en;
   wire ic_en_en = ~wait_bus_clr;

   wire dec_exc_vld_d;
   wire [5:0] dec_exc_code_d;
   
   // The stall_dec signal is asserted when exu_ifu_stall is active.
   // Due to a one-cycle read delay in the instruction queue (IQ), the decode
   // stage must predict whether the currently decoded instructions will cause
   // a stall once they reach the execution (_e) stage.
   // To prevent instructions from being lost (dropped), stall_dec is
   // preemptively asserted one cycle earlier upon decoding CSR or LSU
   // instructions.
   // Additional instruction types may be added to this preemptive stall logic
   // in the future.
   assign stall_dec = stall;
   assign stall_iq = stall | ifu_exu_csr_vld_d | ifu_exu_lsu_vld_d; 

   wire fcl_req;
   assign ifu_icu_req_ic1 = fcl_req & ic_en;
   assign ifu_biu_rd_req = fcl_req & ~ic_en;

   //assign ack = ic_en ? icu_ifu_ack_ic1 : biu_ifu_rd_ack;
   assign ack = icu_ifu_ack_ic1 | biu_ifu_rd_ack;
   assign data = ic_en ? icu_ifu_data_ic2 : biu_ifu_data;
   assign data_vld = ic_en ? icu_ifu_data_valid_ic2 : biu_ifu_data_valid;

   c7bifu_fcl u_fcl (
      .clk                             (clk),
      .resetn                          (resetn),
      .fcl_req                         (fcl_req),
      .ack                             (ack),
      .data_vld                        (data_vld),
      .exu_ifu_except                  (exu_ifu_except),
      .exu_ifu_branch                  (exu_ifu_branch),
      .exu_ifu_ertn                    (exu_ifu_ertn),
      .exu_ifu_stall                   (exu_ifu_stall),
      .csr_ifu_ic_en_pls               (csr_ifu_ic_en_pls),
      .pf_addr_sel_init                (pf_addr_sel_init),
      .pf_addr_sel_old                 (pf_addr_sel_old),
      .pf_addr_sel_inc                 (pf_addr_sel_inc),
      .pf_addr_sel_brn                 (pf_addr_sel_brn),
      .pf_addr_sel_isr                 (pf_addr_sel_isr),
      .pf_addr_sel_ert                 (pf_addr_sel_ert),
      .pf_addr_en                      (pf_addr_en),
      .fcl_data_vld                    (fcl_data_vld),
      .stall                           (stall),
      .flush                           (flush),
      .flush_dly1                      (flush_dly1),
      .iq_full                         (iq_full),
      .wait_bus_clr                    (wait_bus_clr)
   );

   assign pf_addr_inc = pf_addr_q + 4'h8;

   assign pf_addr_in = {32{pf_addr_sel_init}} & 32'h1c000000     |
                       {32{pf_addr_sel_old}}  & pf_addr_q        |
                       {32{pf_addr_sel_inc}}  & pf_addr_inc      |      
                       {32{pf_addr_sel_brn}}  & exu_ifu_brn_addr |
                       {32{pf_addr_sel_isr}}  & exu_ifu_isr_addr |
                       {32{pf_addr_sel_ert}}  & exu_ifu_ert_addr;		      
   // uty: test
   //assign ifu_icu_addr_ic1 = pf_addr_in;
   //assign ifu_icu_addr_ic1 = pf_addr_q;
   assign ifu_icu_addr_ic1 = pf_addr_q & {32{ic_en}};
   assign ifu_biu_rd_addr = pf_addr_q & {32{~ic_en}};

   wire [31:0] iq_start_addr = ic_en ? ifu_icu_addr_ic1 : ifu_biu_rd_addr;
   wire [31:0] iq_data_addr = {iq_start_addr[31:3], 3'b0};

   c7bifu_iq u_iq (
      .clk                             (clk),
      .resetn                          (resetn),
      //.data_addr                       ({ifu_icu_addr_ic1[31:3], 3'b0}),
      .data_addr                       (iq_data_addr),
      //.data                            (icu_ifu_data_ic2),
      .data                            (data),
      //.data_vld                        (icu_data_vld),
      .data_vld                        (fcl_data_vld),
      //.start_addr                      (ifu_icu_addr_ic1),
      .start_addr                      (iq_start_addr),
      .stall                           (stall_iq),
      //.flush                           (flush),
      .flush                           (flush | flush_dly1), // because ifu_icu_addr_ic1 takes pf_addr_q install of pf_addr_in, there is 1 cycle delay, therefore the iq also needs to wait 1 cycel for the correct updated ifu_icu_addr_ic1
      .iq_full                         (iq_full),
      .inst_addr                       (inst_addr_f),
      .inst                            (inst_f),
      .inst_vld                        (inst_vld_f)
   );


   c7bifu_dec u_dec (
      .clk                             (clk),
      .resetn                          (resetn),
      
      .stall                           (stall_dec),
      .flush                           (flush),

      .inst_vld_f                      (inst_vld_f),
      .inst_addr_f                     (inst_addr_f),
      .inst_f                          (inst_f),

      .ifu_exu_vld_d                   (ifu_exu_vld_d),
      .ifu_exu_pc_d                    (ifu_exu_pc_d),
      .ifu_exu_rs1_d                   (ifu_exu_rs1_d),
      .ifu_exu_rs2_d                   (ifu_exu_rs2_d),
      .ifu_exu_rd_d                    (ifu_exu_rd_d),
      .ifu_exu_wen_d                   (ifu_exu_wen_d),
      .ifu_exu_imm_shifted_d           (ifu_exu_imm_shifted_d),

      // alu
      .ifu_exu_alu_vld_d               (ifu_exu_alu_vld_d),
      .ifu_exu_alu_op_d                (ifu_exu_alu_op_d),
      .ifu_exu_alu_a_pc_d              (ifu_exu_alu_a_pc_d),
      .ifu_exu_alu_c_d                 (ifu_exu_alu_c_d),
      .ifu_exu_alu_double_word_d       (ifu_exu_alu_double_word_d),
      .ifu_exu_alu_b_imm_d             (ifu_exu_alu_b_imm_d),

      // lsu
      .ifu_exu_lsu_vld_d               (ifu_exu_lsu_vld_d),
      .ifu_exu_lsu_op_d                (ifu_exu_lsu_op_d),
      .ifu_exu_lsu_double_read_d       (ifu_exu_lsu_double_read_d),

      // bru
      .ifu_exu_bru_vld_d               (ifu_exu_bru_vld_d),
      .ifu_exu_bru_op_d                (ifu_exu_bru_op_d),
      .ifu_exu_bru_offset_d            (ifu_exu_bru_offset_d),

      // mul
      .ifu_exu_mul_vld_d               (ifu_exu_mul_vld_d),
      .ifu_exu_mul_signed_d            (ifu_exu_mul_signed_d),
      .ifu_exu_mul_double_d            (ifu_exu_mul_double_d),
      .ifu_exu_mul_hi_d                (ifu_exu_mul_hi_d),
      .ifu_exu_mul_short_d             (ifu_exu_mul_short_d),

      // div
      ifu_exu_div_vld_d                (ifu_exu_div_vld_d),
      ifu_exu_div_signed_d             (ifu_exu_div_signed_d),
      ifu_exu_div_mod_d                (ifu_exu_div_mod_d),

      // csr
      .ifu_exu_csr_vld_d               (ifu_exu_csr_vld_d),
      .ifu_exu_csr_raddr_d             (ifu_exu_csr_raddr_d),
      .ifu_exu_csr_xchg_d              (ifu_exu_csr_xchg_d),
      .ifu_exu_csr_wen_d               (ifu_exu_csr_wen_d),
      .ifu_exu_csr_waddr_d             (ifu_exu_csr_waddr_d),

      // ertn
      .ifu_exu_ertn_vld_d              (ifu_exu_ertn_vld_d),

      // exc
      .dec_exc_vld_d                   (dec_exc_vld_d),
      .dec_exc_code_d                  (dec_exc_code_d)
   );

   // When ifu_exu_exc_vld_d is asserted, EXU must cancel execution of any
   // simultaneously valid instruction.
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

   dffrle_ns #(1) ic_en_reg (
      .din (csr_ifu_ic_en),
      .en  (ic_en_en),
      .clk (clk),
      .rst_l (resetn),
      .q   (ic_en));

endmodule
