// karatsuba_multiplier_tb.sv
// Testbench for Karatsuba polynomial multiplier

`timescale 1ns / 1ps
`include "global_params.vh"

module karatsuba_multiplier_tb;

    // 测试信号
    logic                   clk;
    logic                   rst_n;
    // logic [`DATA_WIDTH-1:0] a[`N-1:0];
    // logic [`DATA_WIDTH-1:0] b[`N-1:0];
    logic [`DATA_WIDTH-1:0] c[`N-1:0];
    
    // DUT实例化
    top_karatsuba_multiplier dut (
        .clk(clk),
        .rst_n(rst_n),
        // .a(a),
        // .b(b),
        .c(c)
    );
    
    // 时钟生成 - 周期10ns (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // 测试执行
    initial begin
        // 初始化
        rst_n = 0;
        // for (int i = 0; i < `N; i++) begin
        //     a[i] = 0;
        //     b[i] = 0;
        // end
        
        // 复位
        repeat(3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        //------------------------------------------------
        // 测试用例1: 简单多项式
        //------------------------------------------------
        // $display("Test Case 1: Simple Polynomials");
        
        // // 设置输入
        // // 多项式A: x^2 + 2x + 3
        // a[0] <= 3; a[1] <= 2; a[2] <= 1;
        // for (int i = 3; i < `N; i++) a[i] <= 0;
        
        // // 多项式B: x^2 + x + 1
        // b[0] <= 1; b[1] <= 1; b[2] <= 1;
        // for (int i = 3; i < `N; i++) b[i] <= 0;
        
        // // 等待固定延迟 - 乘法器总延迟为9个周期
        // repeat(10) @(posedge clk); // 多等1个周期确保结果稳定
        
        // //------------------------------------------------
        // // 测试用例2: 随机多项式
        // //------------------------------------------------
        // $display("\nTest Case 2: Random Polynomials");
        
        // // 生成随机输入
        // for (int i = 0; i < `N; i++) begin
        //     a[i] <= $urandom % `Q;
        //     b[i] <= $urandom % `Q;
        // end
        
        
        // // 等待固定延迟
        // repeat(10) @(posedge clk);
        
        // //------------------------------------------------
        // // 测试用例3: 边界值测试
        // //------------------------------------------------
        // $display("\nTest Case 3: Boundary Values");
        
        // // 设置所有系数为Q-1（边界值）
        // for (int i = 0; i < `N; i++) begin
        //     a[i] <= `Q - 1;
        //     b[i] <= `Q - 1;
        // end
        
        // // 等待固定延迟
        // repeat(10) @(posedge clk);
        
        // // 测试完成
        // $display("\nAll tests completed!");
        repeat(100) @(posedge clk);
        $finish;
    end

endmodule