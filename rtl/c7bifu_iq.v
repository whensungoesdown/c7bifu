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
localparam PTR_WIDTH = 2;

// ================= Internal Signal Definitions =================
reg [31:0] queue_addr [0:DEPTH_WORDS-1];
reg [31:0] queue_data [0:DEPTH_WORDS-1];
reg [PTR_WIDTH:0] wr_ptr;
reg [PTR_WIDTH:0] rd_ptr;

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
assign free_slots = DEPTH_WORDS - entry_count;

// 队列满：需要至少2个空闲槽位来写入64位数据
assign queue_full = (free_slots < 2);

// 队列空
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
            2'b01:   entry_count <= entry_count - 1;
            2'b10:   entry_count <= entry_count + (skip_first_half && (data_addr == expected_addr) ? 1 : 2);
            2'b11:   entry_count <= entry_count + (skip_first_half && (data_addr == expected_addr) ? 0 : 1);
            default: entry_count <= entry_count;
        endcase
    end
end

// ================= Pointer Index Calculation =================
// 关键修正：确保指针索引正确回绕
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
        // 写指针更新
        if (wr_en) begin
            if (skip_first_half && (data_addr == expected_addr)) begin
                wr_ptr <= wr_ptr + 1;
            end else begin
                wr_ptr <= wr_ptr + 2;
            end
        end
        
        // 读指针更新
        if (rd_en) begin
            rd_ptr <= rd_ptr + 1;
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
            // 只写高32位
            queue_addr[wr_ptr_idx] <= expected_addr + 4;
            queue_data[wr_ptr_idx] <= data[63:32];
        end else begin
            // 写完整的64位
            queue_addr[wr_ptr_idx] <= data_addr;
            queue_data[wr_ptr_idx] <= data[31:0];
            
            // 关键修正：正确处理回绕
            if (DEPTH_WORDS == 4) begin
                case (wr_ptr_idx)
                    2'b00: begin
                        queue_addr[1] <= data_addr + 4;
                        queue_data[1] <= data[63:32];
                    end
                    2'b01: begin
                        queue_addr[2] <= data_addr + 4;
                        queue_data[2] <= data[63:32];
                    end
                    2'b10: begin
                        queue_addr[3] <= data_addr + 4;
                        queue_data[3] <= data[63:32];
                    end
                    2'b11: begin
                        queue_addr[0] <= data_addr + 4;
                        queue_data[0] <= data[63:32];
                    end
                endcase
            end else begin
                // 通用回绕处理
                queue_addr[(wr_ptr_idx + 1) % DEPTH_WORDS] <= data_addr + 4;
                queue_data[(wr_ptr_idx + 1) % DEPTH_WORDS] <= data[63:32];
            end
        end
    end
end

// ================= Data Read Logic =================
// 组合逻辑输出（零延迟）

wire output_valid;
assign output_valid = rd_en && !flush;

// 关键修正：使用寄存的输出避免毛刺和重复
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
