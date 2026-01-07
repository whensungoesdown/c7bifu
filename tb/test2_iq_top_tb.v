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
reg  [31:0] data_addr;
reg  [63:0] data;
reg         data_vld;
reg         stall;
reg         flush;
wire        iq_full;
wire [31:0] inst_addr;
wire [31:0] inst;
wire        inst_vld;

// ================= Instantiate DUT =================
c7bifu_iq dut (
    .clk         (clk),
    .resetn      (resetn),
    .data_addr   (data_addr),
    .data        (data),
    .data_vld    (data_vld),
    .stall       (stall),
    .flush       (flush),
    .iq_full     (iq_full),
    .inst_addr   (inst_addr),
    .inst        (inst),
    .inst_vld    (inst_vld)
);

// ================= Test Variables =================
integer test_num;
integer error_count;
integer cycle_count;

// ================= Helper Functions =================
function [79:0] get_separator;
    input [7:0] char;
    input integer length;
    integer i;
    reg [79:0] result;
    begin
        result = "";
        for (i = 0; i < length && i < 80; i = i + 1) begin
            result = {result, char};
        end
        get_separator = result;
    end
endfunction

// ================= Enhanced Test Sequences =================
task reset_test;
    begin
        $display("\n[%0t] ==================================================", $time);
        $display("[%0t] Test %0d: Reset Test", $time, test_num);
        $display("[%0t] ==================================================", $time);
        
        resetn = 1'b0;
        data_addr = 32'h0;
        data = 64'h0;
        data_vld = 1'b0;
        stall = 1'b0;
        flush = 1'b0;
        @(posedge clk);
        @(posedge clk);
        
        // Check outputs during reset
        if (iq_full !== 1'b0) begin
            $display("  ERROR: iq_full should be 0 during reset, got %b", iq_full);
            error_count = error_count + 1;
        end
        
        if (inst_vld !== 1'b0) begin
            $display("  ERROR: inst_vld should be 0 during reset, got %b", inst_vld);
            error_count = error_count + 1;
        end
        
        resetn = 1'b1;
        @(posedge clk);
        @(posedge clk);
        
        $display("  Reset test completed");
        test_num = test_num + 1;
    end
endtask

task write_packets;
    input [31:0] start_addr;
    input [31:0] num_packets;
    input [31:0] data_pattern;
    reg [31:0] i;
    integer packets_written;
    begin
        $display("\n[%0t] ==================================================", $time);
        $display("[%0t] Test %0d: Write %0d packets", $time, test_num, num_packets);
        $display("[%0t] ==================================================", $time);
        
        i = 0;
        packets_written = 0;
        while (i < num_packets) begin
            data_addr = start_addr + (i * 8);
            data = {32'h1000 + data_pattern + i, 32'h2000 + data_pattern + i};
            data_vld = 1'b1;
            
            @(posedge clk);
            
            if (!iq_full) begin
                packets_written = packets_written + 1;
                $display("  Packet %0d written: Addr=0x%08h, Data=0x%016h", 
                         i, data_addr, data);
            end else begin
                $display("  Queue FULL! Packet %0d not written", i);
                data_vld = 1'b0;  // Stop writing when full
                i = num_packets;  // Exit loop
            end
            i = i + 1;
        end
        
        data_vld = 1'b0;
        //@(posedge clk);
        
        $display("  Total packets written: %0d", packets_written);
        test_num = test_num + 1;
    end
endtask

task read_instructions;
    input [31:0] max_cycles;
    reg [31:0] i;
    integer instructions_read;
    begin
        $display("\n[%0t] ==================================================", $time);
        $display("[%0t] Test %0d: Read instructions (max %0d cycles)", 
                 $time, test_num, max_cycles);
        $display("[%0t] ==================================================", $time);
        
        stall = 1'b0;
        i = 0;
        instructions_read = 0;
        
        while (i < max_cycles) begin
            @(posedge clk);
            
            if (inst_vld) begin
                $display("  Cycle %0d: Read Addr=0x%08h, Inst=0x%08h", 
                         i, inst_addr, inst);
                instructions_read = instructions_read + 1;
            end
            i = i + 1;
        end
        
        stall = 1'b1;
        @(posedge clk);
        
        $display("  Total instructions read: %0d", instructions_read);
	if (instructions_read !== 4) begin
            $display("  ERROR: Should read 4 instructions!");
            error_count = error_count + 1;
	end

        test_num = test_num + 1;
    end
endtask

task test_queue_capacity;
    reg [31:0] i;
    integer expected_full_at;
    begin
        $display("\n[%0t] ==================================================", $time);
        $display("[%0t] Test %0d: Queue Capacity Test", $time, test_num);
        $display("[%0t] ==================================================", $time);
        
        // Queue depth is 4 instructions
        // Each write is 2 instructions (64-bit)
        // So after 2 writes (4 instructions), queue should be full
        
        $display("  Queue capacity: 4 instructions");
        $display("  Each write: 2 instructions (64-bit)");
        $display("  Expected: Queue should be full after 2 writes");
        
        data_vld = 1'b1;
        data_addr = 32'h1000;
        i = 0;
        expected_full_at = 2;  // Should be full after 2 writes
        
        while (i < 4) begin  // Try 4 writes (would be 8 instructions if no limit)
            data_vld = 1'b1;
            data = {32'hA0000000 + i, 32'hB0000000 + i};
            
            @(posedge clk);
            
            $display("  Write %0d: iq_full = %b", i, iq_full);
            
            if (iq_full) begin
                if (i == expected_full_at) begin
                    $display("  SUCCESS: Queue full at write %0d as expected", i);
                end else begin
                    $display("  ERROR: Queue full at write %0d, expected at %0d", 
                             i, expected_full_at);
                    error_count = error_count + 1;
                end
                i = 4;  // Exit loop
            end
            
	    // data_vld at every cycle
            //data_vld = 1'b0;
            //@(posedge clk);

            data_addr = data_addr + 8;
            i = i + 1;
        end
        
        if (!iq_full && i >= 4) begin
            $display("  ERROR: Queue never became full after %0d writes!", i);
            error_count = error_count + 1;
        end
        
        data_vld = 1'b0;
        @(posedge clk);
        test_num = test_num + 1;
    end
endtask

task test_flush_operation;
    begin
        $display("\n[%0t] ==================================================", $time);
        $display("[%0t] Test %0d: Flush Operation Test", $time, test_num);
        $display("[%0t] ==================================================", $time);
        
        // Write some data
        $display("  Writing 2 packets...");
        write_packets(32'h2000, 2, 32'h1000);
        
        // Check if queue has data
        //@(posedge clk);
        if (iq_full) begin
            $display("  Queue is full before flush");
        end
        
        // Apply flush
        $display("  Applying flush...");
        flush = 1'b1;
        @(posedge clk);
        flush = 1'b0;
        @(posedge clk);
        
        // Check that queue appears empty
        if (iq_full !== 1'b0) begin
            $display("  ERROR: iq_full should be 0 after flush, got %b", iq_full);
            error_count = error_count + 1;
        end
        
        if (inst_vld !== 1'b0) begin
            $display("  ERROR: inst_vld should be 0 after flush, got %b", inst_vld);
            error_count = error_count + 1;
        end
        
        // Try to read - should get nothing
        $display("  Trying to read after flush...");
        stall = 1'b0;
        repeat(3) @(posedge clk);
        
        if (inst_vld) begin
            $display("  ERROR: Should not read valid data after flush");
            error_count = error_count + 1;
        end
        
        stall = 1'b1;
        @(posedge clk);
        
        $display("  Flush test completed");
        test_num = test_num + 1;
    end
endtask

task test_stall_operation;
    begin
        $display("\n[%0t] ==================================================", $time);
        $display("[%0t] Test %0d: Stall Operation Test", $time, test_num);
        $display("[%0t] ==================================================", $time);
        
        // Write some data
        $display("  Writing 1 packet...");
        write_packets(32'h3000, 1, 32'h2000);
        
        // Apply stall and check no output
        $display("  Applying stall...");
        stall = 1'b1;
        repeat(3) @(posedge clk);
        
        if (inst_vld !== 1'b0) begin
            $display("  ERROR: Should not output when stalled, inst_vld = %b", inst_vld);
            error_count = error_count + 1;
        end
        
        // Release stall and read
        $display("  Releasing stall...");
        stall = 1'b0;

        @(posedge clk);

        if (!inst_vld) begin
            $display("  ERROR: No instruction read after releasing stall");
            error_count = error_count + 1;
        end
        
        @(posedge clk);

        if (!inst_vld) begin
            $display("  ERROR: Should read 2 instructions");
            error_count = error_count + 1;
        end
        
        $display("  Stall test completed");
        test_num = test_num + 1;
    end
endtask

task test_concurrent_operations;
    begin
        $display("\n[%0t] ==================================================", $time);
        $display("[%0t] Test %0d: Concurrent Operations Test", $time, test_num);
        $display("[%0t] ==================================================", $time);
        
        $display("  Starting concurrent write and read...");
        
        fork
            // Write thread: try to write 4 packets
            begin : write_thread
                reg [31:0] i;
                i = 0;
                while (i < 4) begin
                    data_addr = 32'h4000 + (i * 8);
                    data = {32'hC0000000 + i, 32'hD0000000 + i};
                    data_vld = 1'b1;
                    @(posedge clk);
                    
                    if (iq_full) begin
                        $display("    Write %0d: Queue full, stopping writes", i);
                        data_vld = 1'b0;
                        i = 4;  // Exit loop
                    end
                    i = i + 1;
                end
                data_vld = 1'b0;
            end
            
            // Read thread: read for 10 cycles
            begin : read_thread
                reg [31:0] i;
                stall = 1'b0;
                i = 0;
                while (i < 10) begin
                    @(posedge clk);
                    if (inst_vld) begin
                        $display("    Read cycle %0d: Addr=0x%08h", i, inst_addr);
                    end
                    i = i + 1;
                end
            end
        join
        
        stall = 1'b1;
        @(posedge clk);
        
        $display("  Concurrent operations test completed");
        test_num = test_num + 1;
    end
endtask

// ================= Main Test Sequence =================
initial begin
    // Initialize
    test_num = 1;
    error_count = 0;
    cycle_count = 0;
    
    data_addr = 32'h0;
    data = 64'h0;
    data_vld = 1'b0;
    stall = 1'b0;
    flush = 1'b0;
    
    // Wait for reset to be released
    @(posedge resetn);
    repeat(2) @(posedge clk);
    
    $display("\n==================================================");
    $display("Starting c7bifu_iq Testbench - Comprehensive Tests");
    $display("==================================================");
    $display("Queue Depth: 4 instructions (128 bytes)");
    $display("Write: 64-bit (2 instructions per write)");
    $display("Read: 32-bit (1 instruction per read)");
    $display("==================================================\n");
    
    // ================= Run All Tests =================
    // Test 1: Reset functionality
    reset_test;
    
    // Test 2: Queue capacity and full detection
    test_queue_capacity;
    
    // Clear queue by reading
    $display("\n[%0t] Clearing queue...", $time);
    stall = 1'b0;
    repeat(10) @(posedge clk);
    stall = 1'b1;
    @(posedge clk);
    
    // Test 3: Basic write and read
    $display("\n[%0t] ==================================================", $time);
    $display("[%0t] Test %0d: Basic Write/Read Test", $time, test_num);
    $display("[%0t] ==================================================", $time);
    write_packets(32'h00001000, 2, 32'h0000);
    read_instructions(8);
    
    // Test 4: Flush operation
    test_flush_operation;
    
    // Test 5: Stall operation
    test_stall_operation;
    
//    // Test 6: Concurrent operations
//    test_concurrent_operations;
    
    // ================= Final Summary =================
    $display("\n==================================================");
    $display("TEST SUITE SUMMARY");
    $display("--------------------------------------------------");
    $display("Total tests completed: %0d", test_num - 1);
    $display("Total errors detected: %0d", error_count);
    
    if (error_count == 0) begin
        $display("\nALL TESTS PASSED!");
        $display("Instruction Queue is functioning correctly.");
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

// ================= Cycle Counter and Monitoring =================
always @(posedge clk) begin
    cycle_count = cycle_count + 1;
end

// ================= Enhanced Monitoring =================
always @(posedge clk) begin
    // Monitor control state changes
    if (resetn && (data_vld || inst_vld || flush || stall)) begin
        $display("[%0t] Cycle %0d: state={wr:%b, rd:%b, full:%b, flush:%b, stall:%b}", 
                 $time, cycle_count, 
                 data_vld, inst_vld, iq_full, flush, stall);
    end
end

// ================= Waveform Dumping =================
initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, top_tb);
end

endmodule
