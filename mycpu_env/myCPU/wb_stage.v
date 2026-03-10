module wb_stage(
    input wire          clk,
    input wire          reset,
    // valid/allow
    input wire           mem_to_wb_valid,
    input wire           allowin_out,
    output wire          allowin_wb,     
    // in/out data
    //// mem_to_wb
    input wire    [31:0] pc_mem,
    input wire    [31:0] rf_wdata_mem,
    input wire    [ 4:0] rf_waddr_mem,
    input wire           rf_we_mem,
    //// wb_to_id
    output wire          rf_we_wb,
    output wire   [ 4:0] rf_waddr_wb,
    output wire   [31:0] rf_wdata_wb,
    // trace
    output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_we,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);

// 单周期的信号
// assign rf_waddr = dest;
// assign rf_wdata = final_result;

// 流水线的信号
reg  valid_wb;
wire ready_go_wb;

reg  [31:0] pc;
reg         rf_we;
reg  [ 4:0] rf_waddr;
reg  [31:0] rf_wdata;

// 单周期

// 流水线
assign rf_we_wb = rf_we & mem_to_wb_valid & allowin_wb;
assign rf_waddr_wb = rf_waddr;
assign rf_wdata_wb = rf_wdata;

always @(posedge clk) begin
    if (reset) begin
        valid_wb <= 1'b0;
    end
    else if (allowin_wb) begin
        valid_wb <= mem_to_wb_valid;
    end

    if (mem_to_wb_valid && allowin_wb) begin
        pc <= pc_mem;
        rf_we <= rf_we_mem;
        rf_waddr <= rf_waddr_mem;
        rf_wdata <= rf_wdata_mem;
    end
end

assign ready_go_wb = 1'b1;
assign allowin_wb = !valid_wb || ready_go_wb && allowin_out;
// assign wb_to_out_valid = valid_wb && ready_go_wb;

assign debug_wb_pc       = pc;
assign debug_wb_rf_we   = {4{rf_we}};
assign debug_wb_rf_wnum  = rf_waddr;
assign debug_wb_rf_wdata = rf_wdata;
endmodule