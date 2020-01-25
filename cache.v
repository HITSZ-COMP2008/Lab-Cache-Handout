`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/24 13:27:26
// Design Name: 
// Module Name: cache_stub
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cache(
    // Global Signals
    input clk,
    input reset,
    // Input Signals from Grader
    input [9:0] raddr_from_top,
    input rreq_from_top,
    // Input Signals from Memory Module
    input [7:0] rdata_from_mem,
    input rvalid_from_mem,
    input rlast_from_mem,
    // Output Signals to Grader
    output [7:0] rdata_to_top,
    output rvalid_to_top,
    // Output Signals to Memory Module
    output rreq_to_mem,
    output [9:0] raddr_to_mem,
    output [1:0] burst_len_to_mem
    );

// Implement your Cache Here
//always @(posedge clk)   begin
//    if(reset)   begin
//        rdata_to_top <= 0;
//        rvalid_to_top <= 0;
//    end else if(rreq_from_top) begin
//        rdata_to_top <= 1;
//        rvalid_to_top <= raddr_from_top + 1;
//    end else begin
//        rdata_to_top <= 0;
//        rvalid_to_top <= 0;
//    end
//end
assign burst_len_to_mem = 0;
assign raddr_to_mem = raddr_from_top;
assign rdata_to_top = rdata_from_mem;
assign rreq_to_mem = rreq_from_top;
assign rvalid_to_top = rvalid_from_mem;

endmodule
