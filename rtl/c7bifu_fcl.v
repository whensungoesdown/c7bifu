module c7bifu_fcl (
   input              clk,
   input              resetn,
   output             fcl_req,
   input              ack,
   input              data_vld,
   input              exu_ifu_except,
   input              exu_ifu_branch,
   input              exu_ifu_ertn,
   input              exu_ifu_stall,
   input              csr_ifu_ic_en_pls,

   output             pf_addr_sel_init,
   output             pf_addr_sel_old,
   output             pf_addr_sel_inc,
   output             pf_addr_sel_brn,
   output             pf_addr_sel_isr,
   output             pf_addr_sel_ert,

   output             pf_addr_en,
   output             fcl_data_vld,

   output             stall,
   output             flush,
   output             flush_dly1,
   input              iq_full,

   output             wait_bus_clr
);

   // Pipeline, pf (pre-fetch) and f (fetch)
   // Create stall in pf when waiting for memory ack (icu_ack)
   // Create stall in f when waiting for data valid

   wire addr_stall;
   wire data_stall;

   wire stall_pf;
   wire stall_f;

   wire req;
   wire req_in;
   wire req_q;

   wire d_stall_in;
   wire d_stall_q;

   wire except;
   wire branch;
   wire ertn;

   wire data_cancel_in;
   wire data_cancel_q;
   wire data_cancel_en;



   // Synchronizes resetn to clock domain, active for one cycle after resetn
   // deassertion This ensures clean reset state transitions and prevents
   // metastability
   //Timing:           ___     ___     ___     ___     ___
   // clk        _____/   \___/   \___/   \___/   \___/
   // resetn     _______________/
   // resetn_sync_q       ____________/
   //                         | 1cycle|
   wire resetn_sync_q;


   wire wait_bus_clr_bgn;
   wire wait_bus_clr_end;
   wire wait_bus_clr_in;
   wire wait_bus_clr_q;

   assign wait_bus_clr_bgn = csr_ifu_ic_en_pls;
   assign wait_bus_clr_end = ~data_stall;

   assign wait_bus_clr_in = (~wait_bus_clr_end) & (wait_bus_clr_bgn | wait_bus_clr_q); 
   assign wait_bus_clr = wait_bus_clr_in;


   assign flush = except | branch | ertn;

   assign addr_stall = req_q; 


   assign stall_pf = addr_stall | stall_f | iq_full;
   assign stall_f = data_stall & ~flush;


   // req                             : --_____
   // ack                             : _____-_
   //
   // req_in                          : _----__
   // req_q                           : __----_

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
                                //& ~d_stall_in
   //assign req = (( ~req_q & ~d_stall_q) | flush)
   assign req = (( ~req_q & ~d_stall_in) | flush) // uty: test
		    & ~iq_full
		    & ~wait_bus_clr_in
		    ; //& resetn_sync_q;

   assign req_in = (~ack) & (req | req_q);

   dffrl_ns #(1) req_reg (
      .din (req_in),
      .clk (clk),
      .rst_l (resetn),
      .q   (req_q));

   // When iq_full, fcl_req needs to cancel immediately
   // if wait through the registers, then it will be late.
   // Therefore, cancel fcl_req now.
   //assign fcl_req = req_q;
   assign fcl_req = req_q & ~iq_full & ~wait_bus_clr_in;


   // ack                                 : _-_____
   // data_vld                            : _____-_
   //
   // d_stall_in                          : _----__
   // d_stall_q                           : __----_

   assign d_stall_in = (d_stall_q & ~data_vld) | ack;

   dffrl_ns #(1) d_stall_reg (
      .din (d_stall_in),
      .clk (clk),
      .rst_l (resetn),
      .q   (d_stall_q));

   assign data_stall = d_stall_q;


   //
   // pf_addr
   //
   wire stall_pf_minus_data_vld = stall_pf & ~fcl_data_vld;

   assign except = exu_ifu_except;
   assign branch = exu_ifu_branch;
   assign ertn = exu_ifu_ertn;

   // addrs do not need a flush
   assign pf_addr_sel_init = ~resetn_sync_q;
   //assign pf_addr_sel_old = stall_pf & ~pf_addr_sel_init & ~pf_addr_sel_brn & ~pf_addr_sel_isr & ~pf_addr_sel_ert;
   //assign pf_addr_sel_old = stall_pf_minus_data_vld & ~pf_addr_sel_init & ~pf_addr_sel_brn & ~pf_addr_sel_isr & ~pf_addr_sel_ert;
   //                       stall_pf here seems to be useless, review
   //                          |
   assign pf_addr_sel_old = stall_pf & ~pf_addr_sel_init & ~pf_addr_sel_brn & ~pf_addr_sel_isr & ~pf_addr_sel_ert & ~pf_addr_sel_inc;
   //assign pf_addr_sel_inc = ~stall_pf & ~flush & ~pf_addr_sel_init;
   //assign pf_addr_sel_inc = ~stall_pf_minus_data_vld & ~flush & ~pf_addr_sel_init;
   assign pf_addr_sel_inc = ~stall_pf_minus_data_vld & ~flush & ~flush_dly1 & ~pf_addr_sel_init;

   // addrs need flush
   assign pf_addr_sel_brn = branch;
   assign pf_addr_sel_isr = except;
   assign pf_addr_sel_ert = ertn;

   //assign pf_addr_en = ~stall_pf | flush;
   //wire data_vld = stall_pf ? fcl_data_vld : 1'b0;
   //assign pf_addr_en = ~stall_pf | fcl_data_vld | flush;
   assign pf_addr_en = pf_addr_sel_init | fcl_data_vld | flush;


   //
   // data_cancel
   //
   // When an exception occurs during a data stall (data_stall == 1), set
   // data_cancel_q to 1.
   // This flag will cancel the next arriving data_vld signal,
   // preventing invalid instruction data from being processed.
   //
   // Note: data_vld clears data_cancel_q when it arrives.
   // If except and data_vld occur in the same cycle,
   // data_cancel_q will NOT be set.
   //assign data_cancel_in = (data_stall & except) & ~data_vld;
   //assign data_cancel_in = (data_stall & flush) & ~data_vld;
   // another situation is that right at the flush cycle, fcl_req
   // & ack both 1, it is the very begining of a icu data fetch,
   // (data_stall not started yet, or the next cycle, icache hit,
   // data_vld asserted)
   assign data_cancel_in = ((data_stall | ack) & flush) & ~data_vld;
   assign data_cancel_en = flush | data_vld;

   assign fcl_data_vld = data_vld & ~data_cancel_q;

   assign stall = exu_ifu_stall;


   //
   // Registers
   //

   dffrl_ns #(1) reset_sync_reg (
      .din (1'b1),
      .clk (clk),
      .rst_l (resetn),
      .q   (resetn_sync_q));

   dffrl_ns #(1) wait_bus_clr_reg (
      .din (wait_bus_clr_in),
      .clk (clk),
      .rst_l (resetn),
      .q   (wait_bus_clr_q));

   dffrle_ns #(1) data_cancel_reg (
      .din (data_cancel_in),
      .clk (clk),
      .rst_l (resetn),
      .en (data_cancel_en),
      .q   (data_cancel_q));

   dff_ns #(1) flush_dly1_reg (
      .din (flush),
      .clk (clk),
      .q   (flush_dly1));

endmodule
