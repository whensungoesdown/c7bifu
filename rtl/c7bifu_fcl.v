module c7bifu_fcl (
   input              clk,
   input              resetn,
   output             ifu_icu_req_ic1,
   input              icu_ifu_ack_ic1,
   input              icu_ifu_data_valid_ic2,
   input              exu_ifu_except,
   input              exu_ifu_branch,
   input              exu_ifu_ertn,

   output             pf_addr_sel_init,
   output             pf_addr_sel_old,
   output             pf_addr_sel_inc,
   output             pf_addr_sel_brn,
   output             pf_addr_sel_isr,
   output             pf_addr_sel_ert,

   output             pf_addr_en
);

   // Pipeline, pf (pre-fetch) and f (fetch)
   // Create stall in pf when waiting for memory ack (icu_ack)
   // Create stall in f when waiting for data valid

   wire addr_stall;
   wire data_stall;

   wire stall_pf;
   wire stall_f;

   wire flush;

   wire icu_req;
   wire icu_req_in;
   wire icu_req_q;

   wire d_stall_in;
   wire d_stall_q;

   wire except;
   wire branch;
   wire ertn;


   // Synchronizes resetn to clock domain, active for one cycle after resetn
   // deassertion This ensures clean reset state transitions and prevents
   // metastability
   //Timing:           ___     ___     ___     ___     ___
   // clk        _____/   \___/   \___/   \___/   \___/
   // resetn     _______________/
   // resetn_sync_q       ____________/
   //                         | 1cycle|
   wire resetn_sync_q;


   assign flush = except | branch | ertn;
   //assign flush = 1'b0;

   assign addr_stall = icu_req_q; 


   assign stall_pf = addr_stall | stall_f;
   assign stall_f = data_stall & ~flush;


   // icu_req                             : --_____
   // icu_ifu_ack_ic1                     : _____-_
   //
   // icu_req_in                          : _----__
   // icu_req_q                           : __----_

   // Problem with using d_stall_in:
   // - addr_stall and data_stall would become sequential (back-to-back)
   // - This creates continuous stall_pf (always 1)
   // - Result: No time window for pf_addr_reg updates
   //
   // Solution: Use registered d_stall_q instead
   // - Creates gaps between stalls for address updates
   //
   // # clk    : ^^^^^^^^^^
   // # resetn : ----------
   // # req    : --___--___
   // # ack    : _-____-___
   // # valid  : ___-____-_


   // Note: resetn_sync_q omitted to prevent premature address increment
   //
   // Fix: Keep stall_pf asserted during entire reset period
   //      Ensures 0x1C000000 is properly registered before any increment

   assign icu_req = ~icu_req_q
		  //& ~d_stall_in
		  & ~d_stall_q
		  ; //& resetn_sync_q;

   assign icu_req_in = (icu_req_q & ~icu_ifu_ack_ic1) | icu_req;

   dffrl_ns #(1) icu_req_reg (
      .din (icu_req_in),
      .clk (clk),
      .rst_l (resetn),
      .q   (icu_req_q));

   assign ifu_icu_req_ic1 = icu_req_q;


   // icu_ifu_ack_ic1                     : _-_____
   // icu_ifu_data_valid_ic2              : _____-_
   //
   // d_stall_in                          : _----__
   // d_stall_q                           : __----_

   assign d_stall_in = (d_stall_q & ~icu_ifu_data_valid_ic2) | icu_ifu_ack_ic1;

   dffrl_ns #(1) d_stall_reg (
      .din (d_stall_in),
      .clk (clk),
      .rst_l (resetn),
      .q   (d_stall_q));

   assign data_stall = d_stall_q;


   //
   // pf_addr
   //

   assign except = exu_ifu_except;
   assign branch = exu_ifu_branch;
   assign ertn = exu_ifu_ertn;

   // addrs do not need a flush
   assign pf_addr_sel_init = ~resetn_sync_q;
   assign pf_addr_sel_old = stall_pf & ~pf_addr_sel_init;
   assign pf_addr_sel_inc = ~stall_pf & ~except & ~branch & ~pf_addr_sel_init;

   // addrs need flush
   assign pf_addr_sel_brn = ~except & branch;
   assign pf_addr_sel_isr = except;
   assign pf_addr_sel_ert = ertn;

   assign pf_addr_en = ~stall_pf;


   //
   // Registers
   //

   dffrl_ns #(1) reset_sync_reg (
      .din (1'b1),
      .clk (clk),
      .rst_l (resetn),
      .q   (resetn_sync_q));

endmodule
