`include "dec_defs.v"
`include "alu_defs.v"
`include "c7blsu_defs.v"
`include "bru_defs.v"

module decoder (
    input  [31:0] inst,
    output [`LDECODE_RES_BIT-1:0] res
);

wire [5:0] op_func = inst[31:26];
wire [4:0] op_rd   = inst[ 4: 0];
wire [4:0] op_rj   = inst[ 9: 5];
wire [4:0] op_rk   = inst[14:10];
wire [4:0] op_sa   = inst[19:15];
wire [5:0] op_def  = inst[25:20];

////fix
//alu        
wire op_clo_w      = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b00100;
wire op_clz_w      = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b00101;
wire op_cto_w      = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b00110;
wire op_ctz_w      = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b00111;
wire op_clo_d      = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b01000;
wire op_clz_d      = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b01001;
wire op_cto_d      = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b01010;
wire op_ctz_d      = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b01011;
wire op_revb_2h    = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b01100;
wire op_revb_4h    = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b01101;
wire op_revb_2w    = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b01110;
wire op_revb_d     = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b01111;
wire op_revh_2w    = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b10000;
wire op_revh_d     = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b10001;
wire op_bitrev_4b  = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b10010;
wire op_bitrev_8b  = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b10011;
wire op_bitrev_w   = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b10100;
wire op_bitrev_d   = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b10101;
wire op_ext_w_h    = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b10110;
wire op_ext_w_b    = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b10111;
wire op_rdtimel_w  = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b11000;
wire op_rdtimeh_w  = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b11001;
wire op_rdtime_d   = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b11010;
wire op_cpucfg     = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00000 && op_rk == 5'b11011;
wire op_asrtle_d   = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00010                       && op_rd == 5'b00000;
wire op_asrtgt_d   = op_func == 6'b000000 && op_def == 6'b000000 && op_sa == 5'b00011                       && op_rd == 5'b00000;
wire op_alsl_w     = op_func == 6'b000000 && op_def == 6'b000000 && op_sa[4:2] == 3'b010;
wire op_alsl_wu    = op_func == 6'b000000 && op_def == 6'b000000 && op_sa[4:2] == 3'b011;
wire op_bytepick_w = op_func == 6'b000000 && op_def == 6'b000000 && op_sa[4:2] == 3'b100;
wire op_bytepick_d = op_func == 6'b000000 && op_def == 6'b000000 && op_sa[4:3] == 2'b11;
wire op_add_w      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b00000;
wire op_add_d      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b00001;
wire op_sub_w      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b00010;
wire op_sub_d      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b00011;
wire op_slt        = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b00100;
wire op_sltu       = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b00101;
wire op_maskeqz    = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b00110;
wire op_masknez    = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b00111;
wire op_nor        = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b01000;
wire op_and        = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b01001;
wire op_or         = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b01010;
wire op_xor        = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b01011;
wire op_orn        = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b01100;
wire op_andn       = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b01101;
wire op_sll_w      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b01110;
wire op_srl_w      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b01111;
wire op_sra_w      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b10000;
wire op_sll_d      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b10001;
wire op_srl_d      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b10010;
wire op_sra_d      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b10011;
wire op_rotr_w     = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b10110;
wire op_rotr_d     = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b10111;
wire op_mul_w      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b11000;
wire op_mulh_w     = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b11001;
wire op_mulh_wu    = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b11010;
wire op_mul_d      = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b11011;
wire op_mulh_d     = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b11100;
wire op_mulh_du    = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b11101;
wire op_mulw_d_w   = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b11110;
wire op_mulw_d_wu  = op_func == 6'b000000 && op_def == 6'b000001 && op_sa == 5'b11111;
wire op_div_w      = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b00000;
wire op_mod_w      = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b00001;
wire op_div_wu     = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b00010;
wire op_mod_wu     = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b00011;
wire op_div_d      = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b00100;
wire op_mod_d      = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b00101;
wire op_div_du     = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b00110;
wire op_mod_du     = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b00111;
wire op_crc_w_b_w  = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b01000;
wire op_crc_w_h_w  = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b01001;
wire op_crc_w_w_w  = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b01010;
wire op_crc_w_d_w  = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b01011;
wire op_crcc_w_b_w = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b01100;
wire op_crcc_w_h_w = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b01101;
wire op_crcc_w_w_w = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b01110;
wire op_crcc_w_d_w = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b01111;
wire op_break      = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b10100;
//wire op_dbgcall    = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b10101;
wire op_syscall    = op_func == 6'b000000 && op_def == 6'b000010 && op_sa == 5'b10110;
wire op_alsl_d     = op_func == 6'b000000 && op_def == 6'b000010 && op_sa[4:2] == 3'b110;
wire op_slli_w     = op_func == 6'b000000 && op_def == 6'b000100 && op_sa == 5'b00001;
wire op_slli_d     = op_func == 6'b000000 && op_def == 6'b000100 && op_sa[4:1] == 4'b0001;
wire op_srli_w     = op_func == 6'b000000 && op_def == 6'b000100 && op_sa == 5'b01001;
wire op_srli_d     = op_func == 6'b000000 && op_def == 6'b000100 && op_sa[4:1] == 4'b0101;
wire op_srai_w     = op_func == 6'b000000 && op_def == 6'b000100 && op_sa == 5'b10001;
wire op_srai_d     = op_func == 6'b000000 && op_def == 6'b000100 && op_sa[4:1] == 4'b1001;
wire op_rotri_w    = op_func == 6'b000000 && op_def == 6'b000100 && op_sa == 5'b11001;
wire op_rotri_d    = op_func == 6'b000000 && op_def == 6'b000100 && op_sa[4:1] == 4'b1101;
wire op_bstrins_w  = op_func == 6'b000000 && op_def[5:1] == 5'b00011 && op_sa[0] == 1'b0;
wire op_bstrpick_w = op_func == 6'b000000 && op_def[5:1] == 5'b00011 && op_sa[0] == 1'b1;
wire op_bstrins_d  = op_func == 6'b000000 && op_def[5:2] == 4'b0010;
wire op_bstrpick_d = op_func == 6'b000000 && op_def[5:2] == 4'b0011;

//imm12
wire op_slti       = op_func == 6'b000000 && op_def[5:2] == 4'b1000;
wire op_sltui      = op_func == 6'b000000 && op_def[5:2] == 4'b1001;
wire op_addi_w     = op_func == 6'b000000 && op_def[5:2] == 4'b1010;
wire op_addi_d     = op_func == 6'b000000 && op_def[5:2] == 4'b1011;
wire op_lu52i_d    = op_func == 6'b000000 && op_def[5:2] == 4'b1100;
wire op_andi       = op_func == 6'b000000 && op_def[5:2] == 4'b1101;
wire op_ori        = op_func == 6'b000000 && op_def[5:2] == 4'b1110;
wire op_xori       = op_func == 6'b000000 && op_def[5:2] == 4'b1111;

//imm
wire op_addu16i_d  = op_func == 6'b000100;
wire op_lu12i_w    = op_func == 6'b000101 && op_def[5] == 1'b0;
wire op_lu32i_d    = op_func == 6'b000101 && op_def[5] == 1'b1;
wire op_pcaddi     = op_func == 6'b000110 && op_def[5] == 1'b0;
wire op_pcalau12i  = op_func == 6'b000110 && op_def[5] == 1'b1;
wire op_pcaddu12i  = op_func == 6'b000111 && op_def[5] == 1'b0;
wire op_pcaddu18i  = op_func == 6'b000111 && op_def[5] == 1'b1;

//plv
wire op_csrrd      = op_func == 6'b000001 && op_def[5:4] == 2'b00                                           && op_rj == 5'b00000;
wire op_csrwr      = op_func == 6'b000001 && op_def[5:4] == 2'b00                                           && op_rj == 5'b00001;
wire op_csrxchg    = op_func == 6'b000001 && op_def[5:4] == 2'b00                                           && (op_rj != 5'b00001 && op_rj != 5'b00000);
//wire op_gcsrrd     = op_func == 6'b000001 && op_def[5:4] == 2'b01                                           && op_rj == 5'b00000;
//wire op_gcsrwr     = op_func == 6'b000001 && op_def[5:4] == 2'b01                                           && op_rj == 5'b00001;
//wire op_gcsrxchg   = op_func == 6'b000001 && op_def[5:4] == 2'b01                                           && (op_rj != 5'b00001 && op_rj != 5'b00000);
wire op_cache      = op_func == 6'b000001 && op_def[5:2] == 4'b1000;
//wire op_lddir      = op_func == 6'b000001 && op_def == 6'b100100 && op_sa[4:3] == 2'b00;
//wire op_ldpte      = op_func == 6'b000001 && op_def == 6'b100100 && op_sa[4:3] == 2'b01                                           && op_rd == 5'b00000;
wire op_iocsrrd_b  = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b00000;
wire op_iocsrrd_h  = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b00001;
wire op_iocsrrd_w  = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b00010;
wire op_iocsrrd_d  = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b00011;
wire op_iocsrwr_b  = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b00100;
wire op_iocsrwr_h  = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b00101;
wire op_iocsrwr_w  = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b00110;
wire op_iocsrwr_d  = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b00111;
wire op_tlbinv     = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01000 && op_rj == 5'b00000 && op_rd == 5'b00000;
wire op_gtlbinv    = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01000 && op_rj == 5'b00000 && op_rd == 5'b00001;
wire op_tlbflush   = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01001 && op_rj == 5'b00000 && op_rd == 5'b00000;
wire op_gtlbflush  = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01001 && op_rj == 5'b00000 && op_rd == 5'b00001;
wire op_tlbp       = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01010 && op_rj == 5'b00000 && op_rd == 5'b00000;
wire op_gtlbp      = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01010 && op_rj == 5'b00000 && op_rd == 5'b00001;
wire op_tlbr       = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01011 && op_rj == 5'b00000 && op_rd == 5'b00000;
wire op_gtlbr      = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01011 && op_rj == 5'b00000 && op_rd == 5'b00001;
wire op_tlbwi      = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01100 && op_rj == 5'b00000 && op_rd == 5'b00000;
wire op_gtlbwi     = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01100 && op_rj == 5'b00000 && op_rd == 5'b00001;
wire op_tlbwr      = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01101 && op_rj == 5'b00000 && op_rd == 5'b00000;
wire op_gtlbwr     = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01101 && op_rj == 5'b00000 && op_rd == 5'b00001;
wire op_eret       = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10000 && op_rk == 5'b01110 && op_rj == 5'b00000 && op_rd == 5'b00000;
wire op_wait       = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10001;
wire op_invtlb     = op_func == 6'b000001 && op_def == 6'b100100 && op_sa == 5'b10011;

//mem
wire op_ll_w        = op_func == 6'b001000 && op_def[5:4] == 2'b00;
wire op_sc_w        = op_func == 6'b001000 && op_def[5:4] == 2'b01;
wire op_ll_d        = op_func == 6'b001000 && op_def[5:4] == 2'b10;
wire op_sc_d        = op_func == 6'b001000 && op_def[5:4] == 2'b11;
wire op_ldptr_w     = op_func == 6'b001001 && op_def[5:4] == 2'b00;
wire op_stptr_w     = op_func == 6'b001001 && op_def[5:4] == 2'b01;
wire op_ldptr_d     = op_func == 6'b001001 && op_def[5:4] == 2'b10;
wire op_stptr_d     = op_func == 6'b001001 && op_def[5:4] == 2'b11;
wire op_ld_b        = op_func == 6'b001010 && op_def[5:2] == 4'b0000;
wire op_ld_h        = op_func == 6'b001010 && op_def[5:2] == 4'b0001;
wire op_ld_w        = op_func == 6'b001010 && op_def[5:2] == 4'b0010;
wire op_ld_d        = op_func == 6'b001010 && op_def[5:2] == 4'b0011;
wire op_st_b        = op_func == 6'b001010 && op_def[5:2] == 4'b0100;
wire op_st_h        = op_func == 6'b001010 && op_def[5:2] == 4'b0101;
wire op_st_w        = op_func == 6'b001010 && op_def[5:2] == 4'b0110;
wire op_st_d        = op_func == 6'b001010 && op_def[5:2] == 4'b0111;
wire op_ld_bu       = op_func == 6'b001010 && op_def[5:2] == 4'b1000;
wire op_ld_hu       = op_func == 6'b001010 && op_def[5:2] == 4'b1001;
wire op_ld_wu       = op_func == 6'b001010 && op_def[5:2] == 4'b1010;
wire op_preld       = op_func == 6'b001010 && op_def[5:2] == 4'b1011;
wire op_ldx_b       = op_func == 6'b001110 && op_def == 6'b000000 && op_sa == 5'b00000;
wire op_ldx_h       = op_func == 6'b001110 && op_def == 6'b000000 && op_sa == 5'b01000;
wire op_ldx_w       = op_func == 6'b001110 && op_def == 6'b000000 && op_sa == 5'b10000;
wire op_ldx_d       = op_func == 6'b001110 && op_def == 6'b000000 && op_sa == 5'b11000;
wire op_stx_b       = op_func == 6'b001110 && op_def == 6'b000001 && op_sa == 5'b00000;
wire op_stx_h       = op_func == 6'b001110 && op_def == 6'b000001 && op_sa == 5'b01000;
wire op_stx_w       = op_func == 6'b001110 && op_def == 6'b000001 && op_sa == 5'b10000;
wire op_stx_d       = op_func == 6'b001110 && op_def == 6'b000001 && op_sa == 5'b11000;
wire op_ldx_bu      = op_func == 6'b001110 && op_def == 6'b000010 && op_sa == 5'b00000;
wire op_ldx_hu      = op_func == 6'b001110 && op_def == 6'b000010 && op_sa == 5'b01000;
wire op_ldx_wu      = op_func == 6'b001110 && op_def == 6'b000010 && op_sa == 5'b10000;
wire op_preldx      = op_func == 6'b001110 && op_def == 6'b000010 && op_sa == 5'b11000;
wire op_amswap_w    = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b00000;
wire op_amswap_d    = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b00001;
wire op_amadd_w     = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b00010;
wire op_amadd_d     = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b00011;
wire op_amand_w     = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b00100;
wire op_amand_d     = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b00101;
wire op_amor_w      = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b00110;
wire op_amor_d      = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b00111;
wire op_amxor_w     = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b01000;
wire op_amxor_d     = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b01001;
wire op_ammax_w     = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b01010;
wire op_ammax_d     = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b01011;
wire op_ammin_w     = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b01100;
wire op_ammin_d     = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b01101;
wire op_ammax_wu    = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b01110;
wire op_ammax_du    = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b01111;
wire op_ammin_wu    = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b10000;
wire op_ammin_du    = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b10001;
wire op_amswap_db_w = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b10010;
wire op_amswap_db_d = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b10011;
wire op_amadd_db_w  = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b10100;
wire op_amadd_db_d  = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b10101;
wire op_amand_db_w  = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b10110;
wire op_amand_db_d  = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b10111;
wire op_amor_db_w   = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b11000;
wire op_amor_db_d   = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b11001;
wire op_amxor_db_w  = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b11010;
wire op_amxor_db_d  = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b11011;
wire op_ammax_db_w  = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b11100;
wire op_ammax_db_d  = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b11101;
wire op_ammin_db_w  = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b11110;
wire op_ammin_db_d  = op_func == 6'b001110 && op_def == 6'b000110 && op_sa == 5'b11111;
wire op_ammax_db_wu = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b00000;
wire op_ammax_db_du = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b00001;
wire op_ammin_db_wu = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b00010;
wire op_ammin_db_du = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b00011;
wire op_dbar        = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b00100;
wire op_ibar        = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b00101;
wire op_ldgt_b      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b10000;
wire op_ldgt_h      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b10001;
wire op_ldgt_w      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b10010;
wire op_ldgt_d      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b10011;
wire op_ldle_b      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b10100;
wire op_ldle_h      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b10101;
wire op_ldle_w      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b10110;
wire op_ldle_d      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b10111;
wire op_stgt_b      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b11000;
wire op_stgt_h      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b11001;
wire op_stgt_w      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b11010;
wire op_stgt_d      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b11011;
wire op_stle_b      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b11100;
wire op_stle_h      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b11101;
wire op_stle_w      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b11110;
wire op_stle_d      = op_func == 6'b001110 && op_def == 6'b000111 && op_sa == 5'b11111;

//branch
wire op_beqz       = op_func == 6'b010000;
wire op_bnez       = op_func == 6'b010001;
wire op_bceqz      = op_func == 6'b010010 && op_rj[4:3] == 2'b00;
wire op_bcnez      = op_func == 6'b010010 && op_rj[4:3] == 2'b01;
wire op_jiscr0     = op_func == 6'b010010 && op_rj == 5'b10000;
wire op_jiscr1     = op_func == 6'b010010 && op_rj == 5'b11000;
wire op_jirl       = op_func == 6'b010011;
wire op_b          = op_func == 6'b010100;
wire op_bl         = op_func == 6'b010101;
wire op_beq        = op_func == 6'b010110;
wire op_bne        = op_func == 6'b010111;
wire op_blt        = op_func == 6'b011000;
wire op_bge        = op_func == 6'b011001;
wire op_bltu       = op_func == 6'b011010;
wire op_bgeu       = op_func == 6'b011011;

////float
//mem
wire op_fld_s      = op_func == 6'b001010 && op_def[5:2] == 4'b1100;
wire op_fst_s      = op_func == 6'b001010 && op_def[5:2] == 4'b1101;
wire op_fld_d      = op_func == 6'b001010 && op_def[5:2] == 4'b1110;
wire op_fst_d      = op_func == 6'b001010 && op_def[5:2] == 4'b1111;

//alu
wire op_fadd_s       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b00001;
wire op_fadd_d       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b00010;
wire op_fsub_s       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b00101;
wire op_fsub_d       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b00110;
wire op_fmul_s       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b01001;
wire op_fmul_d       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b01010;
wire op_fdiv_s       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b01101;
wire op_fdiv_d       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b01110;
wire op_fmax_s       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b10001;
wire op_fmax_d       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b10010;
wire op_fmin_s       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b10101;
wire op_fmin_d       = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b10110;
wire op_fmaxa_s      = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b11001;
wire op_fmaxa_d      = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b11010;
wire op_fmina_s      = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b11101;
wire op_fmina_d      = op_func == 6'b000000 && op_def == 6'b010000 && op_sa == 5'b11110;
wire op_fscaleb_s    = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b00001;
wire op_fscaleb_d    = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b00010;
wire op_fcopysign_s  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b00101;
wire op_fcopysign_d  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b00110;
wire op_fabs_s       = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b00001;
wire op_fabs_d       = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b00010;
wire op_neg_s        = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b00101;
wire op_neg_d        = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b00110;
wire op_flogb_s      = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b01001;
wire op_flogb_d      = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b01010;
wire op_fclass_s     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b01101;
wire op_fclass_d     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b01110;
wire op_fsqrt_s      = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b10001;
wire op_fsqrt_d      = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b10010;
wire op_frecip_s     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b10101;
wire op_frecip_d     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b10110;
wire op_frsqrt_s     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b11001;
wire op_frsqrt_d     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01000 && op_rk == 5'b11010;
wire op_fmov_s       = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b00101;
wire op_fmov_d       = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b00110;
wire op_movgr2fr_w   = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b01001;
wire op_movgr2fr_d   = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b01010;
wire op_movgr2frh_w  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b01011;
wire op_movfr2gr_s   = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b01101;
wire op_movfr2gr_d   = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b01110;
wire op_movfrh2gr_s  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b01111;
wire op_movgr2fcsr   = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b10000;
wire op_movfcsr2gr   = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b10010;
wire op_movfr2cf     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b10100 && op_rd[4:3] == 2'b0;
wire op_movcf2fr     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b10101 && op_rj[4:3] == 2'b0;
wire op_movgr2cf     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b10110 && op_rd[4:3] == 2'b0;
wire op_movcf2gr     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b01001 && op_rk == 5'b10111 && op_rj[4:3] == 2'b0;
wire op_fcvt_s_d     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10010 && op_rk == 5'b00110;
wire op_fcvt_d_s     = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10010 && op_rk == 5'b01001;
wire op_ftintrm_w_s  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10100 && op_rk == 5'b00001;
wire op_ftintrm_w_d  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10100 && op_rk == 5'b00010;
//wire op_ftintrm_l_s  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10100 && op_rk == 5'b01001;
//wire op_ftintrm_l_d  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10100 && op_rk == 5'b01010;
wire op_ftintrp_w_s  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10100 && op_rk == 5'b10001;
wire op_ftintrp_w_d  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10100 && op_rk == 5'b10010;
//wire op_ftintrp_l_s  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10100 && op_rk == 5'b11001;
//wire op_ftintrp_l_d  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10100 && op_rk == 5'b11010;
wire op_ftintrz_w_s  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10101 && op_rk == 5'b00001;
wire op_ftintrz_w_d  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10101 && op_rk == 5'b00010;
//wire op_ftintrz_l_s  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10101 && op_rk == 5'b01001;
//wire op_ftintrz_l_d  = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10101 && op_rk == 5'b01010;
wire op_ftintrne_w_s = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10101 && op_rk == 5'b10001;
wire op_ftintrne_w_d = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10101 && op_rk == 5'b10010;
//wire op_ftintrne_l_s = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10101 && op_rk == 5'b11001;
//wire op_ftintrne_l_d = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10101 && op_rk == 5'b11010;
wire op_ftint_w_s    = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10110 && op_rk == 5'b00001;
wire op_ftint_w_d    = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10110 && op_rk == 5'b00010;
//wire op_ftint_l_s    = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10110 && op_rk == 5'b01001;
//wire op_ftint_l_d    = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b10110 && op_rk == 5'b01010;
wire op_ffint_s_w    = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b11010 && op_rk == 5'b00100;
//wire op_ffint_s_l    = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b11010 && op_rk == 5'b00110;
wire op_ffint_d_w    = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b11010 && op_rk == 5'b01000;
//wire op_ffint_d_l    = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b11010 && op_rk == 5'b01010;
wire op_frint_s      = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b11100 && op_rk == 5'b10001;
wire op_frint_d      = op_func == 6'b000000 && op_def == 6'b010001 && op_sa == 5'b11100 && op_rk == 5'b10010;

//oprand 64
wire op_fmadd_s     = op_func == 6'b000010 && op_def == 6'b000001;
wire op_fmadd_d     = op_func == 6'b000010 && op_def == 6'b000010;
wire op_fmsub_s     = op_func == 6'b000010 && op_def == 6'b000101;
wire op_fmsub_d     = op_func == 6'b000010 && op_def == 6'b000110;
wire op_fnmadd_s    = op_func == 6'b000010 && op_def == 6'b001001;
wire op_fnmadd_d    = op_func == 6'b000010 && op_def == 6'b001010;
wire op_fnmsub_s    = op_func == 6'b000010 && op_def == 6'b001101;
wire op_fnmsub_d    = op_func == 6'b000010 && op_def == 6'b001110;
wire op_fcmp_cond_s = op_func == 6'b000011 && op_def == 6'b000001 && op_rd[4:3] == 2'b00;
wire op_fcmp_cond_d = op_func == 6'b000011 && op_def == 6'b000010 && op_rd[4:3] == 2'b00;
wire op_fsel        = op_func == 6'b000011 && op_def == 6'b010000 && op_sa[4:3] == 2'b00;

////function
//fix
wire rd2rj = op_lu32i_d;

wire gr_wen = op_clo_w || op_clz_w || op_cto_w || op_ctz_w  || op_clo_d  || op_clz_d || op_cto_d || op_ctz_d || op_revb_2h || op_revb_4h || op_revb_2w || op_revb_d || 
              op_revh_2w || op_revh_d || op_bitrev_4b || op_bitrev_8b || op_bitrev_w || op_bitrev_d || op_ext_w_h || op_ext_w_b || op_rdtimel_w || op_rdtimeh_w || 
              op_rdtime_d || op_cpucfg || op_asrtle_d || op_asrtgt_d || op_alsl_w || op_alsl_wu || op_bytepick_w || op_bytepick_d || op_add_w || op_add_d || op_sub_w || 
              op_sub_d || op_slt || op_sltu || op_maskeqz || op_masknez  || op_nor || op_and || op_or || op_xor || op_orn || op_andn || op_sll_w || op_srl_w || op_sra_w || 
              op_sll_d || op_srl_d || op_sra_d || op_rotr_w || op_rotr_d || op_mul_w || op_mulh_w  || op_mulh_wu || op_mul_d || op_mulh_d || op_mulh_du || op_mulw_d_w || 
              op_mulw_d_wu || op_div_w || op_mod_w || op_div_wu || op_mod_wu || op_div_d || op_mod_d || op_div_du || op_mod_du || op_crc_w_b_w || op_crc_w_h_w || 
              op_crc_w_w_w || op_crc_w_d_w || op_crcc_w_b_w || op_crcc_w_h_w || op_crcc_w_w_w || op_crcc_w_d_w || op_crcc_w_d_w || 
              op_alsl_d || op_slli_w || op_slli_d || op_srli_w || op_srli_d || op_srai_w || op_srai_d || op_rotri_w || op_rotri_d || op_bstrins_w || op_bstrpick_w || 
              op_bstrins_d || op_bstrpick_d || //fix
              op_slti || op_sltui || op_addi_w || op_addi_d || op_lu52i_d || op_andi || op_ori || op_xori || //imm12
              op_addu16i_d || op_lu12i_w || op_lu32i_d || op_pcaddi || op_pcalau12i || op_pcaddu12i || op_pcaddu18i || //imm
              op_csrrd || op_csrxchg || op_csrwr ||//plv
              op_ll_w || op_ll_d || op_ldptr_d || op_ldptr_w || op_ld_b || op_ld_h || op_ld_w || op_ld_d || op_ld_bu || op_ld_hu || op_ld_wu || op_ldx_b || op_ldx_h || 
              op_ldx_w || op_ldx_d || op_ldx_bu || op_ldx_hu || op_ldx_wu || op_sc_w || op_sc_d || 
              op_ldgt_b || op_ldgt_h || op_ldgt_w || op_ldgt_d || op_ldle_b || op_ldle_h || op_ldle_w || op_ldle_d || // mem without gs am 
              op_iocsrrd_b || op_iocsrrd_h || op_iocsrrd_w || op_iocsrrd_d || // iocsr
              op_jirl || op_bl || // branch
              op_movfr2gr_s || op_movfr2gr_d || op_movfrh2gr_s || op_movfcsr2gr || op_movcf2gr; // float

wire rj_read = op_clo_w || op_clz_w || op_cto_w || op_ctz_w  || op_clo_d  || op_clz_d || op_cto_d || op_ctz_d || op_revb_2h || op_revb_4h || op_revb_2w || op_revb_d || 
              op_revh_2w || op_revh_d || op_bitrev_4b || op_bitrev_8b || op_bitrev_w || op_bitrev_d || op_ext_w_h || op_ext_w_b || op_rdtimel_w || op_rdtimeh_w || 
              op_rdtime_d || op_cpucfg || op_asrtle_d || op_asrtgt_d || op_alsl_w || op_alsl_wu || op_bytepick_w || op_bytepick_d || op_add_w || op_add_d || op_sub_w || 
              op_sub_d || op_slt || op_sltu || op_maskeqz || op_masknez  || op_nor || op_and || op_or || op_xor || op_orn || op_andn || op_sll_w || op_srl_w || op_sra_w || 
              op_sll_d || op_srl_d || op_sra_d || op_rotr_w || op_rotr_d || op_mul_w || op_mulh_w  || op_mulh_wu || op_mul_d || op_mulh_d || op_mulh_du || op_mulw_d_w || 
              op_mulw_d_wu || op_div_w || op_mod_w || op_div_wu || op_mod_wu || op_div_d || op_mod_d || op_div_du || op_mod_du || op_crc_w_b_w || op_crc_w_h_w || 
              op_crc_w_w_w || op_crc_w_d_w || op_crcc_w_b_w || op_crcc_w_h_w || op_crcc_w_w_w || op_crcc_w_d_w || op_crcc_w_d_w ||
              op_alsl_d || op_slli_w || op_slli_d || op_srli_w || op_srli_d || op_srai_w || op_srai_d || op_rotri_w || op_rotri_d || op_bstrins_w || op_bstrpick_w || 
              op_bstrins_d || op_bstrpick_d || //fix
              op_slti || op_sltui || op_addi_w || op_addi_d || op_lu52i_d || op_andi || op_ori || op_xori || //imm12
              op_addu16i_d || //imm
              rd2rj ||
              op_csrxchg ||
              op_invtlb || op_cache ||
              op_ll_w || op_sc_w || op_ll_d || op_sc_d || op_ldptr_w || op_stptr_w || op_ldptr_d || op_stptr_d || op_ld_b || op_ld_h || op_ld_w || op_ld_d || op_st_b || 
              op_st_h || op_st_w || op_st_d || op_ld_bu || op_ld_hu || op_ld_wu || op_preld || op_ldx_b || op_ldx_h || op_ldx_w || op_ldx_d || op_stx_b || op_stx_h || op_stx_w || op_stx_d || 
              op_ldx_bu || op_ldx_hu || op_ldx_wu || op_preldx || op_amswap_w || op_amswap_d || op_amadd_w || op_amadd_d || op_amand_w || op_amand_d || op_amor_w ||
              op_amor_d || op_amxor_w || op_amxor_d || op_ammax_w || op_ammax_d || op_ammin_w || op_ammin_d || op_ammax_wu || op_ammax_du || op_ammin_wu || op_ammin_du || 
              op_amswap_db_w || op_amswap_db_d || op_amadd_db_w || op_amadd_db_d || op_amand_db_w || op_amand_db_d || op_amor_db_w || op_amor_db_d || op_amxor_db_w || 
              op_amxor_db_d || op_ammax_db_w || op_ammax_db_d || op_ammin_db_w || op_ammin_db_d || op_ammax_db_wu || op_ammax_db_du || op_ammin_db_wu || op_ammin_db_du || 
              op_ldgt_b || op_ldgt_h || op_ldgt_w || op_ldgt_d || op_ldle_b || op_ldle_h || op_ldle_w || op_ldle_d || op_stgt_b || op_stgt_h || 
              op_stgt_w || op_stgt_d || op_stle_b || op_stle_h || op_stle_w || op_stle_d || //mem
              op_iocsrrd_b || op_iocsrrd_h || op_iocsrrd_w || op_iocsrrd_w || op_iocsrwr_b || op_iocsrwr_h || op_iocsrwr_w || op_iocsrwr_d || // iocsr
              op_beqz || op_bnez || op_jirl || op_beq || op_bne || op_blt || op_bge || op_bltu || op_bgeu || //branch
              op_movgr2fr_w || op_movgr2fr_d || op_movgr2frh_w || op_movgr2fcsr || op_movgr2cf;

wire rk_read = op_asrtle_d || op_asrtgt_d || op_alsl_w || op_alsl_wu || op_bytepick_w || op_bytepick_d || op_add_w || op_add_d || op_sub_w || 
              op_sub_d || op_slt || op_sltu || op_maskeqz || op_masknez  || op_nor || op_and || op_or || op_xor || op_orn || op_andn || op_sll_w || op_srl_w || op_sra_w || 
              op_sll_d || op_srl_d || op_sra_d || op_rotr_w || op_rotr_d || op_mul_w || op_mulh_w  || op_mulh_wu || op_mul_d || op_mulh_d || op_mulh_du || op_mulw_d_w || 
              op_mulw_d_wu || op_div_w || op_mod_w || op_div_wu || op_mod_wu || op_div_d || op_mod_d || op_div_du || op_mod_du || op_crc_w_b_w || op_crc_w_h_w || 
              op_crc_w_w_w || op_crc_w_d_w || op_crcc_w_b_w || op_crcc_w_h_w || op_crcc_w_w_w || op_crcc_w_d_w || op_crcc_w_d_w || op_alsl_d ||//fix
              op_ldx_b || op_ldx_h || op_ldx_w || op_ldx_d || op_ldx_bu || op_ldx_hu || op_ldx_wu || op_stx_b || op_stx_h || op_stx_w || op_stx_d ||
              op_ldgt_b || op_ldgt_h || op_ldgt_w || op_ldgt_d || op_ldle_b || op_ldle_h || op_ldle_w || op_ldle_d || 
              op_stgt_b || op_stgt_h || op_stgt_w || op_stgt_d || op_stle_b || op_stle_h || op_stle_w || op_stle_d ||
              op_preldx || op_invtlb ||
              op_amswap_w || op_amswap_d || op_amadd_w || op_amadd_d || op_amand_w || op_amand_d || op_amor_w || op_amor_d || 
              op_amxor_w || op_amxor_d || op_ammax_w || op_ammax_d || op_ammin_w || op_ammin_d || op_ammax_wu || op_ammax_du || 
              op_ammin_wu || op_ammin_du || op_amswap_db_w || op_amswap_db_d || op_amadd_db_w || op_amadd_db_d || op_amand_db_w || 
              op_amand_db_d || op_amor_db_w || op_amor_db_d || op_amxor_db_w || op_amxor_db_d || op_ammax_db_w || op_ammax_db_d || 
              op_ammin_db_w || op_ammin_db_d || op_ammax_db_wu || op_ammax_db_du || op_ammin_db_wu || op_ammin_db_du;// mem
  
wire rd_write = op_clo_w || op_clz_w || op_cto_w || op_ctz_w  || op_clo_d  || op_clz_d || op_cto_d || op_ctz_d || op_revb_2h || op_revb_4h || op_revb_2w || op_revb_d || 
              op_revh_2w || op_revh_d || op_bitrev_4b || op_bitrev_8b || op_bitrev_w || op_bitrev_d || op_ext_w_h || op_ext_w_b || op_rdtimel_w || op_rdtimeh_w || 
              op_rdtime_d || op_cpucfg || op_alsl_w || op_alsl_wu || op_bytepick_w || op_bytepick_d || op_add_w || op_add_d || op_sub_w || 
              op_sub_d || op_slt || op_sltu || op_maskeqz || op_masknez  || op_nor || op_and || op_or || op_xor || op_orn || op_andn || op_sll_w || op_srl_w || op_sra_w || 
              op_sll_d || op_srl_d || op_sra_d || op_rotr_w || op_rotr_d || op_mul_w || op_mulh_w  || op_mulh_wu || op_mul_d || op_mulh_d || op_mulh_du || op_mulw_d_w || 
              op_mulw_d_wu || op_div_w || op_mod_w || op_div_wu || op_mod_wu || op_div_d || op_mod_d || op_div_du || op_mod_du || op_crc_w_b_w || op_crc_w_h_w || 
              op_crc_w_w_w || op_crc_w_d_w || op_crcc_w_b_w || op_crcc_w_h_w || op_crcc_w_w_w || op_crcc_w_d_w || op_crcc_w_d_w ||
              op_alsl_d || op_slli_w || op_slli_d || op_srli_w || op_srli_d || op_srai_w || op_srai_d || op_rotri_w || op_rotri_d || op_bstrins_w || op_bstrpick_w || 
              op_bstrins_d || op_bstrpick_d || //fix
              op_csrxchg || op_csrwr ||
              op_slti || op_sltui || op_addi_w || op_addi_d || op_lu52i_d || op_andi || op_ori || op_xori || //imm12
              op_addu16i_d || op_lu12i_w || op_lu32i_d || op_pcaddi || op_pcalau12i || op_pcaddu12i || op_pcaddu18i || //imm
              op_ll_w || op_sc_w || op_ll_d || op_sc_d || op_ldptr_w || op_stptr_w || op_ldptr_d || op_stptr_d || op_ld_b || op_ld_h || op_ld_w || op_ld_d || 
              op_ld_bu || op_ld_hu || op_ld_wu || op_ldx_b || op_ldx_h || op_ldx_w || op_ldx_d ||
              op_ldx_bu || op_ldx_hu || op_ldx_wu || op_amswap_w || op_amswap_d || op_amadd_w || op_amadd_d || op_amand_w || op_amand_d || op_amor_w ||
              op_amor_d || op_amxor_w || op_amxor_d || op_ammax_w || op_ammax_d || op_ammin_w || op_ammin_d || op_ammax_wu || op_ammax_du || op_ammin_wu || op_ammin_du || 
              op_amswap_db_w || op_amswap_db_d || op_amadd_db_w || op_amadd_db_d || op_amand_db_w || op_amand_db_d || op_amor_db_w || op_amor_db_d || op_amxor_db_w || 
              op_amxor_db_d || op_ammax_db_w || op_ammax_db_d || op_ammin_db_w || op_ammin_db_d || op_ammax_db_wu || op_ammax_db_du || op_ammin_db_wu || op_ammin_db_du || 
              op_ldgt_b || op_ldgt_h || op_ldgt_w || op_ldgt_d || op_ldle_b || op_ldle_h || op_ldle_w || op_ldle_d || op_stgt_b || op_stgt_h || 
              op_stgt_w || op_stgt_d || op_stle_b || op_stle_h || op_stle_w || op_stle_d || //mem
              op_iocsrrd_b || op_iocsrrd_h || op_iocsrrd_w || op_iocsrrd_w || // iocsr
              op_movfr2gr_s || op_movfr2gr_d || op_movfrh2gr_s || op_movfcsr2gr || op_movcf2gr; // float

  wire mul_related = op_mul_d || op_mul_w || op_mulh_d || op_mulh_du || op_mulh_w || op_mulh_wu || op_mulw_d_w || op_mulw_d_w || op_mulw_d_wu;
  
  wire div_related = op_div_d || op_div_du || op_div_w || op_div_wu || op_mod_d || op_mod_du || op_mod_w || op_mod_wu;

  wire high_target = op_mulh_d || op_mulh_du || op_mulh_w || op_mulh_wu || op_div_d || op_div_du || op_div_w || op_div_wu || //mul div
                     op_b || op_bl || // branch inst which needs long offset
                     op_cto_d || op_cto_w || op_ctz_d || op_ctz_w || // count all instead of leading
                     op_rdtimeh_w;

  wire double_word =  op_clo_d || op_clz_d || op_cto_d || op_ctz_d || op_revb_d || op_revh_d || op_bitrev_d || op_rdtime_d || 
                      op_asrtle_d || op_asrtgt_d || op_bytepick_d ||op_add_d || op_sub_d || op_sll_d || op_srl_d || op_sra_d || 
                      op_rotr_d || op_mul_d || op_mulh_d || op_mulh_du || op_mulw_d_w || op_mulw_d_wu || op_div_d || op_div_du || 
                      op_mod_d || op_mod_du || op_alsl_d || op_slli_d || op_srli_d || op_srai_d || op_rotri_d || op_bstrins_d ||
                      op_bstrpick_d || op_revb_4h || op_bitrev_8b || //fix
                      op_addi_d || op_lu52i_d || //imm12
                      op_addu16i_d || op_lu32i_d || op_pcaddu18i || op_pcalau12i || op_pcaddu12i || op_pcaddi || //imm
                      op_ll_d || op_sc_d || op_ldptr_d || op_stptr_d || op_ld_d || op_st_d || op_ldx_d || op_stx_d || op_amswap_d || 
                      op_iocsrrd_d || op_iocsrwr_d ||
                      op_rdtime_d; 

  wire rd_read = op_jirl || op_beq || op_bne || op_blt || op_bge || op_bltu || op_bgeu ||
                op_bstrins_d || op_bstrins_w ||
                // op_lu32i_d ||
                op_csrxchg || op_csrwr ||
                op_sc_w || op_sc_d || op_stptr_w || op_stptr_d || op_st_b || op_st_h || op_st_w || op_st_d || op_stx_b || op_stx_h || op_stx_w || op_stx_d || 
                op_amswap_w || op_amswap_d || op_amadd_w || op_amadd_d || op_amand_w || op_amand_d || op_amor_w ||
                op_amor_d || op_amxor_w || op_amxor_d || op_ammax_w || op_ammax_d || op_ammin_w || op_ammin_d || op_ammax_wu || op_ammax_du || op_ammin_wu || op_ammin_du || 
                op_amswap_db_w || op_amswap_db_d || op_amadd_db_w || op_amadd_db_d || op_amand_db_w || op_amand_db_d || op_amor_db_w || op_amor_db_d || op_amxor_db_w || 
                op_amxor_db_d || op_ammax_db_w || op_ammax_db_d || op_ammin_db_w || op_ammin_db_d || op_ammax_db_wu || op_ammax_db_du || op_ammin_db_wu || op_ammin_db_du || 
                op_ldgt_b || op_ldgt_h || op_ldgt_w || op_ldgt_d || op_ldle_b || op_ldle_h || op_ldle_w || op_ldle_d || op_stgt_b || op_stgt_h || 
                op_stgt_w || op_stgt_d || op_stle_b || op_stle_h || op_stle_w || op_stle_d || //mem;
                op_iocsrwr_b || op_iocsrwr_h || op_iocsrwr_w || op_iocsrwr_d;

  wire i5 = op_slli_w || op_srli_w || op_srai_w || op_rotri_w || op_slli_d || op_srli_d || op_srai_d || op_rotri_d;
  
  // wire i6 = op_slli_d || op_srli_d || op_srai_d || op_rotri_d;

  wire i12 = op_slti || op_sltui || op_addi_w || op_addi_d || op_lu52i_d || op_andi || op_ori || op_xori || // imm
             op_ld_b || op_ld_h || op_ld_w || op_ld_d || op_st_b || op_st_h || op_st_w || op_st_d || op_ld_bu || op_ld_hu || 
             op_ld_wu || op_preld || op_cache || // mem
             op_fld_d || op_fst_d ;

  wire i14 = op_ll_w || op_sc_w || op_ll_d || op_sc_d || op_ldptr_w || op_stptr_w || op_ldptr_d || op_stptr_d;

  wire i16 = op_addu16i_d;

  wire i20 = op_lu12i_w || op_lu32i_d || op_pcaddi || op_pcalau12i || op_pcaddu12i || op_pcaddu18i;

  wire lui = op_lu12i_w;//op_lu52i_d || op_lu32i_d;

  wire unsign = op_mulh_du || op_mulh_wu || op_mulw_d_wu || op_div_du || op_div_wu || op_mod_du || op_mod_wu || 
                op_slli_w || op_slli_d || op_srli_w || op_srli_d || op_srai_w || op_srai_d || op_rotri_w || op_rotri_d || //fix
                op_andi || op_ori || op_xori || op_clz_d || op_clz_w || op_ctz_d || op_ctz_w ||// imm12
                op_bltu || op_bgeu; // branch

  wire lsu_related =op_ll_w || op_sc_w || op_ll_d || op_sc_d || op_ldptr_w || op_stptr_w || op_ldptr_d || op_stptr_d || op_ld_b || op_ld_h || op_ld_w || op_ld_d || op_st_b || 
                    op_st_h || op_st_w || op_st_d || op_ld_bu || op_ld_hu || op_ld_wu || op_preld || op_ldx_h || op_ldx_w || op_ldx_d || op_ldx_b || op_stx_b || op_stx_h || op_stx_w || op_stx_d || 
                    op_ldx_bu || op_ldx_hu || op_ldx_wu || op_preldx || op_amswap_w || op_amswap_d || op_amadd_w || op_amadd_d || op_amand_w || op_amand_d || op_amor_w ||
                    op_amor_d || op_amxor_w || op_amxor_d || op_ammax_w || op_ammax_d || op_ammin_w || op_ammin_d || op_ammax_wu || op_ammax_du || op_ammin_wu || op_ammin_du || 
                    op_amswap_db_w || op_amswap_db_d || op_amadd_db_w || op_amadd_db_d || op_amand_db_w || op_amand_db_d || op_amor_db_w || op_amor_db_d || op_amxor_db_w || 
                    op_amxor_db_d || op_ammax_db_w || op_ammax_db_d || op_ammin_db_w || op_ammin_db_d || op_ammax_db_wu || op_ammax_db_du || op_ammin_db_wu || op_ammin_db_du || 
                    op_dbar || op_ibar || op_ldgt_b || op_ldgt_h || op_ldgt_w || op_ldgt_d || op_ldle_b || op_ldle_h || op_ldle_w || op_ldle_d || op_stgt_b || op_stgt_h || 
                    op_stgt_w || op_stgt_d || op_stle_b || op_stle_h || op_stle_w || op_stle_d || //mem
                    op_iocsrrd_b || op_iocsrrd_h || op_iocsrrd_w || op_iocsrrd_w || op_iocsrwr_b || op_iocsrwr_h || op_iocsrwr_w || op_iocsrwr_d || // iocsr
                    op_fld_d || op_fst_d ||// float
                    op_invtlb || // to make sure that IS will update lsu_base and lsu_wdata for invtlb
                    op_cache ; // to make sure that IS will update lsu_base and lsu_offset for cache op

  wire bru_related = op_beqz || op_bnez || op_bceqz || op_bcnez || op_jiscr0 || op_jiscr1 || op_jirl || op_b || op_bl || op_beq || op_bne || op_blt || op_bge ||
                     op_bltu || op_bgeu;

  wire csr_related = op_csrrd || op_csrwr || op_csrxchg || op_cpucfg || op_rdtime_d || op_rdtimeh_w || op_rdtimel_w;

  wire csr_write = op_csrwr || op_csrxchg;

  wire csr_read = op_csrrd || csr_write;

  wire csr_xchg = op_csrxchg;

  wire cache_related = op_cache;

  wire tlb_related = op_tlbflush  || op_tlbinv  || op_tlbp  || op_tlbr  || op_tlbwi  || op_tlbwr ||
                     op_gtlbflush || op_gtlbinv || op_gtlbp || op_gtlbr || op_gtlbwi || op_gtlbwr||
                     op_invtlb;

  wire pc_related = op_pcaddi || op_pcaddu12i || op_pcaddu18i || op_pcalau12i;

  wire lsu_st = op_sc_w || op_sc_d || op_stptr_w || op_stptr_d || op_st_b || op_st_h || op_st_w || op_st_d || op_stx_b || op_stx_h || op_stx_w || op_stx_d || 
                op_stgt_b || op_stgt_h || op_stgt_w || op_stgt_d || op_stle_b || op_stle_h || op_stle_w || op_stle_d || 
                op_iocsrwr_b || op_iocsrwr_h || op_iocsrwr_w || op_iocsrwr_d || 
                op_amswap_w || op_amswap_d || op_amadd_w || op_amadd_d || op_amand_w || op_amand_d || op_amor_w || op_amor_d || 
                op_amxor_w || op_amxor_d || op_ammax_w || op_ammax_d || op_ammin_w || op_ammin_d || op_ammax_wu || op_ammax_du || 
                op_ammin_wu || op_ammin_du || op_amswap_db_w || op_amswap_db_d || op_amadd_db_w || op_amadd_db_d || op_amand_db_w || 
                op_amand_db_d || op_amor_db_w || op_amor_db_d || op_amxor_db_w || op_amxor_db_d || op_ammax_db_w || op_ammax_db_d || 
                op_ammin_db_w || op_ammin_db_d || op_ammax_db_wu || op_ammax_db_du || op_ammin_db_wu || op_ammin_db_du;
 
  wire [`LLSU_CODE_BIT-1:0] lsu_code = op_ld_b                 ? `LLSU_LD_B      :
                                       op_ld_h                 ? `LLSU_LD_H      :
                                       (op_ld_w || op_ldptr_w) ? `LLSU_LD_W      :
                                       (op_ld_d || op_ldptr_d) ? `LLSU_LD_D      :
                                       op_st_b                 ? `LLSU_ST_B      :
                                       op_st_h                 ? `LLSU_ST_H      :
                                       (op_st_w || op_stptr_w) ? `LLSU_ST_W      :
                                       (op_st_d || op_stptr_d) ? `LLSU_ST_D      :
                                       op_stx_b                ? `LLSU_STX_B     :
                                       op_stx_h                ? `LLSU_STX_H     :
                                       op_stx_w                ? `LLSU_STX_W     :
                                       op_stx_d                ? `LLSU_STX_D     :
                                       op_ld_bu                ? `LLSU_LD_BU     :
                                       op_ld_hu                ? `LLSU_LD_HU     :
                                       op_ld_wu                ? `LLSU_LD_WU     :
                                       op_ldx_bu               ? `LLSU_LDX_BU    :
                                       op_ldx_hu               ? `LLSU_LDX_HU    :
                                       op_ldx_wu               ? `LLSU_LDX_WU    :
                                       op_ldx_b                ? `LLSU_LDX_B     :
                                       op_ldx_h                ? `LLSU_LDX_H     :
                                       op_ldx_w                ? `LLSU_LDX_W     :
                                       op_ldx_d                ? `LLSU_LDX_D     :
                                       op_ldgt_b               ? `LLSU_LDGT_B    :
                                       op_ldgt_h               ? `LLSU_LDGT_H    :
                                       op_ldgt_w               ? `LLSU_LDGT_W    :
                                       op_ldgt_d               ? `LLSU_LDGT_D    :
                                       op_ldle_b               ? `LLSU_LDLE_B    :
                                       op_ldle_h               ? `LLSU_LDLE_H    :
                                       op_ldle_w               ? `LLSU_LDLE_W    :
                                       op_ldle_d               ? `LLSU_LDLE_D    :
                                       op_stgt_b               ? `LLSU_STGT_B    :
                                       op_stgt_h               ? `LLSU_STGT_H    :
                                       op_stgt_w               ? `LLSU_STGT_W    :
                                       op_stgt_d               ? `LLSU_STGT_D    :
                                       op_stle_b               ? `LLSU_STLE_B    :
                                       op_stle_h               ? `LLSU_STLE_H    :
                                       op_stle_w               ? `LLSU_STLE_W    :
                                       op_stle_d               ? `LLSU_STLE_D    :
                                       op_preld                ? `LLSU_PRELD     :
                                       op_preldx               ? `LLSU_PRELDX    :
                                       op_iocsrrd_b            ? `LLSU_IOCSRRD_B :
                                       op_iocsrrd_h            ? `LLSU_IOCSRRD_H :
                                       op_iocsrrd_w            ? `LLSU_IOCSRRD_W :
                                       op_iocsrrd_w            ? `LLSU_IOCSRRD_D :
                                       op_iocsrwr_b            ? `LLSU_IOCSRWR_B :
                                       op_iocsrwr_h            ? `LLSU_IOCSRWR_H :
                                       op_iocsrwr_w            ? `LLSU_IOCSRWR_W :
                                       op_iocsrwr_d            ? `LLSU_IOCSRWR_D :
                                       op_ll_w                 ? `LLSU_LL_W      :
                                       op_ll_d                 ? `LLSU_LL_D      :
                                       op_sc_w                 ? `LLSU_SC_W      :
                                       op_sc_d                 ? `LLSU_SC_D      :
                                                                 `LLSU_IDLE      ;


  wire [`LMDU_CODE_BIT-1:0] mdu_code = op_mul_w     ? `LMDU_MUL_W     :
                                             op_mulh_w    ? `LMDU_MULH_W    :
                                             op_mulh_wu   ? `LMDU_MULH_WU   :
                                             op_mul_d     ? `LMDU_MUL_D     :
                                             op_mulh_d    ? `LMDU_MULH_D    :
                                             op_mulh_du   ? `LMDU_MULH_DU   :
                                             op_mulw_d_w  ? `LMDU_MULW_D_W  :
                                             op_mulw_d_wu ? `LMDU_MULW_D_WU :
                                             op_div_w     ? `LMDU_DIV_W     :
                                             op_mod_w     ? `LMDU_MOD_W     :
                                             op_div_wu    ? `LMDU_DIV_WU    :
                                             op_mod_wu    ? `LMDU_MOD_WU    :
                                             op_div_d     ? `LMDU_DIV_D     :
                                             op_mod_d     ? `LMDU_MOD_D     :
                                             op_div_du    ? `LMDU_DIV_DU    :
                                                            `LMDU_MOD_DU    ;

  wire [`LALU_CODE_BIT-1:0] alu_code = (op_add_w || op_add_d || op_addi_w || op_addi_d || op_addu16i_d || op_pcaddi || 
                                            op_pcaddu12i || op_pcaddu18i) ? `LALU_ADD :
                                            op_pcalau12i ? `LALU_PCALAU :
                                            (op_sub_w || op_sub_d) ? `LALU_SUB :
                                            (op_and || op_andi) ? `LALU_AND :
                                            (op_andn) ? `LALU_ANDN :
                                            (op_orn) ? `LALU_ORN :
                                            (op_or || op_ori) ? `LALU_OR :
                                            (op_xor || op_xori) ? `LALU_XOR :
                                            (op_nor) ? `LALU_NOR :
                                            (op_slt || op_slti) ? `LALU_SLT :
                                            (op_sltu || op_sltui) ? `LALU_SLTU :
                                            (op_sll_w || op_sll_d || op_slli_d || op_slli_w) ? `LALU_SLL :
                                            (op_srl_w || op_srl_d || op_srli_d || op_srli_w) ? `LALU_SRL :
                                            (op_sra_w || op_sra_d || op_srai_d || op_srai_w) ? `LALU_SRA :
                                            (op_rotr_w || op_rotr_d || op_rotri_w || op_rotri_d) ? `LALU_ROT :
                                            (op_clo_w || op_clz_w ||op_clo_d || op_clz_d) ? `LALU_COUNT_L :
                                            (op_bitrev_4b || op_bitrev_8b) ? `LALU_BITSWAP :
                                            (op_bitrev_w || op_bitrev_d) ? `LALU_BITREV :
                                            (op_bstrpick_w || op_bstrpick_d) ? `LALU_EXT :
                                            (op_bstrins_w || op_bstrins_d) ? `LALU_INS :
                                            op_ext_w_b ? `LALU_SEB :
                                            op_ext_w_h ? `LALU_SEH :
                                            (op_revb_2h || op_revb_4h) ? `LALU_WSBH :
                                            (op_revb_2w || op_revb_d) ? `LALU_REVB :
                                            (op_maskeqz) ? `LALU_SELNEZ :
                                            (op_masknez) ? `LALU_SELEQZ :
                                            (op_alsl_w || op_alsl_d) ? `LALU_LSA :
                                            (op_alsl_wu) ? `LALU_LSAU :
                                            (op_bytepick_w || op_bytepick_d) ? `LALU_ALIGN :
                                            (op_cto_w || op_ctz_w || op_cto_d || op_ctz_d) ? `LALU_COUNT_T :
                                            (op_revh_d || op_revh_2w) ? `LALU_DSHD :
                                            op_lu52i_d ? `LALU_LU52I :
                                            op_lu12i_w ? `LALU_LU12I :
                                            `LALU_LU32I; //op_lu32i_d 

wire [`LBRU_CODE_BIT-1:0] bru_code = (op_beqz || op_bceqz) ? `LBRU_EQZ :
                                           (op_bnez || op_bcnez) ? `LBRU_NEZ :
                                           (op_blt) ? `LBRU_LT :
                                           (op_bge) ? `LBRU_GE :
                                           (op_jirl || op_jiscr0 || op_jiscr1) ? `LBRU_JR :
                                           (op_beq) ? `LBRU_EQ :
                                           (op_bne) ? `LBRU_NE :
                                           (op_bltu)? `LBRU_LTU:
                                           (op_bgeu)? `LBRU_GEU:
                                           (op_bl  )? `LBRU_BL :
                                           `LBRU_IDLE;

wire [`LTLB_CODE_BIT-1:0] tlb_code = op_tlbflush  ? `LTLB_TLBFLUSH  :
                                           op_tlbinv    ? `LTLB_TLBINV    :
                                           op_tlbp      ? `LTLB_TLBP      :
                                           op_tlbr      ? `LTLB_TLBR      :
                                           op_tlbwi     ? `LTLB_TLBWI     :
                                           op_tlbwr     ? `LTLB_TLBWR     :
                                           op_gtlbflush ? `LTLB_GTLBFLUSH :
                                           op_gtlbinv   ? `LTLB_GTLBINV   :
                                           op_gtlbp     ? `LTLB_GTLBP     :
                                           op_gtlbr     ? `LTLB_GTLBR     :
                                           op_gtlbwi    ? `LTLB_GTLBWI    :
                                           op_gtlbwr    ? `LTLB_GTLBWR    :
                                           op_invtlb    ? `LTLB_INVTLB    :
                                                          `LTLB_CODE_BIT'b0;

