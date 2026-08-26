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
   input              icu_ifu_fault_ic2,
   input  [1:0]       icu_ifu_fault_code_ic2,

   // biu interface
   output [31:0]      ifu_biu_rd_addr,
   output             ifu_biu_rd_req,
   input              biu_ifu_rd_ack,
   input              biu_ifu_data_valid,
   input  [63:0]      biu_ifu_data,
   input              biu_ifu_fault,
   input  [1:0]       biu_ifu_fault_code,

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
   output             ifu_exu_lsu_ibar_d,
   output             ifu_exu_lsu_dbar_d,
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
   output             ifu_exu_csr_rdtimel_d,
   output             ifu_exu_csr_rdtimeh_d,

   // ertn
   output             ifu_exu_ertn_vld_d,

   // tlb
   output             ifu_exu_tlb_vld_d,
   output [3:0]       ifu_exu_tlb_op_d, 

   // exc
   output             ifu_exu_exc_vld_d,
   output [5:0]       ifu_exu_exc_code_d,
   output [8:0]       ifu_exu_exc_subcode_d,
   output [31:0]      ifu_exu_exc_badv_d,

   input              csr_ifu_crmd_da, 
   input              csr_ifu_crmd_pg,

   input  [2:0]       csr_ifu_dmw0_pseg,
   input  [2:0]       csr_ifu_dmw0_vseg,

   input  [2:0]       csr_ifu_dmw1_pseg,
   input  [2:0]       csr_ifu_dmw1_vseg,

   input  [18:0]      csr_itlb_tlbehi_vppn,

   input              csr_itlb_tlbidx_ne,
   input  [5:0]       csr_itlb_tlbidx_ps,
   input              csr_itlb_tlbidx_i_d,
   input  [4:0]       csr_itlb_tlbidx_index,

   input  [19:0]      csr_itlb_tlbelo0_ppn,
   input              csr_itlb_tlbelo0_g,
   input  [1:0]       csr_itlb_tlbelo0_mat,
   input  [1:0]       csr_itlb_tlbelo0_plv,
   input              csr_itlb_tlbelo0_d,
   input              csr_itlb_tlbelo0_v,

   input  [19:0]      csr_itlb_tlbelo1_ppn,
   input              csr_itlb_tlbelo1_g,
   input  [1:0]       csr_itlb_tlbelo1_mat,
   input  [1:0]       csr_itlb_tlbelo1_plv,
   input              csr_itlb_tlbelo1_d,
   input              csr_itlb_tlbelo1_v,

   input  [9:0]       csr_itlb_asid_asid,

   input              csr_itlb_tlbrefill_ctx, 

   input  [1:0]       csr_itlb_crmd_plv,

   input  [4:0]       exu_itlb_random_index,

   input              exu_itlb_tlbfill_vld_e,
   input              exu_itlb_tlbwr_vld_e,
   input              exu_itlb_tlbsrch_vld_e,
   input              exu_itlb_invtlb_vld_e,

   input  [4:0]       exu_itlb_invtlb_op_e,
   input  [9:0]       exu_itlb_invtlb_asid_e,
   input  [18:0]      exu_itlb_invtlb_vppn_e,

   // itlb to csr
   output [4:0]       itlb_csr_tlbidx_index,
   output [18:0]      itlb_csr_tlbehi_vppn,
   output             itlb_csr_tlbelo_g,
   output [5:0]       itlb_csr_tlbidx_ps,
   output             itlb_csr_tlbidx_e,
   output             itlb_csr_tlbelo0_v,
   output             itlb_csr_tlbelo0_d,
   output [1:0]       itlb_csr_tlbelo0_mat,
   output [1:0]       itlb_csr_tlbelo0_plv,
   output [19:0]      itlb_csr_tlbelo0_ppn,
   output             itlb_csr_tlbelo1_v,
   output             itlb_csr_tlbelo1_d,
   output [1:0]       itlb_csr_tlbelo1_mat,
   output [1:0]       itlb_csr_tlbelo1_plv,
   output [19:0]      itlb_csr_tlbelo1_ppn,
   output [9:0]       itlb_csr_asid_asid
);

   wire [63:0] data;
   wire data_vld;
   wire ack;

   wire [31:0] pf_vaddr_in;
   wire [31:0] pf_vaddr_q;
   wire [31:0] pf_vaddr_inc;

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

   wire fet_exc_vld;

   wire dec_exc_vld_d;
   wire [5:0] dec_exc_code_d;
   
   wire dec_vld_d;


   wire da_mode = csr_ifu_crmd_da;
   wire pg_mode = ~csr_ifu_crmd_da & csr_ifu_crmd_pg;

   wire match_dmw0; 
   wire match_dmw1; 

   wire tlbr_exception;
   wire pif_exception;
   wire ppi_exception;

   // ---------- TLB search port signals ----------
   wire        tlb_s_vld;
   wire [18:0] tlb_s_vppn;     // VPN2 (19 bits)
   wire        tlb_s_odd_page;
   wire [ 9:0] tlb_s_asid;
   wire        tlb_s_found;
   wire [ 4:0] tlb_s_index;
   wire [19:0] tlb_s_pfn;      // Physical page number
   wire        tlb_s_d;
   wire        tlb_s_v;
   wire [ 1:0] tlb_s_mat;
   wire [ 1:0] tlb_s_plv;

   wire tlb_res_vld;

   // The stall_dec signal is asserted when exu_ifu_stall is active.
   // Due to a one-cycle read delay in the instruction queue (IQ), the decode
   // stage must predict whether the currently decoded instructions will cause
   // a stall once they reach the execution (_e) stage.
   // To prevent instructions from being lost (dropped), stall_iq is
   // preemptively asserted one cycle earlier upon decoding CSR, LSU and DIV
   // instructions.
   // Additional instruction types may be added to this preemptive stall logic
   // in the future.
   assign stall_dec = stall;
   //assign stall_iq = stall | ifu_exu_csr_vld_d | ifu_exu_lsu_vld_d | ifu_exu_div_vld_d; 
   assign stall_iq = stall | ifu_exu_csr_vld_d | ifu_exu_lsu_vld_d | ifu_exu_div_vld_d | ifu_exu_tlb_vld_d; 

   // ifu_fcl makes sure that fcl_req is always comes once cycle after tlb_req
   //wire tlb_req;
   wire fcl_req;
   //assign ifu_icu_req_ic1 = fcl_req & ic_en;
   //assign ifu_biu_rd_req = fcl_req & ~ic_en;
   //assign ifu_icu_req_ic1 = fcl_req & ic_en & (da_mode | (tlb_s_found & tlb_s_v));
   //assign ifu_biu_rd_req = fcl_req & ~ic_en & (da_mode | (tlb_s_found & tlb_s_v));
   assign ifu_icu_req_ic1 = fcl_req & ic_en & (da_mode | match_dmw0 | match_dmw1 | (tlb_s_found & tlb_s_v));
   assign ifu_biu_rd_req  = fcl_req & ~ic_en & (da_mode | match_dmw0 | match_dmw1 | (tlb_s_found & tlb_s_v));

   //assign tlbr_exception = fcl_req & pg_mode & ~tlb_s_found; // uty: test
   assign tlbr_exception = tlb_res_vld & ~tlb_s_found; // uty: test

   assign pif_exception = tlb_res_vld & tlb_s_found & ~tlb_s_v; 
   assign ppi_exception = tlb_res_vld & tlb_s_found & tlb_s_v & (csr_itlb_crmd_plv > tlb_s_plv);

   //assign ack = ic_en ? icu_ifu_ack_ic1 : biu_ifu_rd_ack;
   assign ack = icu_ifu_ack_ic1 | biu_ifu_rd_ack;
   assign data = ic_en ? icu_ifu_data_ic2 : biu_ifu_data;

   assign data_vld = ic_en ? (icu_ifu_data_valid_ic2 | icu_ifu_fault_ic2) : (biu_ifu_data_valid | biu_ifu_fault);
   //assign data_vld = ic_en ? icu_ifu_data_valid_ic2 : biu_ifu_data_valid;

   //
   // if fetch causing exception, hold the fetch until exu_ifu_except brings
   // the exu_ifu_isr_addr
   // --- This does not work, becuase the exception needs to be carried by one
   // instruction to the exu. If data_vld not valid, the whole fetch mechanism
   // may stuck
   //assign data_vld = (ic_en ? icu_ifu_data_valid_ic2 : biu_ifu_data_valid) | exu_ifu_except;

   c7bifu_fcl u_fcl (
      .clk                             (clk),
      .resetn                          (resetn),
      //.tlb_req                         (tlb_req), //
      .fcl_req                         (fcl_req),
      .ack                             (ack),
      .data_vld                        (data_vld),
      .exu_ifu_except                  (exu_ifu_except),
      .exu_ifu_branch                  (exu_ifu_branch),
      .exu_ifu_ertn                    (exu_ifu_ertn),
      .exu_ifu_stall                   (exu_ifu_stall),
      .csr_ifu_ic_en_pls               (csr_ifu_ic_en_pls),

      //.fetch_except_hold               (biu_ifu_fault | icu_ifu_fault_ic2),
      .fetch_except_hold               (biu_ifu_fault | icu_ifu_fault_ic2 | tlbr_exception | pif_exception | ppi_exception),

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

   assign pf_vaddr_inc = pf_vaddr_q + 4'h8;

   assign pf_vaddr_in = {32{pf_addr_sel_init}} & 32'h1c000000     |
                        {32{pf_addr_sel_old}}  & pf_vaddr_q       |
                        {32{pf_addr_sel_inc}}  & pf_vaddr_inc     |      
                        {32{pf_addr_sel_brn}}  & exu_ifu_brn_addr |
                        {32{pf_addr_sel_isr}}  & exu_ifu_isr_addr |
                        {32{pf_addr_sel_ert}}  & exu_ifu_ert_addr;		      
   
   //wire [31:0] iq_start_addr = ic_en ? ifu_icu_addr_ic1 : ifu_biu_rd_addr;
   wire [31:0] iq_start_addr = pf_vaddr_q;
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
      .flush                           (flush | flush_dly1), // because ifu_icu_addr_ic1 takes pf_vaddr_q install of pf_vaddr_in, there is 1 cycle delay, therefore the iq also needs to wait 1 cycel for the correct updated ifu_icu_addr_ic1
      .iq_full                         (iq_full),
      .inst_addr                       (inst_addr_f),
      .inst                            (inst_f),
      .inst_vld                        (inst_vld_f)
   );


   wire [31:0] pf2_phyaddr; 
   // uty: test
   //assign ifu_icu_addr_ic1 = pf_vaddr_q & {32{ic_en}};
   //assign ifu_biu_rd_addr = pf_vaddr_q & {32{~ic_en}};
   assign ifu_icu_addr_ic1 = pf2_phyaddr & {32{ic_en}};
   assign ifu_biu_rd_addr = pf2_phyaddr & {32{~ic_en}};


   // ---------- Drive TLB search inputs ----------
   //assign tlb_s_vld = tlb_req & pg_mode;
   //assign tlb_s_vld = fcl_req & pg_mode;
   // TLB lookup valid only in paging mode and not hit by DMW0 or DMW1
   assign tlb_s_vld = fcl_req & pg_mode & ~(match_dmw0 | match_dmw1);
   // Extract VPN2 (bits 31:13) and odd_page (bit 12) from virtual address
   assign tlb_s_vppn = pf_vaddr_q[31:13];
   assign tlb_s_odd_page = pf_vaddr_q[12];
   // ASID from CSR (assume csr_asid is 10-bit)
   //assign s_asid_tlb    = csr_asid;
   assign tlb_s_asid = csr_itlb_asid_asid;


   // Physical address generation
   // - Direct address mode (DA=1, PG=0): clear high 3 bits
   // - Mapped address mode (DA=0, PG=1):
   //   - If DMW0 hit, use DMW0 direct mapping
   //   - Otherwise use TLB translation result
   assign match_dmw0 = (pf_vaddr_q[31:29] == csr_ifu_dmw0_vseg);
   assign match_dmw1 = (pf_vaddr_q[31:29] == csr_ifu_dmw1_vseg);

   // ---------- Generate physical address ----------
   // Physical address = PFN (20 bits) concatenated with page offset (12 bits)
   // This is valid only when tlb_s_found is 1; otherwise the value is meaningless.
   //assign pf2_phyaddr = da_mode ? pf_vaddr_q : {tlb_s_pfn, pf_vaddr_q[11:0]};
   //assign pf2_phyaddr = da_mode ? (pf_vaddr_q & 32'h1FFFFFFF)  // clear high 3-bit
   //                         : {tlb_s_pfn, pf_vaddr_q[11:0]};
   // Physical address with DMW0 priority over DMW1
   assign pf2_phyaddr = da_mode ? (pf_vaddr_q & 32'h1FFFFFFF)  // not affect 0x1c000000
                                : (match_dmw0 ? {csr_ifu_dmw0_pseg, pf_vaddr_q[28:0]}
                                : (match_dmw1 ? {csr_ifu_dmw1_pseg, pf_vaddr_q[28:0]}
                                              : {tlb_s_pfn, pf_vaddr_q[11:0]}));


   // csr_itlb_tlbidx_i_d    itlb 0, dtlb 1
   wire itlb_we;
   assign itlb_we = (exu_itlb_tlbfill_vld_e | exu_itlb_tlbwr_vld_e) & ~csr_itlb_tlbidx_i_d;

   wire [4:0] itlb_w_index;
   assign itlb_w_index = exu_itlb_tlbfill_vld_e ? exu_itlb_random_index :
                        (exu_itlb_tlbwr_vld_e   ? csr_itlb_tlbidx_index : 5'b0); 

   assign itlb_csr_tlbidx_index = tlb_s_index;


   wire tlbsrch_vld_m;
   wire tlbidx_e;

   assign itlb_csr_tlbidx_e = tlbsrch_vld_m ? tlb_s_found : tlbidx_e;

   wire itlb_inv_en;
   assign itlb_inv_en = exu_itlb_invtlb_vld_e & ~csr_itlb_tlbidx_i_d; 
   //assign itlb_inv_en = exu_itlb_invtlb_vld_e; 


   c7btlb u_itlb(
      .clk                             (clk),
      .resetn                          (resetn),

      // search port
      // exu_itlb_tlbsrch_vld_e has higher priority than tlb_s_vld
      // uty: test todo, make tlb instructions stall IFU
      .s_vld                           (tlb_s_vld | exu_itlb_tlbsrch_vld_e),
      //.s_vppn                          (({19{tlb_s_vld} & tlb_s_vppn}) | ({19{exu_itlb_tlbsrch_vld_e} & csr_itlb_tlbehi_vppn})),
      .s_vppn                          (exu_itlb_tlbsrch_vld_e ? csr_itlb_tlbehi_vppn : tlb_s_vppn),
      .s_odd_page                      (tlb_s_odd_page),
      //.s_asid                          (({10{tlb_s_vld} & tlb_s_asid}) | ({10{exu_itlb_tlbsrch_vld_e} & csr_itlb_asid_asid})),
      //.s_asid                          (exu_itlb_tlbsrch_vld_e ? csr_itlb_asid_asid : tlb_s_asid),
      .s_asid                          (tlb_s_asid),
      .s_found                         (tlb_s_found),
      .s_index                         (tlb_s_index),
      .s_pfn                           (tlb_s_pfn),
      .s_d                             (tlb_s_d),
      .s_v                             (tlb_s_v),
      .s_mat                           (tlb_s_mat),
      .s_plv                           (tlb_s_plv),

      // write port
      .we                              (itlb_we),
      .w_index                         (itlb_w_index),
      .w_vppn                          (csr_itlb_tlbehi_vppn),
      .w_asid                          (csr_itlb_asid_asid),
      .w_g                             (csr_itlb_tlbelo0_g & csr_itlb_tlbelo1_g),
      .w_ps                            (csr_itlb_tlbidx_ps),
      .w_e                             (csr_itlb_tlbrefill_ctx ? 1'b1 : ~csr_itlb_tlbidx_ne),
      .w_v0                            (csr_itlb_tlbelo0_v), 
      .w_d0                            (csr_itlb_tlbelo0_d),
      .w_mat0                          (csr_itlb_tlbelo0_mat),
      .w_plv0                          (csr_itlb_tlbelo0_plv),
      .w_ppn0                          (csr_itlb_tlbelo0_ppn),
      .w_v1                            (csr_itlb_tlbelo1_v),
      .w_d1                            (csr_itlb_tlbelo1_d),
      .w_mat1                          (csr_itlb_tlbelo1_mat),
      .w_plv1                          (csr_itlb_tlbelo1_plv),
      .w_ppn1                          (csr_itlb_tlbelo1_ppn),

      // read port
      .r_index                         (csr_itlb_tlbidx_index),
      .r_vppn                          (itlb_csr_tlbehi_vppn),
      .r_asid                          (itlb_csr_asid_asid),
      .r_g                             (itlb_csr_tlbelo_g),
      .r_ps                            (itlb_csr_tlbidx_ps),
      //.r_e                             (itlb_csr_tlbidx_e),
      .r_e                             (tlbidx_e),
      .r_v0                            (itlb_csr_tlbelo0_v),
      .r_d0                            (itlb_csr_tlbelo0_d),
      .r_mat0                          (itlb_csr_tlbelo0_mat),
      .r_plv0                          (itlb_csr_tlbelo0_plv),
      .r_ppn0                          (itlb_csr_tlbelo0_ppn),
      .r_v1                            (itlb_csr_tlbelo1_v),
      .r_d1                            (itlb_csr_tlbelo1_d),
      .r_mat1                          (itlb_csr_tlbelo1_mat),
      .r_plv1                          (itlb_csr_tlbelo1_plv),
      .r_ppn1                          (itlb_csr_tlbelo1_ppn),

      // invalid port
      .inv_en                          (itlb_inv_en),
      .inv_op                          (exu_itlb_invtlb_op_e),
      .inv_asid                        (exu_itlb_invtlb_asid_e),
      .inv_vppn                        (exu_itlb_invtlb_vppn_e)
   );


   c7bifu_dec u_dec (
      .clk                             (clk),
      .resetn                          (resetn),
      
      .stall                           (stall_dec),
      .flush                           (flush),

      .inst_vld_f                      (inst_vld_f),
      .inst_addr_f                     (inst_addr_f),
      .inst_f                          (inst_f),

      //.ifu_exu_vld_d                   (ifu_exu_vld_d),
      .ifu_exu_vld_d                   (dec_vld_d),
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
      .ifu_exu_lsu_ibar_d              (ifu_exu_lsu_ibar_d),
      .ifu_exu_lsu_dbar_d              (ifu_exu_lsu_dbar_d),
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
      .ifu_exu_div_vld_d               (ifu_exu_div_vld_d),
      .ifu_exu_div_signed_d            (ifu_exu_div_signed_d),
      .ifu_exu_div_mod_d               (ifu_exu_div_mod_d),

      // csr
      .ifu_exu_csr_vld_d               (ifu_exu_csr_vld_d),
      .ifu_exu_csr_raddr_d             (ifu_exu_csr_raddr_d),
      .ifu_exu_csr_xchg_d              (ifu_exu_csr_xchg_d),
      .ifu_exu_csr_wen_d               (ifu_exu_csr_wen_d),
      .ifu_exu_csr_waddr_d             (ifu_exu_csr_waddr_d),
      .ifu_exu_csr_rdtimel_d           (ifu_exu_csr_rdtimel_d),
      .ifu_exu_csr_rdtimeh_d           (ifu_exu_csr_rdtimeh_d),

      // ertn
      .ifu_exu_ertn_vld_d              (ifu_exu_ertn_vld_d),

      // tlb
      .ifu_exu_tlb_vld_d               (ifu_exu_tlb_vld_d),
      .ifu_exu_tlb_op_d                (ifu_exu_tlb_op_d),

      // exc
      .dec_exc_vld_d                   (dec_exc_vld_d),
      .dec_exc_code_d                  (dec_exc_code_d)
   );

   assign fet_exc_vld = biu_ifu_fault | icu_ifu_fault_ic2;
   // biu_ifu_fault_code is not used for now

   // When ifu_exu_exc_vld_d is asserted, EXU must cancel execution of any
   // simultaneously valid instruction.
   //assign ifu_exu_exc_vld_d = dec_exc_vld_d; // | other front exceptions
   //assign ifu_exu_exc_code_d = dec_exc_code_d;

   //assign ifu_exu_exc_vld_d = dec_exc_vld_d | fet_exc_vld;
   //assign ifu_exu_exc_code_d = fet_exc_vld ? `EXC_ADEF: dec_exc_code_d;
   //assign ifu_exu_exc_vld_d = dec_exc_vld_d | fet_exc_vld | tlbr_exception;
   //assign ifu_exu_exc_code_d = tlbr_exception ? `EXC_TLBR :
   //                         (fet_exc_vld ? `EXC_ADEF : dec_exc_code_d);
   //assign ifu_exu_exc_badv_d = ic_en ? ifu_icu_addr_ic1 : ifu_biu_rd_addr;

   assign ifu_exu_exc_vld_d = dec_exc_vld_d | fet_exc_vld | tlbr_exception | pif_exception | ppi_exception;
   
   // priority: dec > fet > tlbr > pif
   assign ifu_exu_exc_code_d = dec_exc_vld_d ? dec_exc_code_d  :
                               fet_exc_vld    ? `EXC_ADEF      :
                               tlbr_exception ? `EXC_TLBR      :
                               pif_exception  ? `EXC_PIF       :
                               ppi_exception  ? `EXC_PPI       :
                                                6'b0;

   // tlbr_exception subcode: itlb 0, dtlb 1
   assign ifu_exu_exc_subcode_d = 8'b0;

   // badv : bad virtual address 
   assign ifu_exu_exc_badv_d = (tlbr_exception | pif_exception | ppi_exception | fet_exc_vld) ?
                               //pf_vaddr_q :
			       pf2_phyaddr:
                               ifu_exu_pc_d;

   // this instruction carries the ADEF exception, so, we have to valid it
   // even though this may not be a valid instruction.
   assign ifu_exu_vld_d = dec_vld_d | ifu_exu_exc_vld_d;


   //
   // Registers
   //

   dffe_ns #(32) pf_addr_reg (
      .din (pf_vaddr_in),
      .en  (pf_addr_en),
      .clk (clk),
      .q   (pf_vaddr_q));

   // uty: test
   // test icache
   //assign ic_en = 1'b1;

   dffrle_ns #(1) ic_en_reg (
      .din (csr_ifu_ic_en),
      .en  (ic_en_en),
      .clk (clk),
      .rst_l (resetn),
      .q   (ic_en));


   dffrl_ns #(1) tlb_res_vld_reg (
      .din (tlb_s_vld),
      .clk (clk),
      .rst_l (resetn),
      .q   (tlb_res_vld));


   // TLB search takes 1 cycle
   dffrl_ns #(1) tlbsrch_vld_m_reg (
      .din   (exu_itlb_tlbsrch_vld_e),
      .rst_l (resetn),
      .clk   (clk),
      .q     (tlbsrch_vld_m));

endmodule
