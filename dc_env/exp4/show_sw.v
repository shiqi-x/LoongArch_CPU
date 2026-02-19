`timescale 1ns/1ps

module show_sw (
    input             clk,          
    input             resetn,     

    input      [3 :0] switch,    //input

    output     [7 :0] num_csn,   //new value   
    output     [6 :0] num_a_g,      

    output     [3 :0] led        //previous value
);

//1. get switch data
//2. show switch data in digital number:
//   only show 0~9
//   if >=10, digital number keep old data.
//3. show previous switch data in led.
//   can show any switch data.

reg [3:0] show_data;
reg [3:0] show_data_r;
reg [3:0] prev_data;

//new value
always @(posedge clk)
begin
// 源代码被注释起来没有使用    show_data   <= ~switch;
// 2.reg类型没有赋值，这里导致了X波形。
    show_data <= ~switch;
end

always @(posedge clk)
begin
    // 源代码：show_data_r = show_data;
// 4.always当中不要使用阻塞赋值，这里导致了越沿采样。
    show_data_r <= show_data;
end
//previous value
always @(posedge clk)
begin
    if(!resetn)
    begin
        prev_data <= 4'd0;
    end
    else if(show_data_r != show_data)
    begin
        prev_data <= show_data_r;
    end
end

//show led: previous value
assign led = ~prev_data;

//show number: new value
show_num u_show_num(
        .clk        (clk      ),
        .resetn     (resetn   ),
        
        .show_data  (show_data),
        // 源代码： .num_csn    (num_scn  ),
        // 1.找了很久才发现这里有问题，num_scn应该是num_csn，导致output端口被悬挂，所以产生了Z波形
        .num_csn    (num_csn  ),
        .num_a_g    (num_a_g  )
);

endmodule

//---------------------------{digital number}begin-----------------------//
module show_num (
    input             clk,          
    input             resetn,     

    input      [3 :0] show_data,
    output     [7 :0] num_csn,      
    output reg [6 :0] num_a_g      
);
//digital number display
assign num_csn = 8'b0111_1111;

wire [6:0] nxt_a_g;

always @(posedge clk)
begin
    if ( !resetn )
    begin
        num_a_g <= 7'b0000000;
    end
    else
    begin
        num_a_g <= nxt_a_g;
    end
end

//keep unchange if show_data>=10
wire [6:0] keep_a_g;
//源代码： assign     keep_a_g = num_a_g + nxt_a_g;
// 3.这里kkep_a_g和nxt_a_g形成了环路，导致了波形停止。
assign keep_a_g = num_a_g;

assign nxt_a_g = show_data==4'd0 ? 7'b1111110 :   //0
                 show_data==4'd1 ? 7'b0110000 :   //1
                 show_data==4'd2 ? 7'b1101101 :   //2
                 show_data==4'd3 ? 7'b1111001 :   //3
                 show_data==4'd4 ? 7'b0110011 :   //4
                 show_data==4'd5 ? 7'b1011011 :   //5
                 // 源代码这里缺少6的数码管显示
                 // 5.所以这里应该是一个功能错误吧。
                 show_data==4'd6 ? 7'b1011111 :   //6
                 show_data==4'd7 ? 7'b1110000 :   //7
                 show_data==4'd8 ? 7'b1111111 :   //8
                 show_data==4'd9 ? 7'b1111011 :   //9
                                   keep_a_g   ;

// // 以上的设计方法确实我觉得还是有一点不是那么的好，参考了AI给出的方案，移除了keep_a_g信号：
// wire [6:0] nxt_a_g;

// always @(posedge clk)
// begin
//     if (!resetn)
//     begin
//         num_a_g <= 7'b0000000;
//     end
//     else if (show_data < 4'd10)  // 来一个条件赋值
//     begin
//         num_a_g <= nxt_a_g;
//     end
// end

// assign nxt_a_g = show_data==4'd0 ? 7'b1111110 :
//                  show_data==4'd1 ? 7'b0110000 :
//                  show_data==4'd2 ? 7'b1101101 :
//                  show_data==4'd3 ? 7'b1111001 :
//                  show_data==4'd4 ? 7'b0110011 :
//                  show_data==4'd5 ? 7'b1011011 :
//                  show_data==4'd6 ? 7'b1011111 :
//                  show_data==4'd7 ? 7'b1110000 :
//                  show_data==4'd8 ? 7'b1111111 :
//                  show_data==4'd9 ? 7'b1111011 :
//                                    7'b0000000;  // 这个默认值实际上不会被用到，因为show_data>=10的时候意味着num_a_g就不会被nxt_a_g赋值了。

endmodule
//----------------------------{digital number}end------------------------//