wire sa = op_alsl_d || op_bytepick_d || op_bytepick_w || op_alsl_w || op_alsl_wu;

wire msbd = op_bstrins_w || op_bstrpick_d || op_bstrins_d || op_bstrpick_w;

wire cpucfg = op_cpucfg;

wire syscall = op_syscall;

wire eret = op_eret;

wire rdtime = op_rdtimel_w || op_rdtimeh_w || op_rdtime_d;

wire [2:0] imm_shift =  (op_pcaddi || op_ll_d || op_ll_w || op_sc_d || op_sc_w || op_ldptr_d || 
                         op_ldptr_w || op_stptr_d || op_stptr_w || bru_related) ? `LIMM_SHIFT_2 :
                        (op_lu12i_w || op_pcaddu12i || op_pcalau12i) ? `LIMM_SHIFT_12 :
                        (op_addu16i_d) ? `LIMM_SHIFT_16 :
                        (op_pcaddu18i) ? `LIMM_SHIFT_18 :
                        (op_lu32i_d)   ? `LIMM_SHIFT_32 :
                        (op_lu52i_d)   ? `LIMM_SHIFT_52 :
                                         `LIMM_SHIFT_0  ;

wire triple_read = op_stx_b || op_stx_d || op_stx_h || op_stx_w || op_stgt_b || op_stgt_h || op_stgt_w || op_stgt_d || op_stle_b || op_stle_h || op_stle_w || op_stle_d;
wire double_read = op_preldx || op_ldx_b || op_ldx_h || op_ldx_w || op_ldx_d || op_ldx_bu || op_ldx_hu || op_ldx_wu || op_ldgt_b || op_ldgt_h || op_ldgt_w || op_ldgt_d || op_ldle_b || op_ldle_h || op_ldle_w || op_ldle_d ||
                   op_amswap_w || op_amswap_d || op_amadd_w || op_amadd_d || op_amand_w || op_amand_d || op_amor_w ||
                   op_amor_d || op_amxor_w || op_amxor_d || op_ammax_w || op_ammax_d || op_ammin_w || op_ammin_d || op_ammax_wu || op_ammax_du || op_ammin_wu || op_ammin_du || 
                   op_amswap_db_w || op_amswap_db_d || op_amadd_db_w || op_amadd_db_d || op_amand_db_w || op_amand_db_d || op_amor_db_w || op_amor_db_d || op_amxor_db_w || 
                   op_amxor_db_d || op_ammax_db_w || op_ammax_db_d || op_ammin_db_w || op_ammin_db_d || op_ammax_db_wu || op_ammax_db_du || op_ammin_db_wu || op_ammin_db_du;

//float
wire float    = op_fmadd_s || op_fmadd_d || op_fmsub_s || op_fld_d || op_fst_d || 
                op_fadd_s || op_fadd_d || op_fsub_s || 
                op_movgr2fr_w || op_movgr2fr_d || op_movgr2frh_w || op_movfr2gr_s || op_movfr2gr_d || op_movfrh2gr_s || op_movgr2fcsr || op_movfcsr2gr ||
                op_movfr2cf || op_movcf2fr || op_movgr2cf || // float
                op_bceqz || op_bcnez;// branch

wire fr_wen   = op_fmadd_s || op_fmadd_d || op_fmsub_s || op_fld_d ||
                op_fadd_s || op_fadd_d || op_fsub_s || // float
                op_movgr2fr_w || op_movgr2fr_d || op_movgr2frh_w || op_movcf2fr;

wire fk_read  = op_fadd_s || op_fadd_d || op_fsub_s;

wire fj_read  = op_fadd_s || op_fadd_d || op_fsub_s || op_movfr2gr_s || op_movfr2gr_d || op_movfrh2gr_s || op_movfr2cf;

wire fd_write = op_fadd_s || op_fadd_d || op_fsub_s || op_movgr2fr_w || op_movgr2fr_d || op_movgr2frh_w || op_movcf2fr;

wire ff_exchange = op_movgr2fr_w || op_movgr2fr_d || op_movgr2frh_w || op_movfr2gr_s || op_movfr2gr_d || op_movfrh2gr_s;

// wire [2:0] fpu_stage = op_fadd_s ? `LFPU_UNI :
//                        op_fadd_d ? `LFPU_DOU :
//                        op_fsub_s ? `LFPU_TRI :
//                                    `LFPU_QUI ;

