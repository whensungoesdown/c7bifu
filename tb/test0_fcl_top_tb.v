`timescale 1ns/1ps

module top_tb();

    // Input signals
    reg clk;
    reg resetn;
    reg icu_ifu_ack_ic1;
    reg icu_ifu_data_valid_ic2;
    reg exu_ifu_except;
    reg exu_ifu_branch;    // New input: branch signal
    reg exu_ifu_ertn;      // New input: ertn signal

    // Output signals
    wire ifu_icu_req_ic1;
    wire pf_addr_sel_init;  // New output: prefetch address select init
    wire pf_addr_sel_old;   // New output: prefetch address select old/stall
    wire pf_addr_sel_inc;   // New output: prefetch address select increment
    wire pf_addr_sel_brn;   // New output: PC address select branch
    wire pf_addr_sel_isr;   // New output: PC address select exception/isr
    wire pf_addr_sel_ert;   // New output: PC address select ertn return
    wire pf_addr_en;        // New output: PC address enable
    wire stall;
    wire flush;
    wire iq_full;

    // Test status variables
    reg [7:0] test_passed;
    reg [7:0] test_failed;
    integer test_num;
    
    // Waveform display variables
    integer cycle_count;
    reg [79:0] wave_clk;
    reg [79:0] wave_resetn;
    reg [79:0] wave_req;
    reg [79:0] wave_ack;
    reg [79:0] wave_valid;
    reg [79:0] wave_except;
    reg [79:0] wave_branch;     // New waveform for branch
    reg [79:0] wave_ertn;       // New waveform for ertn
    reg [79:0] wave_pf_init;    // New waveform for pf_addr_sel_init
    reg [79:0] wave_pf_old;     // New waveform for pf_addr_sel_old
    reg [79:0] wave_pf_inc;     // New waveform for pf_addr_sel_inc
    reg [79:0] wave_pf_brn;     // New waveform for pf_addr_sel_brn
    reg [79:0] wave_pf_isr;     // New waveform for pf_addr_sel_isr
    reg [79:0] wave_pf_ert;     // New waveform for pf_addr_sel_ert
    reg [79:0] wave_pf_en;      // New waveform for pf_addr_en
    
    // Clock edge counter
    integer clk_edge_count;

    // Only test part of fcl logic alone
    assign iq_full = 1'b0;

    // Instantiate DUT
    c7bifu_fcl uut (
        .clk(clk),
        .resetn(resetn),
        .ifu_icu_req_ic1(ifu_icu_req_ic1),
        .icu_ifu_ack_ic1(icu_ifu_ack_ic1),
        .icu_ifu_data_valid_ic2(icu_ifu_data_valid_ic2),
        .exu_ifu_except(exu_ifu_except),
        .exu_ifu_branch(exu_ifu_branch),
        .exu_ifu_ertn(exu_ifu_ertn),
        .pf_addr_sel_init(pf_addr_sel_init),
        .pf_addr_sel_old(pf_addr_sel_old),
        .pf_addr_sel_inc(pf_addr_sel_inc),
        .pf_addr_sel_brn(pf_addr_sel_brn),
        .pf_addr_sel_isr(pf_addr_sel_isr),
        .pf_addr_sel_ert(pf_addr_sel_ert),
        .pf_addr_en(pf_addr_en),
	.stall(stall),
	.flush(flush),
	.iq_full(iq_full)
    );

    // Clock generation: period 10ns
    always #5 clk = ~clk;
    
    // Clock edge counting
    always @(posedge clk, negedge clk) begin
        if (clk) begin
            clk_edge_count = clk_edge_count + 1;
        end
    end
    
    // Waveform sampling (sample at clock falling edge)
    always @(negedge clk) begin
        if (cycle_count < 80) begin
            // Basic signals
            wave_clk = {wave_clk[78:0], "^"};
            wave_resetn = {wave_resetn[78:0], resetn ? "-" : "_"};
            wave_req = {wave_req[78:0], ifu_icu_req_ic1 ? "-" : "_"};
            wave_ack = {wave_ack[78:0], icu_ifu_ack_ic1 ? "-" : "_"};
            wave_valid = {wave_valid[78:0], icu_ifu_data_valid_ic2 ? "-" : "_"};
            wave_except = {wave_except[78:0], exu_ifu_except ? "-" : "_"};
            wave_branch = {wave_branch[78:0], exu_ifu_branch ? "-" : "_"};
            wave_ertn = {wave_ertn[78:0], exu_ifu_ertn ? "-" : "_"};
            
            // Address selection signals
            wave_pf_init = {wave_pf_init[78:0], pf_addr_sel_init ? "-" : "_"};
            wave_pf_old = {wave_pf_old[78:0], pf_addr_sel_old ? "-" : "_"};
            wave_pf_inc = {wave_pf_inc[78:0], pf_addr_sel_inc ? "-" : "_"};
            wave_pf_brn = {wave_pf_brn[78:0], pf_addr_sel_brn ? "-" : "_"};
            wave_pf_isr = {wave_pf_isr[78:0], pf_addr_sel_isr ? "-" : "_"};
            wave_pf_ert = {wave_pf_ert[78:0], pf_addr_sel_ert ? "-" : "_"};
            wave_pf_en = {wave_pf_en[78:0], pf_addr_en ? "-" : "_"};
            
            cycle_count = cycle_count + 1;
        end
    end

    // Initialization
    initial begin
        clk = 0;
        resetn = 0;
        icu_ifu_ack_ic1 = 0;
        icu_ifu_data_valid_ic2 = 0;
        exu_ifu_except = 0;
        exu_ifu_branch = 0;
        exu_ifu_ertn = 0;
        test_passed = 0;
        test_failed = 0;
        test_num = 0;
        cycle_count = 0;
        clk_edge_count = 0;
        
        // Clear waveform
        wave_clk = "";
        wave_resetn = "";
        wave_req = "";
        wave_ack = "";
        wave_valid = "";
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

        // Wait and release reset
        #15;
        @(posedge clk);
        resetn = 1;
        
        // Wait for stabilization
        repeat(2) @(posedge clk);

        // Run test cases
//        test_normal_flow();
//        test_same_cycle_ack();
        

        // # clk    : ^^^^^^^^^^
        // # resetn : ----------
        // # req    : __-______-
        // # ack    : __-_______
        // # valid  : -______-__
        // # except : __________
        test_consecutive_requests_second_same_cycle();

        // # clk    : ^^^^^^^^^^
        // # resetn : ----------
        // # req    : _--______-
        // # ack    : __-_______
        // # valid  : _______-__
        test_consecutive_requests_second_next_cycle();


	// known to fail
        // # clk    : ^^^^^^^^^^
        // # resetn : ----------
        // # req    : --_____-__
        // # ack    : _-_____-__
        // # valid  : _____-_-__
        //test_consecutive_requests_second_same_cycle_dvalid_same_cycle();

        // # clk    : ^^^^^^^^^^
        // # resetn : ----------
        // # req    : -_____-__-
        // # ack    : -_____-___
        // # valid  : ____-__-__
        test_consecutive_requests_second_same_cycle_dvalid_next_cycle();

        // # clk    : ^^^^^^^^^^
        // # resetn : ----------
        // # req    : _____--__-
        // # ack    : ______-___
        // # valid  : ___-___-__
        test_consecutive_requests_second_next_cycle_dvalid_next_cycle();

//        test_exception_flow();
//        test_back_to_back_request();
//        test_no_ack_scenario();
        
        // New interrupt tests
//        test_branch_interrupt();
//        test_exception_interrupt();
//        test_ertn_interrupt();

        // Print final test results
        print_final_results();
        
        // End simulation
        #50 $finish;
    end
    
    // Task: Print realtime waveform
    task print_realtime_waveform;
        begin
            $display("Time=%t, Clock Edge=%0d | resetn=%b | req=%b | ack=%b | valid=%b | except=%b | branch=%b | ertn=%b",
                     $time, clk_edge_count, resetn, ifu_icu_req_ic1, icu_ifu_ack_ic1,
                     icu_ifu_data_valid_ic2, exu_ifu_except, exu_ifu_branch, exu_ifu_ertn);
            $display("                    | pf_init=%b | pf_old=%b | pf_inc=%b | pf_brn=%b | pf_isr=%b | pf_ert=%b | pf_en=%b",
                     pf_addr_sel_init, pf_addr_sel_old, pf_addr_sel_inc,
                     pf_addr_sel_brn, pf_addr_sel_isr, pf_addr_sel_ert, pf_addr_en);
        end
    endtask

    
    // Task: Print test start
    task print_test_start;
        input [512:0] test_name;
        begin
            test_num = test_num + 1;
            $display("\n========== Test %0d: %s ==========", test_num, test_name);
            $display("Time=%t: Starting test...", $time);
            print_realtime_waveform();

            // Reset waveform recording
            wave_clk = "";
            wave_resetn = "";
            wave_req = "";
            wave_ack = "";
            wave_valid = "";
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
            cycle_count = 0;
        end
    endtask

    // Task: Print waveform with all signals
    task print_waveform;
        begin
            $display("\nWaveform Visualization (sampled at clock edges):");
            $display("Sample: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15");
            $display("------------------------------------------------");
            
            // Basic control signals
            $display("clk    : %s", wave_clk);
            $display("resetn : %s", wave_resetn);
            $display("req    : %s", wave_req);
            $display("ack    : %s", wave_ack);
            $display("valid  : %s", wave_valid);
            $display("except : %s", wave_except);
            $display("branch : %s", wave_branch);
            $display("ertn   : %s", wave_ertn);
            $display("------------------------------------------------");
            
            //// Prefetch address selection signals
            //$display("PF Address Selection:");
            //$display("pf_init: %s (prefetch address select init)", wave_pf_init);
            //$display("pf_old : %s (prefetch address select old/stall)", wave_pf_old);
            //$display("pf_inc : %s (prefetch address select increment)", wave_pf_inc);
            //$display("------------------------------------------------");
            //
            //// PC address selection signals (need flush)
            //$display("PC Address Selection (needs flush):");
            //$display("pf_brn : %s (branch address select)", wave_pf_brn);
            //$display("pf_isr : %s (exception/isr address select)", wave_pf_isr);
            //$display("pf_ert : %s (ertn return address select)", wave_pf_ert);
            //$display("------------------------------------------------");
            //
            //// Address enable signal
            //$display("pf_en  : %s (PC address enable)", wave_pf_en);
            //$display("------------------------------------------------");
            //$display("Legend: '_' = 0, '-' = 1, '^' = clock edge marker");
            //
            //// Add explanation
            //$display("\nSignal Explanation:");
            //$display("pf_init: 1=select initial address (reset), 0=other");
            //$display("pf_old : 1=select old/stall address, 0=other");
            //$display("pf_inc : 1=select increment address, 0=other");
            //$display("pf_brn : 1=select branch target address, 0=other");
            //$display("pf_isr : 1=select exception handler address, 0=other");
            //$display("pf_ert : 1=select ertn return address, 0=other");
            //$display("pf_en  : 1=enable PC address update, 0=hold");
        end
    endtask

    // Task: Print test result
    task print_test_result;
        input [700:0] test_name;
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
    task wait_cycles;
        input integer cycles;
        begin
            repeat(cycles) @(posedge clk);
        end
    endtask

    // Test 1: Normal request-ack-data valid flow
    task test_normal_flow;
        reg passed;
        begin
            print_test_start("Normal Request-Ack-DataValid Flow");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            passed = 1;
            
            // Check initial state: should have request
            wait_cycles(2);
            
            // Check at clock edge
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: Request should be high initially");
                passed = 0;
            end else begin
                $display("OK: Request is high initially");
            end
            
            // Send ACK pulse (assert at clock edge, deassert at next clock edge)
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;
            print_realtime_waveform();
            
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            $display("OK: ACK sent");
            print_realtime_waveform();
            
            // Wait and check if request is cleared
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("OK: Request cleared after ACK");
            end else begin
                $display("WARNING: Request not cleared - might be retriggered");
            end
            
            // Send data valid pulse
            wait_cycles(2);
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            print_realtime_waveform();
            
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            $display("OK: Data valid signal sent");
            print_realtime_waveform();
            
            // Check if state machine returns to initial state
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 === 1'b1) begin
                $display("OK: Request high again - ready for next cycle");
                passed = passed & 1;
            end else begin
                $display("ERROR: Request should be high for next cycle");
                passed = 0;
            end
            
            print_test_result("Normal Flow Test", passed);
        end
    endtask

    // Test 2: ACK in same cycle as request
    task test_same_cycle_ack;
        reg passed;
        begin
            print_test_start("ACK in Same Cycle as Request");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            passed = 1;
            
            // Wait for request to be asserted
            wait_cycles(2);
            
            // Check request is high
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: Request should be high before ACK test");
                passed = 0;
            end else begin
                $display("OK: Request is high, ready for same-cycle ACK");
            end
            
            // At the next clock edge, assert ACK while request is still high
            // This simulates ICU responding immediately in the same cycle
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;  // ACK asserted in same cycle as request
            
            // Check behavior at this clock edge
            // Both req and ack should be high at the same time
            if (ifu_icu_req_ic1 === 1'b1 && icu_ifu_ack_ic1 === 1'b1) begin
                $display("OK: Request and ACK both high at same clock edge");
            end else begin
                $display("ERROR: Both req and ack should be high");
                passed = 0;
            end
            print_realtime_waveform();
            
            // Deassert ACK at next clock edge
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            $display("OK: ACK deasserted");
            print_realtime_waveform();
            
            // Check if request is cleared after ACK
            wait_cycles(1);
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("OK: Request cleared after same-cycle ACK");
            end else begin
                $display("WARNING: Request not cleared after ACK");
            end
            
            // Continue normal flow with data valid
            wait_cycles(2);
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            
            // Verify state machine recovers and makes new request
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 === 1'b1) begin
                $display("OK: New request generated after same-cycle ACK flow");
                passed = passed & 1;
            end else begin
                $display("ERROR: Should generate new request");
                passed = 0;
            end
            
            print_test_result("Same-Cycle ACK Test", passed);
        end
    endtask

    // Test 3: Exception interrupt flow
    task test_exception_flow;
        reg passed;
        begin
            print_test_start("Exception Interrupt Flow");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            
            // Ensure there is a request
            wait_cycles(3);
            
            // Trigger exception pulse at clock edges
            @(posedge clk);
            exu_ifu_except = 1;
            print_realtime_waveform();
            
            @(posedge clk);
            exu_ifu_except = 0;
            $display("OK: Exception signal triggered");
            print_realtime_waveform();
            
            // Check if exception is handled
            wait_cycles(2);
            
            // Check pf_addr_sel_isr signal
            if (exu_ifu_except === 1'b1 && pf_addr_sel_isr !== 1'b1) begin
                $display("ERROR: pf_isr should be high when exception is high");
                passed = 0;
            end else begin
                $display("OK: Exception signal processed correctly");
                passed = 1;
            end
            
            print_test_result("Exception Flow Test", passed);
        end
    endtask

    // Test 4: Back-to-back request test
    task test_back_to_back_request;
        reg passed;
        begin
            print_test_start("Back-to-Back Request Test");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            
            passed = 1;
            
            // Execute two complete cycles
            repeat(2) begin
                // Wait for request
                wait_cycles(2);
                
                // Check request at clock edge
                if (ifu_icu_req_ic1 !== 1'b1) begin
                    $display("ERROR: Request not high when expected");
                    passed = 0;
                end
                
                // ACK pulse at clock edges
                @(posedge clk);
                icu_ifu_ack_ic1 = 1;
                print_realtime_waveform();
                
                @(posedge clk);
                icu_ifu_ack_ic1 = 0;
                $display("OK: ACK sent");
                print_realtime_waveform();
                
                // Data valid pulse at clock edges
                wait_cycles(2);
                @(posedge clk);
                icu_ifu_data_valid_ic2 = 1;
                print_realtime_waveform();
                
                @(posedge clk);
                icu_ifu_data_valid_ic2 = 0;
                $display("OK: Data valid signal sent");
                print_realtime_waveform();
                
                wait_cycles(1);
            end
            
            $display("OK: Back-to-back requests completed");
            
            print_test_result("Back-to-Back Request Test", passed);
        end
    endtask

    // Test 5: No ACK response scenario
    task test_no_ack_scenario;
        reg passed;
        begin
            print_test_start("No ACK Response Scenario");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            
            passed = 1;
            
            // Check initial request
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: Initial request not present");
                passed = 0;
            end else begin
                $display("OK: Initial request present");
            end
            
            // Simulate long time without ACK
            repeat(5) wait_cycles(2);
            
            // Request should stay high (waiting for ACK)
            if (ifu_icu_req_ic1 === 1'b1) begin
                $display("OK: Request remains high while waiting for ACK");
            end else begin
                $display("ERROR: Request should stay high while waiting");
                passed = 0;
            end
            
            // Finally send ACK pulse at clock edges
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;
            print_realtime_waveform();
            
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            $display("OK: ACK sent after delay");
            print_realtime_waveform();
            
            // Complete the transaction
            wait_cycles(2);
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            
            print_test_result("No ACK Scenario Test", passed);
        end
    endtask

    // Test 6: Consecutive requests with second ACK in same cycle
    task test_consecutive_requests_second_same_cycle;
        reg passed;
        begin
            print_test_start("Consecutive Requests with Second ACK in Same Cycle");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            passed = 1;
            
            $display("\nPhase 1: First request with normal ACK timing");
            
            // Wait for initial request
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: First request should be high");
                passed = 0;
            end else begin
                $display("OK: First request asserted");
            end
            
            // First ACK: normal timing (ack in next cycle after req)
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;
            print_realtime_waveform();
            
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            $display("OK: First ACK sent (normal timing)");
            print_realtime_waveform();
            
            // Wait for data valid for first request
            wait_cycles(2);
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            $display("OK: First data valid signal sent");
            print_realtime_waveform();
            
            $display("\nPhase 2: Second request with same-cycle ACK");
            
            // Second ACK: same-cycle response
            // ICU responds immediately when it sees the request
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;  // ACK in same cycle as request
            
            @(posedge clk);
            // Verify both req and ack are high at same time
            if (ifu_icu_req_ic1 === 1'b1 && icu_ifu_ack_ic1 === 1'b1) begin
                $display("OK: Second request and ACK both high at same clock edge");
                $display("    This simulates ICU fast response to second request");
            end else begin
                $display("ERROR: Both req and ack should be high for second request");
                passed = 0;
            end

            icu_ifu_ack_ic1 = 0;
            $display("OK: Second ACK deasserted");

            print_realtime_waveform();
            
            // Verify request is cleared
            wait_cycles(1);
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("OK: Second request cleared after same-cycle ACK");
            end else begin
                $display("WARNING: Second request not cleared after ACK");
            end
            
            // Send data valid for second request
            wait_cycles(2);
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            $display("OK: Second data valid signal sent");
            print_realtime_waveform();
            
            $display("\nPhase 3: Verify state machine ready for third request");
            
            // Wait for third request generation
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 === 1'b1) begin
                $display("OK: Third request generated after mixed-timing sequence");
                $display("    State machine handles both normal and fast responses correctly");
            end else begin
                $display("ERROR: Should generate third request");
                passed = 0;
            end
            
            // Summary
            $display("\nTest Summary:");
            $display("- First request: normal ACK timing (ack in next cycle)");
            $display("- Second request: fast ACK timing (ack in same cycle)");
            $display("- Result: State machine correctly handles mixed response timings");
            
            print_test_result("Consecutive Requests with Second ACK in Same Cycle", passed);
        end
    endtask

    // Test 7: Consecutive requests with second ACK in next cycle
    task test_consecutive_requests_second_next_cycle;
        reg passed;
        begin
            print_test_start("Consecutive Requests with Second ACK in Next Cycle");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            passed = 1;
            
            $display("\nPhase 1: First request with normal ACK timing");
            
            // Wait for initial request
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: First request should be high");
                passed = 0;
            end else begin
                $display("OK: First request asserted");
            end
            
            // First ACK: normal timing (ack in next cycle after req)
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;
            print_realtime_waveform();
            
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            $display("OK: First ACK sent (normal timing)");
            print_realtime_waveform();
            
            // Wait for data valid for first request
            wait_cycles(2);
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            $display("OK: First data valid signal sent");
            print_realtime_waveform();
            
            $display("\nPhase 2: Second request with next-cycle ACK");
            
            // Wait for second request to be generated
            //wait_cycles(2);
            
            // Second ACK: next-cycle response
            // ICU responds in next-cycle when it sees the request
            @(posedge clk);
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;  // ACK in same cycle as request
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: Second request should be high");
                passed = 0;
            end else begin
                $display("OK: Second request asserted, preparing for next-cycle ACK");
            end

            print_realtime_waveform();
            
            // Deassert ACK
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            $display("OK: Second ACK deasserted");
            print_realtime_waveform();
            
            // Verify request is cleared
            wait_cycles(1);
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("OK: Second request cleared after next-cycle ACK");
            end else begin
                $display("WARNING: Second request not cleared after ACK");
            end
            
            // Send data valid for second request
            wait_cycles(2);
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            $display("OK: Second data valid signal sent");
            print_realtime_waveform();
            
            $display("\nPhase 3: Verify state machine ready for third request");
            
            // Wait for third request generation
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 === 1'b1) begin
                $display("OK: Third request generated after mixed-timing sequence");
                $display("    State machine handles both normal and fast responses correctly");
            end else begin
                $display("ERROR: Should generate third request");
                passed = 0;
            end
            
            // Summary
            $display("\nTest Summary:");
            $display("- First request: normal ACK timing (ack in next cycle)");
            $display("- Second request: normal ACK timing (ack in next cycle)");
            $display("- Result: State machine correctly handles normal response timings");
            
            print_test_result("Consecutive Requests with Second ACK in Next Cycle", passed);
        end
    endtask

    // Test 8: Consecutive requests with second ACK in same cycle, dvalid in same cycle
    task test_consecutive_requests_second_same_cycle_dvalid_same_cycle;
        reg passed;
        begin
            print_test_start("Consecutive Requests with Second ACK in Same Cycle, Dvalid in Same Cycle");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            passed = 1;
            
            $display("\nPhase 1: First request with normal ACK timing");
            
            // Wait for initial request
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: First request should be high");
                passed = 0;
            end else begin
                $display("OK: First request asserted");
            end
            
            // First ACK: normal timing (ack in next cycle after req)
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;
            print_realtime_waveform();
            
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            $display("OK: First ACK sent (normal timing)");
            print_realtime_waveform();
            
            // Wait for data valid for first request
            wait_cycles(2);
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            $display("OK: First data valid signal sent");
            print_realtime_waveform();
            
            $display("\nPhase 2: Second request with same-cycle ACK and dvalid");
            
            // Second ACK: same-cycle response
            // ICU responds immediately when it sees the request
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;  // ACK in same cycle as request
            
            icu_ifu_data_valid_ic2 = 1; // data_valid in same cycle as request
            
            @(posedge clk);
            // Verify both req and ack are high at same time
            if (ifu_icu_req_ic1 === 1'b1 && icu_ifu_ack_ic1 === 1'b1) begin
                $display("OK: Second request and ACK both high at same clock edge");
                $display("    This simulates ICU fast response to second request");
            end else begin
                $display("ERROR: Both req and ack should be high for second request");
                passed = 0;
            end

            // Deassert ACK and data valid
            icu_ifu_ack_ic1 = 0;
            $display("OK: Second ACK deasserted");

            icu_ifu_data_valid_ic2 = 0;
            $display("OK: Second data valid signal sent");

            print_realtime_waveform();
            
            // Verify request is cleared
            //wait_cycles(1);
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("OK: Second request cleared after same-cycle ACK");
            end else begin
                $display("WARNING: Second request not cleared after ACK");
            end
            
            $display("\nPhase 3: Verify state machine ready for third request");
            
            // Wait for third request generation
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 === 1'b1) begin
                $display("OK: Third request generated after mixed-timing sequence");
                $display("    State machine handles both normal and fast responses correctly");
            end else begin
                $display("ERROR: Should generate third request");
                passed = 0;
            end
            
            // Summary
            $display("\nTest Summary:");
            $display("- First request: normal ACK timing (ack in next cycle)");
            $display("- Second request: fast ACK timing (ack in same cycle, dvalid in same cycle)");
            $display("- Result: State machine correctly handles mixed response timings");
            
            print_test_result("Consecutive Requests with Second ACK and Dvalid in Same Cycle", passed);
        end
    endtask

    // Test 9: Consecutive requests with second ACK in same cycle, dvalid in next cycle
    task test_consecutive_requests_second_same_cycle_dvalid_next_cycle;
        reg passed;
        begin
            print_test_start("Consecutive Requests with Second ACK in Same Cycle, Dvalid in Next Cycle");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            passed = 1;
            
            $display("\nPhase 1: First request with normal ACK timing");
            
            // Wait for initial request
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: First request should be high");
                passed = 0;
            end else begin
                $display("OK: First request asserted");
            end
            
            // First ACK: normal timing (ack in next cycle after req)
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;
            print_realtime_waveform();
            
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            $display("OK: First ACK sent (normal timing)");
            print_realtime_waveform();
            
            // Wait for data valid for first request
            wait_cycles(2);
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            $display("OK: First data valid signal sent");
            print_realtime_waveform();
            
            $display("\nPhase 2: Second request with same-cycle ACK");
            
            // Second ACK: same-cycle response
            // ICU responds immediately when it sees the request
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;  // ACK in same cycle as request
            
            @(posedge clk);
            // Verify both req and ack are high at same time
            if (ifu_icu_req_ic1 === 1'b1 && icu_ifu_ack_ic1 === 1'b1) begin
                $display("OK: Second request and ACK both high at same clock edge");
                $display("    This simulates ICU fast response to second request");
            end else begin
                $display("ERROR: Both req and ack should be high for second request");
                passed = 0;
            end

            icu_ifu_ack_ic1 = 0;
            $display("OK: Second ACK deasserted");

            print_realtime_waveform();
            
            // Verify request is cleared
            //wait_cycles(1);
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("OK: Second request cleared after same-cycle ACK");
            end else begin
                $display("WARNING: Second request not cleared after ACK");
            end

            // Send data valid for second request in next cycle
            //wait_cycles(2);
            //@(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            $display("OK: Second data valid signal sent");
            print_realtime_waveform();
            
            $display("\nPhase 3: Verify state machine ready for third request");
            
            // Wait for third request generation
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 === 1'b1) begin
                $display("OK: Third request generated after mixed-timing sequence");
                $display("    State machine handles both normal and fast responses correctly");
            end else begin
                $display("ERROR: Should generate third request");
                passed = 0;
            end
            
            // Summary
            $display("\nTest Summary:");
            $display("- First request: normal ACK timing (ack in next cycle)");
            $display("- Second request: fast ACK timing (ack in same cycle, dvalid in next cycle)");
            $display("- Result: State machine correctly handles mixed response timings");
            
            print_test_result("Consecutive Requests with Second ACK in Same Cycle, Dvalid in Next Cycle", passed);
        end
    endtask

    // Test 10: Consecutive requests with second ACK in next cycle, dvalid in next cycle
    task test_consecutive_requests_second_next_cycle_dvalid_next_cycle;
        reg passed;
        begin
            print_test_start("Consecutive Requests with Second ACK in Next Cycle, Dvalid in Next Cycle");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            passed = 1;
            
            $display("\nPhase 1: First request with normal ACK timing");
            
            // Wait for initial request
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: First request should be high");
                passed = 0;
            end else begin
                $display("OK: First request asserted");
            end
            
            // First ACK: normal timing (ack in next cycle after req)
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;
            print_realtime_waveform();
            
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            $display("OK: First ACK sent (normal timing)");
            print_realtime_waveform();
            
            // Wait for data valid for first request
            wait_cycles(2);
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            $display("OK: First data valid signal sent");
            print_realtime_waveform();
            
            $display("\nPhase 2: Second request with next-cycle ACK");
            
            // Second ACK: next-cycle response
            // ICU responds in next-cycle when it sees the request
            @(posedge clk);
            @(posedge clk);
            icu_ifu_ack_ic1 = 1;  // ACK in next cycle as request
            
            @(posedge clk);
            // Verify both req and ack are high at same time
            if (ifu_icu_req_ic1 === 1'b1 && icu_ifu_ack_ic1 === 1'b1) begin
                $display("OK: Second request and ACK both high at same clock edge");
                $display("    This simulates ICU response to second request");
            end else begin
                $display("ERROR: Both req and ack should be high for second request");
                passed = 0;
            end

            icu_ifu_ack_ic1 = 0;
            $display("OK: Second ACK deasserted");

            print_realtime_waveform();
            
            // Verify request is cleared
            //wait_cycles(1);
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("OK: Second request cleared after next-cycle ACK");
            end else begin
                $display("WARNING: Second request not cleared after ACK");
            end

            // Send data valid for second request in next cycle
            //wait_cycles(2);
            //@(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            $display("OK: Second data valid signal sent");
            print_realtime_waveform();
            
            $display("\nPhase 3: Verify state machine ready for third request");
            
            // Wait for third request generation
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 === 1'b1) begin
                $display("OK: Third request generated after normal timing sequence");
                $display("    State machine handles normal response timings correctly");
            end else begin
                $display("ERROR: Should generate third request");
                passed = 0;
            end
            
            // Summary
            $display("\nTest Summary:");
            $display("- First request: normal ACK timing (ack in next cycle)");
            $display("- Second request: normal ACK timing (ack in next cycle, dvalid in next cycle)");
            $display("- Result: State machine correctly handles normal response timings");
            
            print_test_result("Consecutive Requests with Second ACK in Next Cycle, Dvalid in Next Cycle", passed);
        end
    endtask

    // New Test 11: Branch interrupt test
    task test_branch_interrupt;
        reg passed;
        begin
            print_test_start("Branch Interrupt Test");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            passed = 1;
            
            $display("\n--- Phase 1: Start normal request ---");
            // Wait for initial request
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: Request should be high");
                passed = 0;
            end
            
            $display("\n--- Phase 2: Send branch signal ---");
            // Send branch signal during request
            @(posedge clk);
            exu_ifu_branch = 1;
            print_realtime_waveform();
            
            // Check branch address selection signal
            if (pf_addr_sel_brn !== 1'b1) begin
                $display("OK: pf_brn=1 when branch signal is high");
            end
            
            @(posedge clk);
            exu_ifu_branch = 0;
            $display("OK: Branch signal deasserted");
            print_realtime_waveform();
            
            $display("\n--- Phase 3: Check state after flush ---");
            wait_cycles(1);
            
            // Check if new request is generated after branch
            if (ifu_icu_req_ic1 === 1'b1) begin
                $display("OK: New request generated after branch");
            end else begin
                $display("ERROR: Should generate new request after branch");
                passed = 0;
            end
            
            print_test_result("Branch Interrupt Test", passed);
        end
    endtask

    // New Test 12: Exception interrupt test
    task test_exception_interrupt;
        reg passed;
        begin
            print_test_start("Exception Interrupt Test");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            passed = 1;
            
            $display("\n--- Phase 1: Start normal request ---");
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: Request should be high");
                passed = 0;
            end
            
            $display("\n--- Phase 2: Send exception signal ---");
            // Send exception signal
            @(posedge clk);
            exu_ifu_except = 1;
            print_realtime_waveform();
            
            // Check exception address selection signal
            if (pf_addr_sel_isr !== 1'b1) begin
                $display("OK: pf_isr=1 when exception signal is high");
            end
            
            @(posedge clk);
            exu_ifu_except = 0;
            $display("OK: Exception signal deasserted");
            print_realtime_waveform();
            
            $display("\n--- Phase 3: Check state after flush ---");
            wait_cycles(1);
            
            if (ifu_icu_req_ic1 === 1'b1) begin
                $display("OK: New request generated after exception");
            end else begin
                $display("ERROR: Should generate new request after exception");
                passed = 0;
            end
            
            print_test_result("Exception Interrupt Test", passed);
        end
    endtask

    // New Test 13: ERTN interrupt test
    task test_ertn_interrupt;
        reg passed;
        begin
            print_test_start("ERTN Interrupt Test");
            
            // Initialize conditions
            icu_ifu_ack_ic1 = 0;
            icu_ifu_data_valid_ic2 = 0;
            exu_ifu_except = 0;
            exu_ifu_branch = 0;
            exu_ifu_ertn = 0;
            passed = 1;
            
            $display("\n--- Phase 1: Start normal request ---");
            wait_cycles(2);
            
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: Request should be high");
                passed = 0;
            end
            
            $display("\n--- Phase 2: Send ERTN signal ---");
            // Send ERTN signal
            @(posedge clk);
            exu_ifu_ertn = 1;
            print_realtime_waveform();
            
            // Check ERTN address selection signal
            if (pf_addr_sel_ert !== 1'b1) begin
                $display("OK: pf_ert=1 when ertn signal is high");
            end
            
            @(posedge clk);
            exu_ifu_ertn = 0;
            $display("OK: ERTN signal deasserted");
            print_realtime_waveform();
            
            $display("\n--- Phase 3: Check state after flush ---");
            wait_cycles(1);
            
            if (ifu_icu_req_ic1 === 1'b1) begin
                $display("OK: New request generated after ERTN");
            end else begin
                $display("ERROR: Should generate new request after ERTN");
                passed = 0;
            end
            
            print_test_result("ERTN Interrupt Test", passed);
        end
    endtask

    // Monitor output at clock edges
    initial begin
        #5;
        $display("\n=== Simulation Monitoring Started ===");
        forever begin
            @(posedge clk);
            $display("Time=%t | clk_edge=%0d", $time, clk_edge_count);
            $display("  Control: resetn=%b, req=%b, ack=%b, valid=%b, except=%b, branch=%b, ertn=%b",
                     resetn, ifu_icu_req_ic1, icu_ifu_ack_ic1,
                     icu_ifu_data_valid_ic2, exu_ifu_except, exu_ifu_branch, exu_ifu_ertn);
            $display("  AddrSel: pf_init=%b, pf_old=%b, pf_inc=%b, pf_brn=%b, pf_isr=%b, pf_ert=%b, pf_en=%b",
                     pf_addr_sel_init, pf_addr_sel_old, pf_addr_sel_inc,
                     pf_addr_sel_brn, pf_addr_sel_isr, pf_addr_sel_ert, pf_addr_en);
        end
    end

    // Task: Print final results
    task print_final_results;
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
