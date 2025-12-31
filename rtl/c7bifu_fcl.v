module c7bifu_fcl (
   input              clk,
   input              resetn,
   output             ifu_icu_req_ic1,
   input              icu_ifu_ack_ic1,
   input              icu_ifu_data_valid_ic2,
   input              exu_ifu_except
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


   assign flush = exu_ifu_except;

   assign addr_stall = icu_req; // & ~icu_ifu_ack;


   assign stall_pf = addr_stall | stall_f;
   assign stall_f = data_stall & ~flush;


   // icu_req                             : --_____
   // icu_ifu_ack_ic1                     : _____-_
   //
   // icu_req_in                          : _----__
   // icu_req_q                           : __----_

   assign icu_req = resetn
                  & ~icu_req_q
		  & ~d_stall_in;

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

endmodule
