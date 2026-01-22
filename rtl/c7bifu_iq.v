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
    output             iq_full,
    output [31:0]      inst_addr,
    output [31:0]      inst,
    output             inst_vld
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

// ================= Entry Counter Logic =================
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        entry_count <= {(PTR_WIDTH+1){1'b0}};
    end else if (flush) begin
        entry_count <= {(PTR_WIDTH+1){1'b0}};
    end else begin
        case ({wr_en, rd_en})
            2'b01:   entry_count <= entry_count - 1'b1;
            2'b10:   begin
                if (skip_first_half && (data_addr == expected_addr)) begin
                    entry_count <= entry_count + 1'b1;
                end else begin
                    entry_count <= entry_count + 2'b10;
                end
            end
            2'b11:   begin
                if (skip_first_half && (data_addr == expected_addr)) begin
                    entry_count <= entry_count;  // +1-1 = 0
                end else begin
                    entry_count <= entry_count + 1'b1;  // +2-1 = +1
                end
            end
            default: entry_count <= entry_count;
        endcase
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
        if (wr_en) begin
            if (skip_first_half && (data_addr == expected_addr)) begin
                wr_ptr <= wr_ptr + 1'b1;
            end else begin
                wr_ptr <= wr_ptr + 2'b10;  // Explicit width specification
            end
        end
        
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
    end
end

// ================= Data Read Logic =================
// Registered output to avoid glitches and duplicates

reg [31:0] inst_addr_reg;
reg [31:0] inst_reg;
reg inst_vld_reg;

always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        inst_addr_reg <= 32'b0;
        inst_reg <= 32'b0;
        inst_vld_reg <= 1'b0;
    end else if (flush) begin
        inst_addr_reg <= 32'b0;
        inst_reg <= 32'b0;
        inst_vld_reg <= 1'b0;
    end else begin
        if (rd_en) begin
            inst_addr_reg <= queue_addr[rd_ptr_idx];
            inst_reg <= queue_data[rd_ptr_idx];
            inst_vld_reg <= 1'b1;
        end else begin
            inst_vld_reg <= 1'b0;
        end
    end
end

assign inst_addr = inst_addr_reg;
assign inst = inst_reg;
assign inst_vld = inst_vld_reg;

endmodule
