`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Harbin Institute of Technology, Shenzhen
// Engineer: Bohan Hu 
// 
// Create Date: 2020/01/23 20:26:07
// Design Name: RAM with latency
// Module Name: ram_wrap
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


module ram_wrap(
    input clk,
    input reset,
(*mark_debug = "true"*)    input rreq,
(*mark_debug = "true"*)    input [9:0]raddr,
(*mark_debug = "true"*)    input [1:0]burst_len,
(*mark_debug = "true"*)    output reg [7:0]rdata,
(*mark_debug = "true"*)    output reg rvalid,
(*mark_debug = "true"*)    output rlast
    );
`define LIMIT 10
parameter   IDLE = 4'b0001, 
            WAIT = 4'b0010,
            RESP = 4'b0100;
            
(*mark_debug = "true"*) reg [3:0] current_state, next_state;
always @(posedge clk)   begin
    if(reset)    begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end
reg [1:0] burst_cnt;
reg [9:0] raddr_latch;
reg [31:0] wait_count;
wire wait_end = (wait_count == `LIMIT);
wire burst_end = (burst_cnt == burst_len);
assign rlast = burst_end & (current_state == RESP);
//wire resp_end; 
always @(*) begin
    case (current_state)    
        IDLE:   begin
            if(rreq)    begin
                next_state = WAIT;
            end else begin
                next_state = IDLE;
            end
        end
        WAIT:  begin
            if(wait_end)    begin
                next_state = RESP;
            end else begin
                next_state = WAIT;
            end
        end
        RESP:   begin
            if(burst_end)    begin
                next_state = IDLE;
            end else begin
                next_state = RESP;
            end
        end
    endcase
end


// Ëø´æµØÖ·
always @(posedge clk)   begin
    if(reset)    begin
        raddr_latch <= 0;
        burst_cnt <= 0;
        wait_count <= 0;
    end else begin
        if(current_state == IDLE)   begin
            raddr_latch <= raddr;
            burst_cnt <= 0;
            wait_count <= 0;
        end else if(current_state == WAIT && next_state == WAIT)  begin
            wait_count <= wait_count + 1;
            raddr_latch <= raddr_latch;
            burst_cnt <= 0;
        end else if(current_state == WAIT && next_state == RESP)  begin
            raddr_latch <= raddr_latch + 1;
            burst_cnt <= 0;
            wait_count <= 0;
        end else if(current_state == RESP)  begin
            raddr_latch <= raddr_latch + 1;
            burst_cnt <= burst_cnt + 1;
            wait_count <= 0;
        end
    end
end

reg [9:0]addr_to_ram;
wire [7:0]data_from_ram;

always @(*) begin
    case(current_state)
        IDLE:   begin
            addr_to_ram = 0;
            rdata = 0;
            rvalid = 0;
        end
        WAIT:  begin
            addr_to_ram = raddr_latch;
            rdata = 0;
            rvalid = 0;
        end
        RESP:   begin
            addr_to_ram = raddr_latch;
            rdata = data_from_ram;
            rvalid = 1;
        end
    endcase
end
blk_mem_gen_0 ut(.clka(clk),.addra(addr_to_ram),.dina(0),.wea(0),.douta(data_from_ram));

endmodule
