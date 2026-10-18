//altera message_off 10230

// Warning (10230): Verilog HDL assignment warning at c7bifu_iq.v(60): truncated value with size 32 to match size of target (3)

module c7bifu_iq (
    input              clk,
    input              resetn,
    input  [31:0]      data_addr,
    input  [63:0]      data,
    input              data_vld,
    input  [31:0]      start_addr,
    input              stall,
    input              flush,
    // fetch exception entry: queued in program order like an instruction
    input              exc_req,
    input  [5:0]       exc_code,
    input  [31:0]      exc_addr,
    output             exc_ack,
    output             iq_full,
    output [31:0]      inst_addr,
    output [31:0]      inst,
    output             inst_vld,
    output             inst_exc,
    output [5:0]       inst_exc_code
);

// ================= Parameter Definitions =================
parameter DEPTH_BYTES = 128;
parameter DEPTH_WORDS = 4;
parameter WORD_BYTES = 4;
localparam PTR_WIDTH = 2;  // For 4 entries, need 2 bits for indexing
localparam COUNTER_WIDTH = PTR_WIDTH + 1;  // 3 bits for counting 0-4 entries

// ================= Internal Signal Definitions =================
reg [31:0] queue_addr [0:DEPTH_WORDS-1];
reg [31:0] queue_data [0:DEPTH_WORDS-1];
reg        queue_exc  [0:DEPTH_WORDS-1];
reg [5:0]  queue_exc_code [0:DEPTH_WORDS-1];
reg [PTR_WIDTH:0] wr_ptr;     // One extra bit for full/empty detection
reg [PTR_WIDTH:0] rd_ptr;     // One extra bit for full/empty detection

// Entry counter for tracking queue occupancy
reg [PTR_WIDTH:0] entry_count;

// Start address alignment handling
reg skip_first_half;
reg [31:0] expected_addr;

// Control signals
wire wr_en;
wire rd_en;
wire queue_full;
wire queue_empty;
wire [PTR_WIDTH-1:0] wr_ptr_idx;
wire [PTR_WIDTH-1:0] rd_ptr_idx;

