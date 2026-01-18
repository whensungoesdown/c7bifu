module c7bifu_iq (
    input              clk,
    input              resetn,
    input  [31:0]      data_addr,
    input  [63:0]      data,
    input              data_vld,
    input  [31:0]      start_addr,
    input              stall,
    input              flush,
    output             iq_full,
    output [31:0]      inst_addr,
    output [31:0]      inst,
    output             inst_vld
);

// ================= Parameter Definitions =================
parameter DEPTH_BYTES = 128;        // Queue depth in bytes
parameter DEPTH_WORDS = 4;          // Queue depth in instructions
parameter WORD_BYTES = 4;           // Bytes per instruction
localparam PTR_WIDTH = 2;           // log2(DEPTH_WORDS) = log2(4) = 2

// ================= Internal Signal Definitions =================
reg [31:0] queue_addr [0:DEPTH_WORDS-1];  // Address queue
reg [31:0] queue_data [0:DEPTH_WORDS-1];  // Data queue
reg [PTR_WIDTH:0] wr_ptr;                 // Write pointer
reg [PTR_WIDTH:0] rd_ptr;                 // Read pointer

// Entry counter for tracking queue occupancy
reg [PTR_WIDTH:0] entry_count;

// Start address alignment handling
reg skip_first_half;               // Flag to skip first 32-bit half of 64-bit data
reg [31:0] expected_addr;          // Expected aligned address for data

// Control signals
wire wr_en;
wire rd_en;
wire queue_full;
wire queue_empty;
wire [PTR_WIDTH-1:0] wr_ptr_idx;
wire [PTR_WIDTH-1:0] rd_ptr_idx;

// ================= skip_first_half Handling =================
// This flag indicates whether we need to skip the lower 32 bits of the first
// 64-bit data word after flush, based on start_addr alignment
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        skip_first_half <= 1'b0;
        expected_addr <= 32'b0;
    end else if (flush) begin
        // On flush, set alignment information based on start_addr
        skip_first_half <= start_addr[2];  // bit[2]=1 means skip lower 32 bits
        expected_addr <= {start_addr[31:3], 3'b000};  // 8-byte aligned address
    end else if (wr_en && skip_first_half && (data_addr == expected_addr)) begin
        // When expected aligned data is received, clear the skip flag
        skip_first_half <= 1'b0;
    end
end

// ================= Queue Status =================
// Calculate actual free slots in the queue
wire [PTR_WIDTH:0] free_slots;
assign free_slots = DEPTH_WORDS - entry_count;

// Queue is full when there's not enough space for a 64-bit write (2 instructions)
assign queue_full = (free_slots < 2);

// Queue is empty when entry_count is zero
assign queue_empty = (entry_count == 0);

// Output iq_full signal
assign iq_full = queue_full;

// ================= Control Signals =================
// Write enable: can write when data is valid and queue is not full
// skip_first_half doesn't block writes, only affects how data is stored
assign wr_en = data_vld && !queue_full;

// Read enable: cannot read during flush or when skip_first_half is set
assign rd_en = !stall && !queue_empty && !flush && !skip_first_half;

// ================= Entry Counter Logic =================
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        entry_count <= {(PTR_WIDTH+1){1'b0}};
    end else if (flush) begin
        // Clear counter on flush
        entry_count <= {(PTR_WIDTH+1){1'b0}};
    end else if (wr_en && !rd_en) begin
        // Write only
        if (skip_first_half && (data_addr == expected_addr)) begin
            // Aligned data with skip: only increment by 1 (store upper 32 bits only)
            entry_count <= entry_count + 1;
        end else begin
            // Normal case: increment by 2 for 64-bit write
            entry_count <= entry_count + 2;
        end
    end else if (!wr_en && rd_en) begin
        // Read only
        entry_count <= entry_count - 1;
    end else if (wr_en && rd_en) begin
        // Both write and read
        if (skip_first_half && (data_addr == expected_addr)) begin
            // +1 write, -1 read = no change
            entry_count <= entry_count;
        end else begin
            // +2 write, -1 read = +1
            entry_count <= entry_count + 1;
        end
    end
end

// ================= Pointer Index Calculation =================
// Use lower bits as array index for circular buffer
assign wr_ptr_idx = wr_ptr[PTR_WIDTH-1:0];
assign rd_ptr_idx = rd_ptr[PTR_WIDTH-1:0];

// ================= FIFO Pointer Logic =================
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        wr_ptr <= {(PTR_WIDTH+1){1'b0}};
        rd_ptr <= {(PTR_WIDTH+1){1'b0}};
    end else if (flush) begin
        // Reset pointers on flush
        wr_ptr <= {(PTR_WIDTH+1){1'b0}};
        rd_ptr <= {(PTR_WIDTH+1){1'b0}};
    end else begin
        if (wr_en) begin
            if (skip_first_half && (data_addr == expected_addr)) begin
                // Aligned data with skip: increment by 1
                wr_ptr <= wr_ptr + 1;
            end else begin
                // Normal case: increment by 2 for 64-bit write
                wr_ptr <= wr_ptr + 2;
            end
        end
        if (rd_en) begin
            // Increment by 1 for 32-bit read
            rd_ptr <= rd_ptr + 1;
        end
    end
end

// ================= Data Write Logic =================
integer i;

always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        // Initialize all queue entries
        for (i = 0; i < DEPTH_WORDS; i = i + 1) begin
            queue_addr[i] <= 32'b0;
            queue_data[i] <= 32'b0;
        end
    end else if (flush) begin
        // Clear all queue entries on flush
        for (i = 0; i < DEPTH_WORDS; i = i + 1) begin
            queue_addr[i] <= 32'b0;
            queue_data[i] <= 32'b0;
        end
    end else if (wr_en) begin
        if (skip_first_half && (data_addr == expected_addr)) begin
            // Aligned data with skip: store only upper 32 bits
            queue_addr[wr_ptr_idx] <= expected_addr + 4;  // Address of upper 32 bits
            queue_data[wr_ptr_idx] <= data[63:32];        // Upper 32 bits of data
        end else begin
            // Normal case: store complete 64-bit data (two instructions)
            queue_addr[wr_ptr_idx] <= data_addr;          // Address of lower 32 bits
            queue_data[wr_ptr_idx] <= data[31:0];         // Lower 32 bits of data
            
            queue_addr[(wr_ptr_idx + 1) % DEPTH_WORDS] <= data_addr + 4;  // Address of upper 32 bits
            queue_data[(wr_ptr_idx + 1) % DEPTH_WORDS] <= data[63:32];    // Upper 32 bits of data
        end
    end
end

// ================= Data Read Logic =================
// Combinational output: zero-latency read
// Output becomes valid immediately when rd_en is asserted

wire output_valid;
assign output_valid = rd_en && !flush;  // Output is valid when reading and not flushing

assign inst_addr = output_valid ? queue_addr[rd_ptr_idx] : 32'b0;
assign inst = output_valid ? queue_data[rd_ptr_idx] : 32'b0;
assign inst_vld = output_valid;

endmodule
