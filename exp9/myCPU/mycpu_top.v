module mycpu_top(
    input  wire        clk,
    input  wire        resetn,
    // inst sram interface
    output wire        inst_sram_en,
    output wire [ 3:0] inst_sram_we,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input  wire [31:0] inst_sram_rdata,
    // data sram interface
    output wire        data_sram_en,
    output wire [ 3:0] data_sram_we,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input  wire [31:0] data_sram_rdata,
    // trace debug interface
    output wire [31:0] debug_wb_pc,
    output wire [ 3:0] debug_wb_rf_we,
    output wire [ 4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);
reg         reset;
always @(posedge clk) reset <= ~resetn;

reg         valid;
always @(posedge clk) begin
    if (reset) begin
        valid <= 1'b0;
    end
    else begin
        valid <= 1'b1;
    end
end

// allowin/valid
wire allowin_id;
wire allowin_exe;
wire allowin_mem;
wire allowin_wb;
wire if_to_id_valid;
wire id_to_exe_valid;
wire exe_to_mem_valid;
wire mem_to_wb_valid;

// if_stage
wire [31:0] inst_if;
wire [31:0] pc_if;
// id_stage
wire [31:0] pc_id;
wire        br_taken_id;
wire [31:0] br_target_id;
wire        br_taken_cancle_id;
wire        rf_we_id;
wire [11:0] alu_op_id;
wire        res_from_mem_id;
wire [ 4:0] rf_waddr_id;
wire [31:0] alu_src1_id;
wire [31:0] alu_src2_id;
wire [31:0] data_sram_wdata_id;
wire [ 3:0] data_sram_we_id;
wire        inst_is_ldw_id;
// exe_stage
wire [31:0] pc_exe;
wire [31:0] alu_result_exe;
wire        rf_we_exe;
wire [ 4:0] rf_waddr_exe;
wire        res_from_mem_exe;
wire [ 4:0] rd_dest_exe;
wire        inst_is_ldw_exe;
wire [31:0] forward_exe;
// mem_stage
wire [31:0] pc_mem;
wire [31:0] rf_wdata_mem;
wire [ 4:0] rf_waddr_mem;
wire        rf_we_mem;
wire [ 4:0] rd_dest_mem;
wire [31:0] forward_mem;
// wb_stage
wire        rf_we_wb;
wire [ 4:0] rf_waddr_wb;
wire [31:0] rf_wdata_wb;
wire [ 4:0] rd_dest_wb;
wire [31:0] forward_wb;

if_stage if_stage(
    .clk                (clk                ),
    .reset              (reset              ),
    // valid/allow
    .in_to_if_valid     (valid              ),
    .allowin_id         (allowin_id         ),
    .if_to_id_valid     (if_to_id_valid     ),
    // id_to_if
    .br_taken_id        (br_taken_id        ),
    .br_target_id       (br_target_id       ),
    .br_taken_cancle_id (br_taken_cancle_id ),
    // if_to_id
    .inst_if            (inst_if            ),
    .pc_if              (pc_if              ),
    // inst_sram_interface
    .inst_sram_en       (inst_sram_en       ),
    .inst_sram_we       (inst_sram_we       ),
    .inst_sram_addr     (inst_sram_addr     ),
    .inst_sram_wdata    (inst_sram_wdata    ),
    .inst_sram_rdata    (inst_sram_rdata    )
);

id_stage id_stage(
    .clk                (clk                ),
    .reset              (reset              ),
    // valid/allow
    .if_to_id_valid     (if_to_id_valid     ),
    .allowin_exe        (allowin_exe        ),
    .id_to_exe_valid    (id_to_exe_valid    ),
    .allowin_id         (allowin_id         ),
    // if_to_id
    .inst_if            (inst_if            ),
    .pc_if              (pc_if              ),
    // exe_to_id
    .rd_dest_exe        (rd_dest_exe        ),
    .inst_is_ldw_exe    (inst_is_ldw_exe    ),
    .forward_exe        (forward_exe        ),
    // mem_to_id
    .rd_dest_mem        (rd_dest_mem        ),
    .forward_mem        (forward_mem        ),
    // wb_to_id
    .rd_dest_wb         (rd_dest_wb         ),
    .rf_we_wb           (rf_we_wb           ),
    .rf_waddr_wb        (rf_waddr_wb        ),
    .rf_wdata_wb        (rf_wdata_wb        ),
    .forward_wb         (forward_wb         ),
    // id_to_if
    .br_taken_id        (br_taken_id        ),
    .br_target_id       (br_target_id       ),
    .br_taken_cancle_id (br_taken_cancle_id ),
    // id_to_exe
    .pc_id              (pc_id              ),
    .rf_we_id           (rf_we_id           ),
    .alu_op_id          (alu_op_id          ),
    .res_from_mem_id    (res_from_mem_id    ),
    .rf_waddr_id        (rf_waddr_id        ),
    .alu_src1_id        (alu_src1_id        ),
    .alu_src2_id        (alu_src2_id        ),
    .data_sram_wdata_id (data_sram_wdata_id ),
    .data_sram_we_id    (data_sram_we_id    ),
    .inst_is_ldw_id     (inst_is_ldw_id     )
);

exe_stage exe_stage(
    .clk                 (clk               ),
    .reset               (reset             ),
    // valid/allow
    .id_to_exe_valid     (id_to_exe_valid   ),
    .allowin_mem         (allowin_mem       ),
    .exe_to_mem_valid    (exe_to_mem_valid  ),
    .allowin_exe         (allowin_exe       ),
    // id_to_exe
    .pc_id               (pc_id             ),
    .rf_we_id            (rf_we_id          ),
    .alu_op_id           (alu_op_id         ),
    .res_from_mem_id     (res_from_mem_id   ),
    .rf_waddr_id         (rf_waddr_id       ),
    .alu_src1_id         (alu_src1_id       ),
    .alu_src2_id         (alu_src2_id       ),
    .data_sram_wdata_id  (data_sram_wdata_id),
    .data_sram_we_id     (data_sram_we_id   ),
    .inst_is_ldw_id      (inst_is_ldw_id    ),
    // exe_to_id
    .rd_dest_exe         (rd_dest_exe       ),
    .inst_is_ldw_exe     (inst_is_ldw_exe   ),
    .forward_exe         (forward_exe       ),
    // exe_to_mem
    .pc_exe              (pc_exe            ),
    .alu_result_exe      (alu_result_exe    ),
    .rf_we_exe           (rf_we_exe         ),
    .rf_waddr_exe        (rf_waddr_exe      ),
    .res_from_mem_exe    (res_from_mem_exe  ),
    // data_sram_interface(write)
    .data_sram_en_exe    (data_sram_en      ),
    .data_sram_we_exe    (data_sram_we      ),
    .data_sram_addr_exe  (data_sram_addr    ),
    .data_sram_wdata_exe (data_sram_wdata   )
);

mem_stage mem_stage(
    .clk                 (clk               ),
    .reset               (reset             ),
    // valid/allow
    .exe_to_mem_valid    (exe_to_mem_valid  ),
    .allowin_wb          (allowin_wb        ),
    .mem_to_wb_valid     (mem_to_wb_valid   ),
    .allowin_mem         (allowin_mem       ),
    // exe_to_mem
    .pc_exe              (pc_exe            ),
    .alu_result_exe      (alu_result_exe    ),
    .rf_we_exe           (rf_we_exe         ),
    .rf_waddr_exe        (rf_waddr_exe      ),
    .res_from_mem_exe    (res_from_mem_exe  ),
    // mem_to_id
    .rd_dest_mem         (rd_dest_mem       ),
    .forward_mem         (forward_mem       ),
    // mem_to_wb
    .pc_mem              (pc_mem            ),
    .rf_wdata_mem        (rf_wdata_mem      ),
    .rf_waddr_mem        (rf_waddr_mem      ),
    .rf_we_mem           (rf_we_mem         ),
    // data_sram_interface(read)
    .data_sram_rdata_mem (data_sram_rdata   )
);

wb_stage wb_stage(
    .clk                 (clk               ),
    .reset               (reset             ),
    // valid/allow
    .mem_to_wb_valid     (mem_to_wb_valid   ),
    .allowin_out         (valid             ),
    .allowin_wb          (allowin_wb        ),
    // mem_to_wb
    .pc_mem              (pc_mem            ),
    .rf_wdata_mem        (rf_wdata_mem      ),
    .rf_waddr_mem        (rf_waddr_mem      ),
    .rf_we_mem           (rf_we_mem         ),
    // wb_to_id
    .rf_we_wb            (rf_we_wb          ),
    .rf_waddr_wb         (rf_waddr_wb       ),
    .rf_wdata_wb         (rf_wdata_wb       ),
    .rd_dest_wb          (rd_dest_wb        ),
    .forward_wb          (forward_wb        ),
    // trace_interface
    .debug_wb_pc         (debug_wb_pc       ),
    .debug_wb_rf_we      (debug_wb_rf_we    ),
    .debug_wb_rf_wnum    (debug_wb_rf_wnum  ),
    .debug_wb_rf_wdata   (debug_wb_rf_wdata )
);

endmodule