// ================= Alignment Handling =================
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        skip_first_half <= 1'b0;
        expected_addr <= 32'b0;
    end else if (flush) begin
        skip_first_half <= start_addr[2];
        expected_addr <= {start_addr[31:3], 3'b000};
    end else if (wr_en && skip_first_half && (data_addr == expected_addr)) begin
        skip_first_half <= 1'b0;
    end
end

// ================= Queue Status =================
wire [PTR_WIDTH:0] free_slots;
// Convert DEPTH_WORDS to proper width for subtraction
assign free_slots = DEPTH_WORDS - entry_count;

// Queue full: need at least 2 free slots for 64-bit data
assign queue_full = (free_slots < 2);

// Queue empty
assign queue_empty = (entry_count == 0);

assign iq_full = queue_full;

// ================= Control Signals =================
assign wr_en = data_vld && !queue_full;
assign rd_en = !stall && !queue_empty && !flush;

// An exception entry takes one slot. It never comes with fetch data (the
// faulting fetch returns none), data has priority anyway.
wire wr_exc = exc_req && !data_vld && (entry_count != DEPTH_WORDS) && !flush;
assign exc_ack = wr_exc;

// entries written this cycle
wire [PTR_WIDTH:0] wr_num = wr_en  ? ((skip_first_half && (data_addr == expected_addr)) ? 1 : 2) :
                            wr_exc ? 1 : 0;

// ================= Entry Counter Logic =================
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        entry_count <= {(PTR_WIDTH+1){1'b0}};
    end else if (flush) begin
        entry_count <= {(PTR_WIDTH+1){1'b0}};
    end else begin
        entry_count <= entry_count + wr_num - (rd_en ? 1 : 0);
    end
end

// ================= Pointer Index Calculation =================
// Key fix: Ensure pointer indices wrap correctly
assign wr_ptr_idx = wr_ptr[PTR_WIDTH-1:0];
assign rd_ptr_idx = rd_ptr[PTR_WIDTH-1:0];

// ================= FIFO Pointer Logic =================
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        wr_ptr <= {(PTR_WIDTH+1){1'b0}};
        rd_ptr <= {(PTR_WIDTH+1){1'b0}};
    end else if (flush) begin
        wr_ptr <= {(PTR_WIDTH+1){1'b0}};
        rd_ptr <= {(PTR_WIDTH+1){1'b0}};
    end else begin
        // Write pointer update
        wr_ptr <= wr_ptr + wr_num;
        
        // Read pointer update
        if (rd_en) begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end
end

// ================= Data Write Logic =================
integer i;

always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        for (i = 0; i < DEPTH_WORDS; i = i + 1) begin
            queue_addr[i] <= 32'b0;
            queue_data[i] <= 32'b0;
        end
    end else if (flush) begin
        for (i = 0; i < DEPTH_WORDS; i = i + 1) begin
            queue_addr[i] <= 32'b0;
            queue_data[i] <= 32'b0;
        end
    end else if (wr_en) begin
        if (skip_first_half && (data_addr == expected_addr)) begin
            // Only write high 32 bits
            queue_addr[wr_ptr_idx] <= expected_addr + 32'h4;
            queue_data[wr_ptr_idx] <= data[63:32];
        end else begin
            // Write full 64 bits
            queue_addr[wr_ptr_idx] <= data_addr;
            queue_data[wr_ptr_idx] <= data[31:0];
            
            // Key fix: Correctly handle wrap-around
            if (DEPTH_WORDS == 4) begin
                case (wr_ptr_idx)
                    2'b00: begin
                        queue_addr[2'b01] <= data_addr + 32'h4;
                        queue_data[2'b01] <= data[63:32];
                    end
                    2'b01: begin
                        queue_addr[2'b10] <= data_addr + 32'h4;
                        queue_data[2'b10] <= data[63:32];
                    end
                    2'b10: begin
                        queue_addr[2'b11] <= data_addr + 32'h4;
                        queue_data[2'b11] <= data[63:32];
                    end
                    2'b11: begin
                        queue_addr[2'b00] <= data_addr + 32'h4;
                        queue_data[2'b00] <= data[63:32];
                    end
                endcase
            end else begin
                // Generic wrap-around handling
                queue_addr[(wr_ptr_idx + 1) % DEPTH_WORDS] <= data_addr + 32'h4;
                queue_data[(wr_ptr_idx + 1) % DEPTH_WORDS] <= data[63:32];
            end
        end
    end else if (wr_exc) begin
        // exception entry: the faulting address, no instruction
        queue_addr[wr_ptr_idx] <= exc_addr;
        queue_data[wr_ptr_idx] <= 32'b0;
    end
end

// Exception flag of each entry. A data write clears the flags of the slots
// it may fill (the second slot is free whenever wr_en is set), an exception
// entry sets it.
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        for (i = 0; i < DEPTH_WORDS; i = i + 1) begin
            queue_exc[i] <= 1'b0;
            queue_exc_code[i] <= 6'b0;
        end
    end else if (flush) begin
        for (i = 0; i < DEPTH_WORDS; i = i + 1) begin
            queue_exc[i] <= 1'b0;
            queue_exc_code[i] <= 6'b0;
        end
    end else if (wr_en) begin
        queue_exc[wr_ptr_idx] <= 1'b0;
        queue_exc[(wr_ptr_idx + 1) % DEPTH_WORDS] <= 1'b0;
    end else if (wr_exc) begin
        queue_exc[wr_ptr_idx] <= 1'b1;
        queue_exc_code[wr_ptr_idx] <= exc_code;
    end
end

// ================= Data Read Logic =================
// Registered output to avoid glitches and duplicates

reg [31:0] inst_addr_reg;
reg [31:0] inst_reg;
reg inst_vld_reg;
reg inst_exc_reg;
reg [5:0] inst_exc_code_reg;

always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        inst_addr_reg <= 32'b0;
        inst_reg <= 32'b0;
        inst_vld_reg <= 1'b0;
        inst_exc_reg <= 1'b0;
        inst_exc_code_reg <= 6'b0;
    end else if (flush) begin
        inst_addr_reg <= 32'b0;
        inst_reg <= 32'b0;
        inst_vld_reg <= 1'b0;
        inst_exc_reg <= 1'b0;
        inst_exc_code_reg <= 6'b0;
    end else begin
        if (rd_en) begin
            inst_addr_reg <= queue_addr[rd_ptr_idx];
            inst_reg <= queue_data[rd_ptr_idx];
            inst_vld_reg <= 1'b1;
            inst_exc_reg <= queue_exc[rd_ptr_idx];
            inst_exc_code_reg <= queue_exc_code[rd_ptr_idx];
        end else begin
            inst_vld_reg <= 1'b0;
            inst_exc_reg <= 1'b0;
        end
    end
end

assign inst_addr = inst_addr_reg;
assign inst = inst_reg;
assign inst_vld = inst_vld_reg;
assign inst_exc = inst_exc_reg;
assign inst_exc_code = inst_exc_code_reg;

endmodule
