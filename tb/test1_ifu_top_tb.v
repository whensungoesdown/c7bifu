`timescale 1ns/1ps

module top_tb();

    // Input signals
    reg clk;
    reg resetn;
    
    // CSR interface - ICache enable
    reg csr_ifu_ic_en;
    reg csr_ifu_ic_en_pls;
    
    // CSR DA/PG and DMW signals
    reg        csr_ifu_crmd_da;
    reg        csr_ifu_crmd_pg;
    reg [2:0]  csr_ifu_dmw0_pseg;
    reg [2:0]  csr_ifu_dmw0_vseg;
    reg [2:0]  csr_ifu_dmw1_pseg;
    reg [2:0]  csr_ifu_dmw1_vseg;
    
    // TLB CSR inputs from EXU
    reg [18:0] csr_itlb_tlbehi_vppn;
    reg        csr_itlb_tlbidx_ne;
    reg [5:0]  csr_itlb_tlbidx_ps;
    reg        csr_itlb_tlbidx_i_d;
    reg [4:0]  csr_itlb_tlbidx_index;
    reg [19:0] csr_itlb_tlbelo0_ppn;
    reg        csr_itlb_tlbelo0_g;
    reg [1:0]  csr_itlb_tlbelo0_mat;
    reg [1:0]  csr_itlb_tlbelo0_plv;
    reg        csr_itlb_tlbelo0_d;
    reg        csr_itlb_tlbelo0_v;
    reg [19:0] csr_itlb_tlbelo1_ppn;
    reg        csr_itlb_tlbelo1_g;
    reg [1:0]  csr_itlb_tlbelo1_mat;
    reg [1:0]  csr_itlb_tlbelo1_plv;
    reg        csr_itlb_tlbelo1_d;
    reg        csr_itlb_tlbelo1_v;
    reg        csr_itlb_tlbrefill_ctx;
    reg [9:0]  csr_itlb_asid_asid;
    reg [4:0]  exu_itlb_random_index;
    reg        exu_itlb_tlbfill_vld_e;
    reg        exu_itlb_tlbwr_vld_e;
    reg        exu_itlb_tlbsrch_vld_e;
    reg        exu_itlb_invtlb_vld_e;
    reg [4:0]  exu_itlb_invtlb_op_e;
    reg [9:0]  exu_itlb_invtlb_asid_e;
    reg [18:0] exu_itlb_invtlb_vppn_e;
    
    // ICU interface
    reg icu_ifu_ack_ic1;
    reg icu_ifu_data_valid_ic2;
    reg icu_ifu_fault_ic2;
    reg [1:0] icu_ifu_fault_code_ic2;
    reg [63:0] icu_ifu_data_ic2;
    
    // BIU interface
    reg biu_ifu_rd_ack;
    reg biu_ifu_data_valid;
    reg [63:0] biu_ifu_data;
    reg biu_ifu_fault;
    reg [1:0] biu_ifu_fault_code;
    
    // EXU interface (inputs)
    reg exu_ifu_except;
    reg [31:0] exu_ifu_isr_addr;
    reg exu_ifu_branch;
    reg [31:0] exu_ifu_brn_addr;
    reg exu_ifu_ertn;
    reg [31:0] exu_ifu_ert_addr;
    reg exu_ifu_stall;
    
    // DUT outputs
    wire [31:0] ifu_icu_addr_ic1;
    wire ifu_icu_req_ic1;
    wire [31:0] ifu_biu_rd_addr;
    wire ifu_biu_rd_req;
    
    // EXU output signals
    wire ifu_exu_vld_d;
    wire [31:0] ifu_exu_pc_d;
    wire [4:0] ifu_exu_rs1_d;
    wire [4:0] ifu_exu_rs2_d;
    wire [4:0] ifu_exu_rd_d;
    wire ifu_exu_wen_d;
    wire [31:0] ifu_exu_imm_shifted_d;
    wire ifu_exu_alu_vld_d;
    wire [5:0] ifu_exu_alu_op_d;
    wire ifu_exu_alu_a_pc_d;
    wire [31:0] ifu_exu_alu_c_d;
    wire ifu_exu_alu_double_word_d;
    wire ifu_exu_alu_b_imm_d;
    wire ifu_exu_lsu_vld_d;
    wire ifu_exu_lsu_ibar_d;
    wire ifu_exu_lsu_dbar_d;
    wire [6:0] ifu_exu_lsu_op_d;
    wire ifu_exu_lsu_double_read_d;
    wire ifu_exu_bru_vld_d;
    wire [3:0] ifu_exu_bru_op_d;
    wire [31:0] ifu_exu_bru_offset_d;
    wire ifu_exu_mul_vld_d;
    wire ifu_exu_mul_signed_d;
    wire ifu_exu_mul_double_d;
    wire ifu_exu_mul_hi_d;
    wire ifu_exu_mul_short_d;
    wire ifu_exu_div_vld_d;
    wire ifu_exu_div_signed_d;
    wire ifu_exu_div_mod_d;
    wire ifu_exu_csr_vld_d;
    wire [13:0] ifu_exu_csr_raddr_d;
    wire ifu_exu_csr_xchg_d;
    wire ifu_exu_csr_wen_d;
    wire [13:0] ifu_exu_csr_waddr_d;
    wire ifu_exu_csr_rdtimel_d;
    wire ifu_exu_csr_rdtimeh_d;
    wire ifu_exu_ertn_vld_d;
    
    // TLB output ports from IFU to EXU
    wire ifu_exu_tlb_vld_d;
    wire [3:0] ifu_exu_tlb_op_d;
    
    wire ifu_exu_exc_vld_d;
    wire [5:0] ifu_exu_exc_code_d;
    wire [8:0] ifu_exu_exc_subcode_d;
    wire [31:0] ifu_exu_exc_badv_d;
    
    // ITLB CSR output ports (from DUT, not used in test)
    wire [4:0]  itlb_csr_tlbidx_index;
    wire [18:0] itlb_csr_tlbehi_vppn;
    wire        itlb_csr_tlbelo_g;
    wire [5:0]  itlb_csr_tlbidx_ps;
    wire        itlb_csr_tlbidx_e;
    wire        itlb_csr_tlbelo0_v;
    wire        itlb_csr_tlbelo0_d;
    wire [1:0]  itlb_csr_tlbelo0_mat;
    wire [1:0]  itlb_csr_tlbelo0_plv;
    wire [19:0] itlb_csr_tlbelo0_ppn;
    wire        itlb_csr_tlbelo1_v;
    wire        itlb_csr_tlbelo1_d;
    wire [1:0]  itlb_csr_tlbelo1_mat;
    wire [1:0]  itlb_csr_tlbelo1_plv;
    wire [19:0] itlb_csr_tlbelo1_ppn;
    wire [9:0]  itlb_csr_asid_asid;
    
    // Internal signals for monitoring (from DUT)
    wire [31:0] pf_addr_q;
    wire pf_addr_sel_init;
    wire pf_addr_sel_old;
    wire pf_addr_sel_inc;
    wire pf_addr_sel_brn;
    wire pf_addr_sel_isr;
    wire pf_addr_sel_ert;
    wire pf_addr_en;
    wire fcl_data_vld;
    
    // Test status variables
    reg [7:0] test_passed;
    reg [7:0] test_failed;
    integer test_num;
    
    // Waveform display variables
    integer cycle_count;
    reg [179:0] wave_clk;
    reg [179:0] wave_resetn;
    reg [179:0] wave_req;
    reg [179:0] wave_ack;
    reg [179:0] wave_valid;
    reg [179:0] wave_data_vld;
    reg [179:0] wave_except;
    reg [179:0] wave_branch;
    reg [179:0] wave_ertn;
    reg [179:0] wave_pf_init;
    reg [179:0] wave_pf_old;
    reg [179:0] wave_pf_inc;
    reg [179:0] wave_pf_brn;
    reg [179:0] wave_pf_isr;
    reg [179:0] wave_pf_ert;
    reg [179:0] wave_pf_en;
    reg [179:0] wave_pf_addr_hex;
    reg [179:0] wave_pf_addr_dec;
    
    // Clock edge counter
    integer clk_edge_count;
    
    // Expected address tracking
    reg [31:0] expected_pc;
    reg [31:0] next_expected_pc;
    
    // ACK control
    reg ack_mode;  // 0 = next-cycle ACK, 1 = same-cycle ACK

    // Instantiate DUT using named connections
    c7bifu dut (
        .clk(clk),
        .resetn(resetn),
        
        .csr_ifu_ic_en(csr_ifu_ic_en),
        .csr_ifu_ic_en_pls(csr_ifu_ic_en_pls),
        
        .ifu_icu_addr_ic1(ifu_icu_addr_ic1),
        .ifu_icu_req_ic1(ifu_icu_req_ic1),
        .icu_ifu_ack_ic1(icu_ifu_ack_ic1),
        .icu_ifu_data_valid_ic2(icu_ifu_data_valid_ic2),
        .icu_ifu_fault_ic2(icu_ifu_fault_ic2),
        .icu_ifu_fault_code_ic2(icu_ifu_fault_code_ic2),
        .icu_ifu_data_ic2(icu_ifu_data_ic2),
        
        .ifu_biu_rd_addr(ifu_biu_rd_addr),
        .ifu_biu_rd_req(ifu_biu_rd_req),
        .biu_ifu_rd_ack(biu_ifu_rd_ack),
        .biu_ifu_data_valid(biu_ifu_data_valid),
        .biu_ifu_data(biu_ifu_data),
        .biu_ifu_fault(biu_ifu_fault),
        .biu_ifu_fault_code(biu_ifu_fault_code),
        
        .exu_ifu_except(exu_ifu_except),
        .exu_ifu_isr_addr(exu_ifu_isr_addr),
        .exu_ifu_branch(exu_ifu_branch),
        .exu_ifu_brn_addr(exu_ifu_brn_addr),
        .exu_ifu_ertn(exu_ifu_ertn),
        .exu_ifu_ert_addr(exu_ifu_ert_addr),
        .exu_ifu_stall(exu_ifu_stall),
        
        .ifu_exu_vld_d(ifu_exu_vld_d),
        .ifu_exu_pc_d(ifu_exu_pc_d),
        .ifu_exu_rs1_d(ifu_exu_rs1_d),
        .ifu_exu_rs2_d(ifu_exu_rs2_d),
        .ifu_exu_rd_d(ifu_exu_rd_d),
        .ifu_exu_wen_d(ifu_exu_wen_d),
        .ifu_exu_imm_shifted_d(ifu_exu_imm_shifted_d),
        
        .ifu_exu_alu_vld_d(ifu_exu_alu_vld_d),
        .ifu_exu_alu_op_d(ifu_exu_alu_op_d),
        .ifu_exu_alu_a_pc_d(ifu_exu_alu_a_pc_d),
        .ifu_exu_alu_c_d(ifu_exu_alu_c_d),
        .ifu_exu_alu_double_word_d(ifu_exu_alu_double_word_d),
        .ifu_exu_alu_b_imm_d(ifu_exu_alu_b_imm_d),
        
        .ifu_exu_lsu_vld_d(ifu_exu_lsu_vld_d),
        .ifu_exu_lsu_ibar_d(ifu_exu_lsu_ibar_d),
        .ifu_exu_lsu_dbar_d(ifu_exu_lsu_dbar_d),
        .ifu_exu_lsu_op_d(ifu_exu_lsu_op_d),
        .ifu_exu_lsu_double_read_d(ifu_exu_lsu_double_read_d),
        
        .ifu_exu_bru_vld_d(ifu_exu_bru_vld_d),
        .ifu_exu_bru_op_d(ifu_exu_bru_op_d),
        .ifu_exu_bru_offset_d(ifu_exu_bru_offset_d),
        
        .ifu_exu_mul_vld_d(ifu_exu_mul_vld_d),
        .ifu_exu_mul_signed_d(ifu_exu_mul_signed_d),
        .ifu_exu_mul_double_d(ifu_exu_mul_double_d),
        .ifu_exu_mul_hi_d(ifu_exu_mul_hi_d),
        .ifu_exu_mul_short_d(ifu_exu_mul_short_d),
        
        .ifu_exu_div_vld_d(ifu_exu_div_vld_d),
        .ifu_exu_div_signed_d(ifu_exu_div_signed_d),
        .ifu_exu_div_mod_d(ifu_exu_div_mod_d),
        
        .ifu_exu_csr_vld_d(ifu_exu_csr_vld_d),
        .ifu_exu_csr_raddr_d(ifu_exu_csr_raddr_d),
        .ifu_exu_csr_xchg_d(ifu_exu_csr_xchg_d),
        .ifu_exu_csr_wen_d(ifu_exu_csr_wen_d),
        .ifu_exu_csr_waddr_d(ifu_exu_csr_waddr_d),
        .ifu_exu_csr_rdtimel_d(ifu_exu_csr_rdtimel_d),
        .ifu_exu_csr_rdtimeh_d(ifu_exu_csr_rdtimeh_d),
        
        .ifu_exu_ertn_vld_d(ifu_exu_ertn_vld_d),
        
        .ifu_exu_tlb_vld_d(ifu_exu_tlb_vld_d),
        .ifu_exu_tlb_op_d(ifu_exu_tlb_op_d),
        
        .ifu_exu_exc_vld_d(ifu_exu_exc_vld_d),
        .ifu_exu_exc_code_d(ifu_exu_exc_code_d),
        .ifu_exu_exc_subcode_d(ifu_exu_exc_subcode_d),
        .ifu_exu_exc_badv_d(ifu_exu_exc_badv_d),
        
        .csr_itlb_tlbehi_vppn(csr_itlb_tlbehi_vppn),
        .csr_itlb_tlbidx_ne(csr_itlb_tlbidx_ne),
        .csr_itlb_tlbidx_ps(csr_itlb_tlbidx_ps),
        .csr_itlb_tlbidx_i_d(csr_itlb_tlbidx_i_d),
        .csr_itlb_tlbidx_index(csr_itlb_tlbidx_index),
        .csr_itlb_tlbelo0_ppn(csr_itlb_tlbelo0_ppn),
        .csr_itlb_tlbelo0_g(csr_itlb_tlbelo0_g),
        .csr_itlb_tlbelo0_mat(csr_itlb_tlbelo0_mat),
        .csr_itlb_tlbelo0_plv(csr_itlb_tlbelo0_plv),
        .csr_itlb_tlbelo0_d(csr_itlb_tlbelo0_d),
        .csr_itlb_tlbelo0_v(csr_itlb_tlbelo0_v),
        .csr_itlb_tlbelo1_ppn(csr_itlb_tlbelo1_ppn),
        .csr_itlb_tlbelo1_g(csr_itlb_tlbelo1_g),
        .csr_itlb_tlbelo1_mat(csr_itlb_tlbelo1_mat),
        .csr_itlb_tlbelo1_plv(csr_itlb_tlbelo1_plv),
        .csr_itlb_tlbelo1_d(csr_itlb_tlbelo1_d),
        .csr_itlb_tlbelo1_v(csr_itlb_tlbelo1_v),
        .csr_itlb_tlbrefill_ctx(csr_itlb_tlbrefill_ctx),
        .csr_itlb_asid_asid(csr_itlb_asid_asid),
        .exu_itlb_random_index(exu_itlb_random_index),
        .exu_itlb_tlbfill_vld_e(exu_itlb_tlbfill_vld_e),
        .exu_itlb_tlbwr_vld_e(exu_itlb_tlbwr_vld_e),
        .exu_itlb_tlbsrch_vld_e(exu_itlb_tlbsrch_vld_e),
        .exu_itlb_invtlb_vld_e(exu_itlb_invtlb_vld_e),
        .exu_itlb_invtlb_op_e(exu_itlb_invtlb_op_e),
        .exu_itlb_invtlb_asid_e(exu_itlb_invtlb_asid_e),
        .exu_itlb_invtlb_vppn_e(exu_itlb_invtlb_vppn_e),
        
        .csr_ifu_crmd_da(csr_ifu_crmd_da),
        .csr_ifu_crmd_pg(csr_ifu_crmd_pg),
        .csr_ifu_dmw0_pseg(csr_ifu_dmw0_pseg),
        .csr_ifu_dmw0_vseg(csr_ifu_dmw0_vseg),
        .csr_ifu_dmw1_pseg(csr_ifu_dmw1_pseg),
        .csr_ifu_dmw1_vseg(csr_ifu_dmw1_vseg),
        
        .itlb_csr_tlbidx_index(itlb_csr_tlbidx_index),
        .itlb_csr_tlbehi_vppn(itlb_csr_tlbehi_vppn),
        .itlb_csr_tlbelo_g(itlb_csr_tlbelo_g),
        .itlb_csr_tlbidx_ps(itlb_csr_tlbidx_ps),
        .itlb_csr_tlbidx_e(itlb_csr_tlbidx_e),
        .itlb_csr_tlbelo0_v(itlb_csr_tlbelo0_v),
        .itlb_csr_tlbelo0_d(itlb_csr_tlbelo0_d),
        .itlb_csr_tlbelo0_mat(itlb_csr_tlbelo0_mat),
        .itlb_csr_tlbelo0_plv(itlb_csr_tlbelo0_plv),
        .itlb_csr_tlbelo0_ppn(itlb_csr_tlbelo0_ppn),
        .itlb_csr_tlbelo1_v(itlb_csr_tlbelo1_v),
        .itlb_csr_tlbelo1_d(itlb_csr_tlbelo1_d),
        .itlb_csr_tlbelo1_mat(itlb_csr_tlbelo1_mat),
        .itlb_csr_tlbelo1_plv(itlb_csr_tlbelo1_plv),
        .itlb_csr_tlbelo1_ppn(itlb_csr_tlbelo1_ppn),
        .itlb_csr_asid_asid(itlb_csr_asid_asid)
    );

    // Connect to internal signals for monitoring
    assign pf_addr_q = dut.pf_vaddr_q;
    assign pf_addr_sel_init = dut.pf_addr_sel_init;
    assign pf_addr_sel_old = dut.pf_addr_sel_old;
    assign pf_addr_sel_inc = dut.pf_addr_sel_inc;
    assign pf_addr_sel_brn = dut.pf_addr_sel_brn;
    assign pf_addr_sel_isr = dut.pf_addr_sel_isr;
    assign pf_addr_sel_ert = dut.pf_addr_sel_ert;
    assign pf_addr_en = dut.pf_addr_en;
    assign fcl_data_vld = dut.fcl_data_vld;

    // Clock generation: period 10ns
    always begin
        #5 clk = ~clk;
    end
    
    // Clock edge counting
    always @(posedge clk) begin
        clk_edge_count = clk_edge_count + 1;
    end
    
    // Waveform sampling (sample at clock falling edge)
    always @(negedge clk) begin
        if (cycle_count < 180) begin
            // Basic signals
            wave_clk      <= {wave_clk[178:0], "^"};
            wave_resetn   <= {wave_resetn[178:0], (resetn ? "-" : "_")};
            wave_req      <= {wave_req[178:0], (ifu_icu_req_ic1 ? "-" : "_")};
            wave_ack      <= {wave_ack[178:0], (icu_ifu_ack_ic1 ? "-" : "_")};
            wave_valid    <= {wave_valid[178:0], (icu_ifu_data_valid_ic2 ? "-" : "_")};
            wave_data_vld <= {wave_data_vld[178:0], (fcl_data_vld ? "-" : "_")};
            wave_except   <= {wave_except[178:0], (exu_ifu_except ? "-" : "_")};
            wave_branch   <= {wave_branch[178:0], (exu_ifu_branch ? "-" : "_")};
            wave_ertn     <= {wave_ertn[178:0], (exu_ifu_ertn ? "-" : "_")};
            
            // Address selection signals (monitor internal wires)
            wave_pf_init  <= {wave_pf_init[178:0], (pf_addr_sel_init ? "-" : "_")};
            wave_pf_old   <= {wave_pf_old[178:0], (pf_addr_sel_old ? "-" : "_")};
            wave_pf_inc   <= {wave_pf_inc[178:0], (pf_addr_sel_inc ? "-" : "_")};
            wave_pf_brn   <= {wave_pf_brn[178:0], (pf_addr_sel_brn ? "-" : "_")};
            wave_pf_isr   <= {wave_pf_isr[178:0], (pf_addr_sel_isr ? "-" : "_")};
            wave_pf_ert   <= {wave_pf_ert[178:0], (pf_addr_sel_ert ? "-" : "_")};
            wave_pf_en    <= {wave_pf_en[178:0], (pf_addr_en ? "-" : "_")};
            
            // Current PC value in hex and decimal (truncated for display)
            wave_pf_addr_hex <= {wave_pf_addr_hex[178:0], get_hex_char(pf_addr_q[3:0])};
            wave_pf_addr_dec <= {wave_pf_addr_dec[178:0], get_dec_char(pf_addr_q % 10)};
            
            cycle_count <= cycle_count + 1;
        end
    end
    
    // Helper function to get hex character
    function automatic [7:0] get_hex_char;
        input [3:0] nibble;
        begin
            case(nibble)
                4'h0: get_hex_char = "0";
                4'h1: get_hex_char = "1";
                4'h2: get_hex_char = "2";
                4'h3: get_hex_char = "3";
                4'h4: get_hex_char = "4";
                4'h5: get_hex_char = "5";
                4'h6: get_hex_char = "6";
                4'h7: get_hex_char = "7";
                4'h8: get_hex_char = "8";
                4'h9: get_hex_char = "9";
                4'hA: get_hex_char = "A";
                4'hB: get_hex_char = "B";
                4'hC: get_hex_char = "C";
                4'hD: get_hex_char = "D";
                4'hE: get_hex_char = "E";
                4'hF: get_hex_char = "F";
                default: get_hex_char = "?";
            endcase
        end
    endfunction
    
    // Helper function to get decimal character
    function automatic [7:0] get_dec_char;
        input integer digit;
        integer mod_digit;
        begin
            mod_digit = digit % 10;
            case(mod_digit)
                0: get_dec_char = "0";
                1: get_dec_char = "1";
                2: get_dec_char = "2";
                3: get_dec_char = "3";
                4: get_dec_char = "4";
                5: get_dec_char = "5";
                6: get_dec_char = "6";
                7: get_dec_char = "7";
                8: get_dec_char = "8";
                9: get_dec_char = "9";
                default: get_dec_char = "?";
            endcase
        end
    endfunction
    
    // Task: Generate ACK based on mode
    task automatic generate_ack;
        begin
            if (ack_mode == 1'b1) begin
                // Same-cycle ACK mode
                if (ifu_icu_req_ic1 == 1'b1) begin
                    icu_ifu_ack_ic1 = 1'b1;
                    @(posedge clk);
                    icu_ifu_ack_ic1 = 1'b0;
                    $display("Time=%t: Same-cycle ACK generated", $time);
                end
            end else begin
                // Next-cycle ACK mode (default)
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
                $display("Time=%t: Next-cycle ACK generated", $time);
            end
        end
    endtask

    // Initialization block
    initial begin
        clk = 0;
        resetn = 0;
        
        // CSR interface
        csr_ifu_ic_en = 1'b1;
        csr_ifu_ic_en_pls = 1'b0;
        
        // Set DA=1, PG=0, DMW all zero
        csr_ifu_crmd_da    = 1'b1;
        csr_ifu_crmd_pg    = 1'b0;
        csr_ifu_dmw0_pseg  = 3'b0;
        csr_ifu_dmw0_vseg  = 3'b0;
        csr_ifu_dmw1_pseg  = 3'b0;
        csr_ifu_dmw1_vseg  = 3'b0;
        
        // Initialize all TLB CSR inputs to 0
        csr_itlb_tlbehi_vppn    = 19'b0;
        csr_itlb_tlbidx_ne      = 1'b0;
        csr_itlb_tlbidx_ps      = 6'b0;
        csr_itlb_tlbidx_i_d     = 1'b0;
        csr_itlb_tlbidx_index   = 5'b0;
        csr_itlb_tlbelo0_ppn    = 20'b0;
        csr_itlb_tlbelo0_g      = 1'b0;
        csr_itlb_tlbelo0_mat    = 2'b0;
        csr_itlb_tlbelo0_plv    = 2'b0;
        csr_itlb_tlbelo0_d      = 1'b0;
        csr_itlb_tlbelo0_v      = 1'b0;
        csr_itlb_tlbelo1_ppn    = 20'b0;
        csr_itlb_tlbelo1_g      = 1'b0;
        csr_itlb_tlbelo1_mat    = 2'b0;
        csr_itlb_tlbelo1_plv    = 2'b0;
        csr_itlb_tlbelo1_d      = 1'b0;
        csr_itlb_tlbelo1_v      = 1'b0;
        csr_itlb_tlbrefill_ctx  = 1'b0;
        csr_itlb_asid_asid      = 10'b0;
        exu_itlb_random_index   = 5'b0;
        exu_itlb_tlbfill_vld_e  = 1'b0;
        exu_itlb_tlbwr_vld_e    = 1'b0;
        exu_itlb_tlbsrch_vld_e  = 1'b0;
        exu_itlb_invtlb_vld_e   = 1'b0;
        exu_itlb_invtlb_op_e    = 5'b0;
        exu_itlb_invtlb_asid_e  = 10'b0;
        exu_itlb_invtlb_vppn_e  = 19'b0;
        
        // ICU interface
        icu_ifu_ack_ic1 = 0;
        icu_ifu_data_valid_ic2 = 0;
        icu_ifu_fault_ic2 = 0;
        icu_ifu_fault_code_ic2 = 0;
        
        // BIU interface
        biu_ifu_rd_ack = 0;
        biu_ifu_data_valid = 0;
        biu_ifu_data = 64'h0;
        biu_ifu_fault = 0;
        biu_ifu_fault_code = 0;
        
        // EXU interface
        exu_ifu_except = 0;
        exu_ifu_isr_addr = 32'h0;
        exu_ifu_branch = 0;
        exu_ifu_brn_addr = 32'h0;
        exu_ifu_ertn = 0;
        exu_ifu_ert_addr = 32'h0;
        exu_ifu_stall = 0;
        
        ack_mode = 1'b0;  // default next-cycle ACK mode
        
        test_passed = 0;
        test_failed = 0;
        test_num = 0;
        cycle_count = 0;
        clk_edge_count = 0;
        expected_pc = 32'h1c000000; // Initial PC after reset
        
        // Clear waveform strings
        wave_clk = "";
        wave_resetn = "";
        wave_req = "";
        wave_ack = "";
        wave_valid = "";
        wave_data_vld = "";
        wave_except = "";
        wave_branch = "";
        wave_ertn = "";
        wave_pf_init = "";
        wave_pf_old = "";
        wave_pf_inc = "";
        wave_pf_brn = "";
        wave_pf_isr = "";
        wave_pf_ert = "";
        wave_pf_en = "";
        wave_pf_addr_hex = "";
        wave_pf_addr_dec = "";

        // Wait and release reset
        @(posedge clk);
        #52;
        resetn = 1;
        
        // Wait for stabilization
        repeat(2) @(posedge clk);

        // Run test cases
        test_normal_increment_flow_long_cycle_ack_long_dvalid();
        test_normal_increment_flow_next_cycle_ack();
        test_normal_increment_flow_same_cycle_ack();

        test_exception_interrupt_no_datacancel();
        test_exception_interrupt_datacancel();

        test_branch_no_datacancel();
        test_branch_datacancel();

        test_ertn_no_datacancel();
        test_ertn_datacancel();

        // Print final test results
        print_final_results();
        
        // End simulation
        #50 $finish;
    end
    
    // ================================
    // TASKS: PRINTING AND UTILITIES
    // ================================
    
    // Task: Print realtime waveform
    task automatic print_realtime_waveform;
        begin
            $display("Time=%t, Clock Edge=%0d | resetn=%b | req=%b | ack=%b | valid=%b | data_vld=%b | except=%b | branch=%b | ertn=%b",
                     $time, clk_edge_count, resetn, ifu_icu_req_ic1, icu_ifu_ack_ic1,
                     icu_ifu_data_valid_ic2, fcl_data_vld, exu_ifu_except, exu_ifu_branch, exu_ifu_ertn);
            $display("                    | pf_addr=0x%h | ifu_addr=0x%h", 
                     pf_addr_q, ifu_icu_addr_ic1);
            $display("                    | pf_init=%b | pf_old=%b | pf_inc=%b | pf_brn=%b | pf_isr=%b | pf_ert=%b | pf_en=%b",
                     pf_addr_sel_init, pf_addr_sel_old, pf_addr_sel_inc,
                     pf_addr_sel_brn, pf_addr_sel_isr, pf_addr_sel_ert, pf_addr_en);
        end
    endtask
    
    // Task: Print test start
    task automatic print_test_start;
        input [512:0] test_name;
        begin
            test_num = test_num + 1;
            $display("\n========== Test %0d: %s ==========", test_num, test_name);
            $display("Time=%t: Starting test...", $time);
            $display("ACK Mode: %s", (ack_mode ? "Same-cycle" : "Next-cycle"));
            print_realtime_waveform();

            // Reset waveform recording
            wave_clk = "";
            wave_resetn = "";
            wave_req = "";
            wave_ack = "";
            wave_valid = "";
            wave_data_vld = "";
            wave_except = "";
            wave_branch = "";
            wave_ertn = "";
            wave_pf_init = "";
            wave_pf_old = "";
            wave_pf_inc = "";
            wave_pf_brn = "";
            wave_pf_isr = "";
            wave_pf_ert = "";
            wave_pf_en = "";
            wave_pf_addr_hex = "";
            wave_pf_addr_dec = "";
            cycle_count = 0;
        end
    endtask

    // Task: Print waveform with all signals
    task automatic print_waveform;
        begin
            $display("\nWaveform Visualization (sampled at clock edges):");
            $display("Sample: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15");
            $display("------------------------------------------------");
            
            // Basic control signals
            $display("clk      : %s", wave_clk);
            $display("resetn   : %s", wave_resetn);
            $display("req      : %s", wave_req);
            $display("ack      : %s", wave_ack);
            $display("valid    : %s", wave_valid);
            $display("data_vld : %s", wave_data_vld);
            $display("except   : %s", wave_except);
            $display("branch   : %s", wave_branch);
            $display("ertn     : %s", wave_ertn);
            $display("------------------------------------------------");
            
            // Address selection signals
            $display("PF Address Selection:");
            $display("pf_init  : %s (select initial address)", wave_pf_init);
            $display("pf_old   : %s (select old/stall address)", wave_pf_old);
            $display("pf_inc   : %s (select increment address)", wave_pf_inc);
            $display("pf_brn   : %s (select branch address)", wave_pf_brn);
            $display("pf_isr   : %s (select exception address)", wave_pf_isr);
            $display("pf_ert   : %s (select ertn address)", wave_pf_ert);
            $display("pf_en    : %s (address update enable)", wave_pf_en);
            $display("------------------------------------------------");
            
            // Address value (LSB in hex and decimal)
            $display("PF Addr LSB: hex:%s, dec:%s", wave_pf_addr_hex, wave_pf_addr_dec);
            $display("------------------------------------------------");
            $display("Legend: '_' = 0, '-' = 1, '^' = clock edge marker");
        end
    endtask

    // Task: Print test result
    task automatic print_test_result;
        input [512:0] test_name;
        input passed;
        begin
            // Print waveform with all signals
            print_waveform();
            
            // Print result
            if (passed) begin
                test_passed = test_passed + 1;
                $display("Time=%t: %s - PASSED", $time, test_name);
            end else begin
                test_failed = test_failed + 1;
                $display("Time=%t: %s - FAILED", $time, test_name);
            end
            $display("========================================");
        end
    endtask

    // Task: Wait for N clock cycles
    task automatic wait_cycles;
        input integer cycles;
        begin
            repeat(cycles) @(posedge clk);
        end
    endtask
    
    // Task: Simulate data valid after ACK
    task automatic generate_data_valid;
        begin
            icu_ifu_data_valid_ic2 = 1'b1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b0;
            $display("Time=%t: Data valid generated", $time);
        end
    endtask

    // Task: Simulate data valid after ACK with long delay
    task automatic generate_data_valid_longcycle;
        begin
            wait_cycles(1 + ($random % 5));
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b0;
            $display("Time=%t: Data valid generated (long delay)", $time);
        end
    endtask
    
    // ================================
    // TEST CASES
    // ================================
    
    // Test 1: Normal increment flow with long-cycle ACK and long-cycle data valid
    task automatic test_normal_increment_flow_long_cycle_ack_long_dvalid;
        reg passed;
        integer i;
        begin
            print_test_start("Normal Increment Flow - Long-Cycle ACK, Long-Cycle dvalid");
            passed = 1'b1;
            
            ack_mode = 1'b0;
            
            resetn = 1'b0;
            wait_cycles(1);
            resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            for (i = 0; i < 3; i = i + 1) begin
                $display("\n--- Cycle %0d ---", i);
                
                if (ifu_icu_addr_ic1 !== expected_pc) begin
                    $display("ERROR: Cycle %0d - Expected: 0x%h, Got: 0x%h", 
                            i, expected_pc, ifu_icu_addr_ic1);
                    passed = 1'b0;
                end else begin
                    $display("OK: Cycle %0d address correct: 0x%h", i, expected_pc);
                end
                
                wait_cycles(5);
                generate_ack();
                print_realtime_waveform();
                
                generate_data_valid_longcycle();
                
                expected_pc = expected_pc + 32'h8;
                
                wait_cycles(1);
            end
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Final address - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Final address correct: 0x%h", expected_pc);
            end
            
            print_test_result("Normal Increment Flow - Next-Cycle ACK", passed);
        end
    endtask
    
    // Test 2: Normal increment flow with next-cycle ACK
    task automatic test_normal_increment_flow_next_cycle_ack;
        reg passed;
        integer i;
        begin
            print_test_start("Normal Increment Flow - Next-Cycle ACK");
            passed = 1'b1;
            
            ack_mode = 1'b0;
            
            resetn = 1'b0;
            wait_cycles(1);
            resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            for (i = 0; i < 3; i = i + 1) begin
                $display("\n--- Cycle %0d ---", i);
                
                if (ifu_icu_addr_ic1 !== expected_pc) begin
                    $display("ERROR: Cycle %0d - Expected: 0x%h, Got: 0x%h", 
                            i, expected_pc, ifu_icu_addr_ic1);
                    passed = 1'b0;
                end else begin
                    $display("OK: Cycle %0d address correct: 0x%h", i, expected_pc);
                end
                
                generate_ack();
                print_realtime_waveform();
                
                generate_data_valid();
                
                expected_pc = expected_pc + 32'h8;
                
                wait_cycles(1);
            end
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Final address - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Final address correct: 0x%h", expected_pc);
            end
            
            print_test_result("Normal Increment Flow - Next-Cycle ACK", passed);
        end
    endtask
    
    // Test 3: Normal increment flow with same-cycle ACK
    task automatic test_normal_increment_flow_same_cycle_ack;
        reg passed;
        integer i;
        begin
            print_test_start("Normal Increment Flow - Same-Cycle ACK");
            passed = 1'b1;
            
            ack_mode = 1'b1;
            
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            for (i = 1; i <= 3; i = i + 1) begin
                $display("\n--- Cycle %0d ---", i);
                
                if (ifu_icu_addr_ic1 !== expected_pc) begin
                    $display("ERROR: Cycle %0d - Expected: 0x%h, Got: 0x%h", 
                            i, expected_pc, ifu_icu_addr_ic1);
                    passed = 1'b0;
                end else begin
                    $display("OK: Cycle %0d address correct: 0x%h", i, expected_pc);
                end
                
                if (ifu_icu_req_ic1 == 1'b1) begin
                    icu_ifu_ack_ic1 = 1'b1;
                    @(posedge clk);
                    icu_ifu_ack_ic1 = 1'b0;
                    $display("Time=%t: Same-cycle ACK applied", $time);
                end
                
                generate_data_valid();
                
                expected_pc = expected_pc + 32'h8;
                
                wait_cycles(1);
            end
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Final address - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Final address correct: 0x%h", expected_pc);
            end
            
            print_test_result("Normal Increment Flow - Same-Cycle ACK", passed);
        end
    endtask
    
    // Test 4: Exception interrupt without data_cancel
    task automatic test_exception_interrupt_no_datacancel;
        reg passed;
        begin
            print_test_start("Exception Interrupt");
            passed = 1'b1;
            
            ack_mode = 1'b1;
            
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            expected_pc = expected_pc + 32'h8;
            wait_cycles(2);
            
            exu_ifu_except = 1'b1;
            exu_ifu_isr_addr = 32'h1c000100;
            
            @(posedge clk);
            @(posedge clk);
            print_realtime_waveform();
            
            if (ifu_icu_addr_ic1 !== 32'h1c000100) begin
                $display("ERROR: Exception handler address - Expected: 0x1c000100, Got: 0x%h", 
                        ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Exception handler address correct: 0x1c000100");
            end
            
            exu_ifu_except = 1'b0;
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            
            if (fcl_data_vld !== 1'b1) begin
                $display("ERROR: fcl_data_vld should be 1 after ERTN data valid");
                passed = 1'b0;
            end
            
            expected_pc = 32'h1c000100 + 32'h8;
            wait_cycles(2);
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Address after exception - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Address after exception correct: 0x%h", expected_pc);
            end
            
            print_test_result("Exception Interrupt - Same-Cycle ACK", passed);
        end
    endtask
    
    // Test 5: Exception interrupt with data_cancel
    task automatic test_exception_interrupt_datacancel;
        reg passed;
        begin
            print_test_start("Exception Interrupt - data_cancel");
            passed = 1'b1;
            
            ack_mode = 1'b1;
            
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            @(posedge clk);
            
            expected_pc = expected_pc + 32'h8;
            icu_ifu_ack_ic1 = 1'b1;
            @(posedge clk);
            icu_ifu_ack_ic1 = 1'b0;
            
            wait_cycles(2);
            
            exu_ifu_except = 1'b1;
            exu_ifu_isr_addr = 32'h1c000100;
            
            @(posedge clk);
            print_realtime_waveform();
            exu_ifu_except = 1'b0;
            
            generate_data_valid_longcycle();
            
            if (fcl_data_vld === 1'b1) begin
                $display("ERROR: fcl_data_vld should not be 1 because data for 0x1c000008 is canceled");
                passed = 1'b0;
            end
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            
            if (fcl_data_vld !== 1'b1) begin
                $display("ERROR: fcl_data_vld should be 1 after data valid");
                passed = 1'b0;
            end else begin
                $display("OK: fcl_data_vld is 1 after data valid for 0x1c000100");
                passed = 1'b1;
            end
            
            expected_pc = 32'h1c000100 + 32'h8;
            wait_cycles(2);
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Address after exception - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Address after exception correct: 0x%h", expected_pc);
            end
            
            print_test_result("Exception Interrupt - data_cancel", passed);
        end
    endtask

    // Test 6: Branch without data_cancel
    task automatic test_branch_no_datacancel;
        reg passed;
        begin
            print_test_start("Branch");
            passed = 1'b1;
            
            ack_mode = 1'b1;
            
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            expected_pc = expected_pc + 32'h8;
            wait_cycles(2);
            
            exu_ifu_branch = 1'b1;
            exu_ifu_brn_addr = 32'h1c000200;
            
            @(posedge clk);
            @(posedge clk);
            print_realtime_waveform();
            
            if (ifu_icu_addr_ic1 !== 32'h1c000200) begin
                $display("ERROR: Branch address - Expected: 0x1c000200, Got: 0x%h", 
                        ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Branch address correct: 0x1c000200");
            end
            
            exu_ifu_branch = 1'b0;
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            
            if (fcl_data_vld !== 1'b1) begin
                $display("ERROR: fcl_data_vld should be 1 after branch address data valid");
                passed = 1'b0;
            end
            
            expected_pc = 32'h1c000200 + 32'h8;
            wait_cycles(2);
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Address after branch - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Address after branch correct: 0x%h", expected_pc);
            end
            
            print_test_result("Branch - no data_cancel", passed);
        end
    endtask
    
    // Test 7: Branch with data_cancel
    task automatic test_branch_datacancel;
        reg passed;
        begin
            print_test_start("Branch - data_cancel");
            passed = 1'b1;
            
            ack_mode = 1'b1;
            
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            @(posedge clk);
            
            expected_pc = expected_pc + 32'h8;
            icu_ifu_ack_ic1 = 1'b1;
            @(posedge clk);
            icu_ifu_ack_ic1 = 1'b0;
            
            wait_cycles(2);
            
            exu_ifu_branch = 1'b1;
            exu_ifu_brn_addr = 32'h1c000200;
            
            @(posedge clk);
            print_realtime_waveform();
            exu_ifu_branch = 1'b0;
            
            generate_data_valid_longcycle();
            
            if (fcl_data_vld === 1'b1) begin
                $display("ERROR: fcl_data_vld should not be 1 because data for 0x1c000008 is canceled");
                passed = 1'b0;
            end
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            
            if (fcl_data_vld !== 1'b1) begin
                $display("ERROR: fcl_data_vld should be 1 after data valid");
                passed = 1'b0;
            end else begin
                $display("OK: fcl_data_vld is 1 after data valid for 0x1c000200");
                passed = 1'b1;
            end
            
            expected_pc = 32'h1c000200 + 32'h8;
            wait_cycles(2);
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Address after branch - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Address after branch correct: 0x%h", expected_pc);
            end
            
            print_test_result("Branch - data_cancel", passed);
        end
    endtask

    // Test 8: ERTN without data_cancel
    task automatic test_ertn_no_datacancel;
        reg passed;
        begin
            print_test_start("ERTN without data_cancel");
            passed = 1'b1;
            
            ack_mode = 1'b1;
            
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            expected_pc = expected_pc + 32'h8;
            wait_cycles(2);
            
            exu_ifu_ertn = 1'b1;
            exu_ifu_ert_addr = 32'h1c000300;
            
            @(posedge clk);
            @(posedge clk);
            print_realtime_waveform();
            
            if (ifu_icu_addr_ic1 !== 32'h1c000300) begin
                $display("ERROR: ERTN address - Expected: 0x1c000300, Got: 0x%h", 
                        ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: ERTN address correct: 0x1c000300");
            end
            
            exu_ifu_ertn = 1'b0;
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            
            if (fcl_data_vld !== 1'b1) begin
                $display("ERROR: fcl_data_vld should be 1 after ERTN address data valid");
                passed = 1'b0;
            end
            
            expected_pc = 32'h1c000300 + 32'h8;
            wait_cycles(2);
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Address after ERTN - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Address after ERTN correct: 0x%h", expected_pc);
            end
            
            print_test_result("ERTN - no data_cancel", passed);
        end
    endtask
    
    // Test 9: ERTN with data_cancel
    task automatic test_ertn_datacancel;
        reg passed;
        begin
            print_test_start("ERTN with data_cancel");
            passed = 1'b1;
            
            ack_mode = 1'b1;
            
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            @(posedge clk);
            
            expected_pc = expected_pc + 32'h8;
            icu_ifu_ack_ic1 = 1'b1;
            @(posedge clk);
            icu_ifu_ack_ic1 = 1'b0;
            
            wait_cycles(2);
            
            exu_ifu_ertn = 1'b1;
            exu_ifu_ert_addr = 32'h1c000300;
            
            @(posedge clk);
            print_realtime_waveform();
            exu_ifu_ertn = 1'b0;
            
            generate_data_valid_longcycle();
            
            if (fcl_data_vld === 1'b1) begin
                $display("ERROR: fcl_data_vld should not be 1 because data for 0x1c000008 is canceled");
                passed = 1'b0;
            end
            
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            
            if (fcl_data_vld !== 1'b1) begin
                $display("ERROR: fcl_data_vld should be 1 after data valid");
                passed = 1'b0;
            end else begin
                $display("OK: fcl_data_vld is 1 after data valid for 0x1c000300");
                passed = 1'b1;
            end
            
            expected_pc = 32'h1c000300 + 32'h8;
            wait_cycles(2);
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Address after ERTN - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Address after ERTN correct: 0x%h", expected_pc);
            end
            
            print_test_result("ERTN with data_cancel", passed);
        end
    endtask

    // ================================
    // MONITOR AND FINAL REPORT
    // ================================
    
    // Monitor output at clock edges
    initial begin
        #5;
        $display("\n=== Simulation Monitoring Started ===");
        forever begin
            @(posedge clk);
            $display("Time=%t | clk_edge=%0d", $time, clk_edge_count);
            $display("  Control: resetn=%b, req=%b, ack=%b, valid=%b, data_vld=%b, except=%b, branch=%b, ertn=%b",
                     resetn, ifu_icu_req_ic1, icu_ifu_ack_ic1,
                     icu_ifu_data_valid_ic2, fcl_data_vld, exu_ifu_except, exu_ifu_branch, exu_ifu_ertn);
            $display("  Address: pf_addr=0x%h, ifu_addr=0x%h", 
                     pf_addr_q, ifu_icu_addr_ic1);
        end
    end

    // Task: Print final results
    task automatic print_final_results;
        begin
            $display("\n\n========== FINAL TEST RESULTS ==========");
            $display("Total Tests: %0d", test_num);
            $display("Passed:      %0d", test_passed);
            $display("Failed:      %0d", test_failed);
            $display("========================================");
            
            if (test_failed == 0) begin
                $display("ALL TESTS PASSED!");
                $display("\nPASS!\n");
                $display("\033[0;32m");
                $display("**************************************************");
                $display("*                                                *");
                $display("*      * * *       *        * * *     * * *      *");
                $display("*      *    *     * *      *         *           *");
                $display("*      * * *     *   *      * * *     * * *      *");
                $display("*      *        * * * *          *         *     *");
                $display("*      *       *       *    * * *     * * *      *");
                $display("*                                                *");
                $display("**************************************************");
                $display("\n");
                $display("\033[0m");
            end else begin
                $display("SOME TESTS FAILED!");
                $display("\nFAIL!\n");
                $display("\033[0;31m");
                $display("**************************************************");
                $display("*                                                *");
                $display("*      * * *       *         ***      *          *");
                $display("*      *          * *         *       *          *");
                $display("*      * * *     *   *        *       *          *");
                $display("*      *        * * * *       *       *          *");
                $display("*      *       *       *     ***      * * *      *");
                $display("*                                                *");
                $display("**************************************************");
                $display("\n");
                $display("\033[0m");
            end
        end
    endtask

endmodule
