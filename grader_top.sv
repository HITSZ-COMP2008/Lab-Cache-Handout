`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Harbin Institute of Technology, Shenzhen 
// Engineer: Bohan Hu
// 
// Create Date: 2020/01/23 23:40:45
// Design Name: Cache Design Lab Grader
// Module Name: Grader
// Project Name: Cache Design Lab
// Target Devices: xc7a100tfgg484-1
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


module grader_top(
    input clk,
    input reset,
    input [9:0] end_addr,
    output reg [9:0] count,
    output reg test_success,
    output reg test_fail
    );

// trace rom
reg [9:0] test_addr;
reg cache_read;
wire cache_rvalid;
wire [7:0] cache_rdata;
wire [7:0] trace_rdata;

wire rreq_cache2mem;
wire [9:0] raddr_cache2mem;
wire [1:0] burst_len_cache2mem;
wire [7:0] rdata_mem2cache;
wire rvalid_mem2cache;
wire rlast_mem2cache;
blk_mem_gen_0 trace(.clka(clk),.addra(test_addr),.dina(0),.wea(0),.douta(trace_rdata));
cache ut0(      .clk(clk),
                .reset(reset),
                .raddr_from_top(test_addr),
                .rreq_from_top(cache_read),
                .rdata_to_top(cache_rdata),
                .rvalid_to_top(cache_rvalid),
                .rreq_to_mem(rreq_cache2mem),
                .raddr_to_mem(raddr_cache2mem),
                .burst_len_to_mem(burst_len_cache2mem),
                .rdata_from_mem(rdata_mem2cache),
                .rvalid_from_mem(rvalid_mem2cache),
                .rlast_from_mem(rlast_mem2cache)      );
ram_wrap mem0(  .clk(clk),
                .reset(reset),
                .rreq(rreq_cache2mem),
                .raddr(raddr_cache2mem),
                .burst_len(burst_len_cache2mem),
                .rdata(rdata_mem2cache),
                .rvalid(rvalid_mem2cache),
                .rlast(rlast_mem2cache)    );
                
enum logic [7:0] { IDLE = 8'b0000_0000,
               READ_TRACE = 8'b0000_0001,
               READ_CACHE = 8'b0000_0010,
               RES_COMPARE = 8'b0010_0000,
               TEST_FAIL = 8'b0000_1000,
               TEST_PASS = 8'b0001_0000 } current_state, next_state;
               
always @(posedge clk)   begin
    if(reset)   begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// TODO:需要一个地址访问序列（可以存在distributed rom里面）

reg [7:0] data_from_cache;
reg [7:0] data_from_trace;

always @(posedge clk)   begin
    if(reset)   begin
        data_from_cache <= 0;
    end else begin
        if(current_state == READ_CACHE && cache_rvalid) begin
            data_from_cache <= cache_rdata;
        end
    end
end

always @(posedge clk)   begin
    if(reset)   begin
        data_from_trace <= 0;
    end else begin
        if(current_state == READ_TRACE) begin
            data_from_trace <= trace_rdata;
        end
    end
end

always @(*) begin
    case (current_state)
        IDLE:   begin
            next_state = READ_TRACE;
        end
        READ_TRACE: begin
            next_state = READ_CACHE;
        end
        READ_CACHE: begin
            if(cache_rvalid)   begin
                next_state = RES_COMPARE;
            end else begin   // 如果已经读取完毕
                next_state = READ_CACHE;
            end
        end
        RES_COMPARE: begin
            if(data_from_cache == data_from_trace)   begin
                if(test_addr == end_addr)   begin
                    next_state = TEST_PASS;
                end else begin
                    next_state = READ_TRACE;
                end
            end else begin
                next_state = TEST_FAIL;
            end
        end
        TEST_FAIL:  begin
            next_state = TEST_FAIL;
        end
        TEST_PASS:  begin
            next_state = TEST_PASS;
        end
    endcase
end

always @(posedge clk)   begin
    if(reset)   begin  
        count <= 0;
    end else if(current_state == TEST_PASS || current_state == TEST_FAIL)   begin
        count <= count;
    end else begin
        count <= count + 1;
    end
end

reg [7:0] addr_gen;
// 测试访问地址生成
always @(posedge clk)   begin
    if(reset)   begin
        addr_gen <= 0;
    end else begin
        if(current_state == READ_CACHE && next_state == RES_COMPARE) begin
            addr_gen <= addr_gen + 1;
        end
    end
end

always @(*) begin
    case (current_state)
        IDLE:   begin
            test_addr = 0;
            cache_read = 0;
            test_success = 0;
            test_fail = 0;
        end
        READ_TRACE: begin
            test_addr = addr_gen;
            cache_read = 0;
            test_success = 0;
            test_fail = 0;
        end
        READ_CACHE: begin
            test_addr = addr_gen;
            cache_read = 1; 
            test_success = 0;
            test_fail = 0;
        end
        RES_COMPARE:    begin
            test_addr = addr_gen;
            cache_read = 0;
            test_success = 0;
            test_fail = 0;
        end
        TEST_FAIL:  begin
            test_addr = 0;
            cache_read = 0;
            test_success = 0;
            test_fail = 1;
        end
        TEST_PASS:  begin
            test_addr = 0;
            cache_read = 0;
            test_success = 1;
            test_fail = 0;
        end
    endcase
end

endmodule
