module c7bifu_iq (
    input              clk,
    input              resetn,
    input  [31:0]      data_addr,
    input  [63:0]      data,
    input              data_vld,
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

// Control signals
wire wr_en;
wire rd_en;
wire queue_full;
wire queue_empty;
wire [PTR_WIDTH-1:0] wr_ptr_idx;
wire [PTR_WIDTH-1:0] rd_ptr_idx;

// ================= Queue Status =================
// Queue is full when there's not enough space for a 64-bit write (2 instructions)
wire [PTR_WIDTH:0] free_slots;
assign free_slots = DEPTH_WORDS - entry_count;  // Number of free instruction slots
assign queue_full = (free_slots < 2);           // Can write only if free_slots >= 2
// Or equivalently:
// assign queue_full = (entry_count > (DEPTH_WORDS - 2));
assign queue_empty = (entry_count == 0);

assign iq_full = queue_full;

// ================= Control Signals =================
assign wr_en = data_vld && !queue_full;  // Write enable
assign rd_en = !stall && !queue_empty;   // Read enable

// ================= Entry Counter Logic =================
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        entry_count <= {(PTR_WIDTH+1){1'b0}};
    end else if (flush) begin
        entry_count <= {(PTR_WIDTH+1){1'b0}};
    end else begin
        case ({wr_en, rd_en})
            2'b01:   entry_count <= entry_count - 1;      // Read only: -1
            2'b10:   entry_count <= entry_count + 2;      // Write only: +2 (64-bit = 2 instructions)
            2'b11:   entry_count <= entry_count + 1;      // Both read and write: +2-1 = +1
            default: entry_count <= entry_count;          // No operation
        endcase
    end
end

// ================= Pointer Index Calculation =================
// Use lower bits as array index (circular buffer)
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
        if (wr_en) begin
            wr_ptr <= wr_ptr + 2;  // Increment by 2 for 64-bit write
        end
        if (rd_en) begin
            rd_ptr <= rd_ptr + 1;  // Increment by 1 for 32-bit read
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
        // Store first instruction (lower 32 bits)
        queue_addr[wr_ptr_idx] <= data_addr;
        queue_data[wr_ptr_idx] <= data[31:0];
        
        // Store second instruction (upper 32 bits)
        // Use modulo operation to handle wrap-around
        queue_addr[(wr_ptr_idx + 1) % DEPTH_WORDS] <= data_addr + 4;
        queue_data[(wr_ptr_idx + 1) % DEPTH_WORDS] <= data[63:32];
    end
end

// ================= Data Read Logic =================
// Combinational output: zero-latency read
// When rd_en is asserted, the output becomes valid immediately in the same cycle
assign inst_addr = queue_addr[rd_ptr_idx];  // Instruction address output
assign inst = queue_data[rd_ptr_idx];       // Instruction data output
assign inst_vld = rd_en;                    // Output valid when read is enabled
// Or equivalently:
// assign inst_vld = (!stall && !queue_empty);

endmodule
