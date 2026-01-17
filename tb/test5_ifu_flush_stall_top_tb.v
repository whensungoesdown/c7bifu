`timescale 1ns/1ps

module top_tb();

// ============================================
// Clock and Reset
// ============================================
reg clk;
reg resetn;

// ============================================
// ICU Interface
// ============================================
wire [31:0] ifu_icu_addr_ic1;
wire ifu_icu_req_ic1;
reg icu_ifu_ack_ic1;
reg icu_ifu_data_valid_ic2;
reg [63:0] icu_ifu_data_ic2;

// ============================================
// EXU Interface
// ============================================
reg exu_ifu_except;
reg [31:0] exu_ifu_isr_addr;
reg exu_ifu_branch;
reg [31:0] exu_ifu_brn_addr;
reg exu_ifu_ertn;
reg [31:0] exu_ifu_ert_addr;
reg exu_ifu_stall;

// Test control
integer test_count;
integer pass_count;
integer fail_count;
integer cycle_counter;

// Instruction stream tracking
integer expected_pc;
integer last_pc;
integer instruction_count;

// ============================================
// DUT Instantiation
// ============================================
c7bifu uut (
    .clk(clk),
    .resetn(resetn),
    
    // ICU interface
    .ifu_icu_addr_ic1(ifu_icu_addr_ic1),
    .ifu_icu_req_ic1(ifu_icu_req_ic1),
    .icu_ifu_ack_ic1(icu_ifu_ack_ic1),
    .icu_ifu_data_valid_ic2(icu_ifu_data_valid_ic2),
    .icu_ifu_data_ic2(icu_ifu_data_ic2),
    
    // EXU interface inputs
    .exu_ifu_except(exu_ifu_except),
    .exu_ifu_isr_addr(exu_ifu_isr_addr),
    .exu_ifu_branch(exu_ifu_branch),
    .exu_ifu_brn_addr(exu_ifu_brn_addr),
    .exu_ifu_ertn(exu_ifu_ertn),
    .exu_ifu_ert_addr(exu_ifu_ert_addr),
    .exu_ifu_stall(exu_ifu_stall),
    
    // EXU interface outputs
    .ifu_exu_vld_d(),
    .ifu_exu_pc_d(),
    .ifu_exu_rs1_d(),
    .ifu_exu_rs2_d(),
    .ifu_exu_rd_d(),
    .ifu_exu_wen_d(),
    .ifu_exu_imm_shifted_d(),
    
    // Other outputs (not used in this test)
    .ifu_exu_alu_vld_d(),
    .ifu_exu_alu_op_d(),
    .ifu_exu_alu_a_pc_d(),
    .ifu_exu_alu_c_d(),
    .ifu_exu_alu_double_word_d(),
    .ifu_exu_alu_b_imm_d(),
    .ifu_exu_lsu_vld_d(),
    .ifu_exu_lsu_op_d(),
    .ifu_exu_lsu_double_read_d(),
    .ifu_exu_bru_vld_d(),
    .ifu_exu_bru_op_d(),
    .ifu_exu_bru_offset_d(),
    .ifu_exu_mul_vld_d(),
    .ifu_exu_mul_signed_d(),
    .ifu_exu_mul_double_d(),
    .ifu_exu_mul_hi_d(),
    .ifu_exu_mul_short_d(),
    .ifu_exu_csr_vld_d(),
    .ifu_exu_csr_raddr_d(),
    .ifu_exu_csr_xchg_d(),
    .ifu_exu_csr_wen_d(),
    .ifu_exu_csr_waddr_d(),
    .ifu_exu_ertn_vld_d(),
    .ifu_exu_exc_vld_d(),
    .ifu_exu_exc_code_d()
);

// ============================================
// Clock Generation
// ============================================
always #5 clk = ~clk;

// ============================================
// ICU Behavior Model
// ============================================
reg [63:0] icu_memory [0:1023]; // 1KB memory for testing

// Initialize ICU memory with test instructions
initial begin
    // Fill memory with sequential instructions
    // Each 64-bit word contains two 32-bit instructions
    // Addresses are 8-byte aligned (64-bit)
    icu_memory[0] = 64'h00108093_00210113; // addr 0x1c000000: addi x1, x0, 1; addi x2, x2, 2
    icu_memory[1] = 64'h00318193_00420213; // addr 0x1c000008: addi x3, x3, 3; addi x4, x4, 4
    icu_memory[2] = 64'h00528293_00630313; // addr 0x1c000010: addi x5, x5, 5; addi x6, x6, 6
    icu_memory[3] = 64'h00738393_00840413; // addr 0x1c000018: addi x7, x7, 7; addi x8, x8, 8
    icu_memory[4] = 64'h00948493_00A50513; // addr 0x1c000020: addi x9, x9, 9; addi x10, x10, 10
    icu_memory[5] = 64'h00B58593_00C60613; // addr 0x1c000028: addi x11, x11, 11; addi x12, x12, 12
    
    // Branch target addresses (specific addresses for testing)
    icu_memory[32'h1c000008 >> 3] = 64'h00D68693_00E70713; // branch target: addi x13, x13, 13; addi x14, x14, 14
    icu_memory[32'h1c000010 >> 3] = 64'h00F78793_01080813; // ISR: addi x15, x15, 15; addi x16, x16, 16
    icu_memory[32'h1c000018 >> 3] = 64'h01188893_01290913; // ERT: addi x17, x17, 17; addi x18, x18, 18
    icu_memory[32'h1c000020 >> 3] = 64'h01398993_014A0A13; // branch after stall: addi x19, x19, 19; addi x20, x20, 20
    
    // Continue sequential instructions
    icu_memory[6] = 64'h015A8A93_016B0B13; // addr 0x1c000030
    icu_memory[7] = 64'h017B8B93_018C0C13; // addr 0x1c000038
    icu_memory[8] = 64'h019C8C93_01AD0D13; // addr 0x1c000040
end

// ICU response process - simplified
reg [1:0] icu_state;
reg [63:0] icu_data_to_send;

always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        icu_ifu_ack_ic1 <= 1'b0;
        icu_ifu_data_valid_ic2 <= 1'b0;
        icu_ifu_data_ic2 <= 64'h0;
        icu_state <= 2'b00;
    end
    else begin
        // Default values
        icu_ifu_ack_ic1 <= 1'b0;
        icu_ifu_data_valid_ic2 <= 1'b0;
        
        case (icu_state)
            2'b00: begin // Idle - wait for request
                if (ifu_icu_req_ic1) begin
                    // Send ACK immediately
                    icu_ifu_ack_ic1 <= 1'b1;
                    // Get data from memory
                    if (ifu_icu_addr_ic1[31:3] < 1024) begin
                        icu_data_to_send <= icu_memory[ifu_icu_addr_ic1[31:3]];
                    end
                    else begin
                        icu_data_to_send <= 64'h0;
                    end
                    icu_state <= 2'b01;
                end
            end
            
            2'b01: begin // Send data on next cycle
                icu_ifu_data_valid_ic2 <= 1'b1;
                icu_ifu_data_ic2 <= icu_data_to_send;
                icu_state <= 2'b10;
            end
            
            2'b10: begin // Wait one cycle before next request
                icu_state <= 2'b00;
            end
            
            default: begin
                icu_state <= 2'b00;
            end
        endcase
    end
end

// ============================================
// Test Procedures
// ============================================

// Initialize signals
task init_signals;
begin
    exu_ifu_except = 1'b0;
    exu_ifu_isr_addr = 32'h0;
    exu_ifu_branch = 1'b0;
    exu_ifu_brn_addr = 32'h0;
    exu_ifu_ertn = 1'b0;
    exu_ifu_ert_addr = 32'h0;
    exu_ifu_stall = 1'b0;
    expected_pc = 32'h1c000000;
    last_pc = -1;
    instruction_count = 0;
end
endtask

// Reset DUT
task reset_dut;
begin
    resetn = 1'b0;
    repeat(4) @(posedge clk);
    resetn = 1'b1;
    repeat(2) @(posedge clk);
    expected_pc = 32'h1c000000;
    last_pc = -1;
    instruction_count = 0;
end
endtask

// Advance n cycles
task advance_cycles;
    input integer n;
    integer i;
begin
    for (i = 0; i < n; i = i + 1) begin
        @(posedge clk);
        cycle_counter = cycle_counter + 1;
    end
end
endtask

// Check test result
task check_test_result;
    input integer test_passed;
    input [8*80:1] test_name;
begin
    test_count = test_count + 1;
    if (test_passed) begin
        $display("  [PASS] %s", test_name);
        pass_count = pass_count + 1;
    end
    else begin
        $display("  [FAIL] %s", test_name);
        fail_count = fail_count + 1;
    end
end
endtask

// Check instruction stream continuity
task check_instruction_stream;
    input integer current_pc;
    input integer is_branch;
begin
    if (last_pc >= 0 && !is_branch) begin
        // Check PC increments by 4 for sequential execution
        if (current_pc !== last_pc + 4) begin
            $display("    ERROR: PC discontinuity! Last PC=%h, Current PC=%h", last_pc, current_pc);
        end
    end
    last_pc = current_pc;
    instruction_count = instruction_count + 1;
end
endtask

// ============================================
// Test 1: Normal fetch (no stall, no flush)
// ============================================
task test_normal_fetch;
    integer vld_count;
    integer test_passed;
    integer start_cycle;
    integer timeout_flag;
    integer i;
    integer continue_loop;
    integer stream_ok;
begin
    $display("\n=== Test 1: Normal Fetch Operation ===");
    $display("Cycle: %0d", cycle_counter);
    
    // Setup
    init_signals;
    reset_dut;
    
    $display("  Waiting for IFU to start fetching...");
    
    // Wait for first request with timeout
    start_cycle = cycle_counter;
    timeout_flag = 0;
    continue_loop = 1;
    
    // Simple timeout loop - Verilog-2001 style
    i = 0;
    while (continue_loop && i < 30) begin
        if (ifu_icu_req_ic1 === 1'b1) begin
            continue_loop = 0;
        end
        else begin
            advance_cycles(1);
            i = i + 1;
        end
    end
    
    if (ifu_icu_req_ic1 === 1'b1) begin
        $display("  IFU request detected at cycle %0d, addr=%h", cycle_counter, ifu_icu_addr_ic1);
        
        // Monitor valid signals for several cycles
        vld_count = 0;
        stream_ok = 1;
        for (i = 0; i < 20; i = i + 1) begin
            advance_cycles(1);
            if (uut.ifu_exu_vld_d === 1'b1) begin
                vld_count = vld_count + 1;
                $display("    Cycle %0d: Instruction valid, PC=%h", cycle_counter, uut.ifu_exu_pc_d);
                // Check instruction stream continuity
                check_instruction_stream(uut.ifu_exu_pc_d, 0);
            end
        end
        
        // Check results - should get valid instructions
        test_passed = (vld_count > 0) ? 1 : 0;
        check_test_result(test_passed, "normal_fetch: Should get valid instructions");
        
        // Check that ICU protocol worked
        //test_passed = (icu_ifu_ack_ic1 === 1'b1 || icu_ifu_data_valid_ic2 === 1'b1) ? 1 : 0;
        //check_test_result(test_passed, "normal_fetch: ICU should respond with ACK and data");
        
        // Check instruction count
        $display("  Total instructions fetched: %0d", instruction_count);
        test_passed = (instruction_count >= 4) ? 1 : 0; // Should fetch at least 4 instructions
        check_test_result(test_passed, "normal_fetch: Should fetch multiple instructions");
    end
    else begin
        $display("  ERROR: No IFU request after 30 cycles");
        check_test_result(0, "normal_fetch: IFU should make request");
    end
    
    advance_cycles(5);
end
endtask

// ============================================
// Test 2: Stall operation with sequential stream
// ============================================
task test_stall_operation;
    integer vld_count;
    integer test_passed;
    integer i;
    integer instructions_before_stall;
    integer instructions_during_stall;
    integer instructions_after_stall;
    integer pc_before_stall;
    integer pc_after_stall;
begin
    $display("\n=== Test 2: Stall Operation with Sequential Stream ===");
    $display("Cycle: %0d", cycle_counter);
    
    // Setup
    init_signals;
    reset_dut;
    
    // Let IFU start normally
    advance_cycles(5);
    
    // Count instructions before stall
    instructions_before_stall = 0;
    pc_before_stall = -1;
    for (i = 0; i < 5; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            instructions_before_stall = instructions_before_stall + 1;
            pc_before_stall = uut.ifu_exu_pc_d;
            $display("  Before stall: Instruction %0d, PC=%h", instructions_before_stall, pc_before_stall);
        end
    end
    
    // Apply stall
    exu_ifu_stall = 1'b1;
    $display("  Stall applied at cycle %0d", cycle_counter);
    $display("  Last PC before stall: %h", pc_before_stall);
    
    // Monitor during stall - should get NO valid instructions
    instructions_during_stall = 0;
    for (i = 0; i < 8; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            instructions_during_stall = instructions_during_stall + 1;
            $display("    Cycle %0d: Got valid during stall (UNEXPECTED!), PC=%h", 
                     cycle_counter, uut.ifu_exu_pc_d);
        end
    end
    
    // Check no valids during stall
    test_passed = (instructions_during_stall === 0) ? 1 : 0;
    check_test_result(test_passed, "stall_block: No valid instructions during stall");
    
    // Release stall
    exu_ifu_stall = 1'b0;
    $display("  Stall released at cycle %0d", cycle_counter);
    
    // Wait a bit for pipeline to clear
    //advance_cycles(2);
    
    // Check that requests resume
    //test_passed = (ifu_icu_req_ic1 === 1'b1) ? 1 : 0;
    //check_test_result(test_passed, "stall_recovery: Request should resume after stall");
    
    // Check sequential continuation after stall
    instructions_after_stall = 0;
    pc_after_stall = -1;
    for (i = 0; i < 10; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            instructions_after_stall = instructions_after_stall + 1;
            pc_after_stall = uut.ifu_exu_pc_d;
            $display("  After stall: Instruction %0d, PC=%h", 
                     instructions_after_stall, pc_after_stall);
            // Check that PC continues sequentially from before stall
            if (pc_before_stall >= 0 && instructions_after_stall == 1) begin
                test_passed = (pc_after_stall === pc_before_stall + 4) ? 1 : 0;
                check_test_result(test_passed, "stall_continuity: PC should continue sequentially after stall");
            end
        end
    end
    
    // Check we got instructions after stall
    test_passed = (instructions_after_stall > 0) ? 1 : 0;
    check_test_result(test_passed, "stall_resume: Should get instructions after stall release");
    
    advance_cycles(5);
end
endtask

// ============================================
// Test 3: Branch flush with stream check
// ============================================
task test_branch_flush;
    integer test_passed;
    reg [31:0] expected_addr;
    integer initial_addr;
    integer i;
    integer instructions_before_branch;
    integer instructions_after_branch;
    integer first_pc_after_branch;
begin
    $display("\n=== Test 3: Branch Flush Operation with Stream Check ===");
    $display("Cycle: %0d", cycle_counter);
    
    // Setup
    init_signals;
    reset_dut;
    expected_addr = 32'h1c000090;
    
    // Let IFU start fetching
    advance_cycles(3);
    initial_addr = ifu_icu_addr_ic1;
    $display("  Initial fetch address: %h", initial_addr);
    
    // Get a few instructions before branch
    instructions_before_branch = 0;
    for (i = 0; i < 5; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            instructions_before_branch = instructions_before_branch + 1;
            $display("  Before branch: Instruction %0d, PC=%h", 
                     instructions_before_branch, uut.ifu_exu_pc_d);
        end
    end
    
    // Apply branch flush
    exu_ifu_branch = 1'b1;
    exu_ifu_brn_addr = expected_addr;
    $display("  Branch flush at cycle %0d, target=%h", cycle_counter, expected_addr);
    
    advance_cycles(1);
    exu_ifu_branch = 1'b0;
    
    // Wait for address to update
    //advance_cycles(3);
    
    // Check address updated
    test_passed = (ifu_icu_addr_ic1 === expected_addr) ? 1 : 0;
    check_test_result(test_passed, "branch_flush: Address should update to branch target");
    
    // Wait for ICU to respond to new address
    //advance_cycles(5);
    
    // Check instructions from branch target
    instructions_after_branch = 0;
    first_pc_after_branch = -1;
    for (i = 0; i < 8; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            instructions_after_branch = instructions_after_branch + 1;
            if (first_pc_after_branch < 0) begin
                first_pc_after_branch = uut.ifu_exu_pc_d;
            end
            $display("  After branch: Instruction %0d, PC=%h", 
                     instructions_after_branch, uut.ifu_exu_pc_d);
        end
    end
    
    // Check we got instructions from branch target
    test_passed = (instructions_after_branch > 0) ? 1 : 0;
    check_test_result(test_passed, "branch_flush: Should get instructions from branch target");
    
    // Check first PC after branch matches target
    if (first_pc_after_branch >= 0) begin
        test_passed = (first_pc_after_branch === expected_addr) ? 1 : 0;
        check_test_result(test_passed, "branch_stream: First instruction should be at branch target");
    end
    
    advance_cycles(5);
end
endtask

// ============================================
// Test 4: Exception flush with stream check
// ============================================
task test_exception_flush;
    integer test_passed;
    reg [31:0] expected_addr;
    integer i;
    integer instructions_after_exception;
    integer first_pc_after_exception;
begin
    $display("\n=== Test 4: Exception Flush Operation with Stream Check ===");
    $display("Cycle: %0d", cycle_counter);
    
    // Setup
    init_signals;
    reset_dut;
    expected_addr = 32'h1c000100;
    
    // Let IFU start
    advance_cycles(1);
    
    // Get a few instructions before exception
    for (i = 0; i < 5; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            $display("  Before exception: PC=%h", uut.ifu_exu_pc_d);
        end
    end
    
    // Apply exception flush
    exu_ifu_except = 1'b1;
    exu_ifu_isr_addr = expected_addr;
    $display("  Exception flush at cycle %0d, ISR=%h", cycle_counter, expected_addr);
    
    advance_cycles(1);
    exu_ifu_except = 1'b0;
    
    // Wait for address to update
    //advance_cycles(3);
    
    // Check address updated
    test_passed = (ifu_icu_addr_ic1 === expected_addr) ? 1 : 0;
    check_test_result(test_passed, "exception_flush: Address should update to ISR address");
    
    // Check instructions from ISR
    instructions_after_exception = 0;
    first_pc_after_exception = -1;
    for (i = 0; i < 10; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            instructions_after_exception = instructions_after_exception + 1;
            if (first_pc_after_exception < 0) begin
                first_pc_after_exception = uut.ifu_exu_pc_d;
            end
            $display("  After exception: Instruction %0d, PC=%h", 
                     instructions_after_exception, uut.ifu_exu_pc_d);
        end
    end
    
    // Check we got instructions from ISR
    test_passed = (instructions_after_exception > 0) ? 1 : 0;
    check_test_result(test_passed, "exception_flush: Should get instructions from ISR");
    
    // Check first PC after exception matches ISR address
    if (first_pc_after_exception >= 0) begin
        test_passed = (first_pc_after_exception === expected_addr) ? 1 : 0;
        check_test_result(test_passed, "exception_stream: First instruction should be at ISR address");
    end
    
    advance_cycles(5);
end
endtask

// ============================================
// Test 5: ERTN flush with stream check
// ============================================
task test_ertn_flush;
    integer test_passed;
    reg [31:0] expected_addr;
    integer i;
    integer instructions_after_ertn;
    integer first_pc_after_ertn;
begin
    $display("\n=== Test 5: ERTN Flush Operation with Stream Check ===");
    $display("Cycle: %0d", cycle_counter);
    
    // Setup
    init_signals;
    reset_dut;
    expected_addr = 32'h1c000200;
    
    //advance_cycles(5);
    
    // Get a few instructions before ERTN
    for (i = 0; i < 8; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            $display("  Before ERTN: PC=%h", uut.ifu_exu_pc_d);
        end
    end
    
    // Apply ERTN flush
    exu_ifu_ertn = 1'b1;
    exu_ifu_ert_addr = expected_addr;
    $display("  ERTN flush at cycle %0d, ERT=%h", cycle_counter, expected_addr);
    
    advance_cycles(1);
    exu_ifu_ertn = 1'b0;
    
    // Wait for address to update
    //advance_cycles(3);
    
    // Check address updated
    test_passed = (ifu_icu_addr_ic1 === expected_addr) ? 1 : 0;
    check_test_result(test_passed, "ertn_flush: Address should update to ERT address");
    
    // Check instructions from ERT
    instructions_after_ertn = 0;
    first_pc_after_ertn = -1;
    for (i = 0; i < 10; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            instructions_after_ertn = instructions_after_ertn + 1;
            if (first_pc_after_ertn < 0) begin
                first_pc_after_ertn = uut.ifu_exu_pc_d;
            end
            $display("  After ERTN: Instruction %0d, PC=%h", 
                     instructions_after_ertn, uut.ifu_exu_pc_d);
        end
    end
    
    // Check we got instructions from ERT
    test_passed = (instructions_after_ertn > 0) ? 1 : 0;
    check_test_result(test_passed, "ertn_flush: Should get instructions from ERT");
    
    // Check first PC after ERTN matches ERT address
    if (first_pc_after_ertn >= 0) begin
        test_passed = (first_pc_after_ertn === expected_addr) ? 1 : 0;
        check_test_result(test_passed, "ertn_stream: First instruction should be at ERT address");
    end
    
    advance_cycles(5);
end
endtask

// ============================================
// Test 6: Combined stall and flush with stream
// ============================================
task test_combined_stall_flush;
    integer test_passed;
    reg [31:0] except_target;
    integer initial_addr;
    integer i;
    integer instructions_before_stall;
    integer instructions_during_stall;
    integer instructions_after_release;
    integer first_pc_after_release;
begin
    $display("\n=== Test 6: Combined Stall and Flush with Stream Check ===");
    $display("Cycle: %0d", cycle_counter);
    
    // Setup
    init_signals;
    reset_dut;
    except_target = 32'h1c000300;
    
    // Let IFU start
    advance_cycles(1);
    initial_addr = ifu_icu_addr_ic1;
    $display("  Initial address: %h", initial_addr);
    
    // Get some instructions before stall
    instructions_before_stall = 0;
    for (i = 0; i < 7; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            instructions_before_stall = instructions_before_stall + 1;
            $display("  Before stall: Instruction %0d, PC=%h", 
                     instructions_before_stall, uut.ifu_exu_pc_d);
        end
    end
    
    // Apply stall
    exu_ifu_stall = 1'b1;
    $display("  Stall applied at cycle %0d", cycle_counter);
    
    advance_cycles(2);
    
    // Apply exception flush while stalled
    exu_ifu_except = 1'b1;
    exu_ifu_isr_addr = except_target;
    $display("  Except flush while stalled at cycle %0d", cycle_counter);
    
    advance_cycles(1);
    exu_ifu_except = 1'b0;
    
    // Monitor during stall - should get NO valid instructions
    instructions_during_stall = 0;
    for (i = 0; i < 4; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            instructions_during_stall = instructions_during_stall + 1;
            $display("    ERROR: Got valid during stall+flush, PC=%h", uut.ifu_exu_pc_d);
        end
    end
    
    // Check no valids during stall+flush
    test_passed = (instructions_during_stall === 0) ? 1 : 0;
    check_test_result(test_passed, "stall_flush_combined: No valids during stall+flush");
    
    // Release stall
    exu_ifu_stall = 1'b0;
    $display("  Stall released at cycle %0d", cycle_counter);
    
    // Wait for address to update
    //advance_cycles(3);
   
    // During stall, fetch is still going on, it should fetch address after
    // except target already. 
    // Check address updated to branch target
    test_passed = (ifu_icu_addr_ic1 >= except_target) ? 1 : 0;
    check_test_result(test_passed, "combined_addr: Should fetch from except target even during stall.");
    
    // Check instructions from branch target
    instructions_after_release = 0;
    first_pc_after_release = -1;
    for (i = 0; i < 10; i = i + 1) begin
        advance_cycles(1);
        if (uut.ifu_exu_vld_d === 1'b1) begin
            instructions_after_release = instructions_after_release + 1;
            if (first_pc_after_release < 0) begin
                first_pc_after_release = uut.ifu_exu_pc_d;
            end
            $display("  After release: Instruction %0d, PC=%h", 
                     instructions_after_release, uut.ifu_exu_pc_d);
        end
    end
    
    // Check we got instructions after release
    test_passed = (instructions_after_release > 0) ? 1 : 0;
    check_test_result(test_passed, "combined_resume: Should get instructions after stall release");
    
    // Check first PC after release matches except target
    if (first_pc_after_release >= 0) begin
        test_passed = (first_pc_after_release === except_target) ? 1 : 0;
        check_test_result(test_passed, "combined_stream: First instruction should be at except target");
    end
    
    advance_cycles(5);
end
endtask

// ============================================
// Main Test Sequence
// ============================================
initial begin
    // Initialize
    clk = 1'b0;
    test_count = 0;
    pass_count = 0;
    fail_count = 0;
    cycle_counter = 0;
    
    $display("\n==========================================");
    $display("Starting c7bifu Stall/Flush Tests");
    $display("With instruction stream checking");
    $display("==========================================\n");
    
    // Wait a bit
    #10;
    
    // Run all tests
//    test_normal_fetch;
//    test_stall_operation;
//    test_branch_flush;
//    test_exception_flush;
//    test_ertn_flush;
    test_combined_stall_flush;
    
    // Summary
    $display("\n==========================================");
    $display("Test Summary");
    $display("==========================================");
    $display("Total Tests:  %0d", test_count);
    $display("Passed:       %0d", pass_count);
    $display("Failed:       %0d", fail_count);
    $display("Total Cycles: %0d", cycle_counter);
    
    if (fail_count == 0) begin
        $display("\nSUCCESS: All tests PASSED!");
    end
    else begin
        $display("\nFAILURE: %0d test(s) FAILED!", fail_count);
    end
    
    $display("==========================================\n");
    
    // Finish
    #100 $finish;
end

// ============================================
// Simple Monitor
// ============================================
always @(posedge clk) begin
    if (resetn === 1'b1 && cycle_counter > 0) begin
        $display("MONITOR[%0d]: vld=%b, req=%b, ack=%b, data_vld=%b, stall=%b, addr=%h",
                 cycle_counter, uut.ifu_exu_vld_d, ifu_icu_req_ic1, icu_ifu_ack_ic1,
                 icu_ifu_data_valid_ic2, exu_ifu_stall, ifu_icu_addr_ic1);
    end
end

endmodule
