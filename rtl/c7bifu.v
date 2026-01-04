module c7bifu (
   input              clk,
   input              resetn,

   output [31:0]      ifu_icu_addr_ic1,
   output             ifu_icu_req_ic1,
   input              icu_ifu_ack_ic1,
   input              icu_ifu_data_valid_ic2,
   input              exu_ifu_except,
   input  [31:0]      exu_ifu_isr_addr,
   input              exu_ifu_branch,
   input  [31:0]      exu_ifu_brn_addr,
   input              exu_ifu_ertn,
   input  [31:0]      exu_ifu_ert_addr
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

   
   c7bifu_fcl u_fcl (
      .clk                             (clk),
      .resetn                          (resetn),
      .ifu_icu_req_ic1                 (ifu_icu_req_ic1),
      .icu_ifu_ack_ic1                 (icu_ifu_ack_ic1),
      .icu_ifu_data_valid_ic2          (icu_ifu_data_valid_ic2),
      .exu_ifu_except                  (exu_ifu_except),
      .exu_ifu_branch                  (exu_ifu_branch),
      .exu_ifu_ertn                    (exu_ifu_ertn),
      .pf_addr_sel_init                (pf_addr_sel_init),
      .pf_addr_sel_old                 (pf_addr_sel_old),
      .pf_addr_sel_inc                 (pf_addr_sel_inc),
      .pf_addr_sel_brn                 (pf_addr_sel_brn),
      .pf_addr_sel_isr                 (pf_addr_sel_isr),
      .pf_addr_sel_ert                 (pf_addr_sel_ert),
      .pf_addr_en                      (pf_addr_en),
      .icu_data_vld                    (icu_data_vld)
   );

   assign pf_addr_inc = pf_addr_q + 4'h8;

   assign pf_addr_in = {32{pf_addr_sel_init}} & 32'h1c000000     |
                       {32{pf_addr_sel_old}}  & pf_addr_q        |
                       {32{pf_addr_sel_inc}}  & pf_addr_inc      |      
                       {32{pf_addr_sel_brn}}  & exu_ifu_brn_addr |
                       {32{pf_addr_sel_isr}}  & exu_ifu_isr_addr |
                       {32{pf_addr_sel_ert}}  & exu_ifu_ert_addr;		      
   assign ifu_icu_addr_ic1 = pf_addr_in;


   //
   // Registers
   //

   dffe_ns #(32) pf_addr_reg (
      .din (pf_addr_in),
      .en  (pf_addr_en),
      .clk (clk),
      .q   (pf_addr_q));

endmodule
