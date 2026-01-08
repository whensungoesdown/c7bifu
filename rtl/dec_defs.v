`define LDECODE_RES_BIT  60
`define LGR_WEN          0
`define LRJ_READ         1
`define LRK_READ         2
`define LRD_WRITE        3
`define LMUL_RELATED     4
`define LDIV_RELATED     5
`define LDOUBLE_WORD     6
`define LHIGH_TARGET     7
`define LI5              8
`define LI12             9
`define LI16             10
`define LI20             11
`define LUNSIGN          12
`define LLSU_RELATED     13
`define LBRU_RELATED     14
`define LCSR_RELATED     15
`define LCSR_WRITE       16
`define LCACHE_RELATED   17
`define LTLB_RELATED     18
`define LPC_RELATED      19
`define LRD_READ         20
`define LLSU_ST          21
`define LSA              22
`define LMSBW            23
`define LCPUCFG          24
`define LBREAK           25
`define LSYSCALL         26
`define LERET            27
`define LOP_CODE         34:28
`define LLUI             35
`define LIMM_SHIFT       38:36
`define LI14             39
`define LCSR_READ        40
`define LCSR_XCHG        41
`define LTRIPLE_READ     42
`define LDOUBLE_READ     43
`define LFLOAT           44
`define LFR_WEN          45
`define LFJ_READ         46
`define LFK_READ         47
`define LFD_READ         48
`define LFF_EXCHANGE     50:49
`define LFPU_STAGE       53:51
`define LDBAR            54
`define LIBAR            55
`define LRD2RJ           56
`define LINE             57
`define LRDTIME          58
`define LWAIT            59

`define LOP_CODE_BIT     7
`define LALU_CODE        33:28
`define LBRU_CODE        31:28
`define LMDU_CODE        31:28
`define LTLB_CODE        31:28


// IMM SHIFT encoding
`define LIMM_SHIFT_0     3'b000
`define LIMM_SHIFT_2     3'b001
`define LIMM_SHIFT_12    3'b010
`define LIMM_SHIFT_16    3'b011
`define LIMM_SHIFT_18    3'b100
`define LIMM_SHIFT_32    3'b101
`define LIMM_SHIFT_52    3'b110


// MDU encoding
`define LMDU_CODE_BIT    4
`define LMDU_MUL_W       4'b0000
`define LMDU_MULH_W      4'b0001
`define LMDU_MULH_WU     4'b0010
`define LMDU_MUL_D       4'b0011
`define LMDU_MULH_D      4'b0100
`define LMDU_MULH_DU     4'b0101
`define LMDU_MULW_D_W    4'b0110
`define LMDU_MULW_D_WU   4'b0111
`define LMDU_DIV_W       4'b1000
`define LMDU_MOD_W       4'b1001
`define LMDU_DIV_WU      4'b1010
`define LMDU_MOD_WU      4'b1011
`define LMDU_DIV_D       4'b1100
`define LMDU_MOD_D       4'b1101
`define LMDU_DIV_DU      4'b1110
`define LMDU_MOD_DU      4'b1111

// TLBop encoding
`define LTLB_CODE_BIT    4
`define LTLB_TLBFLUSH    `LTLB_CODE_BIT'b0000
`define LTLB_TLBINV      `LTLB_CODE_BIT'b0001
`define LTLB_TLBP        `LTLB_CODE_BIT'b0010
`define LTLB_TLBR        `LTLB_CODE_BIT'b0011
`define LTLB_TLBWI       `LTLB_CODE_BIT'b0100
`define LTLB_TLBWR       `LTLB_CODE_BIT'b0101
`define LTLB_GTLBFLUSH   `LTLB_CODE_BIT'b0110
`define LTLB_GTLBINV     `LTLB_CODE_BIT'b0111
`define LTLB_GTLBP       `LTLB_CODE_BIT'b1000
`define LTLB_GTLBR       `LTLB_CODE_BIT'b1001
`define LTLB_GTLBWI      `LTLB_CODE_BIT'b1010
`define LTLB_GTLBWR      `LTLB_CODE_BIT'b1011
`define LTLB_INVTLB      `LTLB_CODE_BIT'b1100

// CSR encoding
`define LCSR_CODE_BIT    8
`define LCSR_VALID       0
`define LTLB_VALID       1
`define LCACHE_VALID     2
`define LCSR_OP_BIT      5
`define LCSR_OP          7:3
`define LCSR_IDLE        `LCSR_OP_BIT'b00000 
`define LCSR_CSRRD       `LCSR_OP_BIT'b00001 
`define LCSR_CSRWR       `LCSR_OP_BIT'b00010 
`define LCSR_CSRXCHG     `LCSR_OP_BIT'b00011 


// from defines.vh

// EXCCODE
`define EXC_INT         6'h00
`define EXC_PIL         6'h01
`define EXC_PIS         6'h02
`define EXC_PIF         6'h03
`define EXC_PWE         6'h04
`define EXC_PNR         6'h05
`define EXC_PNE         6'h06
`define EXC_PPI         6'h07
`define EXC_ADEF        6'h08
`define EXC_ADEM        6'h08
`define EXC_ALE         6'h09
`define EXC_BCE         6'h0a
`define EXC_SYS         6'h0b
`define EXC_BRK         6'h0c
`define EXC_INE         6'h0d
`define EXC_IPE         6'h0e
`define EXC_FPD         6'h0f
`define EXC_SXD         6'h10
`define EXC_ASXD        6'd11
`define EXC_FPE         6'd12
`define EXC_VFPE        6'd12
`define EXC_WPEF        6'h13
`define EXC_WPEM        6'h13
`define EXC_BTD         6'h14
`define EXC_BTE         6'h15
`define EXC_GSPR        6'h16
`define EXC_HYP         6'h17
`define EXC_GCSC        6'h18
`define EXC_GCHC        6'h18

`define EXC_CACHEERR    6'h1e

`define EXC_ERROR       6'h3e
`define EXC_TLBR        6'h3f

`define EXC_NONE        6'h30

// instruction encoding
`define GET_RK(x)       x[14:10]
`define GET_RJ(x)       x[ 9: 5]
`define GET_RD(x)       x[ 4: 0]
`define GET_SA(x)       x[17:15]
`define GET_MSLSBD(x)   x[21:10]
`define GET_I5(x)       x[14:10]
`define GET_I6(x)       x[15:10]
`define GET_I12(x)      x[21:10]
`define GET_I14(x)      x[23:10]
`define GET_I16(x)      x[25:10]
`define GET_I20(x)      x[24: 5]
`define GET_OFFSET16(x) x[25:10]
`define GET_OFFSET21(x) {x[4:0],x[25:10]}
`define GET_OFFSET26(x) {x[9:0],x[25:10]}
`define GET_CSR(x)      x[23:10] // TO CHECK!!!!!!!!!!!!!!!!!!!!!!!!!!!

