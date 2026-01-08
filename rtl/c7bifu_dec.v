`include "dec_defs.v"

module c7bifu_dec (
   input              clk,
   input              resetn,

   input              stall,
   input              flush,

   input              inst_vld_f,
   input  [31:0]      inst_addr_f,
   input  [31:0]      inst_f,

   output             ifu_exu_vld_d,
   output [31:0]      ifu_exu_pc_d,

   output [4:0]       ifu_exu_rs1_d,
   output [4:0]       ifu_exu_rs2_d,
   output             ifu_exu_double_read_d,
   output [31:0]      ifu_exu_imm_shifted_d,

   output [4:0]       ifu_exu_rd_d,
   output             ifu_exu_wen_d,
   
   // alu
   output             ifu_exu_alu_vld_d,
   output [5:0]       ifu_exu_alu_op_d,
   output [31:0]      ifu_exu_alu_c_d,
   output             ifu_exu_alu_double_word_d,
   output             ifu_exu_alu_b_imm_d,
   //output [4:0]       ifu_exu_alu_rd_d,
   //output             ifu_exu_alu_wen_d,

   // lsu
   output             ifu_exu_lsu_vld_d,
   output [6:0]       ifu_exu_lsu_op_d,
   //output [4:0]       ifu_exu_lsu_rd_d,
   //output             ifu_exu_lsu_wen_d,

   // bru
   output             ifu_exu_bru_vld_d,
   output [3:0]       ifu_exu_bru_op_d,
   output [31:0]      ifu_exu_bru_offset_d,
   //output             ifu_exu_bru_wen_d,

   // mul
   output             ifu_exu_mul_vld_d,
   //output [4:0]       ifu_exu_mul_rd_d,
   //output             ifu_exu_mul_wen_d,
   output             ifu_exu_mul_signed_d,
   output             ifu_exu_mul_double_d,
   output             ifu_exu_mul_hi_d,
   output             ifu_exu_mul_short_d,

   // csr
   output             ifu_exu_csr_vld_d,
   output [13:0]      ifu_exu_csr_raddr_d,
   //output             ifu_exu_csr_rdwen_d,
   output             ifu_exu_csr_xchg_d,
   output             ifu_exu_csr_wen_d,
   output [13:0]      ifu_exu_csr_waddr_d,

   // ertn
   output             ifu_exu_ertn_vld_d,

   // exc
   output             dec_exc_vld_d,
   output [5:0]       dec_exc_code_d
);

   wire [31:0] inst_d;
   wire        inst_vld_d;

   wire [`LDECODE_RES_BIT-1:0] op_d;

   wire [31:0] alu_c_d;
   wire [31:0] imm_shifted_d;
   wire [31:0] br_offs_d;


   decoder u_decoder(
      .inst                            (inst_d),
      .res                             (op_d)
   );


   c7bifu_imd u_imd(
      .inst                            (inst_d),
      .op                              (op_d),
      .imm_shifted                     (imm_shifted_d),
      .alu_c                           (alu_c_d),
      .br_offs                         (br_offs_d)
      );

   assign dec_exc_vld_d = op_d[`LSYSCALL] | op_d[`LBREAK ] | op_d[`LINE]; // || int_except;
   assign dec_exc_code_d = //int_except                ? `EXC_INT          :  // interrupt send into EXU
                           op_d[`LSYSCALL] ? `EXC_SYS :
                           op_d[`LBREAK  ] ? `EXC_BRK :
                           op_d[`LINE    ] ? `EXC_INE :
                                              6'd0;
   // Suppress normal instruction dispatch when an exception occurs
   // Instead, dispatch the exception valid signal (ifu_exu_exc_vld_d) and
   // code (ifu_exu_exc_code_d)
   // Note: Cache pipeline exceptions must also be routed to c7bifu_dec
   // for proper exception handling in the decode stage
   wire alu_dispatch_d = ~op_d[`LLSU_RELATED] && ~op_d[`LBRU_RELATED] && ~op_d[`LMUL_RELATED] && ~op_d[`LDIV_RELATED] && ~op_d[`LCSR_RELATED] && ~dec_exc_vld_d;
   wire lsu_dispatch_d = op_d[`LLSU_RELATED] && ~dec_exc_vld_d;
   wire bru_dispatch_d = op_d[`LBRU_RELATED] && ~dec_exc_vld_d;
   wire mul_dispatch_d = op_d[`LMUL_RELATED] && ~dec_exc_vld_d;
   //wire div_dispatch_d = op_d[`LDIV_RELATED] && ~dec_exc_vld_d;
   wire none_dispatch_d = (op_d[`LCSR_RELATED] || op_d[`LTLB_RELATED] || op_d[`LCACHE_RELATED]) && ~dec_exc_vld_d;
   wire ertn_dispatch_d = op_d[`LERET] && ~dec_exc_vld_d;


   // These control signals are shared by multiple functional modules.
   // Instead of creating duplicate aliased versions for each consumer,
   // we distribute a single copy throughout the pipeline.
   //
   // This approach is necessary because signals like ifu_exu_rs1_d and 
   // ifu_exu_rs2_d must be directly accessible to execution unit (EXU)
   // bypass logic for correct operand forwarding.
   //
   // Register destination (rd) and write enable (wen) signals are derived
   // from instruction opcode decoding (see decoder.v GR_WEN).
   //
   // Single-cycle instructions (ALU, MUL, BRU) propagate rd and wen through
   // the main pipeline stages normally.
   //
   // Long-latency operations (e.g., LSU memory accesses) require special
   // handling: they stall the IFU, ensuring they remain the sole instruction
   // in the pipeline. For such instructions, the execution control logic (ecl)
   // must latch and preserve rd and wen signals across multiple cycles.
   assign ifu_exu_rs1_d = op_d[`LRD2RJ  ] ? `GET_RD(inst_d) : `GET_RJ(inst_d);
   assign ifu_exu_rs2_d = op_d[`LRD_READ] ? `GET_RD(inst_d) : `GET_RK(inst_d);

   assign ifu_exu_double_read_d = op_d[`LDOUBLE_READ] & lsu_dispatch_d;
   assign ifu_exu_imm_shifted_d = imm_shifted_d;

   assign ifu_exu_wen_d = op_d[`LGR_WEN];
   assign ifu_exu_rd_d = (op_d[`LBRU_RELATED] && (op_d[`LBRU_CODE] == `LBRU_BL)) ? 5'd1 : `GET_RD(inst_d);

   // alu
   assign ifu_exu_alu_vld_d = alu_dispatch_d & ifu_exu_vld_d;
   assign ifu_exu_alu_op_d = op_d[`LALU_CODE]; // ALU_CODE_BIT 6
   assign ifu_exu_alu_c_d = alu_c_d;
   assign ifu_alu_double_word_d = op_d[`LDOUBLE_WORD];
   assign ifu_exu_alu_b_imm_d = (op_d[`LI5] || op_d[`LI12] || op_d[`LI16] || op_d[`LI20]) & alu_dispatch_d;
   //assign ifu_exu_alu_rd_d = rd_d;
   //assign ifu_exu_alu_wen_d = wen_d & ifu_exu_alu_vld_d;

   //wire [31:0] alu_a_d = alu_a_pc? fdp_dec_pc_d : exu_ifu_rs1_data_d;
   //wire [31:0] alu_b_d = alu_b_imm_d? imm_shifted_d : exu_ifu_rs2_data_d;

   // lsu
   assign ifu_exu_lsu_vld_d = lsu_dispatch_d & ifu_exu_vld_d; 
   assign ifu_exu_lsu_op_d = op_d[`LOP_CODE];
   //assign ifu_exu_lsu_rd_d = rd_d;
   //assign ifu_exu_lsu_wen_d = wen_d & ifu_exu_lsu_vld_d;
   
   // bru
   assign ifu_exu_bru_vld_d = bru_dispatch_d & ifu_exu_vld_d;
   assign ifu_exu_bru_op_d = op_d[`LBRU_CODE];
   assign ifu_exu_bru_offset_d = br_offs_d;
   //wire op_jirl = ifu_exu_bru_op_d == `LBRU_JR;
   //wire op_bl = ifu_exu_bru_op_d == `LBRU_BL;
   //assign ifu_exu_bru_wen_d = (op_jirl | op_bl) & ifu_exu_bru_vld_d;

   // mul
   assign ifu_exu_mul_vld_d = mul_dispatch_d & ifu_exu_vld_d;
   //assign ifu_exu_mul_rd_d = rd_d;
   //assign ifu_exu_mul_wen_d = wen_d & ifu_exu_vld_d;
   wire [`LMDU_CODE_BIT-1:0] mul_op_d = op_d[`LMDU_CODE];

   assign ifu_exu_mul_signed_d = mul_op_d == `LMDU_MUL_W    ||
                                 mul_op_d == `LMDU_MULH_W   ||
                                 mul_op_d == `LMDU_MUL_D    ||
                                 mul_op_d == `LMDU_MULH_D   ||
                                 mul_op_d == `LMDU_MULW_D_W ;
   assign ifu_exu_mul_double_d = mul_op_d == `LMDU_MUL_D    ||
                                 mul_op_d == `LMDU_MULH_D   ||
                                 mul_op_d == `LMDU_MULH_DU  ;
   assign ifu_exu_mul_hi_d     = mul_op_d == `LMDU_MULH_W   ||
                                 mul_op_d == `LMDU_MULH_WU  ||
                                 mul_op_d == `LMDU_MULH_D   ||
                                 mul_op_d == `LMDU_MULH_DU  ;
   assign ifu_exu_mul_short_d  = mul_op_d == `LMDU_MUL_W    ||
                                 mul_op_d == `LMDU_MULH_W   ||
                                 mul_op_d == `LMDU_MULH_WU  ;

   // csr
   assign ifu_exu_csr_vld_d = none_dispatch_d & ifu_exu_vld_d;
   assign ifu_exu_csr_raddr_d = `GET_CSR(inst_d);
   //assign ifu_exu_csr_rdwen_d = wen_d & ifu_exu_csr_vld_d;
   assign ifu_exu_csr_xchg_d = op_d[`LCSR_XCHG];
   assign ifu_exu_csr_wen_d = (op_d[`LCSR_XCHG] | op_d[`LCSR_WRITE]) & ifu_exu_csr_vld_d;
   assign ifu_exu_csr_waddr_d = `GET_CSR(inst_d);

   // ertn
   assign ifu_exu_ertn_vld_d = ertn_dispatch_d & ifu_exu_vld_d;


   //
   // Registers
   //

   // Pipeline register enable logic
   // inst_vld_f is already controlled by previous pipeline stage (IQ)
   // and includes stall logic, so no need to apply && ~stall here
   wire reg_en = inst_vld_f;

   // Pipeline register reset logic
   // Reset registers when resetn is low (active low) OR flush is high
   wire reg_rst = ~resetn || flush;

   // Pipeline PC register
   dffrle_ns #(32) ifu_exu_pc_reg (
      .din   (inst_addr_f),
      .rst_l (~reg_rst),     // Active low reset: invert reg_rst
      .en    (reg_en),
      .clk   (clk),
      .q     (ifu_exu_pc_d)
   );

   // Instruction register
   dffrle_ns #(32) inst_reg (
      .din   (inst_f),
      .rst_l (~reg_rst),     // Active low reset: invert reg_rst
      .en    (reg_en),
      .clk   (clk),
      .q     (inst_d)
   );

   // Instruction valid register
   dffrle_ns #(1) inst_vld_reg (
      .din   (inst_vld_f),
      .rst_l (~reg_rst),     // Active low reset: invert reg_rst
      .en    (reg_en),
      .clk   (clk),
      .q     (inst_vld_d)
   );

   // Output valid signal - gated by stall
   // When stall is asserted, do not output valid signal to next pipeline stage
   // This prevents downstream stages from executing stalled instructions
   assign ifu_exu_vld_d = inst_vld_d && ~stall;

endmodule
