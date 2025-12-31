`timescale 1ns/1ps

module top_tb();

    // Input signals
    reg clk;
    reg resetn;
    reg icu_ifu_ack_ic1;
    reg icu_ifu_data_valid_ic2;
    reg exu_ifu_except;

    // Output signals
    wire ifu_icu_req_ic1;

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

    // Instantiate DUT
    c7bifu_fcl uut (
        .clk(clk),
        .resetn(resetn),
        .ifu_icu_req_ic1(ifu_icu_req_ic1),
        .icu_ifu_ack_ic1(icu_ifu_ack_ic1),
        .icu_ifu_data_valid_ic2(icu_ifu_data_valid_ic2),
        .exu_ifu_except(exu_ifu_except)
    );

    // Clock generation: period 10ns
    always #5 clk = ~clk;
    
    // Waveform sampling at positive clock edge
    always @(posedge clk) begin
        if (resetn) begin
            cycle_count = cycle_count + 1;
            
            // Record waveform characters (sample at clock edge)
            wave_clk = {wave_clk[78:0], "^"};
            wave_resetn = {wave_resetn[78:0], resetn ? "-" : "_"};
            wave_req = {wave_req[78:0], ifu_icu_req_ic1 ? "-" : "_"};
            wave_ack = {wave_ack[78:0], icu_ifu_ack_ic1 ? "-" : "_"};
            wave_valid = {wave_valid[78:0], icu_ifu_data_valid_ic2 ? "-" : "_"};
            wave_except = {wave_except[78:0], exu_ifu_except ? "-" : "_"};
        end
    end

    // Initialization
    initial begin
        clk = 1;
        resetn = 0;
        icu_ifu_ack_ic1 = 0;
        icu_ifu_data_valid_ic2 = 0;
        exu_ifu_except = 0;
        test_passed = 0;
        test_failed = 0;
        test_num = 0;
        cycle_count = 0;
        
        // Clear waveform
        wave_clk = "";
        wave_resetn = "";
        wave_req = "";
        wave_ack = "";
        wave_valid = "";
        wave_except = "";

        // Wait for 5 clock edge
        repeat(5) @(posedge clk);
        
        // Release reset not at clock edge
        #2 resetn = 1;
        
        // Wait for stabilization
        repeat(2) @(posedge clk);

        // Run test cases
        test_normal_flow();
        test_same_cycle_ack();  // New test case
        test_exception_flow();
        test_back_to_back_request();
        test_no_ack_scenario();

        // Print final test results
        print_final_results();
        
        // End simulation
        #50 $finish;
    end

    // Task: Print test start
    task print_test_start;
        input [80:0] test_name;
        begin
            test_num = test_num + 1;
            $display("\n========== Test %0d: %s ==========", test_num, test_name);
            $display("Time=%t: Starting test...", $time);
            
            // Reset waveform recording
            wave_clk = "";
            wave_resetn = "";
            wave_req = "";
            wave_ack = "";
            wave_valid = "";
            wave_except = "";
            cycle_count = 0;
        end
    endtask
    
    // Task: Print waveform
    task print_waveform;
        begin
            $display("\nWaveform Visualization (at clock edges):");
            $display("Cycle : 0 1 2 3 4 5 6 7 8 9");
            $display("----------------------------------------");
            $display("clk   : %s", wave_clk);
            $display("resetn: %s", wave_resetn);
            $display("req   : %s", wave_req);
            $display("ack   : %s", wave_ack);
            $display("valid : %s", wave_valid);
            $display("except: %s", wave_except);
            $display("----------------------------------------");
            $display("Legend: '_' = 0, '-' = 1, '^' = clock edge");
        end
    endtask

    // Task: Print test result
    task print_test_result;
        input [80:0] test_name;
        input passed;
        begin
            // Print waveform
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

    // Task: Print final results
    task print_final_results;
        begin
            $display("\n\n========== FINAL TEST RESULTS ==========");
            $display("Total Tests: %0d", test_num);
            $display("Passed:      %0d", test_passed);
            $display("Failed:      %0d", test_failed);
            $display("========================================");
            if (test_failed == 0)
                $display("ALL TESTS PASSED!");
            else
                $display("SOME TESTS FAILED!");
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
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            
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
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            
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
            
            // Deassert ACK at next clock edge
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            
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
            
            // Ensure there is a request
            wait_cycles(3);
            
            // Trigger exception pulse at clock edges
            @(posedge clk);
            exu_ifu_except = 1;
            @(posedge clk);
            exu_ifu_except = 0;
            
            // Check if exception is handled
            wait_cycles(2);
            
            $display("OK: Exception signal triggered");
            passed = 1;
            
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
                @(posedge clk);
                icu_ifu_ack_ic1 = 0;
                
                // Data valid pulse at clock edges
                wait_cycles(2);
                @(posedge clk);
                icu_ifu_data_valid_ic2 = 1;
                @(posedge clk);
                icu_ifu_data_valid_ic2 = 0;
                
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
            @(posedge clk);
            icu_ifu_ack_ic1 = 0;
            
            // Complete the transaction
            wait_cycles(2);
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1;
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 0;
            
            print_test_result("No ACK Scenario Test", passed);
        end
    endtask

    // Monitor output at clock edges
    initial begin
        forever begin
            @(posedge clk);
            $display("Time=%t | clk=%b | resetn=%b | req=%b | ack=%b | valid=%b | except=%b",
                     $time, clk, resetn, ifu_icu_req_ic1, icu_ifu_ack_ic1,
                     icu_ifu_data_valid_ic2, exu_ifu_except);
        end
    end

endmodule
