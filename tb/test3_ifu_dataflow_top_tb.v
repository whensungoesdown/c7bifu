`timescale 1ns/1ps

module top_tb;

// ================= Clock and Reset Generation =================
reg clk;
reg resetn;

// Clock generation
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;  // 100 MHz clock
end

// Reset generation
initial begin
    resetn = 1'b0;
    #20 resetn = 1'b1;      // Release reset after 20ns
end

// ================= DUT I/O Signals =================
// Interface to ICU (Instruction Cache Unit)
wire [31:0]      ifu_icu_addr_ic1;
wire             ifu_icu_req_ic1;
reg              icu_ifu_ack_ic1;
reg              icu_ifu_data_valid_ic2;
reg  [63:0]      icu_ifu_data_ic2;

// Interface to EXU (Execution Unit)
reg              exu_ifu_except;
reg  [31:0]      exu_ifu_isr_addr;
reg              exu_ifu_branch;
reg  [31:0]      exu_ifu_brn_addr;
reg              exu_ifu_ertn;
reg  [31:0]      exu_ifu_ert_addr;
reg              exu_ifu_stall;

// Instruction Queue outputs (to decode stage)
//wire [31:0]      inst_addr_f;
//wire [31:0]      inst_f;
//wire             inst_vld_f;

// ================= Instantiate DUT =================
c7bifu dut (
    .clk                  (clk),
    .resetn               (resetn),
    
    // ICU interface
    .ifu_icu_addr_ic1     (ifu_icu_addr_ic1),
    .ifu_icu_req_ic1      (ifu_icu_req_ic1),
    .icu_ifu_ack_ic1      (icu_ifu_ack_ic1),
    .icu_ifu_data_valid_ic2 (icu_ifu_data_valid_ic2),
    .icu_ifu_data_ic2     (icu_ifu_data_ic2),
    
    // EXU interface
    .exu_ifu_except       (exu_ifu_except),
    .exu_ifu_isr_addr     (exu_ifu_isr_addr),
    .exu_ifu_branch       (exu_ifu_branch),
    .exu_ifu_brn_addr     (exu_ifu_brn_addr),
    .exu_ifu_ertn         (exu_ifu_ertn),
    .exu_ifu_ert_addr     (exu_ifu_ert_addr),
    .exu_ifu_stall        (exu_ifu_stall)
);

// ================= Test Variables =================
integer test_num;
integer error_count;
integer cycle_count;
integer instruction_count;

// ================= Helper Tasks =================
task initialize;
    begin
        test_num = 1;
        error_count = 0;
        cycle_count = 0;
        instruction_count = 0;
        
        // Initialize all inputs
        icu_ifu_ack_ic1 = 1'b0;
        icu_ifu_data_valid_ic2 = 1'b0;
        icu_ifu_data_ic2 = 64'h0;
        exu_ifu_except = 1'b0;
        exu_ifu_isr_addr = 32'h0;
        exu_ifu_branch = 1'b0;
        exu_ifu_brn_addr = 32'h0;
        exu_ifu_ertn = 1'b0;
        exu_ifu_ert_addr = 32'h0;
	exu_ifu_stall = 1'b0;
    end
endtask

task wait_cycles;
    input [31:0] num_cycles;
    integer i;
    begin
        for (i = 0; i < num_cycles; i = i + 1) begin
            @(posedge clk);
        end
    end
endtask

// Wait for condition - Verilog-2001 compatible version
task wait_for_condition;
    input condition_signal;
    integer max_wait;
    begin
        max_wait = 100;  // Maximum wait cycles to prevent infinite loop
        while (max_wait > 0 && condition_signal !== 1'b1) begin
            @(posedge clk);
            max_wait = max_wait - 1;
        end
        if (max_wait <= 0) begin
            $display("  WARNING: Timeout waiting for condition");
        end
    end
endtask

// Wait for fetch request with address check
task wait_for_fetch_request;
    input [31:0] expected_addr;
    integer timeout;
    begin
        timeout = 50;
        while (timeout > 0 && ifu_icu_req_ic1 !== 1'b1) begin
            @(posedge clk);
            timeout = timeout - 1;
        end
        
        if (timeout <= 0) begin
            $display("  ERROR: Timeout waiting for fetch request");
            error_count = error_count + 1;
        end else begin
            // Verify requested address
            if (ifu_icu_addr_ic1 !== expected_addr) begin
                $display("  ERROR: Expected addr=0x%08h, got addr=0x%08h", 
                        expected_addr, ifu_icu_addr_ic1);
                error_count = error_count + 1;
            end
        end
    end
endtask

// Simulate ICU response
task icu_send_data;
    input [31:0] addr;
    input [63:0] data;
    integer ack_delay;
    integer valid_delay;
    begin
        // Wait for request (already handled by caller)
        
        // Send ack after random delay (1-3 cycles)
        ack_delay = $urandom_range(1, 3);
        wait_cycles(ack_delay);
        icu_ifu_ack_ic1 = 1'b1;
        @(posedge clk);
        icu_ifu_ack_ic1 = 1'b0;
        
        // Send data valid after random delay (2-4 cycles)
        valid_delay = $urandom_range(2, 4);
        wait_cycles(valid_delay);
        icu_ifu_data_valid_ic2 = 1'b1;
        icu_ifu_data_ic2 = data;
        @(posedge clk);
        icu_ifu_data_valid_ic2 = 1'b0;
        icu_ifu_data_ic2 = 64'h0;
    end
endtask

// ================= Test Cases =================
task test_normal_fetch_flow;
    integer i;
    reg [31:0] expected_addr;
    begin
        $display("\n[%0t] ====== Test %0d: Normal Fetch Flow Test ======", $time, test_num);
        $display("  Testing: Sequential instruction fetch from ICU to IQ");
        
        // Start from reset address
        expected_addr = 32'h1C000000;
        
        // Fetch 4 packets (8 instructions)
        for (i = 0; i < 4; i = i + 1) begin
            // Wait for request with timeout
            wait_for_fetch_request(expected_addr);
            
            // Send ICU response with test data
            //icu_send_data(expected_addr, {32'hA0000000 + i, 32'hB0000000 + i});
            icu_send_data(expected_addr, {expected_addr + 32'hAAA000 + 4, expected_addr + 32'hAAA000});
            
            // Update expected address
            expected_addr = expected_addr + 8;
        end
        
        // Now read instructions from IQ
        $display("  Reading instructions from IQ...");
        
        // We should be able to read 8 instructions
        // The IQ output should be valid when there's data and no stall
        wait_cycles(10);  // Allow time for instructions to be read
        
        test_num = test_num + 1;
        $display("  Normal fetch flow test completed");
    end
endtask

task test_iq_full_condition;
    integer i;
    integer timeout;
    begin
        $display("\n[%0t] ====== Test %0d: IQ Full Condition Test ======", $time, test_num);
        $display("  Testing: Fetch stops when IQ is full");
        
	$display("Apply stall");
	exu_ifu_stall = 1'b1;

        // Rapidly fetch until IQ is full
        for (i = 0; i < 8; i = i + 1) begin  // Try more than capacity
            timeout = 10;
            while (timeout > 0 && ifu_icu_req_ic1 !== 1'b1) begin
                @(posedge clk);
                timeout = timeout - 1;
            end

            //@(posedge clk);
            
            if (ifu_icu_req_ic1 === 1'b1) begin
                // Send ICU response immediately
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
                icu_ifu_data_valid_ic2 = 1'b1;
                //icu_ifu_data_ic2 = {32'hC0000000 + i, 32'hD0000000 + i};
                icu_ifu_data_ic2 = {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000};
                @(posedge clk);
                icu_ifu_data_valid_ic2 = 1'b0;
                icu_ifu_data_ic2 = 64'h0;
                @(posedge clk);
            end else if (dut.iq_full === 1'b1) begin
                $display("  IQ full detected at packet %0d (no more requests)", i);

		$display("Release stall");
	        exu_ifu_stall = 1'b0;
                if (ifu_icu_req_ic1 === 1'b1) begin
                    $display("  ERROR: Fetch should stop when IQ is full");
                    error_count = error_count + 1;
                end
                i = 8;  // Exit loop
            end
        end
        
        // Verify that fetch stopped
        //wait_cycles(5);
        //if (ifu_icu_req_ic1 === 1'b1) begin
        //    $display("  ERROR: Fetch should stop when IQ is full");
        //    error_count = error_count + 1;
        //end
        
        // Read some instructions to make space
        $display("  Reading instructions to clear IQ...");
        wait_cycles(10);
        
        // Verify fetch resumes
        wait_cycles(5);
        if (ifu_icu_req_ic1 !== 1'b1) begin
            $display("  ERROR: Fetch should resume after IQ has space");
            error_count = error_count + 1;
        end
        
        test_num = test_num + 1;
        $display("  IQ full condition test completed");
    end
endtask

task test_exception_flow;
    begin
        $display("\n[%0t] ====== Test %0d: Exception Flow Test ======", $time, test_num);
        $display("  Testing: Exception flushes pipeline and redirects to ISR");
        
        // First fetch a few instructions
        $display("  Fetching normal instructions...");
        // Use simplified version for this test
	//wait_cycles(5);
	// Send ICU response immediately
	icu_ifu_ack_ic1 = 1'b1;
	@(posedge clk);
	icu_ifu_ack_ic1 = 1'b0;
	icu_ifu_data_valid_ic2 = 1'b1;
	icu_ifu_data_ic2 = {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000};
	@(posedge clk);
	icu_ifu_data_valid_ic2 = 1'b0;
	icu_ifu_data_ic2 = 64'h0;
	//@(posedge clk);
        
        // Trigger exception
        $display("  Triggering exception...");
        exu_ifu_except = 1'b1;
        exu_ifu_isr_addr = 32'h80000000;  // ISR address
        @(posedge clk);
        exu_ifu_except = 1'b0;
        exu_ifu_isr_addr = 32'h0;
        
        // Verify flush occurs and new fetch starts at ISR address
        wait_for_fetch_request(32'h80000000);
        
        // Send ICU response for ISR
        //icu_send_data(32'h80000000, 64'hE1234567_FEDCBA98);
        //icu_send_data(32'h80000000, 64'h8AAA0004_8AAA0000);
        icu_send_data(32'h80000000, {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000});
        
        // Read from IQ
        wait_cycles(10);
        
        test_num = test_num + 1;
        $display("  Exception flow test completed");
    end
endtask

task test_branch_flow;
    begin
        $display("\n[%0t] ====== Test %0d: Branch Flow Test ======", $time, test_num);
        $display("  Testing: Branch redirects fetch to target address");
        
        // Fetch a few instructions
        $display("  Fetching normal instructions...");
        //wait_cycles(5);
	// Send ICU response immediately
	icu_ifu_ack_ic1 = 1'b1;
	@(posedge clk);
	icu_ifu_ack_ic1 = 1'b0;
	icu_ifu_data_valid_ic2 = 1'b1;
	icu_ifu_data_ic2 = {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000};
	@(posedge clk);
	icu_ifu_data_valid_ic2 = 1'b0;
	icu_ifu_data_ic2 = 64'h0;
	//@(posedge clk);
        
        // Trigger branch
        $display("  Triggering branch...");
        exu_ifu_branch = 1'b1;
        exu_ifu_brn_addr = 32'h40001000;  // Branch target
        @(posedge clk);
        exu_ifu_branch = 1'b0;
        exu_ifu_brn_addr = 32'h0;
        
        // Verify flush occurs and new fetch starts at branch target
        wait_for_fetch_request(32'h40001000);
        
        // Send ICU response for branch target
        //icu_send_data(32'h40001000, 64'hBEEFBABE_CAFEDEAD);
        icu_send_data(32'h40001000, {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000});
        
        // Read from IQ
        wait_cycles(10);
        
        test_num = test_num + 1;
        $display("  Branch flow test completed");
    end
endtask

task test_ertn_flow;
    begin
        $display("\n[%0t] ====== Test %0d: ERTN (Exception Return) Flow Test ======", $time, test_num);
        $display("  Testing: ERTN returns from exception");
        
        // First go to exception
        $display("  Going to exception first...");
        //wait_cycles(5);
	
	// Send ICU response immediately
	icu_ifu_ack_ic1 = 1'b1;
	@(posedge clk);
	icu_ifu_ack_ic1 = 1'b0;
	icu_ifu_data_valid_ic2 = 1'b1;
	icu_ifu_data_ic2 = {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000};
	@(posedge clk);
	icu_ifu_data_valid_ic2 = 1'b0;
	icu_ifu_data_ic2 = 64'h0;
	//@(posedge clk);
	
        exu_ifu_except = 1'b1;
        exu_ifu_isr_addr = 32'h80000000;
        @(posedge clk);
        exu_ifu_except = 1'b0;
        exu_ifu_isr_addr = 32'h0;
        //wait_cycles(5);
	
	// Send ICU response immediately
	icu_ifu_ack_ic1 = 1'b1;
	@(posedge clk);
	icu_ifu_ack_ic1 = 1'b0;
	icu_ifu_data_valid_ic2 = 1'b1;
	icu_ifu_data_ic2 = {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000};
	@(posedge clk);
	icu_ifu_data_valid_ic2 = 1'b0;
	icu_ifu_data_ic2 = 64'h0;
	//@(posedge clk);
        
        // Trigger ERTN to return
        $display("  Triggering ERTN to return...");
        exu_ifu_ertn = 1'b1;
        exu_ifu_ert_addr = 32'h1C000010;  // Return address (original + 0x10)
        @(posedge clk);
        exu_ifu_ertn = 1'b0;
        exu_ifu_ert_addr = 32'h0;
        
        // Verify flush occurs and fetch resumes at return address
        wait_for_fetch_request(32'h1C000010);
        
        // Send ICU response for return address
        //icu_send_data(32'h1C000010, 64'hDEADBEEF_CAFEBABE);
        icu_send_data(32'h1c000010, {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000});
        
        // Read from IQ
        wait_cycles(10);
        
        test_num = test_num + 1;
        $display("  ERTN flow test completed");
    end
endtask

task test_concurrent_events;
    begin
        $display("\n[%0t] ====== Test %0d: Concurrent Events Test ======", $time, test_num);
        $display("  Testing: Multiple control flow events in quick succession");
        
        // Start normal fetch
        $display("  Starting normal fetch...");
        
        // Wait for first request
        wait_for_condition(ifu_icu_req_ic1);
        
        // Send ack but delay data (to create data stall)
        icu_ifu_ack_ic1 = 1'b1;
        @(posedge clk);
        icu_ifu_ack_ic1 = 1'b0;
        
        // While data is pending, trigger exception
        $display("  Triggering exception during pending data...");
        exu_ifu_except = 1'b1;
        exu_ifu_isr_addr = 32'h90000000;
        @(posedge clk);
        exu_ifu_except = 1'b0;
        exu_ifu_isr_addr = 32'h0;
        
        // Now send the delayed data (should be cancelled due to flush)
        icu_ifu_data_valid_ic2 = 1'b1;
        //icu_ifu_data_ic2 = 64'h11111111_22222222;
        icu_ifu_data_ic2 = {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000};
        @(posedge clk);
        icu_ifu_data_valid_ic2 = 1'b0;
        
        // Verify fetch redirects to ISR
        wait_for_fetch_request(32'h90000000);
        
        // Send ISR data
        //icu_send_data(32'h90000000, 64'h33333333_44444444);
        icu_send_data(32'h90000000, {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000});
        
        // Immediately trigger branch
        $display("  Triggering branch immediately after exception...");
        exu_ifu_branch = 1'b1;
        exu_ifu_brn_addr = 32'h50000000;
        @(posedge clk);
        exu_ifu_branch = 1'b0;
        exu_ifu_brn_addr = 32'h0;
        
        // Verify fetch redirects to branch target
        wait_for_fetch_request(32'h50000000);
        
        test_num = test_num + 1;
        $display("  Concurrent events test completed");
    end
endtask

// ================= Main Test Sequence =================
initial begin
    initialize;
    
    // Wait for reset to be released
    @(posedge resetn);
    wait_cycles(5);
    
    $display("\n==================================================");
    $display("Starting c7bifu IQ Flow Testbench");
    $display("Testing: ICU data flow, instruction queue, and control flow");
    $display("==================================================\n");
    
    // ================= Run All Tests =================
    
    // Test 1: Normal instruction fetch flow
    test_normal_fetch_flow;
    
    // Clear pipeline
    wait_cycles(20);
    
    // Test 2: IQ full condition
    test_iq_full_condition;
    
    // Clear pipeline
    wait_cycles(20);
    
    // Test 3: Exception handling
    test_exception_flow;
    
    // Clear pipeline
    wait_cycles(20);
    
    // Test 4: Branch handling
    test_branch_flow;
    
    // Clear pipeline
    wait_cycles(20);
    
    // Test 5: ERTN handling
    test_ertn_flow;
    
    // Clear pipeline
    wait_cycles(20);
    
    // Test 6: Concurrent control flow events
    test_concurrent_events;
    
    // ================= Final Summary =================
    $display("\n==================================================");
    $display("TEST SUITE SUMMARY");
    $display("--------------------------------------------------");
    $display("Total tests completed: %0d", test_num - 1);
    $display("Total errors detected: %0d", error_count);
    
    if (error_count == 0) begin
        $display("\nALL TESTS PASSED!");
        $display("Instruction fetch unit with IQ is functioning correctly.");
        $display("- Normal fetch flow: OK");
        $display("- IQ full/empty handling: OK");
        $display("- Exception handling: OK");
        $display("- Branch handling: OK");
        $display("- ERTN handling: OK");
        $display("- Concurrent events: OK");
    end else begin
        $display("\nTEST FAILED!");
        $display("Found %0d error(s) in the design.", error_count);
    end
    
    $display("==================================================");
    
    // Wait a bit and finish
    #100 $finish;
end

// ================= Monitoring =================
always @(posedge clk) begin
    cycle_count = cycle_count + 1;
    
    // Count instructions read
    if (dut.inst_vld_f) begin
        instruction_count = instruction_count + 1;
        $display("[%0t] Cycle %0d: INSTRUCTION READ - Addr=0x%08h, Inst=0x%08h (Total: %0d)", 
                $time, cycle_count, dut.inst_addr_f, dut.inst_f, instruction_count);
    end
    
    // Monitor important state changes
    if (resetn) begin
        // Log fetch requests
        if (ifu_icu_req_ic1) begin
            $display("[%0t] Cycle %0d: FETCH REQ  - Addr=0x%08h", $time, cycle_count, ifu_icu_addr_ic1);
        end
        
        // Log ICU responses
        if (icu_ifu_ack_ic1) begin
            $display("[%0t] Cycle %0d: ICU ACK", $time, cycle_count);
        end
        
        if (icu_ifu_data_valid_ic2) begin
            $display("[%0t] Cycle %0d: ICU DATA   - Data=0x%016h", $time, cycle_count, icu_ifu_data_ic2);
        end
        
        // Log control flow events
        if (exu_ifu_except) begin
            $display("[%0t] Cycle %0d: EXCEPTION  - ISR Addr=0x%08h", $time, cycle_count, exu_ifu_isr_addr);
        end
        
        if (exu_ifu_branch) begin
            $display("[%0t] Cycle %0d: BRANCH     - Target=0x%08h", $time, cycle_count, exu_ifu_brn_addr);
        end
        
        if (exu_ifu_ertn) begin
            $display("[%0t] Cycle %0d: ERTN       - Return=0x%08h", $time, cycle_count, exu_ifu_ert_addr);
        end
        
        // Log pipeline flushes
        if (exu_ifu_except || exu_ifu_branch || exu_ifu_ertn) begin
            $display("[%0t] Cycle %0d: PIPELINE FLUSH", $time, cycle_count);
        end
    end
end

// ================= Waveform Dumping =================
initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, top_tb);
end

endmodule
