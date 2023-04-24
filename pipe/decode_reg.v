`include "define.v"

module decode_reg (
    input wire clk_i,

    input wire D_stall_i,
    input wire D_bubble_i,

    input wire [    `ADDR_BUS] f_pc_i,
    input wire [    `STAT_BUS] f_stat_i,
    input wire [   `ICODE_BUS] f_icode_i,
    input wire [    `IFUN_BUS] f_ifun_i,
    input wire [`REG_ADDR_BUS] f_rA_i,
    input wire [`REG_ADDR_BUS] f_rB_i,
    input wire [    `DATA_BUS] f_valC_i,
    input wire [    `ADDR_BUS] f_valP_i,

    output reg [    `ADDR_BUS] D_pc_o,
    output reg [    `STAT_BUS] D_stat_o,
    output reg [   `ICODE_BUS] D_icode_o,
    output reg [    `IFUN_BUS] D_ifun_o,
    output reg [`REG_ADDR_BUS] D_rA_o,
    output reg [`REG_ADDR_BUS] D_rB_o,
    output reg [    `DATA_BUS] D_valC_o,
    output reg [    `ADDR_BUS] D_valP_o
);

  always @(posedge clk_i) begin
    if (D_bubble_i) begin
      D_stat_o  <= `STAT_ZERO;
      D_pc_o    <= `ADDR_ZERO;
      D_icode_o <= `INOP;
      D_ifun_o  <= `IFUN_ZERO;
      D_rA_o    <= `NREG;
      D_rB_o    <= `NREG;
      D_valC_o  <= `DATA_ZERO;
      D_valP_o  <= `ADDR_ZERO;
    end else if (~D_stall_i) begin
      D_stat_o  <= f_stat_i;
      D_pc_o    <= f_pc_i;
      D_icode_o <= f_icode_i;
      D_ifun_o  <= f_ifun_i;
      D_rA_o    <= f_rA_i;
      D_rB_o    <= f_rB_i;
      D_valC_o  <= f_valC_i;
      D_valP_o  <= f_valP_i;
    end
  end

endmodule
