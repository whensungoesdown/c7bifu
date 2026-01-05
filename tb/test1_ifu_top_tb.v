`timescale 1ns/1ps

module top_tb();

    // Input signals
    reg clk;
    reg resetn;
    reg icu_ifu_ack_ic1;          // 添加ACK输入
    reg icu_ifu_data_valid_ic2;
    reg exu_ifu_except;
    reg exu_ifu_branch;
    reg exu_ifu_ertn;
    
    // Branch and interrupt address inputs
    reg [31:0] exu_ifu_isr_addr;
    reg [31:0] exu_ifu_brn_addr;
    reg [31:0] exu_ifu_ert_addr;
    
    // Output signals
    wire [31:0] ifu_icu_addr_ic1;
    wire ifu_icu_req_ic1;
    wire icu_data_vld;            // NEW: icu_data_vld output signal
    
    // Internal signals from c7bifu
    wire [31:0] pf_addr_q;
    wire pf_addr_sel_init;
    wire pf_addr_sel_old;
    wire pf_addr_sel_inc;
    wire pf_addr_sel_brn;
    wire pf_addr_sel_isr;
    wire pf_addr_sel_ert;
    wire pf_addr_en;
    
    // Test status variables
    reg [7:0] test_passed;
    reg [7:0] test_failed;
    integer test_num;
    
    // Waveform display variables
    integer cycle_count;
    reg [179:0] wave_clk;
    reg [179:0] wave_resetn;
    reg [179:0] wave_req;
    reg [179:0] wave_ack;          // 添加ACK波形
    reg [179:0] wave_valid;
    reg [179:0] wave_data_vld;     // NEW: icu_data_vld waveform
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
    reg ack_mode;  // 0 = 下一周期ACK, 1 = 同一周期ACK

    // Instantiate DUT
    c7bifu dut (
        .clk(clk),
        .resetn(resetn),
        .ifu_icu_addr_ic1(ifu_icu_addr_ic1),
        .ifu_icu_req_ic1(ifu_icu_req_ic1),
	.icu_ifu_ack_ic1(icu_ifu_ack_ic1),
        .icu_ifu_data_valid_ic2(icu_ifu_data_valid_ic2),
        .exu_ifu_except(exu_ifu_except),
        .exu_ifu_isr_addr(exu_ifu_isr_addr),
        .exu_ifu_branch(exu_ifu_branch),
        .exu_ifu_brn_addr(exu_ifu_brn_addr),
        .exu_ifu_ertn(exu_ifu_ertn),
        .exu_ifu_ert_addr(exu_ifu_ert_addr)
    );

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
            wave_data_vld <= {wave_data_vld[178:0], (icu_data_vld ? "-" : "_")}; // NEW: Add icu_data_vld to waveform
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
                // 同一周期ACK模式
                // 当看到req为高时，立即在同一周期给出ACK
                if (ifu_icu_req_ic1 == 1'b1) begin
                    icu_ifu_ack_ic1 = 1'b1;
                    @(posedge clk);
                    icu_ifu_ack_ic1 = 1'b0;
                    $display("Time=%t: Same-cycle ACK generated", $time);
                end
            end else begin
                // 下一周期ACK模式（默认）
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
        icu_ifu_ack_ic1 = 0;
        icu_ifu_data_valid_ic2 = 0;
        exu_ifu_except = 0;
        exu_ifu_branch = 0;
        exu_ifu_ertn = 0;
        exu_ifu_isr_addr = 32'h0;
        exu_ifu_brn_addr = 32'h0;
        exu_ifu_ert_addr = 32'h0;
        ack_mode = 1'b0;  // 默认下一周期ACK模式
        
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
        wave_data_vld = ""; // NEW: Initialize icu_data_vld waveform string
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
//        test_reset_sequence();
        
        // 测试不同ACK模式
        test_normal_increment_flow_long_cycle_ack_long_dvalid();
        test_normal_increment_flow_next_cycle_ack();  // 下一周期ACK
        test_normal_increment_flow_same_cycle_ack();  // 同一周期ACK
        
//        test_mixed_ack_modes();  // 混合ACK模式
        
        // 中断测试（使用同一周期ACK）
//        ack_mode = 1'b1;
//        test_branch_interrupt();

        test_exception_interrupt_no_datacancel();
        test_exception_interrupt_datacancel();

        test_branch_no_datacancel();
        test_branch_datacancel();

        test_ertn_no_datacancel();
        test_ertn_datacancel();

//        
//        test_back_to_back_requests();

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
            $display("Time=%t, Clock Edge=%0d | resetn=%b | req=%b | ack=%b | valid=%b | data_vld=%b | except=%b | branch=%b | ertn=%b", // MODIFIED: Added data_vld
                     $time, clk_edge_count, resetn, ifu_icu_req_ic1, icu_ifu_ack_ic1,
                     icu_ifu_data_valid_ic2, icu_data_vld, exu_ifu_except, exu_ifu_branch, exu_ifu_ertn); // MODIFIED: Added icu_data_vld
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
            wave_data_vld = ""; // NEW: Reset icu_data_vld waveform string
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
            $display("data_vld : %s", wave_data_vld); // NEW: Display icu_data_vld waveform
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
            // 在ACK之后等待1-2个周期，然后给出data valid
            //wait_cycles(1 + ($random % 2));
            //@(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b1; // send immediately, simulate icache hit
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b0;
            $display("Time=%t: Data valid generated", $time);
        end
    endtask

    // Task: Simulate data valid after ACK
    task automatic generate_data_valid_longcycle;
        begin
            // 在ACK之后等待1-2个周期，然后给出data valid
            wait_cycles(1 + ($random % 5));
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b1; // send immediately, simulate icache hit
            @(posedge clk);
            icu_ifu_data_valid_ic2 = 1'b0;
            $display("Time=%t: Data valid generated", $time);
        end
    endtask
    
    // ================================
    // TEST CASES
    // ================================
    
    // Test 1: Reset sequence test
    task automatic test_reset_sequence;
        reg passed;
        begin
            print_test_start("Reset Sequence Test");
            passed = 1'b1;
            
            // Apply reset
            resetn = 1'b0;
            wait_cycles(2);
            
            // Check initial address after reset
            if (ifu_icu_addr_ic1 !== 32'h1c000000) begin
                $display("ERROR: Reset address - Expected: 0x1c000000, Got: 0x%h", 
                        ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Reset address correct: 0x1c000000");
            end
            
            // Check request should be asserted
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: Request should be high after reset");
                passed = 1'b0;
            end
            
            // Release reset
            resetn = 1'b1;
            wait_cycles(2);
            
            // Request should remain high
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: Request should stay high after reset release");
                passed = 1'b0;
            end
            
            print_test_result("Reset Sequence Test", passed);
        end
    endtask

    // Test 1.5: Normal increment flow with long-cycle ACK, long-cycle dvalid
    task automatic test_normal_increment_flow_long_cycle_ack_long_dvalid;
        reg passed;
        integer i;
        begin
            print_test_start("Normal Increment Flow - Long-Cycle ACK, Long-Cycle dvalid");
            passed = 1'b1;
            
            // Set ACK mode to next-cycle
            ack_mode = 1'b0;
            
            // Start from reset state
            resetn = 1'b0;
            wait_cycles(1);
            resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            // Test 3 normal increments with next-cycle ACK
            for (i = 0; i < 3; i = i + 1) begin
                $display("\n--- Cycle %0d ---", i);
                
                // Check current address
                if (ifu_icu_addr_ic1 !== expected_pc) begin
                    $display("ERROR: Cycle %0d - Expected: 0x%h, Got: 0x%h", 
                            i, expected_pc, ifu_icu_addr_ic1);
                    passed = 1'b0;
                end else begin
                    $display("OK: Cycle %0d address correct: 0x%h", i, expected_pc);
                end
                
                wait_cycles(5); // long-cycle to simulate icache refill
                generate_ack();
                print_realtime_waveform();
                
                // Generate data valid
                generate_data_valid_longcycle();
                
                // PC should increment by 8
                expected_pc = expected_pc + 32'h8;
                
                wait_cycles(1);
            end
            
            // Final address check
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
            
            // Set ACK mode to next-cycle
            ack_mode = 1'b0;
            
            // Start from reset state
            resetn = 1'b0;
            wait_cycles(1);
            resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            // Test 3 normal increments with next-cycle ACK
            for (i = 0; i < 3; i = i + 1) begin
                $display("\n--- Cycle %0d ---", i);
                
                // Check current address
                if (ifu_icu_addr_ic1 !== expected_pc) begin
                    $display("ERROR: Cycle %0d - Expected: 0x%h, Got: 0x%h", 
                            i, expected_pc, ifu_icu_addr_ic1);
                    passed = 1'b0;
                end else begin
                    $display("OK: Cycle %0d address correct: 0x%h", i, expected_pc);
                end
                
                // Generate next-cycle ACK
                generate_ack();
                print_realtime_waveform();
                
                // Generate data valid
                generate_data_valid();
                
                // PC should increment by 8
                expected_pc = expected_pc + 32'h8;
                
                wait_cycles(1);
            end
            
            // Final address check
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
    
    // Test 3: Normal increment flow with same-cycle ACK, next cycle dvalid
    // # clk    : ^^^^^^^^^^
    // # resetn : ----------
    // # req    : --__-__-__
    // # ack    : _-__-__-__
    // # valid  : __-__-__-_
    // # except : __________
    // # branch : __________
    // # ertn   : __________
    // # ------------------------------------------------
    // # PF Address Selection:
    // # pf_init: __________ (select initial address)
    // # pf_old : ---_--_--_ (select old/stall address)
    // # pf_inc : ___-__-__- (select increment address)
    // # pf_brn : __________ (select branch address)
    // # pf_isr : __________ (select exception address)
    // # pf_ert : __________ (select ertn address)
    // # pf_en  : ___-__-__- (address update enable)

    task automatic test_normal_increment_flow_same_cycle_ack;
        reg passed;
        integer i;
        begin
            print_test_start("Normal Increment Flow - Same-Cycle ACK");
            passed = 1'b1;
            
            // Set ACK mode to same-cycle
            ack_mode = 1'b1;
            
            // Start from reset state
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
	    // Test 3 normal increments with same-cycle ACK
	    $display("\n--- Cycle %0d ---", 1);

	    // Check current address
	    if (ifu_icu_addr_ic1 !== expected_pc) begin
		    $display("ERROR: Cycle %0d - Expected: 0x%h, Got: 0x%h", 
			    i, expected_pc, ifu_icu_addr_ic1);
		    passed = 1'b0;
	    end else begin
		    $display("OK: Cycle %0d address correct: 0x%h", i, expected_pc);
	    end

	    // Wait for request to be high
	    //wait_cycles(1);

	    // Generate same-cycle ACK
	    //if (ifu_icu_req_ic1 == 1'b1) begin
	    // 在同一时钟周期内给ACK
	    icu_ifu_ack_ic1 = 1'b1;
	    //print_realtime_waveform();

	    @(posedge clk);
	    icu_ifu_ack_ic1 = 1'b0;
	    $display("Time=%t: Same-cycle ACK applied", $time);
	    //end

	    // Generate data valid
	    generate_data_valid();

	    // PC should increment by 8
	    expected_pc = expected_pc + 32'h8;

	    wait_cycles(1);

	    $display("\n--- Cycle %0d ---", 2);

	    // Check current address
	    if (ifu_icu_addr_ic1 !== expected_pc) begin
		    $display("ERROR: Cycle %0d - Expected: 0x%h, Got: 0x%h", 
			    i, expected_pc, ifu_icu_addr_ic1);
		    passed = 1'b0;
	    end else begin
		    $display("OK: Cycle %0d address correct: 0x%h", i, expected_pc);
	    end

	    // Wait for request to be high
	    //wait_cycles(1);

	    // Generate same-cycle ACK
	    //if (ifu_icu_req_ic1 == 1'b1) begin
	    // 在同一时钟周期内给ACK
	    icu_ifu_ack_ic1 = 1'b1;
	    //print_realtime_waveform();

	    @(posedge clk);
	    icu_ifu_ack_ic1 = 1'b0;
	    $display("Time=%t: Same-cycle ACK applied", $time);

	    // Generate data valid
	    generate_data_valid();

	    expected_pc = expected_pc + 32'h8;

	    wait_cycles(1);

	    $display("\n--- Cycle %0d ---", 3);

	    // Check current address
	    if (ifu_icu_addr_ic1 !== expected_pc) begin
		    $display("ERROR: Cycle %0d - Expected: 0x%h, Got: 0x%h", 
			    i, expected_pc, ifu_icu_addr_ic1);
		    passed = 1'b0;
	    end else begin
		    $display("OK: Cycle %0d address correct: 0x%h", i, expected_pc);
	    end

	    // Wait for request to be high
	    //wait_cycles(1);

	    // Generate same-cycle ACK
	    //if (ifu_icu_req_ic1 == 1'b1) begin
	    // 在同一时钟周期内给ACK
	    icu_ifu_ack_ic1 = 1'b1;
	    //print_realtime_waveform();

	    @(posedge clk);
	    icu_ifu_ack_ic1 = 1'b0;
	    $display("Time=%t: Same-cycle ACK applied", $time);

	    // Generate data valid
	    generate_data_valid();

	    expected_pc = expected_pc + 32'h8;

	    wait_cycles(1);
            
            // Final address check
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
    
    // Test 4: Mixed ACK modes
    task automatic test_mixed_ack_modes;
        reg passed;
        integer i;
        begin
            print_test_start("Mixed ACK Modes Test");
            passed = 1'b1;
            
            // Start from reset state
            resetn = 1'b0;
            wait_cycles(1);
            resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            // Test sequence with alternating ACK modes
            for (i = 0; i < 4; i = i + 1) begin
                $display("\n--- Cycle %0d ---", i);
                
                // Alternate between ACK modes
                ack_mode = i[0];  // 偶数周期用下一周期ACK，奇数周期用同一周期ACK
                
                // Check current address
                if (ifu_icu_addr_ic1 !== expected_pc) begin
                    $display("ERROR: Cycle %0d - Expected: 0x%h, Got: 0x%h", 
                            i, expected_pc, ifu_icu_addr_ic1);
                    passed = 1'b0;
                end else begin
                    $display("OK: Cycle %0d address correct: 0x%h", i, expected_pc);
                end
                
                // Generate ACK based on current mode
                if (ack_mode == 1'b0) begin
                    // 下一周期ACK
                    @(posedge clk);
                    icu_ifu_ack_ic1 = 1'b1;
                    print_realtime_waveform();
                    @(posedge clk);
                    icu_ifu_ack_ic1 = 1'b0;
                end else begin
                    // 同一周期ACK
                    // 等待req为高
                    wait_cycles(1);
                    if (ifu_icu_req_ic1 == 1'b1) begin
                        icu_ifu_ack_ic1 = 1'b1;
                        print_realtime_waveform();
                        @(posedge clk);
                        icu_ifu_ack_ic1 = 1'b0;
                    end
                end
                
                // Generate data valid
                generate_data_valid();
                
                // PC should increment by 8
                expected_pc = expected_pc + 32'h8;
                
                wait_cycles(1);
            end
            
            print_test_result("Mixed ACK Modes Test", passed);
        end
    endtask
    
    // Test 5: Branch interrupt with same-cycle ACK
    task automatic test_branch_interrupt;
        reg passed;
        begin
            print_test_start("Branch Interrupt - Same-Cycle ACK");
            passed = 1'b1;
            
            // Set ACK mode to same-cycle
            ack_mode = 1'b1;
            
            // Start from known state
            resetn = 1'b0;
            wait_cycles(1);
            resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            // Get one normal increment first with same-cycle ACK
            // Wait for request
            wait_cycles(1);
            
            // Give same-cycle ACK
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            // Data valid
            generate_data_valid();
            expected_pc = expected_pc + 32'h8;
            wait_cycles(2);
            
            // Now trigger branch with same-cycle ACK
            exu_ifu_branch = 1'b1;
            exu_ifu_brn_addr = 32'h80000000; // Branch target
            
            @(posedge clk);
            print_realtime_waveform();
            
            // Check branch address is selected
            if (ifu_icu_addr_ic1 !== 32'h80000000) begin
                $display("ERROR: Branch target address - Expected: 0x80000000, Got: 0x%h", 
                        ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Branch target address correct: 0x80000000");
            end
            
            @(posedge clk);
            exu_ifu_branch = 1'b0;
            
            // Give same-cycle ACK for branch target
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            // Simulate data valid for branch target
            generate_data_valid();
            
            // Next address should be branch target + 8
            expected_pc = 32'h80000000 + 32'h8;
            wait_cycles(2);
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Address after branch - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Address after branch correct: 0x%h", expected_pc);
            end
            
            print_test_result("Branch Interrupt - Same-Cycle ACK", passed);
        end
    endtask
    
    // Test 6: Exception interrupt without data_cancel
    // # clk      :      ^^^^^^^^^^^^^^^^^^
    // # resetn   :      _____-------------
    // # req      :      -_____---__----__-
    // # ack      :      ________-_____-___
    // # valid    :      _________-_____-__
    // # data_vld :      _________-_____-__
    // # except   :      ____________-_____
    // # branch   :      __________________
    // # ertn     :      __________________
    task automatic test_exception_interrupt_no_datacancel;
        reg passed;
        begin
            print_test_start("Exception Interrupt");
            passed = 1'b1;
            
            // Set ACK mode to same-cycle
            ack_mode = 1'b1;
            
            // Start from known state
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            // Get one normal increment first with same-cycle ACK
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            expected_pc = expected_pc + 32'h8;
            wait_cycles(2);
            
            // Trigger exception
            exu_ifu_except = 1'b1;
            exu_ifu_isr_addr = 32'h1c000100; // Exception handler
            
            @(posedge clk);
            print_realtime_waveform();
            
            // Check exception address is selected
            if (ifu_icu_addr_ic1 !== 32'h1c000100) begin
                $display("ERROR: Exception handler address - Expected: 0x1c000100, Got: 0x%h", 
                        ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Exception handler address correct: 0x1c000100");
            end
            
            //@(posedge clk);
            exu_ifu_except = 1'b0;
            
            // Give same-cycle ACK for exception handler
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            // Simulate data valid for exception handler
            generate_data_valid();

	    if (icu_data_vld !== 1'b1) begin
                $display("ERROR: icu_data_vld should be 1 after ERTN data valid");
                passed = 1'b0;
            end
            
            // Next address should be handler + 8
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
    
    // Test 6.5: Exception interrupt with data_cancel
    // # clk      : ^^^^^^^^^^^^^^^^^^^^^^
    // # resetn   : _---------------------
    // # req      : __---__-___--------__-
    // # ack      : ____-__-__________-___
    // # valid    : _____-__________-__-__
    // # data_vld : _____-_____________-__
    // # except   : __________-___________
    // # branch   : ______________________
    // # ertn     : ______________________
    task automatic test_exception_interrupt_datacancel;
        reg passed;
        begin
            print_test_start("Exception Interrupt - data_cancel");
            passed = 1'b1;
            
            // Set ACK mode to same-cycle
            ack_mode = 1'b1;
            
            // Start from known state
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            // Get one normal increment first with same-cycle ACK
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();

            @(posedge clk);

            expected_pc = expected_pc + 32'h8;
            icu_ifu_ack_ic1 = 1'b1; // next ack, same cycle
            @(posedge clk);
            icu_ifu_ack_ic1 = 1'b0; // next ack, same cycle

            wait_cycles(2);
            
            // Trigger exception
            exu_ifu_except = 1'b1;
            exu_ifu_isr_addr = 32'h1c000100; // Exception handler
            
            @(posedge clk);
            print_realtime_waveform();
            //@(posedge clk);
            exu_ifu_except = 1'b0;

	    // data_valid for the previous 0x1c000008
            generate_data_valid_longcycle();

	    if (icu_data_vld === 1'b1) begin
                $display("ERROR: icu_data_vld should not be 1 because data for 0x1c000008 is canceled");
                passed = 1'b0;
            end
            
            
            // Give ACK for the exception request
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            // Simulate data valid for exception handler
            generate_data_valid();

	    if (icu_data_vld !== 1'b1) begin
                $display("ERROR: icu_data_vld should be 1 after data valid");
                passed = 1'b0;
	    end else begin
                $display("OK: icu_data_vld is 1 after data valid for 0x1c000100");
                passed = 1'b1;
	    end
            
            // Next address should be handler + 8
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

    // Test 7: Branch without data_cancel
    // # clk      :      ^^^^^^^^^^^^^^^^^^
    // # resetn   :      _____-------------
    // # req      :      -_____---__----__-
    // # ack      :      ________-_____-___
    // # valid    :      _________-_____-__
    // # data_vld :      _________-_____-__
    // # except   :      __________________
    // # branch   :      ____________-_____
    // # ertn     :      __________________
    task automatic test_branch_no_datacancel;
        reg passed;
        begin
            print_test_start("Branch");
            passed = 1'b1;
            
            // Set ACK mode to same-cycle
            ack_mode = 1'b1;
            
            // Start from known state
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            // Get one normal increment first with same-cycle ACK
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            expected_pc = expected_pc + 32'h8;
            wait_cycles(2);
            
            // Trigger branch
            exu_ifu_branch = 1'b1;
            exu_ifu_brn_addr = 32'h1c000200; // Branch-to address
            
            @(posedge clk);
            print_realtime_waveform();
            
            // Check branch address is selected
            if (ifu_icu_addr_ic1 !== 32'h1c000200) begin
                $display("ERROR: Branch address - Expected: 0x1c000200, Got: 0x%h", 
                        ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Branch address correct: 0x1c000200");
            end
            
            //@(posedge clk);
            exu_ifu_branch = 1'b0;
            
            // Give same-cycle ACK for branch address
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            // Simulate data valid for branch address
            generate_data_valid();

	    if (icu_data_vld !== 1'b1) begin
                $display("ERROR: icu_data_vld should be 1 after branch address data valid");
                passed = 1'b0;
            end
            
            // Next address should be handler + 8
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
    
    // Test 7.5: Branch with data_cancel
    // # clk      : ^^^^^^^^^^^^^^^^^^^^^^
    // # resetn   : _---------------------
    // # req      : __---__-___--------__-
    // # ack      : ____-__-__________-___
    // # valid    : _____-__________-__-__
    // # data_vld : _____-_____________-__
    // # except   : ______________________
    // # branch   : __________-___________
    // # ertn     : ______________________
    task automatic test_branch_datacancel;
        reg passed;
        begin
            print_test_start("Branch - data_cancel");
            passed = 1'b1;
            
            // Set ACK mode to same-cycle
            ack_mode = 1'b1;
            
            // Start from known state
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            // Get one normal increment first with same-cycle ACK
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();

            @(posedge clk);

            expected_pc = expected_pc + 32'h8;
            icu_ifu_ack_ic1 = 1'b1; // next ack, same cycle
            @(posedge clk);
            icu_ifu_ack_ic1 = 1'b0; // next ack, same cycle

            wait_cycles(2);
            
            // Trigger branch
            exu_ifu_branch = 1'b1;
            exu_ifu_brn_addr = 32'h1c000200; // Branch address
            
            @(posedge clk);
            print_realtime_waveform();
            //@(posedge clk);
            exu_ifu_branch = 1'b0;

	    // data_valid for the previous 0x1c000008
            generate_data_valid_longcycle();

	    if (icu_data_vld === 1'b1) begin
                $display("ERROR: icu_data_vld should not be 1 because data for 0x1c000008 is canceled");
                passed = 1'b0;
            end
            
            
            // Give ACK for the branch request
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            // Simulate data valid for branch fetch data
            generate_data_valid();

	    if (icu_data_vld !== 1'b1) begin
                $display("ERROR: icu_data_vld should be 1 after data valid");
                passed = 1'b0;
	    end else begin
                $display("OK: icu_data_vld is 1 after data valid for 0x1c000200");
                passed = 1'b1;
	    end
            
            // Next address should be handler + 8
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

    // Test 8: ertn without data_cancel
    // # clk      :      ^^^^^^^^^^^^^^^^^^
    // # resetn   :      _____-------------
    // # req      :      -_____---__----__-
    // # ack      :      ________-_____-___
    // # valid    :      _________-_____-__
    // # data_vld :      _________-_____-__
    // # except   :      __________________
    // # branch   :      __________________
    // # ertn     :      ____________-_____
    task automatic test_ertn_no_datacancel;
        reg passed;
        begin
            print_test_start("ertn without data_cancel");
            passed = 1'b1;
            
            // Set ACK mode to same-cycle
            ack_mode = 1'b1;
            
            // Start from known state
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            // Get one normal increment first with same-cycle ACK
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();
            expected_pc = expected_pc + 32'h8;
            wait_cycles(2);
            
            // Trigger ertn
            exu_ifu_ertn = 1'b1;
            exu_ifu_ert_addr = 32'h1c000300; // ertn address
            
            @(posedge clk);
            print_realtime_waveform();
            
            // Check ertn address is selected
            if (ifu_icu_addr_ic1 !== 32'h1c000300) begin
                $display("ERROR: ertn address - Expected: 0x1c000300, Got: 0x%h", 
                        ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: ertn address correct: 0x1c000300");
            end
            
            //@(posedge clk);
            exu_ifu_ertn = 1'b0;
            
            // Give same-cycle ACK for ertn address
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            // Simulate data valid for ertn address
            generate_data_valid();

	    if (icu_data_vld !== 1'b1) begin
                $display("ERROR: icu_data_vld should be 1 after ertn address data valid");
                passed = 1'b0;
            end
            
            // Next address should be handler + 8
            expected_pc = 32'h1c000300 + 32'h8;
            wait_cycles(2);
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Address after ertn - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Address after ertn correct: 0x%h", expected_pc);
            end
            
            print_test_result("Branch - no data_cancel", passed);
        end
    endtask
    
    // Test 8.5: ertn with data_cancel
    // # clk      : ^^^^^^^^^^^^^^^^^^^^^^
    // # resetn   : _---------------------
    // # req      : __---__-___--------__-
    // # ack      : ____-__-__________-___
    // # valid    : _____-__________-__-__
    // # data_vld : _____-_____________-__
    // # except   : ______________________
    // # branch   : ______________________
    // # ertn     : __________-___________
    task automatic test_ertn_datacancel;
        reg passed;
        begin
            print_test_start("ertn with data_cancel");
            passed = 1'b1;
            
            // Set ACK mode to same-cycle
            ack_mode = 1'b1;
            
            // Start from known state
            resetn = 1'b0;
            wait_cycles(5);
            #2 resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            // Get one normal increment first with same-cycle ACK
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            generate_data_valid();

            @(posedge clk);

            expected_pc = expected_pc + 32'h8;
            icu_ifu_ack_ic1 = 1'b1; // next ack, same cycle
            @(posedge clk);
            icu_ifu_ack_ic1 = 1'b0; // next ack, same cycle

            wait_cycles(2);
            
            // Trigger ertn
            exu_ifu_ertn = 1'b1;
            exu_ifu_ert_addr = 32'h1c000300; // ertn address
            
            @(posedge clk);
            print_realtime_waveform();
            //@(posedge clk);
            exu_ifu_ertn = 1'b0;

	    // data_valid for the previous 0x1c000008
            generate_data_valid_longcycle();

	    if (icu_data_vld === 1'b1) begin
                $display("ERROR: icu_data_vld should not be 1 because data for 0x1c000008 is canceled");
                passed = 1'b0;
            end
            
            
            // Give ACK for the ertn request
            wait_cycles(1);
            if (ifu_icu_req_ic1 == 1'b1) begin
                icu_ifu_ack_ic1 = 1'b1;
                @(posedge clk);
                icu_ifu_ack_ic1 = 1'b0;
            end
            
            // Simulate data valid for ertn fetch data
            generate_data_valid();

	    if (icu_data_vld !== 1'b1) begin
                $display("ERROR: icu_data_vld should be 1 after data valid");
                passed = 1'b0;
	    end else begin
                $display("OK: icu_data_vld is 1 after data valid for 0x1c000300");
                passed = 1'b1;
	    end
            
            // Next address should be handler + 8
            expected_pc = 32'h1c000300 + 32'h8;
            wait_cycles(2);
            
            if (ifu_icu_addr_ic1 !== expected_pc) begin
                $display("ERROR: Address after ertn - Expected: 0x%h, Got: 0x%h", 
                        expected_pc, ifu_icu_addr_ic1);
                passed = 1'b0;
            end else begin
                $display("OK: Address after ertn correct: 0x%h", expected_pc);
            end
            
            print_test_result("ertn with data_cancel", passed);
        end
    endtask

    // Test 8: Back-to-back requests with same-cycle ACK
    task automatic test_back_to_back_requests;
        reg passed;
        integer i;
        begin
            print_test_start("Back-to-Back Requests - Same-Cycle ACK");
            passed = 1'b1;
            
            // Set ACK mode to same-cycle
            ack_mode = 1'b1;
            
            // Start from reset
            resetn = 1'b0;
            wait_cycles(1);
            resetn = 1'b1;
            wait_cycles(2);
            
            expected_pc = 32'h1c000000;
            
            // Test 5 consecutive fetches with same-cycle ACK
            for (i = 0; i < 5; i = i + 1) begin
                // Check address
                if (ifu_icu_addr_ic1 !== expected_pc) begin
                    $display("ERROR: Fetch %0d - Expected: 0x%h, Got: 0x%h", 
                            i, expected_pc, ifu_icu_addr_ic1);
                    passed = 1'b0;
                end
                
                // Wait for request to be high, then give same-cycle ACK
                wait_cycles(1);
                if (ifu_icu_req_ic1 == 1'b1) begin
                    icu_ifu_ack_ic1 = 1'b1;
                    print_realtime_waveform();
                    @(posedge clk);
                    icu_ifu_ack_ic1 = 1'b0;
                end
                
                // Generate data valid
                generate_data_valid();
                
                // Update expected PC
                expected_pc = expected_pc + 32'h8;
                
                wait_cycles(1);
            end
            
            // Verify request stays high throughout
            if (ifu_icu_req_ic1 !== 1'b1) begin
                $display("ERROR: Request should stay high during back-to-back fetches");
                passed = 1'b0;
            end
            
            print_test_result("Back-to-Back Requests - Same-Cycle ACK", passed);
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
            $display("  Control: resetn=%b, req=%b, ack=%b, valid=%b, data_vld=%b, except=%b, branch=%b, ertn=%b", // MODIFIED: Added data_vld
                     resetn, ifu_icu_req_ic1, icu_ifu_ack_ic1,
                     icu_ifu_data_valid_ic2, icu_data_vld, exu_ifu_except, exu_ifu_branch, exu_ifu_ertn); // MODIFIED: Added icu_data_vld
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
    
    // ================================
    // ADDITIONAL SIGNAL CONNECTIONS
    // ================================
    
    // Connect to internal signals for monitoring
    assign pf_addr_q = dut.pf_addr_q;
    assign pf_addr_sel_init = dut.pf_addr_sel_init;
    assign pf_addr_sel_old = dut.pf_addr_sel_old;
    assign pf_addr_sel_inc = dut.pf_addr_sel_inc;
    assign pf_addr_sel_brn = dut.pf_addr_sel_brn;
    assign pf_addr_sel_isr = dut.pf_addr_sel_isr;
    assign pf_addr_sel_ert = dut.pf_addr_sel_ert;
    assign pf_addr_en = dut.pf_addr_en;
    assign icu_data_vld = dut.icu_data_vld; // NEW: Connect icu_data_vld signal from DUT

endmodule
