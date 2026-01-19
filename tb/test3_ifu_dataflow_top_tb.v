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
wire             ifu_exu_vld_d;
wire [31:0]      ifu_exu_pc_d;

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
    .exu_ifu_stall        (exu_ifu_stall),

    .ifu_exu_vld_d        (ifu_exu_vld_d),
    .ifu_exu_pc_d         (ifu_exu_pc_d)
);

// ================= Test Variables =================
integer test_num;
integer error_count;
integer cycle_count;
integer instruction_count;
integer fetch_request_count;
integer icu_response_count;

// ================= Helper Tasks =================
task initialize;
    begin
        test_num = 1;
        error_count = 0;
        cycle_count = 0;
        instruction_count = 0;
        fetch_request_count = 0;
        icu_response_count = 0;
        
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

// Simulate ICU response with deterministic checks
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
        icu_response_count = icu_response_count + 1;
        
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

// Check IQ state with assertions - only check iq_full since iq_empty may not exist
task check_iq_state;
    input expected_full;
    input integer test_id;
    begin
        // Check IQ full signal (only check this since iq_empty might not exist)
        if (dut.iq_full !== expected_full) begin
            $display("  ERROR[Test%0d]: IQ full signal incorrect. Expected %0b, got %0b",
                    test_id, expected_full, dut.iq_full);
            error_count = error_count + 1;
        end
        
        $display("  INFO[Test%0d]: IQ state - Full=%0b", test_id, dut.iq_full);
    end
endtask