`ifdef GS264C_64BIT
wire valid = op_clo_w     || op_clz_w     || op_cto_w     || op_ctz_w     || op_clo_d     || op_clz_d     || op_cto_d     || op_ctz_d     ||
             op_revb_2h   || op_revb_4h   || op_revb_2w   || op_revb_d    || op_revh_2w   || op_revh_d    || op_bitrev_4b || op_bitrev_8b ||
             op_bitrev_w  || op_bitrev_d  || op_ext_w_h   || op_ext_w_b   || op_rdtimel_w || op_rdtimeh_w || op_rdtime_d  || op_cpucfg    || 
             op_asrtle_d  || op_asrtgt_d  || op_alsl_w    || op_alsl_wu   || op_bytepick_w|| op_bytepick_d|| 
             op_add_w      || op_add_d      || op_sub_w      || op_sub_d      || op_slt        || op_sltu       || op_maskeqz    || 
             op_masknez    || op_nor        || op_and        || op_or         || op_xor        || op_orn        || op_andn       || 
             op_sll_w      || op_srl_w      || op_sra_w      || op_sll_d      || op_srl_d      || op_sra_d      || op_rotr_w     || 
             op_rotr_d     || op_mul_w      || op_mulh_w     || op_mulh_wu    || op_mul_d      || op_mulh_d     || op_mulh_du    || 
             op_mulw_d_w   || op_mulw_d_wu  || op_div_w      || op_mod_w      || op_div_wu     || op_mod_wu     || op_div_d      || 
             op_mod_d      || op_div_du     || op_mod_du     || op_crc_w_b_w  || op_crc_w_h_w  || op_crc_w_w_w  || op_crc_w_d_w  || 
             op_crcc_w_b_w || op_crcc_w_h_w || op_crcc_w_w_w || op_crcc_w_d_w || op_break      || op_dbgcall    || op_syscall    || 
             op_alsl_d     || op_slli_w     || op_slli_d     || op_srli_w     || op_srli_d     || op_srai_w     || op_srai_d     || 
             op_rotri_w    || op_rotri_d    || op_bstrins_w  || op_bstrpick_w || op_bstrins_d  || op_bstrpick_d || op_slti       || 
             op_sltui      || op_addi_w     || op_addi_d     || op_lu52i_d    || op_andi       || op_ori        || op_xori       || 
             op_addu16i_d  || op_lu12i_w    || op_lu32i_d    || op_pcaddi     || op_pcalau12i  || op_pcaddu12i  || op_pcaddu18i  ||
             op_csrrd      || op_csrwr      || op_csrxchg    || op_gcsrrd     || op_gcsrwr     || op_gcsrxchg   || op_cache      || 
             op_lddir      || op_ldpte      || op_iocsrrd_b  || op_iocsrrd_h  || op_iocsrrd_w  || op_iocsrrd_d  || op_iocsrwr_b  || 
             op_iocsrwr_h  || op_iocsrwr_w  || op_iocsrwr_d  || op_tlbinv     || op_gtlbinv    || op_tlbflush   || op_gtlbflush  || 
             op_tlbp       || op_gtlbp      || op_tlbr       || op_gtlbr      || op_tlbwi      || op_gtlbwi     || op_tlbwr      || 
             op_gtlbwr     || op_eret       || op_wait       || op_invtlb     ||
             op_ll_w        || op_sc_w        || op_ll_d        || op_sc_d        || op_ldptr_w     || op_stptr_w     || op_ldptr_d     || 
             op_stptr_d     || op_ld_b        || op_ld_h        || op_ld_w        || op_ld_d        || op_st_b        || op_st_h        || 
             op_st_w        || op_st_d        || op_ld_bu       || op_ld_hu       || op_ld_wu       || op_preld       || op_ldx_b       || 
             op_ldx_h       || op_ldx_w       || op_ldx_d       || op_stx_b       || op_stx_h       || op_stx_w       || op_stx_d       || 
             op_ldx_bu      || op_ldx_hu      || op_ldx_wu      || op_preldx      || op_amswap_w    || op_amswap_d    || op_amadd_w     || 
             op_amadd_d     || op_amand_w     || op_amand_d     || op_amor_w      || op_amor_d      || op_amxor_w     || op_amxor_d     || 
             op_ammax_w     || op_ammax_d     || op_ammin_w     || op_ammin_d     || op_ammax_wu    || op_ammax_du    || op_ammin_wu    || 
             op_ammin_du    || op_amswap_db_w || op_amswap_db_d || op_amadd_db_w  || op_amadd_db_d  || op_amand_db_w  || op_amand_db_d  || 
             op_amor_db_w   || op_amor_db_d   || op_amxor_db_w  || op_amxor_db_d  || op_ammax_db_w  || op_ammax_db_d  || op_ammin_db_w  || 
             op_ammin_db_d  || op_ammax_db_wu || op_ammax_db_du || op_ammin_db_wu || op_ammin_db_du || op_dbar        || op_ibar        || 
             op_ldgt_b      || op_ldgt_h      || op_ldgt_w      || op_ldgt_d      || op_ldle_b      || op_ldle_h      || op_ldle_w      || 
             op_ldle_d      || op_stgt_b      || op_stgt_h      || op_stgt_w      || op_stgt_d      || op_stle_b      || op_stle_h      || 
             op_stle_w      || op_stle_d      || op_beqz        || op_bnez        || op_bceqz       || op_bcnez       || op_jiscr0      || 
             op_jiscr1      || op_jirl        || op_b           || op_bl          || op_beq         || op_bne         || op_blt         || 
             op_bge         || op_bltu        || op_bgeu        ||
             op_fld_s        || op_fst_s        ||
             op_fld_d        || op_fst_d        || op_fadd_s       || op_fadd_d       || op_fsub_s       || op_fsub_d       || op_fmul_s       || 
             op_fmul_d       || op_fdiv_s       || op_fdiv_d       || op_fmax_s       || op_fmax_d       || op_fmin_s       || op_fmin_d       || 
             op_fmaxa_s      || op_fmaxa_d      || op_fmina_s      || op_fmina_d      || op_fscaleb_s    || op_fscaleb_d    || op_fcopysign_s  || 
             op_fcopysign_d  || op_fabs_s       || op_fabs_d       || op_neg_s        || op_neg_d        || op_flogb_s      || op_flogb_d      || 
             op_fclass_s     || op_fclass_d     || op_fsqrt_s      || op_fsqrt_d      || op_frecip_s     || op_frecip_d     || op_frsqrt_s     || 
             op_frsqrt_d     || op_fmov_s       || op_fmov_d       || op_movgr2fr_w   || op_movgr2fr_d   || op_movgr2frh_w  || op_movfr2gr_s   || 
             op_movfr2gr_d   || op_movfrh2gr_s  || op_movgr2fcsr   || op_movfcsr2gr   || op_movfr2cf     || op_movcf2fr     || op_movgr2cf     || 
             op_movcf2gr     || op_fcvt_s_d     || op_fcvt_d_s     || op_ftintrm_w_s  || op_ftintrm_w_d  || op_ftintrm_l_s  || op_ftintrm_l_d  || 
             op_ftintrp_w_s  || op_ftintrp_w_d  || op_ftintrp_l_s  || op_ftintrp_l_d  || op_ftintrz_w_s  || op_ftintrz_w_d  || op_ftintrz_l_s  || 
             op_ftintrz_l_d  || op_ftintrne_w_s || op_ftintrne_w_d || op_ftintrne_l_s || op_ftintrne_l_d || op_ftint_w_s    || op_ftint_w_d    || 
             op_ftint_l_s    || op_ftint_l_d    || op_ffint_s_w    || op_ffint_s_l    || op_ffint_d_w    || op_ffint_d_l    || op_frint_s      || 
             op_frint_d      || op_fmadd_s      || op_fmadd_d      || op_fmsub_s      || op_fmsub_d      || op_fnmadd_s     || op_fnmadd_d     || 
             op_fnmsub_s     || op_fnmsub_d     || op_fcmp_cond_s  || op_fcmp_cond_d  || op_fsel         ;
`else
wire valid = op_rdtimel_w || op_rdtimeh_w || op_add_w     || op_sub_w   || op_slt    || op_sltu    || op_nor    || op_and     || op_or      || op_xor     || 
             op_sll_w     || op_srl_w     || op_sra_w     || op_mul_w   || op_mulh_w || op_mulh_wu || op_div_w  || op_mod_w   || op_div_wu  || op_mod_wu  ||
             op_break     || op_syscall   || op_slli_w    || op_srli_w  || op_srai_w || 
             op_fadd_s       || op_fadd_d       || op_fsub_s     || op_fsub_d      || op_fmul_s      || op_fmul_d      || op_fdiv_s      || op_fdiv_d      || op_fmax_s      || 
             op_fmax_d       || op_fmin_s       || op_fmin_d     || op_fmaxa_s     || op_fmaxa_d     || op_fmina_s     || op_fmina_d     || op_fscaleb_s   || op_fscaleb_d   || 
             op_fcopysign_s  || op_fcopysign_d  || op_fabs_s     || op_fabs_d      || op_neg_s       || op_neg_d       || op_flogb_s     || op_flogb_d     || op_fclass_s    ||
             op_fclass_d     || op_fsqrt_s      || op_fsqrt_d    || op_frecip_s    || op_frecip_d    || op_frsqrt_s    || op_frsqrt_d    || op_fmov_s      || op_fmov_d      ||
             op_movgr2fr_w   || op_movgr2frh_w  || op_movfr2gr_s || op_movfrh2gr_s || op_movgr2fcsr  || op_movfcsr2gr  || op_movfr2cf    || op_movcf2fr    || op_movgr2cf    ||
             op_movcf2gr     || op_fcvt_s_d     || op_fcvt_d_s   || op_ftintrm_w_s || op_ftintrm_w_d || op_ftintrp_w_s || op_ftintrp_w_d || op_ftintrz_w_s || op_ftintrz_w_d ||
             op_ftintrne_w_s || op_ftintrne_w_d || op_ftint_w_s  || op_ftint_w_d   || op_ffint_s_w   || op_ffint_d_w   || op_frint_s     || op_frint_d     || 
             op_slti || op_sltui || op_addi_w || op_andi  || op_ori  || op_xori || op_csrrd  || op_csrwr   || op_csrxchg || op_cache   || 
             op_tlbp || op_tlbr  || op_tlbwi  || op_tlbwr || op_eret || op_wait || op_tlbinv || op_invtlb  ||
             op_fmadd_s     || op_fmadd_d     || op_fmsub_s || op_fmsub_d || op_fnmadd_s || op_fnmadd_d || op_fnmsub_s || op_fnmsub_d ||
             op_fcmp_cond_s || op_fcmp_cond_d || op_fsel    ||
             op_lu12i_w || op_pcaddu12i || op_ll_w  || op_sc_w  || op_ld_b  || op_ld_h  || op_ld_w  || op_st_b  || op_st_h  ||
             op_st_w    || op_ld_bu     || op_ld_wu || op_ld_hu || op_preld || op_fld_s || op_fst_s || op_fld_d || op_fst_d ||
             op_dbar    || op_ibar      || op_bceqz || op_bcnez || op_jirl  || op_b     || op_bl    || op_beq   || op_bne   ||
             op_blt     || op_bge       || op_bltu  || op_bgeu  || op_bnez  || op_beqz ;
