`include "define.v"

module fetch_reg (
    input wire clk_i,
    input wire F_stall_i,
    input wire F_bubble_i,
    input wire [`ADDR_BUS] f_predPC_i,

    output reg [`ADDR_BUS] F_predPC_o
);

always @(posedge clk_i) begin
    if(F_bubble_i)
        F_predPC_o <= `ADDR_ZERO;
    else if(~F_stall_i)
        F_predPC_o <= f_predPC_i;
end

initial begin
    F_predPC_o <= `ADDR_ZERO;
end
    
endmodule
