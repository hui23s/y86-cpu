`include "define.v"

module memory_reg (
    input wire clk_i,

    input wire M_stall_i,
    input wire M_bubble_i,

    input wire [    `STAT_BUS] e_stat_i,
    input wire [    `ADDR_BUS] e_pc_i,
    input wire [   `ICODE_BUS] e_icode_i,
    input wire [    `IFUN_BUS] e_ifun_i,
    input wire                 e_Cnd_i,
    input wire [    `DATA_BUS] e_valE_i,
    input wire [    `DATA_BUS] e_valA_i,
    input wire [`REG_ADDR_BUS] e_dstE_i,
    input wire [`REG_ADDR_BUS] e_dstM_i,


    output reg [    `ADDR_BUS] M_pc_o,
    output reg [    `STAT_BUS] M_stat_o,
    output reg [   `ICODE_BUS] M_icode_o,
    output reg [    `IFUN_BUS] M_ifun_o,
    output reg                 M_Cnd_o,
    output reg [    `DATA_BUS] M_valE_o,
    output reg [    `DATA_BUS] M_valA_o,
    output reg [`REG_ADDR_BUS] M_dstE_o,
    output reg [`REG_ADDR_BUS] M_dstM_o
);

  always @(posedge clk_i) begin
    if (M_bubble_i) begin
      M_stat_o  <= `STAT_ZERO;
      M_pc_o    <= `ADDR_ZERO;
      M_icode_o <= `INOP;
      M_ifun_o  <= `IFUN_ZERO;
      M_Cnd_o   <= `FALSE;
      M_valE_o  <= `DATA_ZERO;
      M_valA_o  <= `DATA_ZERO;
      M_dstE_o  <= `NREG;
      M_dstM_o  <= `NREG;
    end else if (~M_stall_i) begin
      M_stat_o  <= e_stat_i;
      M_pc_o    <= e_pc_i;
      M_icode_o <= e_icode_i;
      M_ifun_o  <= e_ifun_i;
      M_Cnd_o   <= e_Cnd_i;
      M_valE_o  <= e_valE_i;
      M_valA_o  <= e_valA_i;
      M_dstE_o  <= e_dstE_i;
      M_dstM_o  <= e_dstM_i;
    end
  end

endmodule

