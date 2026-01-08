`include "dec_defs.v"
`include "alu_defs.v"

module c7bifu_imd(
   input  [31:0]                        inst,
   input  [`LDECODE_RES_BIT-1:0]  op,
   output [31:0]                        imm_shifted,
   output [31:0]                  alu_c,
   output [31:0]                  br_offs
   );

   //immediate operater prepare
   wire [ 4:0] port0_i5  = `GET_I5(inst);
   wire [ 5:0] port0_i6  = `GET_I6(inst);
   wire [11:0] port0_i12 = `GET_I12(inst);
   wire [13:0] port0_i14 = `GET_I14(inst);
   wire [15:0] port0_i16 = `GET_I16(inst);
   wire [19:0] port0_i20 = `GET_I20(inst);
   
   wire [31:0] port0_i5_u  = {27'b0,port0_i5};
   wire [31:0] port0_i6_u  = {26'b0,port0_i6};
   wire [31:0] port0_i12_u = {20'b0,port0_i12};
   wire [31:0] port0_i12_s = {{20{port0_i12[11]}},port0_i12};
   wire [31:0] port0_i14_s = {{18{port0_i14[13]}},port0_i14};
   wire [31:0] port0_i16_s = {{16{port0_i16[15]}},port0_i16};
   wire [31:0] port0_i20_s = {{12{port0_i20[19]}},port0_i20};

   wire [31:0] port0_i5_i = op[`LDOUBLE_WORD] ? port0_i6_u : port0_i5_u;
   wire [31:0] port0_i12_i = op[`LUNSIGN] ? port0_i12_u : port0_i12_s;

   wire [31:0] port0_imm = op[`LI5 ] ? port0_i5_i  :
	       op[`LI12] ? port0_i12_i :
	       op[`LI14] ? port0_i14_s :
	       op[`LI16] ? port0_i16_s :
	       op[`LI20] ? port0_i20_s :
	       32'b0;

   assign imm_shifted = op[`LIMM_SHIFT] == `LIMM_SHIFT_2  ? {port0_imm[29:0], 2'b0} :
				  op[`LIMM_SHIFT] == `LIMM_SHIFT_12 ? {port0_imm[19:0],12'b0} :
				  op[`LIMM_SHIFT] == `LIMM_SHIFT_16 ? {port0_imm[15:0],16'b0} :
				  op[`LIMM_SHIFT] == `LIMM_SHIFT_18 ? {port0_imm[13:0],18'b0} :
				  port0_imm; 


   assign alu_c = (op[`LALU_CODE] == `LALU_COUNT_L || op[`LALU_CODE] == `LALU_COUNT_T) ? {31'd0,!op[`LUNSIGN]} :
			(op[`LSA] || op[`LALU_CODE] == `LALU_ALIGN) ? {29'd0,`GET_SA(inst)} :
			(op[`LALU_CODE] == `LALU_EXT || op[`LALU_CODE] == `LALU_INS) ? {20'd0,`GET_MSLSBD(inst)} :
			(op[`LALU_CODE] == `LALU_ROT) ? port0_imm :
			port0_imm;


   wire [15:0] port0_offset16 = `GET_OFFSET16(inst);
   wire [20:0] port0_offset21 = `GET_OFFSET21(inst);
   wire [25:0] port0_offset26 = `GET_OFFSET26(inst);
   
   wire [31:0] port0_offset = op[`LRD_READ    ] ? {{14{port0_offset16[15]}},port0_offset16,2'b0} :
	                      op[`LHIGH_TARGET] ? {{ 4{port0_offset26[25]}},port0_offset26,2'b0} :
	                                                          {{ 9{port0_offset21[20]}},port0_offset21,2'b0} ;

   assign br_offs = port0_offset;
   
endmodule // cpu7_ifu_imd
