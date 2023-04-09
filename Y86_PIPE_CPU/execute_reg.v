`include "define.v"

module execute_reg (
    input wire clk_i,

    input wire E_stall_i,
    input wire E_bubble_i,

    input wire [    `STAT_BUS] d_stat_i,
    input wire [    `ADDR_BUS] d_pc_i,
    input wire [   `ICODE_BUS] d_icode_i,
    input wire [    `IFUN_BUS] d_ifun_i,
    input wire [    `DATA_BUS] d_valC_i,
    input wire [    `DATA_BUS] d_valA_i,
    input wire [    `DATA_BUS] d_valB_i,
    input wire [`REG_ADDR_BUS] d_dstE_i,
    input wire [`REG_ADDR_BUS] d_dstM_i,
    input wire [`REG_ADDR_BUS] d_srcA_i,
    input wire [`REG_ADDR_BUS] d_srcB_i,


    output reg [    `ADDR_BUS] E_pc_o,
    output reg [    `STAT_BUS] E_stat_o,
    output reg [   `ICODE_BUS] E_icode_o,
    output reg [    `IFUN_BUS] E_ifun_o,
    output reg [    `DATA_BUS] E_valC_o,
    output reg [    `DATA_BUS] E_valA_o,
    output reg [    `DATA_BUS] E_valB_o,
    output reg [`REG_ADDR_BUS] E_dstE_o,
    output reg [`REG_ADDR_BUS] E_dstM_o,
    output reg [`REG_ADDR_BUS] E_srcA_o,
    output reg [`REG_ADDR_BUS] E_srcB_o
);

  always @(posedge clk_i) begin
    if (E_bubble_i) begin
      E_stat_o  <= `STAT_ZERO;
      E_pc_o    <= `ADDR_ZERO;
      E_icode_o <= `INOP;
      E_ifun_o  <= `IFUN_ZERO;
      E_valC_o  <= `DATA_ZERO;
      E_valA_o  <= `ADDR_ZERO;
      E_valB_o  <= `ADDR_ZERO;
      E_dstE_o  <= `NREG;
      E_dstM_o  <= `NREG;
      E_srcA_o  <= `NREG;
      E_srcB_o  <= `NREG;
    end else if (~E_stall_i) begin
      E_stat_o  <= d_stat_i;
      E_pc_o    <= d_pc_i;
      E_icode_o <= d_icode_i;
      E_ifun_o  <= d_ifun_i;
      E_valC_o  <= d_valC_i;
      E_valA_o  <= d_valA_i;
      E_valB_o  <= d_valB_i;
      E_dstE_o  <= d_dstE_i;
      E_dstM_o  <= d_dstM_i;
      E_srcA_o  <= d_srcA_i;
      E_srcB_o  <= d_srcB_i;
    end
  end

endmodule
