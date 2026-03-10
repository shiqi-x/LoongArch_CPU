module mem_stage(
    input wire           clk,
    input wire           reset,
    // valid/allow
    input wire           exe_to_mem_valid,
    input wire           allowin_wb,
    output wire          mem_to_wb_valid,
    output wire          allowin_mem,
    // in/out data
    //// exe_to_mem
    input wire  [31:0] pc_exe,
    input wire  [31:0] alu_result_exe,
    input wire         rf_we_exe,
    input wire  [ 4:0] rf_waddr_exe,
    input wire         res_from_mem_exe,
    //// mem_to_wb
    output wire [31:0] pc_mem,
    output wire [31:0] rf_wdata_mem,
    output wire [ 4:0] rf_waddr_mem,
    output             rf_we_mem,
    // data_sram_interface(读过程)
    input wire  [31:0] data_sram_rdata_mem
);

// 单周期的信号
// wire [31:0] final_result;
wire [31:0] mem_result;

// 流水线的信号
reg  valid_mem;
wire ready_go_mem;

reg  [31:0] pc;
reg         res_from_mem;
reg  [31:0] alu_result;
reg  [ 4:0] rf_waddr;
reg         rf_we;

// 单周期
assign mem_result = data_sram_rdata_mem;

// 流水线
assign rf_wdata_mem = res_from_mem ? mem_result : alu_result;
assign rf_waddr_mem = rf_waddr;
assign rf_we_mem = rf_we;
assign pc_mem = pc;

always @(posedge clk) begin
    if (reset) begin
        valid_mem <= 1'b0;
    end
    else if (allowin_mem) begin
        valid_mem <= exe_to_mem_valid;
    end

    if (exe_to_mem_valid && allowin_mem) begin
        pc <= pc_exe;
        res_from_mem <= res_from_mem_exe;
        alu_result <= alu_result_exe;
        rf_waddr <= rf_waddr_exe;
        rf_we <= rf_we_exe;
    end
end

assign ready_go_mem = 1'b1;
assign allowin_mem = !valid_mem || ready_go_mem && allowin_wb;
assign mem_to_wb_valid = valid_mem && ready_go_mem;

endmodule