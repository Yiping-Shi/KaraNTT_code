// barrett_reduce_tb.sv
// Simple testbench for Barrett modular reduction module using only delays

`timescale 1ns / 1ps
`include "global_params.vh"

module barrett_reduce_tb;

    // Test signals
    logic                   clk;
    logic                   rst_n;
    logic [`ACC_WIDTH-1:0]  value_in;
    logic [`DATA_WIDTH-1:0] result_out;
    
    // DUT instantiation
    barrett_reduce dut (
        .clk(clk),
        .rst_n(rst_n),
        .value_in(value_in),
        .result_out(result_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Reference modulus calculation
    function automatic int unsigned mod_q(longint unsigned value);
        return int'(value % `Q);
    endfunction
    
    // Test procedure
    initial begin
        // Initialize
        rst_n = 0;
        value_in = 0;
        
        // Reset
        #20 rst_n = 1;
        #15;
        
        // Test case 1: Simple value 1
        @(posedge clk)
        $display("Test 1: value_in = 1, expected = %0d", mod_q(1));
        value_in <= 1;
        #10;
        
        // Test case 2: Simple value 0
        @(posedge clk)
        $display("Test 2: value_in = 0, expected = %0d", mod_q(0));
        value_in <= 0;
        #10;
        
        // Test case 3: Exact modulus Q
        @(posedge clk)
        $display("Test 3: value_in = Q (%0d), expected = %0d", `Q, mod_q(`Q));
        value_in <= `Q;
        #10;
        
        // Test case 4: Q - 1
        @(posedge clk)
        $display("Test 4: value_in = Q-1 (%0d), expected = %0d", `Q-1, mod_q(`Q-1));
        value_in <= `Q - 1;
        #10;
        
        // Test case 5: Q + 1
        @(posedge clk)
        $display("Test 5: value_in = Q+1 (%0d), expected = %0d", `Q+1, mod_q(`Q+1));
        value_in <= `Q + 1;
        #10;
        
        // Test case 6: 2Q
        @(posedge clk)
        $display("Test 6: value_in = 2Q (%0d), expected = %0d", 2*`Q, mod_q(2*`Q));
        value_in <= 2 * `Q;
        #10;
        
        // Test case 7: 3Q
        @(posedge clk)
        $display("Test 7: value_in = 3Q (%0d), expected = %0d", 3*`Q, mod_q(3*`Q));
        value_in <= 3 * `Q;
        #10;
        
        // Test case 8: Large value
        @(posedge clk)
        $display("Test 8: value_in = 0x123456789ABCDEF, expected = %0d", mod_q(74'h123456789ABCDEF));
        value_in <= 74'h123456789ABCDEF;
        #10;
        
        // Test case 9: Another large value
        @(posedge clk)
        $display("Test 9: value_in = 1000000000000000000, expected = %0d", mod_q(1000000000000000000));
        value_in <= 1000000000000000000;
        #10;
        
        // Test case 10: 5Q - 1
        @(posedge clk)
        $display("Test 10: value_in = 5Q-1 (%0d), expected = %0d", 5*`Q-1, mod_q(5*`Q-1));
        value_in <= 5 * `Q - 1;
        #10;
        
        // Test case 11: 5Q + 1
        @(posedge clk)
        $display("Test 11: value_in = 5Q+1 (%0d), expected = %0d", 5*`Q+1, mod_q(5*`Q+1));
        value_in <= 5 * `Q + 1;
        #10;
        
        // Test case 12: 10Q
        @(posedge clk)
        $display("Test 12: value_in = 10Q (%0d), expected = %0d", 10*`Q, mod_q(10*`Q));
        value_in <= 10 * `Q;
        #10;
        
        // Wait for pipeline flush (3 cycles plus some margin)
        #50;
            
        // End simulation
        $display("Test completed. Check waveform for results.");
        $finish;
    end
    
    // // Display outputs at each clock edge
    // initial begin
    //     // Wait for reset to complete
    //     #35;
        
    //     // Monitor outputs
    //     forever @(posedge clk) begin
    //         #2; // Small delay after clock edge to let signals settle
    //         $display("Time %0t: result_out = %0d", $time, result_out);
    //     end
    // end
    
    // // Display pipeline stages for debug
    // initial begin
    //     // Wait for reset to complete
    //     #35;
        
    //     // Monitor internal signals
    //     forever @(posedge clk) begin
    //         #2; // Small delay after clock edge
    //         $display("Internal: s1_value=%0d, s2_R=%0d", 
    //                 dut.s1_value, dut.s2_R);
    //     end
    // end

endmodule