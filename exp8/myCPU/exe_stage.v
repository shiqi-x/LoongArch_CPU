module exe_stage(
    input  wire        clk,
    input  wire        reset,
    // valid/allow
    input  wire        id_to_exe_valid,
    input  wire        allowin_mem,
    output wire        exe_to_mem_valid,
    output wire        allowin_exe,
    // id_to_exe
    input  wire [31:0] pc_id,
    input  wire        rf_we_id,
    input  wire [11:0] alu_op_id,
    input  wire        res_from_mem_id,
    input  wire [ 4:0] rf_waddr_id,
    input  wire [31:0] alu_src1_id,
    input  wire [31:0] alu_src2_id,
    input  wire [31:0] data_sram_wdata_id,
    input  wire [ 3:0] data_sram_we_id,
    // exe_to_id
    output wire [ 4:0] rd_dest_exe,
    // exe_to_mem
    output wire [31:0] pc_exe,
    output wire [31:0] alu_result_exe,
    output wire        rf_we_exe,
    output wire [ 4:0] rf_waddr_exe,
    output wire        res_from_mem_exe,
    // data_sram_interface(write)
    output wire        data_sram_en_exe,
    output wire [ 3:0] data_sram_we_exe,
    output wire [31:0] data_sram_addr_exe,
    output wire [31:0] data_sram_wdata_exe
);

// 单周期的信号
wire [31:0] alu_result;

// 流水线的信号
reg  valid_exe;
wire ready_go_exe;

reg [31:0] pc;
reg [11:0] alu_op;
reg [31:0] alu_src1;
reg [31:0] alu_src2;
reg [ 3:0] data_sram_we;
reg [31:0] data_sram_wdata;
reg        rf_we;
reg [ 4:0] rf_waddr;
reg        res_from_mem;

// 信号处理
always @(posedge clk) begin
    if (reset) begin
        valid_exe <= 1'b0;
    end
    else if (allowin_exe) begin
        valid_exe <= id_to_exe_valid;
    end

    if (id_to_exe_valid && allowin_exe) begin
        pc <= pc_id;
        alu_op <= alu_op_id;
        alu_src1 <= alu_src1_id;
        alu_src2 <= alu_src2_id;
        data_sram_we <= data_sram_we_id;
        data_sram_wdata <= data_sram_wdata_id;
        rf_we <= rf_we_id;
        rf_waddr <= rf_waddr_id;
        res_from_mem <= res_from_mem_id;
    end
end

alu u_alu(
    .alu_op     (alu_op    ),
    .alu_src1   (alu_src1  ),
    .alu_src2   (alu_src2  ),
    .alu_result (alu_result)
    );

assign alu_result_exe = alu_result;
assign rf_we_exe = rf_we;
assign rf_waddr_exe = rf_waddr;
assign res_from_mem_exe = res_from_mem;
assign pc_exe = pc;
assign rd_dest_exe = {5{valid_exe}} & {5{rf_we}} & rf_waddr;

// 流水线结构相关
assign ready_go_exe = 1'b1;
assign allowin_exe = !valid_exe || ready_go_exe && allowin_mem;
assign exe_to_mem_valid = valid_exe && ready_go_exe;

// data_sram_interface
assign data_sram_en_exe    = id_to_exe_valid & allowin_exe;
assign data_sram_we_exe = data_sram_we & {4{id_to_exe_valid & allowin_exe}};
// ##########这里的写使能是待人思考的问题
assign data_sram_addr_exe  = alu_result;
assign data_sram_wdata_exe = data_sram_wdata;

endmodule