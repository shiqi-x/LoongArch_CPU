module if_stage(
    input  wire        clk,
    input  wire        reset,
    // valid/allow
    input  wire        in_to_if_valid,
    input  wire        allowin_id,
    output wire        if_to_id_valid,
    // id_to_if
    input  wire        br_taken_id,
    input  wire [31:0] br_target_id,
    input  wire        br_taken_cancle_id,
    // if_to_id
    output wire [31:0] inst_if,
    output wire [31:0] pc_if,
    // inst_sram_interface
    output wire        inst_sram_en,
    output wire [ 3:0] inst_sram_we,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input  wire [31:0] inst_sram_rdata
);

// 单周期的信号
wire [31:0] seq_pc;
wire [31:0] next_pc;

// 流水线的信号
reg         valid_if;
wire        ready_go_if;

reg  [31:0] pc;

// 信号处理
always @(posedge clk) begin
    if (reset) begin
        valid_if <= 1'b0;
        pc <= 32'h1bfffffc;
    end
    else if (allowin_if) begin
        valid_if <= in_to_if_valid;
    end
    else if (br_taken_cancle_id) begin
        valid_if <= 1'b0;
    end

    if (in_to_if_valid && allowin_if) begin
        pc <= next_pc;
    end
end

assign seq_pc = pc + 32'h4;
assign next_pc = br_taken_id ? br_target_id : seq_pc;
assign inst_if = inst_sram_rdata;
assign pc_if = pc;

// 流水线结构相关
assign ready_go_if = 1'b1;
assign allowin_if = !valid_if || ready_go_if && allowin_id;
assign if_to_id_valid = valid_if && ready_go_if;

// inst_sram
assign inst_sram_en = in_to_if_valid && allowin_if;
assign inst_sram_we = 4'h0;
assign inst_sram_addr = next_pc;
assign inst_sram_wdata = 32'h00000000;

endmodule