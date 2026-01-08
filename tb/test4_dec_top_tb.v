`timescale 1ns/1ps

module top_tb();

    // =============================
    // Clock and Reset Signals
    // =============================
    reg         clk;
    reg         resetn;
    
    // =============================
    // Input Signals
    // =============================
    reg         stall;
    reg         flush;
    reg         inst_vld_f;
    reg  [31:0] inst_addr_f;
    reg  [31:0] inst_f;
    
    // =============================
    // Output Signals
    // =============================
    wire        ifu_exu_vld_d;
    wire [31:0] ifu_exu_pc_d;
    wire [4:0]  ifu_exu_rs1_d;
    wire [4:0]  ifu_exu_rs2_d;
    wire        ifu_exu_double_read_d;
    wire [31:0] ifu_exu_imm_shifted_d;
    wire [4:0]  ifu_exu_rd_d;
    wire        ifu_exu_wen_d;
    wire        ifu_exu_alu_vld_d;
    wire [5:0]  ifu_exu_alu_op_d;
    wire [31:0] ifu_exu_alu_c_d;
    wire        ifu_exu_alu_double_word_d;
    wire        ifu_exu_alu_b_imm_d;
    wire        ifu_exu_lsu_vld_d;
    wire [6:0]  ifu_exu_lsu_op_d;
    //wire [4:0]  ifu_exu_lsu_rd_d;
    //wire        ifu_exu_lsu_wen_d;
    wire        ifu_exu_bru_vld_d;
    wire [3:0]  ifu_exu_bru_op_d;
    wire [31:0] ifu_exu_bru_offset_d;
    //wire        ifu_exu_bru_wen_d;
    wire        ifu_exu_mul_vld_d;
    //wire [4:0]  ifu_exu_mul_rd_d;
    //wire        ifu_exu_mul_wen_d;
    wire        ifu_exu_mul_signed_d;
    wire        ifu_exu_mul_double_d;
    wire        ifu_exu_mul_hi_d;
    wire        ifu_exu_mul_short_d;
    wire        ifu_exu_csr_vld_d;
    wire [13:0] ifu_exu_csr_raddr_d;
    //wire        ifu_exu_csr_rdwen_d;
    wire        ifu_exu_csr_xchg_d;
    wire        ifu_exu_csr_wen_d;
    wire [13:0] ifu_exu_csr_waddr_d;
    wire        ifu_exu_ertn_vld_d;
    wire        dec_exc_vld_d;
    wire [5:0]  dec_exc_code_d;
    
    // =============================
    // Statistics Counters
    // =============================
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    // =============================
    // Clock Generation
    // =============================
    always begin
        #5 clk = ~clk;
    end
    
    // =============================
    // DUT (Design Under Test) Instantiation
    // =============================
    c7bifu_dec u_c7bifu_dec (
        .clk                     (clk),
        .resetn                  (resetn),
        .stall                   (stall),
        .flush                   (flush),
        .inst_vld_f              (inst_vld_f),
        .inst_addr_f             (inst_addr_f),
        .inst_f                  (inst_f),
        .ifu_exu_vld_d           (ifu_exu_vld_d),
        .ifu_exu_pc_d            (ifu_exu_pc_d),
        .ifu_exu_rs1_d           (ifu_exu_rs1_d),
        .ifu_exu_rs2_d           (ifu_exu_rs2_d),
        .ifu_exu_double_read_d   (ifu_exu_double_read_d),
        .ifu_exu_imm_shifted_d   (ifu_exu_imm_shifted_d),
        .ifu_exu_rd_d            (ifu_exu_rd_d),
        .ifu_exu_wen_d           (ifu_exu_wen_d),
        .ifu_exu_alu_vld_d       (ifu_exu_alu_vld_d),
        .ifu_exu_alu_op_d        (ifu_exu_alu_op_d),
        .ifu_exu_alu_c_d         (ifu_exu_alu_c_d),
        .ifu_exu_alu_double_word_d (ifu_exu_alu_double_word_d),
        .ifu_exu_alu_b_imm_d     (ifu_exu_alu_b_imm_d),
        .ifu_exu_lsu_vld_d       (ifu_exu_lsu_vld_d),
        .ifu_exu_lsu_op_d        (ifu_exu_lsu_op_d),
        //.ifu_exu_lsu_rd_d        (ifu_exu_lsu_rd_d),
        //.ifu_exu_lsu_wen_d       (ifu_exu_lsu_wen_d),
        .ifu_exu_bru_vld_d       (ifu_exu_bru_vld_d),
        .ifu_exu_bru_op_d        (ifu_exu_bru_op_d),
        .ifu_exu_bru_offset_d    (ifu_exu_bru_offset_d),
	//.ifu_exu_bru_wen_d       (ifu_exu_bru_wen_d),
        .ifu_exu_mul_vld_d       (ifu_exu_mul_vld_d),
        //.ifu_exu_mul_rd_d        (ifu_exu_mul_rd_d),
        //.ifu_exu_mul_wen_d       (ifu_exu_mul_wen_d),
        .ifu_exu_mul_signed_d    (ifu_exu_mul_signed_d),
        .ifu_exu_mul_double_d    (ifu_exu_mul_double_d),
        .ifu_exu_mul_hi_d        (ifu_exu_mul_hi_d),
        .ifu_exu_mul_short_d     (ifu_exu_mul_short_d),
        .ifu_exu_csr_vld_d       (ifu_exu_csr_vld_d),
        .ifu_exu_csr_raddr_d     (ifu_exu_csr_raddr_d),
        //.ifu_exu_csr_rdwen_d     (ifu_exu_csr_rdwen_d),
        .ifu_exu_csr_xchg_d      (ifu_exu_csr_xchg_d),
        .ifu_exu_csr_wen_d       (ifu_exu_csr_wen_d),
        .ifu_exu_csr_waddr_d     (ifu_exu_csr_waddr_d),
        .ifu_exu_ertn_vld_d      (ifu_exu_ertn_vld_d),
        .dec_exc_vld_d           (dec_exc_vld_d),
        .dec_exc_code_d          (dec_exc_code_d)
    );
    
    // =============================
    // Test Function: addi.w $r12,$r0,1
    // =============================
    task test_addi_w_r12_r0_1;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: addi.w $r12,$r0,1 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_alu_vld_d !== 1'b1) begin
                $display("[FAIL] ALU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b01100) begin
                $display("[FAIL] Destination register incorrect: %0d (expected 12)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_alu_b_imm_d !== 1'b1) begin
                $display("[FAIL] Immediate operand flag not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] Write enable flag not set");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  alu_vld_d: %b", ifu_exu_alu_vld_d);
            $display("  rd_d: %0d", ifu_exu_rd_d);
            $display("  alu_b_imm_d: %b", ifu_exu_alu_b_imm_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: st.w $r7,$r6,0 (store word)
    // =============================
    task test_st_w_r7_r6_0;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: st.w $r7,$r6,0 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_lsu_vld_d !== 1'b1) begin
                $display("[FAIL] LSU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Base register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs2_d !== 5'b00111) begin
                $display("[FAIL] Source register rs2 incorrect: %0d (expected 7)", ifu_exu_rs2_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b0) begin
                $display("[FAIL] LSU write enable should be 0 for store instruction");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  lsu_vld_d: %b", ifu_exu_lsu_vld_d);
            $display("  rs1_d (base): %0d", ifu_exu_rs1_d);
            $display("  rs2_d (src): %0d", ifu_exu_rs2_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: ld.w $r5,$r6,0 (load word)
    // =============================
    task test_ld_w_r5_r6_0;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: ld.w $r5,$r6,0 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_lsu_vld_d !== 1'b1) begin
                $display("[FAIL] LSU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Base register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00101) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 5)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] LSU write enable should be 1 for load instruction");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  lsu_vld_d: %b", ifu_exu_lsu_vld_d);
            $display("  rs1_d (base): %0d", ifu_exu_rs1_d);
            $display("  rd_d (dest): %0d", ifu_exu_rd_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: addi.w $r6,$r6,112 (0x70)
    // =============================
    task test_addi_w_r6_r6_112;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: addi.w $r6,$r6,112 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_alu_vld_d !== 1'b1) begin
                $display("[FAIL] ALU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00110) begin
                $display("[FAIL] Destination register incorrect: %0d (expected 6)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Source register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_alu_b_imm_d !== 1'b1) begin
                $display("[FAIL] Immediate operand flag not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] Write enable flag not set");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  alu_vld_d: %b", ifu_exu_alu_vld_d);
            $display("  rd_d: %0d", ifu_exu_rd_d);
            $display("  rs1_d: %0d", ifu_exu_rs1_d);
            $display("  alu_b_imm_d: %b", ifu_exu_alu_b_imm_d);
            $display("  alu_wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: add.w $r8,$r8,$r8
    // =============================
    task test_add_w_r8_r8_r8;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: add.w $r8,$r8,$r8 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_alu_vld_d !== 1'b1) begin
                $display("[FAIL] ALU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b01000) begin
                $display("[FAIL] Destination register incorrect: %0d (expected 8)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b01000) begin
                $display("[FAIL] Source register rs1 incorrect: %0d (expected 8)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs2_d !== 5'b01000) begin
                $display("[FAIL] Source register rs2 incorrect: %0d (expected 8)", ifu_exu_rs2_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_alu_b_imm_d !== 1'b0) begin
                $display("[FAIL] Should not use immediate operand for register-register ADD");
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] Write enable flag not set");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  alu_vld_d: %b", ifu_exu_alu_vld_d);
            $display("  rd_d: %0d", ifu_exu_rd_d);
            $display("  rs1_d: %0d", ifu_exu_rs1_d);
            $display("  rs2_d: %0d", ifu_exu_rs2_d);
            $display("  alu_b_imm_d: %b", ifu_exu_alu_b_imm_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: beq $r0,$r0,8 (branch equal)
    // =============================
    task test_beq_r0_r0_8;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: beq $r0,$r0,8 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_bru_vld_d !== 1'b1) begin
                $display("[FAIL] BRU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00000) begin
                $display("[FAIL] Source register rs1 incorrect: %0d (expected 0)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs2_d !== 5'b00000) begin
                $display("[FAIL] Source register rs2 incorrect: %0d (expected 0)", ifu_exu_rs2_d);
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  bru_vld_d: %b", ifu_exu_bru_vld_d);
            $display("  bru_op_d: %0d", ifu_exu_bru_op_d);
            $display("  rs1_d: %0d", ifu_exu_rs1_d);
            $display("  rs2_d: %0d", ifu_exu_rs2_d);
            $display("  bru_offset_d: 0x%08h", ifu_exu_bru_offset_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: bne $r8,$r7,8 (branch not equal)
    // =============================
    task test_bne_r8_r7_8;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: bne $r8,$r7,8 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_bru_vld_d !== 1'b1) begin
                $display("[FAIL] BRU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b01000) begin
                $display("[FAIL] Source register rs1 incorrect: %0d (expected 8)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs2_d !== 5'b00111) begin
                $display("[FAIL] Source register rs2 incorrect: %0d (expected 7)", ifu_exu_rs2_d);
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  bru_vld_d: %b", ifu_exu_bru_vld_d);
            $display("  bru_op_d: %0d", ifu_exu_bru_op_d);
            $display("  rs1_d: %0d", ifu_exu_rs1_d);
            $display("  rs2_d: %0d", ifu_exu_rs2_d);
            $display("  bru_offset_d: 0x%08h", ifu_exu_bru_offset_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: jirl $r1,$r6,32 (jump and link register)
    // =============================
    task test_jirl_r1_r6_32;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: jirl $r1,$r6,32 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_bru_vld_d !== 1'b1) begin
                $display("[FAIL] BRU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00001) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 1)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Base register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] Write enable flag not set for link register");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  bru_vld_d: %b", ifu_exu_bru_vld_d);
            $display("  rd_d (link): %0d", ifu_exu_rd_d);
            $display("  rs1_d (base): %0d", ifu_exu_rs1_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  bru_offset_d: 0x%08h", ifu_exu_bru_offset_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: mul.w $r5,$r3,$r4
    // =============================
    task test_mul_w_r5_r3_r4;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: mul.w $r5,$r3,$r4 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_mul_vld_d !== 1'b1) begin
                $display("[FAIL] MUL instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00101) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 5)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] Write enable flag not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00011) begin
                $display("[FAIL] Source register rs1 incorrect: %0d (expected 3)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs2_d !== 5'b00100) begin
                $display("[FAIL] Source register rs2 incorrect: %0d (expected 4)", ifu_exu_rs2_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_mul_signed_d !== 1'b1) begin
                $display("[FAIL] Signed multiplication flag incorrect");
                fail_count = fail_count + 1;
            end else if (ifu_exu_mul_short_d !== 1'b1) begin
                $display("[FAIL] Short multiplication flag incorrect");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  mul_vld_d: %b", ifu_exu_mul_vld_d);
            $display("  rd_d: %0d", ifu_exu_rd_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  rs1_d: %0d", ifu_exu_rs1_d);
            $display("  rs2_d: %0d", ifu_exu_rs2_d);
            $display("  mul_signed_d: %b", ifu_exu_mul_signed_d);
            $display("  mul_short_d: %b", ifu_exu_mul_short_d);
            $display("  mul_hi_d: %b", ifu_exu_mul_hi_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: mulh.wu $r5,$r6,$r7 (unsigned multiply high)
    // =============================
    task test_mulh_wu_r5_r6_r7;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: mulh.wu $r5,$r6,$r7 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_mul_vld_d !== 1'b1) begin
                $display("[FAIL] MUL instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00101) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 5)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] Write enable flag not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Source register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs2_d !== 5'b00111) begin
                $display("[FAIL] Source register rs2 incorrect: %0d (expected 7)", ifu_exu_rs2_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_mul_signed_d !== 1'b0) begin
                $display("[FAIL] Should be unsigned multiplication");
                fail_count = fail_count + 1;
            end else if (ifu_exu_mul_hi_d !== 1'b1) begin
                $display("[FAIL] High multiplication flag not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_mul_short_d !== 1'b1) begin
                $display("[FAIL] Short multiplication flag incorrect");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  mul_vld_d: %b", ifu_exu_mul_vld_d);
            $display("  rd_d: %0d", ifu_exu_rd_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  rs1_d: %0d", ifu_exu_rs1_d);
            $display("  rs2_d: %0d", ifu_exu_rs2_d);
            $display("  mul_signed_d: %b", ifu_exu_mul_signed_d);
            $display("  mul_short_d: %b", ifu_exu_mul_short_d);
            $display("  mul_hi_d: %b", ifu_exu_mul_hi_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: mulh.wu $r5,$r3,$r4 (unsigned multiply high)
    // =============================
    task test_mulh_wu_r5_r3_r4;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: mulh.wu $r5,$r3,$r4 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_mul_vld_d !== 1'b1) begin
                $display("[FAIL] MUL instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00101) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 5)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] Write enable flag not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00011) begin
                $display("[FAIL] Source register rs1 incorrect: %0d (expected 3)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs2_d !== 5'b00100) begin
                $display("[FAIL] Source register rs2 incorrect: %0d (expected 4)", ifu_exu_rs2_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_mul_signed_d !== 1'b0) begin
                $display("[FAIL] Should be unsigned multiplication");
                fail_count = fail_count + 1;
            end else if (ifu_exu_mul_hi_d !== 1'b1) begin
                $display("[FAIL] High multiplication flag not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_mul_short_d !== 1'b1) begin
                $display("[FAIL] Short multiplication flag incorrect");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  mul_vld_d: %b", ifu_exu_mul_vld_d);
            $display("  rd_d: %0d", ifu_exu_rd_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  rs1_d: %0d", ifu_exu_rs1_d);
            $display("  rs2_d: %0d", ifu_exu_rs2_d);
            $display("  mul_signed_d: %b", ifu_exu_mul_signed_d);
            $display("  mul_short_d: %b", ifu_exu_mul_short_d);
            $display("  mul_hi_d: %b", ifu_exu_mul_hi_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    // =============================
    // Test Function: lu12i.w $r3,114688
    // =============================
    task test_lu12i_w_r3_114688;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: lu12i.w $r3,114688 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_alu_vld_d !== 1'b1) begin
                $display("[FAIL] ALU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00011) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 3)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_alu_b_imm_d !== 1'b1) begin
                $display("[FAIL] Immediate operand flag not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] Write enable flag not set");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  alu_vld_d: %b", ifu_exu_alu_vld_d);
            $display("  rd_d: %0d", ifu_exu_rd_d);
            $display("  alu_b_imm_d: %b", ifu_exu_alu_b_imm_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: csrrd $r5,0x0 (CSR read)
    // =============================
    task test_csrrd_r5_0;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: csrrd $r5,0x0 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_csr_vld_d !== 1'b1) begin
                $display("[FAIL] CSR instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00101) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 5)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_csr_raddr_d !== 14'h0) begin
                $display("[FAIL] CSR address incorrect: 0x%04h (expected 0x0)", ifu_exu_csr_raddr_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] CSR to rd enable not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_csr_wen_d !== 1'b0) begin
                $display("[FAIL] CSR write enable should be 0 for read");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  csr_vld_d: %b", ifu_exu_csr_vld_d);
            $display("  rd_d: %0d", ifu_exu_rd_d);
            $display("  csr_raddr_d: 0x%04h", ifu_exu_csr_raddr_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  csr_wen_d: %b", ifu_exu_csr_wen_d);
            $display("  csr_xchg_d: %b", ifu_exu_csr_xchg_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: csrwr $r6,0xc (CSR write)
    // =============================
    task test_csrwr_r6_c;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: csrwr $r6,0xc (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_csr_vld_d !== 1'b1) begin
                $display("[FAIL] CSR instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00110) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 6)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_csr_waddr_d !== 14'hc) begin
                $display("[FAIL] CSR address incorrect: 0x%04h (expected 0xc)", ifu_exu_csr_waddr_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_csr_wen_d !== 1'b1) begin
                $display("[FAIL] CSR write enable not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_csr_xchg_d !== 1'b0) begin
                $display("[FAIL] CSR exchange flag should be 0");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  csr_vld_d: %b", ifu_exu_csr_vld_d);
            $display("  rd_d: %0d", ifu_exu_rd_d);
            $display("  csr_waddr_d: 0x%04h", ifu_exu_csr_waddr_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  csr_wen_d: %b", ifu_exu_csr_wen_d);
            $display("  csr_xchg_d: %b", ifu_exu_csr_xchg_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: csrxchg $r5,$r7,0xc (CSR exchange)
    // =============================
    task test_csrxchg_r5_r7_c;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: csrxchg $r5,$r7,0xc (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_csr_vld_d !== 1'b1) begin
                $display("[FAIL] CSR instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00101) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 5)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00111) begin
                $display("[FAIL] Source register rs1 incorrect: %0d (expected 7)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_csr_waddr_d !== 14'hc) begin
                $display("[FAIL] CSR address incorrect: 0x%04h (expected 0xc)", ifu_exu_csr_waddr_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_csr_xchg_d !== 1'b1) begin
                $display("[FAIL] CSR exchange flag not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_csr_wen_d !== 1'b1) begin
                $display("[FAIL] CSR write enable not set");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  csr_vld_d: %b", ifu_exu_csr_vld_d);
            $display("  alu_d: %0d", ifu_exu_rd_d);
            $display("  rs1_d: %0d", ifu_exu_rs1_d);
            $display("  csr_waddr_d: 0x%04h", ifu_exu_csr_waddr_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  csr_wen_d: %b", ifu_exu_csr_wen_d);
            $display("  csr_xchg_d: %b", ifu_exu_csr_xchg_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: ld.b $r7,$r6,0 (load byte)
    // =============================
    task test_ld_b_r7_r6_0;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: ld.b $r7,$r6,0 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_lsu_vld_d !== 1'b1) begin
                $display("[FAIL] LSU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Base register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00111) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 7)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] LSU write enable should be 1 for load instruction");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  lsu_vld_d: %b", ifu_exu_lsu_vld_d);
            $display("  rs1_d (base): %0d", ifu_exu_rs1_d);
            $display("  rd_d (dest): %0d", ifu_exu_rd_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: ld.bu $r7,$r6,0 (load byte unsigned)
    // =============================
    task test_ld_bu_r7_r6_0;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: ld.bu $r7,$r6,0 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_lsu_vld_d !== 1'b1) begin
                $display("[FAIL] LSU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Base register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00111) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 7)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] LSU write enable should be 1 for load instruction");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  lsu_vld_d: %b", ifu_exu_lsu_vld_d);
            $display("  rs1_d (base): %0d", ifu_exu_rs1_d);
            $display("  rd_d (dest): %0d", ifu_exu_rd_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: ld.h $r7,$r6,0 (load halfword)
    // =============================
    task test_ld_h_r7_r6_0;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: ld.h $r7,$r6,0 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_lsu_vld_d !== 1'b1) begin
                $display("[FAIL] LSU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Base register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00111) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 7)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] LSU write enable should be 1 for load instruction");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  lsu_vld_d: %b", ifu_exu_lsu_vld_d);
            $display("  rs1_d (base): %0d", ifu_exu_rs1_d);
            $display("  rd_d (dest): %0d", ifu_exu_rd_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: ld.hu $r7,$r6,0 (load halfword unsigned)
    // =============================
    task test_ld_hu_r7_r6_0;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: ld.hu $r7,$r6,0 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_lsu_vld_d !== 1'b1) begin
                $display("[FAIL] LSU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Base register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00111) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 7)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] LSU write enable should be 1 for load instruction");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  lsu_vld_d: %b", ifu_exu_lsu_vld_d);
            $display("  rs1_d (base): %0d", ifu_exu_rs1_d);
            $display("  rd_d (dest): %0d", ifu_exu_rd_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: st.b $r7,$r6,0 (store byte)
    // =============================
    task test_st_b_r7_r6_0;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: st.b $r7,$r6,0 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_lsu_vld_d !== 1'b1) begin
                $display("[FAIL] LSU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Base register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs2_d !== 5'b00111) begin
                $display("[FAIL] Source register rs2 incorrect: %0d (expected 7)", ifu_exu_rs2_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b0) begin
                $display("[FAIL] LSU write enable should be 0 for store instruction");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  lsu_vld_d: %b", ifu_exu_lsu_vld_d);
            $display("  rs1_d (base): %0d", ifu_exu_rs1_d);
            $display("  rs2_d (src): %0d", ifu_exu_rs2_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: st.h $r7,$r6,0 (store halfword)
    // =============================
    task test_st_h_r7_r6_0;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: st.h $r7,$r6,0 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_lsu_vld_d !== 1'b1) begin
                $display("[FAIL] LSU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Base register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs2_d !== 5'b00111) begin
                $display("[FAIL] Source register rs2 incorrect: %0d (expected 7)", ifu_exu_rs2_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b0) begin
                $display("[FAIL] LSU write enable should be 0 for store instruction");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  lsu_vld_d: %b", ifu_exu_lsu_vld_d);
            $display("  rs1_d (base): %0d", ifu_exu_rs1_d);
            $display("  rs2_d (src): %0d", ifu_exu_rs2_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: st.b $r7,$r6,1 (store byte with offset)
    // =============================
    task test_st_b_r7_r6_1;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: st.b $r7,$r6,1 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_lsu_vld_d !== 1'b1) begin
                $display("[FAIL] LSU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Base register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs2_d !== 5'b00111) begin
                $display("[FAIL] Source register rs2 incorrect: %0d (expected 7)", ifu_exu_rs2_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b0) begin
                $display("[FAIL] LSU write enable should be 0 for store instruction");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  lsu_vld_d: %b", ifu_exu_lsu_vld_d);
            $display("  rs1_d (base): %0d", ifu_exu_rs1_d);
            $display("  rs2_d (src): %0d", ifu_exu_rs2_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: st.h $r7,$r6,2 (store halfword with offset)
    // =============================
    task test_st_h_r7_r6_2;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: st.h $r7,$r6,2 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_lsu_vld_d !== 1'b1) begin
                $display("[FAIL] LSU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00110) begin
                $display("[FAIL] Base register rs1 incorrect: %0d (expected 6)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs2_d !== 5'b00111) begin
                $display("[FAIL] Source register rs2 incorrect: %0d (expected 7)", ifu_exu_rs2_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b0) begin
                $display("[FAIL] LSU write enable should be 0 for store instruction");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  lsu_vld_d: %b", ifu_exu_lsu_vld_d);
            $display("  rs1_d (base): %0d", ifu_exu_rs1_d);
            $display("  rs2_d (src): %0d", ifu_exu_rs2_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: andi $r5,$r5,0x0
    // =============================
    task test_andi_r5_r5_0;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: andi $r5,$r5,0x0 (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_alu_vld_d !== 1'b1) begin
                $display("[FAIL] ALU instruction not detected");
                fail_count = fail_count + 1;
            end else if (ifu_exu_rd_d !== 5'b00101) begin
                $display("[FAIL] Destination register rd incorrect: %0d (expected 5)", ifu_exu_rd_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_rs1_d !== 5'b00101) begin
                $display("[FAIL] Source register rs1 incorrect: %0d (expected 5)", ifu_exu_rs1_d);
                fail_count = fail_count + 1;
            end else if (ifu_exu_alu_b_imm_d !== 1'b1) begin
                $display("[FAIL] Immediate operand flag not set");
                fail_count = fail_count + 1;
            end else if (ifu_exu_wen_d !== 1'b1) begin
                $display("[FAIL] Write enable flag not set");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  alu_vld_d: %b", ifu_exu_alu_vld_d);
            $display("  rd_d: %0d", ifu_exu_rd_d);
            $display("  rs1_d: %0d", ifu_exu_rs1_d);
            $display("  alu_b_imm_d: %b", ifu_exu_alu_b_imm_d);
            $display("  wen_d: %b", ifu_exu_wen_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Function: ertn (exception return)
    // =============================
    task test_ertn;
        input [31:0] expected_pc;
        input [31:0] inst;
        begin
            test_count = test_count + 1;
            $display("==========================================");
            $display("Test %0d: ertn (inst=0x%08h)", test_count, inst);
            $display("==========================================");
            
            // Set test inputs
            inst_vld_f   = 1;
            inst_addr_f  = expected_pc;
            inst_f       = inst;
            
            // Wait one clock cycle for signal propagation
            #10;
            
            // Check output signals
            if (ifu_exu_vld_d !== 1'b1) begin
                $display("[FAIL] Instruction valid at D stage");
                fail_count = fail_count + 1;
            end else if (ifu_exu_ertn_vld_d !== 1'b1) begin
                $display("[FAIL] ERTN instruction not detected");
                fail_count = fail_count + 1;
            end else if (dec_exc_vld_d !== 1'b0) begin
                $display("[FAIL] Unexpected exception detected");
                fail_count = fail_count + 1;
            end else begin
                $display("[PASS] All checks passed");
                pass_count = pass_count + 1;
            end
            
            // Display detailed information
            $display("Detailed results:");
            $display("  PC: 0x%08h", ifu_exu_pc_d);
            $display("  inst_vld_d: %b", ifu_exu_vld_d);
            $display("  ertn_vld_d: %b", ifu_exu_ertn_vld_d);
            $display("  exc_vld_d: %b", dec_exc_vld_d);
            $display("");
            
            // Clear input signals
            inst_vld_f = 0;
            #10;
        end
    endtask
    
    // =============================
    // Test Scheduler Task
    // =============================
    task run_all_tests;
        begin
            // Test 1: addi.w $r12,$r0,1
            test_addi_w_r12_r0_1(32'h8000_0000, 32'h0280040c);
            
            // Test 2: st.w $r7,$r6,0
            test_st_w_r7_r6_0(32'h8000_0004, 32'h298000c7);
            
            // Test 3: ld.w $r5,$r6,0
            test_ld_w_r5_r6_0(32'h8000_0008, 32'h288000c5);
            
            // Test 4: addi.w $r6,$r6,112
            test_addi_w_r6_r6_112(32'h8000_000c, 32'h0281c0c6);
            
            // Test 5: add.w $r8,$r8,$r8
            test_add_w_r8_r8_r8(32'h8000_0010, 32'h00102108);
            
            // Test 6: beq $r0,$r0,8
            test_beq_r0_r0_8(32'h8000_0014, 32'h58000800);
            
            // Test 7: bne $r8,$r7,8
            test_bne_r8_r7_8(32'h8000_0018, 32'h5c000907);
            
            // Test 8: jirl $r1,$r6,32
            test_jirl_r1_r6_32(32'h8000_001c, 32'h4c0020c1);
            
            // Test 9: mul.w $r5,$r3,$r4
            test_mul_w_r5_r3_r4(32'h8000_0020, 32'h001c1065);
            
            // Test 10: mulh.wu $r5,$r6,$r7
            test_mulh_wu_r5_r6_r7(32'h8000_0024, 32'h001d1cc5);
            
            // Test 11: mulh.wu $r5,$r3,$r4
            test_mulh_wu_r5_r3_r4(32'h8000_0028, 32'h001d1065);
            
            // Test 12: lu12i.w $r3,114688
            test_lu12i_w_r3_114688(32'h8000_002c, 32'h14380003);
            
            // Test 13: csrrd $r5,0x0
            test_csrrd_r5_0(32'h8000_0030, 32'h04000005);
            
            // Test 14: csrwr $r6,0xc
            test_csrwr_r6_c(32'h8000_0034, 32'h04003026);
            
            // Test 15: csrxchg $r5,$r7,0xc
            test_csrxchg_r5_r7_c(32'h8000_0038, 32'h040030e5);
            
            // Test 16: ld.b $r7,$r6,0
            test_ld_b_r7_r6_0(32'h8000_003c, 32'h280000c7);
            
            // Test 17: ld.bu $r7,$r6,0
            test_ld_bu_r7_r6_0(32'h8000_0040, 32'h2a0000c7);
            
            // Test 18: ld.h $r7,$r6,0
            test_ld_h_r7_r6_0(32'h8000_0044, 32'h284000c7);
            
            // Test 19: ld.hu $r7,$r6,0
            test_ld_hu_r7_r6_0(32'h8000_0048, 32'h2a4000c7);
            
            // Test 20: st.b $r7,$r6,0
            test_st_b_r7_r6_0(32'h8000_004c, 32'h290000c7);
            
            // Test 21: st.h $r7,$r6,0
            test_st_h_r7_r6_0(32'h8000_0050, 32'h294000c7);
            
            // Test 22: st.b $r7,$r6,1
            test_st_b_r7_r6_1(32'h8000_0054, 32'h290004c7);
            
            // Test 23: st.h $r7,$r6,2
            test_st_h_r7_r6_2(32'h8000_0058, 32'h294008c7);
            
            // Test 24: andi $r5,$r5,0x0
            test_andi_r5_r5_0(32'h8000_005c, 32'h034000a5);
            
            // Test 25: ertn
            test_ertn(32'h8000_0060, 32'h06483800);
            
            // Display final statistics
            display_statistics();
        end
    endtask
    
    // =============================
    // Display Statistics Information
    // =============================
    task display_statistics;
        begin
            $display("\n==========================================");
            $display("TEST SUMMARY");
            $display("==========================================");
            $display("Total tests:  %0d", test_count);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            
            if (fail_count == 0) begin
                $display("RESULT: ALL TESTS PASSED!");
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
                $display("RESULT: SOME TESTS FAILED!");
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
            $display("==========================================\n");
        end
    endtask
    
    // =============================
    // Main Test Flow
    // =============================
    initial begin
        // Initialize signals
        clk          = 0;
        resetn       = 0;
        stall        = 0;
        flush        = 0;
        inst_vld_f   = 0;
        inst_addr_f  = 32'h0;
        inst_f       = 32'h0;
        
        // Initialize statistics
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        // Wait for clock stabilization
        #10;
        
        // Release reset
        resetn = 1;
        $display("[INFO] Reset released at time %0t", $time);
        
        // Wait one clock cycle
        #10;
        
        // Run all tests
        run_all_tests();
        
        // End test
        #10;
        $display("[INFO] Testbench finished at time %0t", $time);
        $finish;
    end

endmodule