`endif

////result
assign res[`LGR_WEN        ] = gr_wen;
assign res[`LRJ_READ       ] = rj_read;
assign res[`LRK_READ       ] = rk_read;
assign res[`LRD_WRITE      ] = rd_write || fd_write;
assign res[`LMUL_RELATED   ] = mul_related;
assign res[`LDIV_RELATED   ] = div_related;
assign res[`LDOUBLE_WORD   ] = double_word;
assign res[`LHIGH_TARGET   ] = high_target;
assign res[`LI5            ] = i5;
assign res[`LI12           ] = i12;
assign res[`LI14           ] = i14;
assign res[`LI16           ] = i16;
assign res[`LI20           ] = i20;
assign res[`LUNSIGN        ] = unsign;
assign res[`LLSU_RELATED   ] = lsu_related;
assign res[`LBRU_RELATED   ] = bru_related;
assign res[`LCSR_RELATED   ] = csr_related;
assign res[`LCSR_WRITE     ] = csr_write;
assign res[`LCACHE_RELATED ] = cache_related;
assign res[`LTLB_RELATED   ] = tlb_related;
assign res[`LPC_RELATED    ] = pc_related;
assign res[`LRD_READ       ] = rd_read;
assign res[`LLSU_ST        ] = lsu_st;
assign res[`LSA            ] = sa;
assign res[`LMSBW          ] = msbd;
assign res[`LBREAK         ] = op_break;
assign res[`LCPUCFG        ] = cpucfg;
assign res[`LSYSCALL       ] = syscall;
assign res[`LERET          ] = eret;
assign res[`LOP_CODE       ] = (mul_related || div_related) ? {3'b0,mdu_code} :
                                     (lsu_related && !op_invtlb ) ?       lsu_code  :
                                     bru_related                  ? {3'b0,bru_code} :
                                     tlb_related                  ? {3'b0,tlb_code} :
                                                                    {1'b0,alu_code} ;
assign res[`LLUI           ] = lui;
assign res[`LIMM_SHIFT     ] = imm_shift;
assign res[`LRD2RJ         ] = rd2rj;
assign res[`LCSR_READ      ] = csr_read;
assign res[`LCSR_XCHG      ] = csr_xchg;
assign res[`LTRIPLE_READ   ] = triple_read;
assign res[`LDOUBLE_READ   ] = double_read;
assign res[`LDBAR          ] = op_dbar ||
                                     op_amswap_db_w || op_amswap_db_d || op_amadd_db_w || op_amadd_db_d || op_amand_db_w || op_amand_db_d || op_amor_db_w || op_amor_db_d || op_amxor_db_w || 
                                     op_amxor_db_d || op_ammax_db_w || op_ammax_db_d || op_ammin_db_w || op_ammin_db_d || op_ammax_db_wu || op_ammax_db_du || op_ammin_db_wu || op_ammin_db_du;
assign res[`LIBAR          ] = op_ibar;
assign res[`LFLOAT         ] = float;
assign res[`LFR_WEN        ] = fr_wen;
assign res[`LFJ_READ       ] = fj_read;
assign res[`LFK_READ       ] = fk_read;
assign res[`LFD_READ       ] = 1'b0;//fd_read;
assign res[`LFF_EXCHANGE   ] = {1'b0,ff_exchange};
// assign res[`LFPU_STAGE     ] = fpu_stage;
assign res[`LFPU_STAGE     ] = 3'b0; // Unimplemented

assign res[`LINE           ] = !valid || (op_invtlb && ((op_rd != 5'h0) && (op_rd != 5'h1) && (op_rd != 5'h2) && (op_rd != 5'h3) && (op_rd != 5'h4) && (op_rd != 5'h5) && (op_rd != 5'h6)));
assign res[`LRDTIME        ] = rdtime;
assign res[`LWAIT          ] = op_wait;

endmodule