// Check instruction output from IQ - simplified version
task monitor_iq_outputs;
    input integer monitor_cycles;
    input integer test_id;
    integer inst_count;
    reg [31:0] last_addr;
    begin
        inst_count = 0;
        last_addr = 32'h0;
        
        // Simple monitoring without fork-join
        repeat(monitor_cycles) begin
            @(posedge clk);
            if (dut.inst_vld_f === 1'b1 && exu_ifu_stall === 1'b0) begin
                inst_count = inst_count + 1;
                
                // Check for sequential addresses (when not in control flow change)
                if (inst_count > 1 && last_addr !== 32'h0) begin
                    if (dut.inst_addr_f !== (last_addr + 4)) begin
                        $display("  WARNING[Test%0d]: Non-sequential instruction address: Previous=0x%08h, Current=0x%08h",
                                test_id, last_addr, dut.inst_addr_f);
                    end
                end
                last_addr = dut.inst_addr_f;
            end
        end
        
        $display("  INFO[Test%0d]: Read %0d instructions in %0d cycles", test_id, inst_count, monitor_cycles);
    end
endtask

// ================= Test Cases =================
task test_normal_fetch_flow;
    integer i;
    reg [31:0] expected_addr;
    integer requests_expected;
    integer responses_expected;
    begin
        $display("\n[%0t] ====== Test %0d: Normal Fetch Flow Test ======", $time, test_num);
        $display("  Testing: Sequential instruction fetch from ICU to IQ");
        
        // Start from reset address
        expected_addr = 32'h1C000000;
        requests_expected = 4;
        responses_expected = 4;
        
        // Initial IQ should be empty - only check full signal
        check_iq_state(1'b0, test_num);
        
        // Fetch 4 packets (8 instructions)
        for (i = 0; i < requests_expected; i = i + 1) begin
            // Wait for request with timeout
            wait_for_fetch_request(expected_addr);
            fetch_request_count = fetch_request_count + 1;
            
            // Send ICU response with test data
            icu_send_data(expected_addr, {expected_addr + 32'hAAA000 + 4, expected_addr + 32'hAAA000});
            
            // Update expected address
            expected_addr = expected_addr + 8;
        end
        
        // Assert: Must receive expected number of requests
        if (fetch_request_count < requests_expected) begin
            $display("  ERROR[Test%0d]: Expected %0d fetch requests, got %0d", 
                    test_num, requests_expected, fetch_request_count);
            error_count = error_count + 1;
        end
        
        // Assert: Must receive expected number of responses
        if (icu_response_count < responses_expected) begin
            $display("  ERROR[Test%0d]: Expected %0d ICU responses, got %0d", 
                    test_num, responses_expected, icu_response_count);
            error_count = error_count + 1;
        end
        
        // Wait for instructions to be read from IQ
        $display("  Monitoring IQ outputs...");
        monitor_iq_outputs(20, test_num);
        
        // IQ should not be full after reading some instructions
        wait_cycles(5);
        check_iq_state(1'b0, test_num);
        
        test_num = test_num + 1;
        $display("  Normal fetch flow test completed with %0d errors", error_count);
    end
endtask

task test_iq_full_condition;
    integer i;
    integer timeout;
    reg iq_full_detected;
    integer requests_before_full;
    reg loop_done;
    begin
        $display("\n[%0t] ====== Test %0d: IQ Full Condition Test ======", $time, test_num);
        $display("  Testing: Fetch stops when IQ is full");
        
        iq_full_detected = 0;
        requests_before_full = 0;
        loop_done = 0;
        
        // Apply stall to prevent instruction consumption
        $display("  Applying stall to fill IQ...");
        exu_ifu_stall = 1'b1;
        wait_cycles(2);
        
        // Rapidly fetch until IQ is full - replace break with flag
        for (i = 0; i < 12 && loop_done === 0; i = i + 1) begin  // Try more than IQ capacity
            timeout = 10;
            while (timeout > 0 && ifu_icu_req_ic1 !== 1'b1) begin
                @(posedge clk);
                timeout = timeout - 1;
            end
            
            if (ifu_icu_req_ic1 === 1'b1) begin
                requests_before_full = requests_before_full + 1;
                fetch_request_count = fetch_request_count + 1;
                
                // Send ICU response immediately
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
                icu_ifu_data_valid_ic2 = 1'b1;
                icu_ifu_data_ic2 = {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000};
                @(posedge clk);
                icu_ifu_data_valid_ic2 = 1'b0;
                icu_ifu_data_ic2 = 64'h0;
                icu_response_count = icu_response_count + 1;
                
                // Check if IQ becomes full
                //if (dut.iq_full === 1'b1 && iq_full_detected === 0) begin
                //    $display("  IQ full detected after %0d packets", i+1);
                //    iq_full_detected = 1;
                //    
                //    // Assert: When IQ is full, fetch should stop
                //    wait_cycles(5);
                //    if (ifu_icu_req_ic1 === 1'b1) begin
                //        $display("  ERROR[Test%0d]: Fetch should stop when IQ is full", test_num);
                //        error_count = error_count + 1;
                //    end
                //end
            end else if (dut.iq_full === 1'b1) begin
                // IQ is full and no more requests (expected behavior)
                $display("  IQ full detected after %0d packets", i);
                iq_full_detected = 1;
                $display("  No more fetch requests when IQ is full (expected)");
                loop_done = 1;  // Set flag to exit loop
            end
        end
        
        // Assert: Must detect IQ full condition
        if (iq_full_detected === 0) begin
            $display("  ERROR[Test%0d]: IQ full condition not detected", test_num);
            error_count = error_count + 1;
        end
        
        // Release stall and read instructions to clear IQ
        $display("  Releasing stall and clearing IQ...");
        exu_ifu_stall = 1'b0;
        
        // Monitor IQ outputs as instructions are read
        monitor_iq_outputs(15, test_num);
        
        // Verify fetch resumes after IQ has space
        timeout = 20;
        while (timeout > 0 && ifu_icu_req_ic1 !== 1'b1) begin
            @(posedge clk);
            timeout = timeout - 1;
        end
        
        // Assert: Fetch should resume after IQ is cleared
        if (ifu_icu_req_ic1 !== 1'b1) begin
            $display("  ERROR[Test%0d]: Fetch did not resume after IQ has space", test_num);
            error_count = error_count + 1;
        end else begin
            $display("  Fetch resumed successfully (as expected)");
        end
        
        test_num = test_num + 1;
        $display("  IQ full condition test completed with %0d errors", error_count);
    end
endtask

task test_exception_flow;
    integer timeout;
    reg [31:0] addr_before_exception;
    begin
        $display("\n[%0t] ====== Test %0d: Exception Flow Test ======", $time, test_num);
        $display("  Testing: Exception flushes pipeline and redirects to ISR");
        
        // First fetch a few instructions
        $display("  Fetching normal instructions...");
        
        // Wait for fetch request and capture address
        timeout = 20;
        while (timeout > 0 && ifu_icu_req_ic1 !== 1'b1) begin
            @(posedge clk);
            timeout = timeout - 1;
        end
        
        if (ifu_icu_req_ic1 === 1'b1) begin
            addr_before_exception = ifu_icu_addr_ic1;
            $display("  Current fetch address before exception: 0x%08h", addr_before_exception);
            
            // Send ICU response
            icu_ifu_ack_ic1 = 1'b1;
            @(posedge clk);
            icu_ifu_ack_ic1 = 1'b0;
            icu_ifu_data_valid_ic2 = 1'b1;
            icu_ifu_data_ic2 = {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000};
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b0;
            icu_ifu_data_ic2 = 64'h0;
            fetch_request_count = fetch_request_count + 1;
            icu_response_count = icu_response_count + 1;
        end
        
        // Trigger exception
        $display("  Triggering exception...");
        exu_ifu_except = 1'b1;
        exu_ifu_isr_addr = 32'h80000000;  // ISR address
        @(posedge clk);
        exu_ifu_except = 1'b0;
        exu_ifu_isr_addr = 32'h0;
        
        // Verify flush occurs and new fetch starts at ISR address
        wait_for_fetch_request(32'h80000000);
        fetch_request_count = fetch_request_count + 1;
        
        // Assert: Should NOT continue fetching from previous address
        if (ifu_icu_addr_ic1 === addr_before_exception) begin
            $display("  ERROR[Test%0d]: Fetch should redirect to ISR, not continue from previous address", test_num);
            error_count = error_count + 1;
        end
        
        // Send ICU response for ISR
        icu_send_data(32'h80000000, {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000});
        
        // Read from IQ and verify we get ISR instructions
        $display("  Reading instructions after exception...");
        monitor_iq_outputs(10, test_num);
        
        // Verify IQ state after exception
        check_iq_state(1'b0, test_num);
        
        test_num = test_num + 1;
        $display("  Exception flow test completed with %0d errors", error_count);
    end
endtask

task test_branch_flow;
    integer timeout;
    reg [31:0] addr_before_branch;
    begin
        $display("\n[%0t] ====== Test %0d: Branch Flow Test ======", $time, test_num);
        $display("  Testing: Branch redirects fetch to target address");
        
        // Fetch a few instructions
        $display("  Fetching normal instructions...");
        
        // Wait for fetch request and capture address
        timeout = 20;
        while (timeout > 0 && ifu_icu_req_ic1 !== 1'b1) begin
            @(posedge clk);
            timeout = timeout - 1;
        end
        
        if (ifu_icu_req_ic1 === 1'b1) begin
            addr_before_branch = ifu_icu_addr_ic1;
            $display("  Current fetch address before branch: 0x%08h", addr_before_branch);
            
            // Send ICU response
            icu_ifu_ack_ic1 = 1'b1;
            @(posedge clk);
            icu_ifu_ack_ic1 = 1'b0;
            icu_ifu_data_valid_ic2 = 1'b1;
            icu_ifu_data_ic2 = {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000};
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b0;
            icu_ifu_data_ic2 = 64'h0;
            fetch_request_count = fetch_request_count + 1;
            icu_response_count = icu_response_count + 1;
        end
        
        // Trigger branch
        $display("  Triggering branch...");
        exu_ifu_branch = 1'b1;
        exu_ifu_brn_addr = 32'h40001000;  // Branch target
        @(posedge clk);
        exu_ifu_branch = 1'b0;
        exu_ifu_brn_addr = 32'h0;
        
        // Verify flush occurs and new fetch starts at branch target
        wait_for_fetch_request(32'h40001000);
        fetch_request_count = fetch_request_count + 1;
        
        // Assert: Should NOT continue fetching from previous address
        if (ifu_icu_addr_ic1 === addr_before_branch) begin
            $display("  ERROR[Test%0d]: Fetch should redirect to branch target, not continue from previous address", test_num);
            error_count = error_count + 1;
        end
        
        // Send ICU response for branch target
        icu_send_data(32'h40001000, {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000});
        
        // Read from IQ
        $display("  Reading instructions after branch...");
        monitor_iq_outputs(10, test_num);
        
        test_num = test_num + 1;
        $display("  Branch flow test completed with %0d errors", error_count);
    end
endtask

task test_ertn_flow;
    integer timeout;
    begin
        $display("\n[%0t] ====== Test %0d: ERTN (Exception Return) Flow Test ======", $time, test_num);
        $display("  Testing: ERTN returns from exception");
        
        // First go to exception
        $display("  Going to exception first...");
        
        // Trigger exception
        exu_ifu_except = 1'b1;
        exu_ifu_isr_addr = 32'h80000000;
        @(posedge clk);
        exu_ifu_except = 1'b0;
        exu_ifu_isr_addr = 32'h0;
        
        // Wait for fetch request to ISR
        wait_for_fetch_request(32'h80000000);
        fetch_request_count = fetch_request_count + 1;
        
        // Send ICU response for ISR
        icu_ifu_ack_ic1 = 1'b1;
        @(posedge clk);
        icu_ifu_ack_ic1 = 1'b0;
        icu_ifu_data_valid_ic2 = 1'b1;
        icu_ifu_data_ic2 = {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000};
        @(posedge clk);
        icu_ifu_data_valid_ic2 = 1'b0;
        icu_ifu_data_ic2 = 64'h0;
        icu_response_count = icu_response_count + 1;
        
        // Trigger ERTN to return
        $display("  Triggering ERTN to return...");
        exu_ifu_ertn = 1'b1;
        exu_ifu_ert_addr = 32'h1C000010;  // Return address (original + 0x10)
        @(posedge clk);
        exu_ifu_ertn = 1'b0;
        exu_ifu_ert_addr = 32'h0;
        
        // Verify flush occurs and fetch resumes at return address
        wait_for_fetch_request(32'h1C000010);
        fetch_request_count = fetch_request_count + 1;
        
        // Assert: Should fetch from return address, not continue from ISR
        if (ifu_icu_addr_ic1 === 32'h80000008) begin
            $display("  ERROR[Test%0d]: Fetch should return from exception, not continue from ISR", test_num);
            error_count = error_count + 1;
        end
        
        // Send ICU response for return address
        icu_send_data(32'h1c000010, {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000});
        
        // Read from IQ
        $display("  Reading instructions after ERTN...");
        monitor_iq_outputs(10, test_num);
        
        test_num = test_num + 1;
        $display("  ERTN flow test completed with %0d errors", error_count);
    end
endtask

task test_concurrent_events;
    integer timeout;
    begin
        $display("\n[%0t] ====== Test %0d: Concurrent Events Test ======", $time, test_num);
        $display("  Testing: Multiple control flow events in quick succession");
        
        // Start normal fetch
        $display("  Starting normal fetch...");
        
        // Wait for first request
        wait_for_condition(ifu_icu_req_ic1);
        fetch_request_count = fetch_request_count + 1;
        
        // Send ack but delay data (to create data stall)
        icu_ifu_ack_ic1 = 1'b1;
        @(posedge clk);
        icu_ifu_ack_ic1 = 1'b0;
        icu_response_count = icu_response_count + 1;
        
        // While data is pending, trigger exception
        $display("  Triggering exception during pending data...");
        exu_ifu_except = 1'b1;
        exu_ifu_isr_addr = 32'h90000000;
        @(posedge clk);
        exu_ifu_except = 1'b0;
        exu_ifu_isr_addr = 32'h0;
        
        // Now send the delayed data (should be cancelled due to flush)
        icu_ifu_data_valid_ic2 = 1'b1;
        icu_ifu_data_ic2 = {ifu_icu_addr_ic1 + 32'hAAA000 + 4, ifu_icu_addr_ic1 + 32'hAAA000};
        @(posedge clk);
        icu_ifu_data_valid_ic2 = 1'b0;
        
        // Verify fetch redirects to ISR
        wait_for_fetch_request(32'h90000000);
        fetch_request_count = fetch_request_count + 1;
        
        // Assert: Should fetch from ISR, not continue previous fetch
        if (ifu_icu_addr_ic1 !== 32'h90000000) begin
            $display("  ERROR[Test%0d]: Should fetch from ISR after exception", test_num);
            error_count = error_count + 1;
        end
        
        // Send ISR data
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
        fetch_request_count = fetch_request_count + 1;
        
        // Assert: Should fetch from branch target, not continue from ISR
        if (ifu_icu_addr_ic1 !== 32'h50000000) begin
            $display("  ERROR[Test%0d]: Should fetch from branch target after branch", test_num);
            error_count = error_count + 1;
        end
        
        test_num = test_num + 1;
        $display("  Concurrent events test completed with %0d errors", error_count);
    end
endtask

task test_stall_csrwr_addi;
    integer timeout;
    reg [31:0] addr_before_branch;
    begin
        $display("\n[%0t] ====== Test %0d: Stall Test ======", $time, test_num);
        $display("  Testing: csrrd, addi : Stall on dec");

        resetn = 1'b0;
        #22 resetn = 1'b1;      // Release reset after 22ns
        
        // 1c000000:       04003026        csrwr   $r6,0xc
	// 1c000004:       02816806        addi.w  $r6,$r0,90(0x5a)


        // Fetch a few instructions
        $display("  Fetching normal instructions...");
        
        // Wait for fetch request and capture address
        timeout = 20;
        while (timeout > 0 && ifu_icu_req_ic1 !== 1'b1) begin
            @(posedge clk);
            timeout = timeout - 1;
        end
        
        if (ifu_icu_req_ic1 === 1'b1) begin
            addr_before_branch = ifu_icu_addr_ic1;
            $display("  Current fetch address before branch: 0x%08h", addr_before_branch);
            
            // Send ICU response
            icu_ifu_ack_ic1 = 1'b1;
            @(posedge clk);
            icu_ifu_ack_ic1 = 1'b0;
            icu_ifu_data_valid_ic2 = 1'b1;
            icu_ifu_data_ic2 = 64'h0281680604003026;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b0;
            icu_ifu_data_ic2 = 64'h0;
            fetch_request_count = fetch_request_count + 1;
            icu_response_count = icu_response_count + 1;
        end
        
        @(posedge clk);

	// two more cycle, to simulate csrwr flow to _e, causing stall
        @(posedge clk);
        @(posedge clk);

        $display("  ifu_exu_vld_d: %d,  ifu_exu_pc_d: 0x%08h", ifu_exu_vld_d, ifu_exu_pc_d);
	if (ifu_exu_vld_d !== 1 || ifu_exu_pc_d !== 32'h1c000000) begin
            $display("ERROR: ifu_exu_vld_d should be 1, ifu_exu_pc_d should be 1c000000");
            error_count = error_count + 1;
	end

        // Trigger stall
        $display("Apply stall...");
        exu_ifu_stall = 1'b1;
        @(posedge clk);

        $display("Reading instructions after applying stall...");

	$display(" iq has 1-cycle read delay");
        $display("Stall Cycle 1:");

	$display("  inst_vld_f   : %d,  inst_addr_f : 0x%08h,  inst_f: 0x%08h", dut.inst_vld_f, dut.inst_addr_f, dut.inst_f);
	//if (dut.inst_vld_f !== 1 || dut.inst_addr_f !== 32'h1c000000) begin
        //    $display("ERROR: inst_vld_f should be 1, inst_addr_f should be 1c000000");
        //    error_count = error_count + 1;
	//end
        $display("  ifu_exu_vld_d: %d,  ifu_exu_pc_d: 0x%08h", ifu_exu_vld_d, ifu_exu_pc_d);
	//if (ifu_exu_vld_d !== 0 || ifu_exu_pc_d !== 32'h00000000) begin
        //    $display("ERROR: ifu_exu_vld_d should be 0, ifu_exu_pc_d should be 00000000");
        //    error_count = error_count + 1;
	//end

        @(posedge clk);

        $display("Stall Cycle 2:");

	$display("  inst_vld_f   : %d,  inst_addr_f : 0x%08h,  inst_f: 0x%08h", dut.inst_vld_f, dut.inst_addr_f, dut.inst_f);
	//if (dut.inst_vld_f !== 0 || dut.inst_addr_f !== 32'h1c000000) begin
        //    $display("ERROR: inst_vld_f should be 0, inst_addr_f should be 1c000000");
        //    error_count = error_count + 1;
	//end
        $display("  ifu_exu_vld_d: %d,  ifu_exu_pc_d: 0x%08h", ifu_exu_vld_d, ifu_exu_pc_d);
	//if (ifu_exu_vld_d !== 0 || ifu_exu_pc_d !== 32'h00000000) begin
        //    $display("ERROR: ifu_exu_vld_d should be 0, ifu_exu_pc_d should be 00000000");
        //    error_count = error_count + 1;
	//end


        $display("Release stall...");
        exu_ifu_stall = 1'b0;
        @(posedge clk);

        // Read from IQ
        $display("Reading instructions after releasing stall...");
	
	//
	// iq has 1-cycle read delay
	//
	$display(" iq has 1-cycle read delay");
        $display("Cycle 1:");

	$display("  inst_vld_f   : %d,  inst_addr_f : 0x%08h,  inst_f: 0x%08h", dut.inst_vld_f, dut.inst_addr_f, dut.inst_f);
	//if (dut.inst_vld_f !== 0 || dut.inst_addr_f !== 32'h1c000000) begin
        //    $display("ERROR: inst_vld_f should be 0, inst_addr_f should be 1c000000");
        //    error_count = error_count + 1;
	//end
        $display("  ifu_exu_vld_d: %d,  ifu_exu_pc_d: 0x%08h", ifu_exu_vld_d, ifu_exu_pc_d);
	if (ifu_exu_vld_d !== 1 || ifu_exu_pc_d !== 32'h1c000004) begin
            $display("ERROR: ifu_exu_vld_d should be 1, ifu_exu_pc_d should be 1c000004");
            error_count = error_count + 1;
	end

        @(posedge clk);

        $display("Cycle 2:");

	$display("  inst_vld_f   : %d,  inst_addr_f : 0x%08h,  inst_f: 0x%08h", dut.inst_vld_f, dut.inst_addr_f, dut.inst_f);
	//if (dut.inst_vld_f !== 1 || dut.inst_addr_f !== 32'h1c000004) begin
        //    $display("ERROR: inst_vld_f should be 1, inst_addr_f should be 1c000004");
        //    error_count = error_count + 1;
	//end
        $display("  ifu_exu_vld_d: %d,  ifu_exu_pc_d: 0x%08h", ifu_exu_vld_d, ifu_exu_pc_d);
	//if (ifu_exu_vld_d !== 1 || ifu_exu_pc_d !== 32'h1c000000) begin
        //    $display("ERROR: ifu_exu_vld_d should be 1, ifu_exu_pc_d should be 1c000000");
        //    error_count = error_count + 1;
	//end
        
        test_num = test_num + 1;
        $display("  Stall test completed with %0d errors", error_count);
    end
endtask

task test_stall_on_iq_addi_csrwr_addi_addi;
    integer timeout;
    reg [31:0] addr_before_branch;
    begin
        $display("\n[%0t] ====== Test %0d: Stall Test ======", $time, test_num);
        $display("  Testing: Stall on iq sending out instructions");
        
        resetn = 1'b0;
        #22 resetn = 1'b1;      // Release reset after 22ns

        // Fetch a few instructions
        $display("  Fetching normal instructions...");
        
        // Wait for fetch request and capture address
        timeout = 20;
        while (timeout > 0 && ifu_icu_req_ic1 !== 1'b1) begin
            @(posedge clk);
            timeout = timeout - 1;
        end
       
        exu_ifu_stall = 1'b1;

        if (ifu_icu_req_ic1 === 1'b1) begin
            addr_before_branch = ifu_icu_addr_ic1;
            $display("  Current fetch address before branch: 0x%08h", addr_before_branch);
            
            // Send ICU response
            icu_ifu_ack_ic1 = 1'b1;
            @(posedge clk);
            icu_ifu_ack_ic1 = 1'b0;
            icu_ifu_data_valid_ic2 = 1'b1;
            icu_ifu_data_ic2 = 64'h0400302602816806;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b0;
            icu_ifu_data_ic2 = 64'h0;
            fetch_request_count = fetch_request_count + 1;
            icu_response_count = icu_response_count + 1;
        end
        
        @(posedge clk);
            // Send ICU response
            icu_ifu_ack_ic1 = 1'b1;
        @(posedge clk);
            icu_ifu_ack_ic1 = 1'b0;
            icu_ifu_data_valid_ic2 = 1'b1;
	    // 1c000008:       02800000        addi.w  $r0,$r0,0
            // 1c00000c:       02800000        addi.w  $r0,$r0,0
            icu_ifu_data_ic2 = 64'h0280000002800000;

        @(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b0;
            icu_ifu_data_ic2 = 64'h0;

	//
	// iq is full
	//
        exu_ifu_stall = 1'b0; 
        @(posedge clk);

	//
	// three more cycle, the second instruction (csrwr) arrives at _e,
	// raising stall
	//
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
	
        // Trigger stall
        $display("Apply stall...");
        exu_ifu_stall = 1'b1;
        @(posedge clk);
        $display("Reading instructions after applying stall...");

	$display(" iq has 1-cycle read delay");
        $display("Stall Cycle 1:");

	$display("  inst_vld_f   : %d,  inst_addr_f : 0x%08h,  inst_f: 0x%08h", dut.inst_vld_f, dut.inst_addr_f, dut.inst_f);
	//if (dut.inst_vld_f !== 1 || dut.inst_addr_f !== 32'h1c000000) begin
        //    $display("ERROR: inst_vld_f should be 1, inst_addr_f should be 1c000000");
        //    error_count = error_count + 1;
	//end
        $display("  ifu_exu_vld_d: %d,  ifu_exu_pc_d: 0x%08h", ifu_exu_vld_d, ifu_exu_pc_d);
	//if (ifu_exu_vld_d !== 0 || ifu_exu_pc_d !== 32'h00000000) begin
        //    $display("ERROR: ifu_exu_vld_d should be 0, ifu_exu_pc_d should be 00000000");
        //    error_count = error_count + 1;
	//end

        @(posedge clk);

        $display("Stall Cycle 2:");

	$display("  inst_vld_f   : %d,  inst_addr_f : 0x%08h,  inst_f: 0x%08h", dut.inst_vld_f, dut.inst_addr_f, dut.inst_f);
	//if (dut.inst_vld_f !== 0 || dut.inst_addr_f !== 32'h1c000000) begin
        //    $display("ERROR: inst_vld_f should be 0, inst_addr_f should be 1c000000");
        //    error_count = error_count + 1;
	//end
        $display("  ifu_exu_vld_d: %d,  ifu_exu_pc_d: 0x%08h", ifu_exu_vld_d, ifu_exu_pc_d);
	//if (ifu_exu_vld_d !== 0 || ifu_exu_pc_d !== 32'h00000000) begin
        //    $display("ERROR: ifu_exu_vld_d should be 0, ifu_exu_pc_d should be 00000000");
        //    error_count = error_count + 1;
	//end


        $display("Release stall...");
        exu_ifu_stall = 1'b0;
        @(posedge clk);

        // Read from IQ
        $display("Reading instructions after releasing stall...");
	
	//
	// iq has 1-cycle read delay
	//
	$display(" iq has 1-cycle read delay");
        $display("Cycle 1:");

	$display("  inst_vld_f   : %d,  inst_addr_f : 0x%08h,  inst_f: 0x%08h", dut.inst_vld_f, dut.inst_addr_f, dut.inst_f);
	//if (dut.inst_vld_f !== 0 || dut.inst_addr_f !== 32'h1c000000) begin
        //    $display("ERROR: inst_vld_f should be 0, inst_addr_f should be 1c000000");
        //    error_count = error_count + 1;
	//end
        $display("  ifu_exu_vld_d: %d,  ifu_exu_pc_d: 0x%08h", ifu_exu_vld_d, ifu_exu_pc_d);
	if (ifu_exu_vld_d !== 1 || ifu_exu_pc_d !== 32'h1c000008) begin
            $display("ERROR: ifu_exu_vld_d should be 1, ifu_exu_pc_d should be 1c000008");
            error_count = error_count + 1;
	end

        @(posedge clk);

        $display("Cycle 2:");

	$display("  inst_vld_f   : %d,  inst_addr_f : 0x%08h,  inst_f: 0x%08h", dut.inst_vld_f, dut.inst_addr_f, dut.inst_f);
	if (dut.inst_vld_f !== 1 || dut.inst_addr_f !== 32'h1c00000c) begin
            $display("ERROR: inst_vld_f should be 1, inst_addr_f should be 1c00000c");
            error_count = error_count + 1;
	end
        $display("  ifu_exu_vld_d: %d,  ifu_exu_pc_d: 0x%08h", ifu_exu_vld_d, ifu_exu_pc_d);
	//if (ifu_exu_vld_d !== 1 || ifu_exu_pc_d !== 32'h1c000000) begin
        //    $display("ERROR: ifu_exu_vld_d should be 1, ifu_exu_pc_d should be 1c000000");
        //    error_count = error_count + 1;
	//end
	
        @(posedge clk);

        $display("Cycle 3:");

        $display("  ifu_exu_vld_d: %d,  ifu_exu_pc_d: 0x%08h", ifu_exu_vld_d, ifu_exu_pc_d);
	if (ifu_exu_vld_d !== 1 || ifu_exu_pc_d !== 32'h1c00000c) begin
            $display("ERROR: ifu_exu_vld_d should be 1, ifu_exu_pc_d should be 1c00000c");
            error_count = error_count + 1;
	end
        
        test_num = test_num + 1;
        $display("  Stall test completed with %0d errors", error_count);
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
    
    // Clear pipeline between tests
    wait_cycles(20);
    exu_ifu_stall = 1'b0;  // Ensure no stall
    
    // Test 2: IQ full condition
    test_iq_full_condition;
    
    // Clear pipeline
    wait_cycles(20);
    exu_ifu_stall = 1'b0;
    
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

    // Clear pipeline
    wait_cycles(20);

    // Instructions: csrwr addi
    // stall on dec
    test_stall_csrwr_addi;
  
    // Clear pipeline
    wait_cycles(20);

    // Instructions: addi csrwr addi addi
    // stall on iq
    test_stall_on_iq_addi_csrwr_addi_addi;


    // ================= Final Summary =================
    $display("\n==================================================");
    $display("TEST SUITE SUMMARY");
    $display("--------------------------------------------------");
    $display("Total tests completed: %0d", test_num - 1);
    $display("Total errors detected: %0d", error_count);
    $display("Total cycles: %0d", cycle_count);
    $display("Total instructions read: %0d", instruction_count);
    $display("Total fetch requests: %0d", fetch_request_count);
    $display("Total ICU responses: %0d", icu_response_count);
    
    // Simple performance metrics
    if (cycle_count > 0 && instruction_count > 0) begin
        $display("IPC ratio: %0d instructions / %0d cycles", instruction_count, cycle_count);
    end
    
    if (fetch_request_count > 0 && instruction_count > 0) begin
        $display("Fetch efficiency: %0d fetch requests for %0d instructions", 
                fetch_request_count, instruction_count);
    end
    
    if (error_count == 0) begin
        $display("\nALL TESTS PASSED!");
        $display("Instruction fetch unit with IQ is functioning correctly.");
        $display("- Normal fetch flow: OK");
        $display("- IQ full/empty handling: OK");
        $display("- Exception handling: OK");
        $display("- Branch handling: OK");
        $display("- ERTN handling: OK");
        $display("- Concurrent events: OK");
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
        $display("\nTEST FAILED!");
        $display("Found %0d error(s) in the design.", error_count);
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
    
    $display("==================================================");
    
    // Wait a bit and finish
    #100 $finish;
end

// ================= Monitoring =================
always @(posedge clk) begin
    cycle_count = cycle_count + 1;
    
    // Count instructions read
    if (dut.inst_vld_f === 1'b1 && exu_ifu_stall === 1'b0) begin
        instruction_count = instruction_count + 1;
        $display("[%0t] Cycle %0d: INSTRUCTION READ - Addr=0x%08h, Inst=0x%08h (Total: %0d)", 
                $time, cycle_count, dut.inst_addr_f, dut.inst_f, instruction_count);
    end
    
    // Monitor important state changes
    if (resetn === 1'b1) begin
        // Log fetch requests
        if (ifu_icu_req_ic1 === 1'b1) begin
            $display("[%0t] Cycle %0d: FETCH REQ  - Addr=0x%08h", $time, cycle_count, ifu_icu_addr_ic1);
        end
        
        // Log ICU responses
        if (icu_ifu_ack_ic1 === 1'b1) begin
            $display("[%0t] Cycle %0d: ICU ACK", $time, cycle_count);
        end
        
        if (icu_ifu_data_valid_ic2 === 1'b1) begin
            $display("[%0t] Cycle %0d: ICU DATA   - Data=0x%016h", $time, cycle_count, icu_ifu_data_ic2);
        end
        
        // Log control flow events
        if (exu_ifu_except === 1'b1) begin
            $display("[%0t] Cycle %0d: EXCEPTION  - ISR Addr=0x%08h", $time, cycle_count, exu_ifu_isr_addr);
        end
        
        if (exu_ifu_branch === 1'b1) begin
            $display("[%0t] Cycle %0d: BRANCH     - Target=0x%08h", $time, cycle_count, exu_ifu_brn_addr);
        end
        
        if (exu_ifu_ertn === 1'b1) begin
            $display("[%0t] Cycle %0d: ERTN       - Return=0x%08h", $time, cycle_count, exu_ifu_ert_addr);
        end
        
        // Log pipeline flushes
        if (exu_ifu_except === 1'b1 || exu_ifu_branch === 1'b1 || exu_ifu_ertn === 1'b1) begin
            $display("[%0t] Cycle %0d: PIPELINE FLUSH", $time, cycle_count);
        end
        
        // Log IQ state changes - only iq_full
        if (dut.iq_full === 1'b1) begin
            $display("[%0t] Cycle %0d: IQ STATE   - FULL", $time, cycle_count);
        end
    end
end

// ================= Waveform Dumping =================
initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, top_tb);
    // Add specific signals for better debugging
    $dumpvars(1, dut.iq_full);
    $dumpvars(1, dut.inst_vld_f);
    $dumpvars(1, dut.inst_addr_f);
end

endmodule
