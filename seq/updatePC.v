`include "define.v"
module updatePC(
    input wire [`ICODE_BUS] icode_i,
    input wire Cnd_i,
    input wire [`ADDR_BUS] valP_i,
    input wire [`ADDR_BUS] valC_i,
    input wire [`ADDR_BUS] valM_i,

    output wire [`ADDR_BUS] next_PC
);

    assign next_PC = ((((icode_i == `IJXX) & Cnd_i) | icode_i == `ICALL) ? valC_i : 
                        icode_i == `IRET ? valM_i : valP_i);
    
endmodule
