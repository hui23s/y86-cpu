`include "define.v"
module updatePC (
    input wire [ `ADDR_BUS] F_predPC_i,
    input wire [`ICODE_BUS] M_icode_i,
    input wire [`ICODE_BUS] W_icode_i,
    input wire              M_Cnd_i,
    input wire [ `ADDR_BUS] M_valA_i,
    input wire [ `ADDR_BUS] W_valM_i,

    output reg [`ADDR_BUS] f_pc_o
);

  always @(*) begin
    if (M_icode_i == `IJXX && !M_Cnd_i) f_pc_o = M_valA_i; // exe阶段计算出cnd之后
    else if (W_icode_i == `IRET) f_pc_o = W_valM_i; //取到写回地址之后
    else f_pc_o = F_predPC_i;
  end
endmodule
