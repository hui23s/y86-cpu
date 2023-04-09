`include "define.v"
module decode (
    input wire clk_i,

    input wire [   `ICODE_BUS] D_icode_i,
    input wire [`REG_ADDR_BUS] D_rA_i,
    input wire [`REG_ADDR_BUS] D_rB_i,
    input wire [    `ADDR_BUS] D_valP_i,
    
    input wire [`REG_ADDR_BUS] e_dstE_i,
    input wire [    `DATA_BUS] e_valE_i,
    input wire [`REG_ADDR_BUS] M_dstM_i,
    input wire [    `DATA_BUS] m_valM_i,
    input wire [`REG_ADDR_BUS] M_dstE_i,
    input wire [    `DATA_BUS] M_valE_i,
    input wire [`REG_ADDR_BUS] W_dstE_i,
    input wire [    `DATA_BUS] W_valE_i,
    input wire [`REG_ADDR_BUS] W_dstM_i,
    input wire [    `DATA_BUS] W_valM_i,

    output wire [    `DATA_BUS] d_valA_o,
    output wire [    `DATA_BUS] d_valB_o,
    output wire [`REG_ADDR_BUS] d_srcA_o,
    output wire [`REG_ADDR_BUS] d_srcB_o,
    output wire [`REG_ADDR_BUS] d_dstE_o,
    output wire [`REG_ADDR_BUS] d_dstM_o
);

  reg  [`DATA_BUS] regfile [14:0];
  wire [`DATA_BUS] d_rvalA;
  wire [`DATA_BUS] d_rvalB;

  assign d_srcA_o = ((D_icode_i == `IRRMOVQ | D_icode_i == `IRMMOVQ | D_icode_i == `IOPQ | D_icode_i == `IPUSHQ) ? D_rA_i : (D_icode_i == `IPOPQ | D_icode_i == `IRET) ? `RSP : `NREG);

  assign d_srcB_o = ((D_icode_i == `IOPQ | D_icode_i == `IRMMOVQ | D_icode_i == `IMRMOVQ) ? D_rB_i : (D_icode_i == `IPUSHQ | D_icode_i == `IPOPQ | D_icode_i == `ICALL | D_icode_i == `IRET) ? `RSP : `NREG);

  assign d_dstE_o = ((D_icode_i == `IRRMOVQ | D_icode_i == `IIRMOVQ | D_icode_i == `IOPQ) ? D_rB_i : (D_icode_i == `IPUSHQ | D_icode_i == `IPOPQ | D_icode_i == `ICALL | D_icode_i == `IRET) ? `RSP : `NREG);

  assign d_dstM_o = ((D_icode_i == `IMRMOVQ | D_icode_i == `IPOPQ) ? D_rA_i : `NREG);

  assign d_rvalA  = (d_srcA_o == `NREG) ? `DATA_ZERO : regfile[d_srcA_o];
  assign d_rvalB  = (d_srcB_o == `NREG) ? `DATA_ZERO : regfile[d_srcB_o];

  // fwd
  //assign d_valA_o = d_rvalA;
  assign d_valA_o = (D_icode_i == `ICALL || D_icode_i == `IJXX) ? D_valP_i : 
                    (d_srcA_o == e_dstE_i) ? e_valE_i :
                    (d_srcA_o == M_dstM_i) ? m_valM_i :
                    (d_srcA_o == M_dstE_i) ? M_valE_i :
                    (d_srcA_o == W_dstM_i) ? W_valM_i :
                    (d_srcA_o == W_dstE_i) ? W_valE_i : d_rvalA;

  //assign d_valB_o = d_rvalB;
  assign d_valB_o = (d_srcB_o == e_dstE_i) ? e_valE_i :
                    (d_srcB_o == M_dstM_i) ? m_valM_i :
                    (d_srcB_o == M_dstE_i) ? M_valE_i :
                    (d_srcB_o == W_dstM_i) ? W_valM_i :
                    (d_srcB_o == W_dstE_i) ? W_valE_i : d_rvalB;

  always @(posedge clk_i) begin
    if (W_dstE_i != `NREG) begin
      regfile[W_dstE_i] <= W_valE_i;
    end

    if (W_dstM_i != `NREG) begin
      regfile[W_dstM_i] <= W_valM_i;
    end
  end

  initial begin
    regfile[0]  = 64'd0;
    regfile[1]  = 64'd1;
    regfile[2]  = 64'd2;
    regfile[3]  = 64'd3;
    regfile[4]  = 64'd64;
    regfile[5]  = 64'd5;
    regfile[6]  = 64'd6;
    regfile[7]  = 64'd7;
    regfile[8]  = 64'd8;
    regfile[9]  = 64'd9;
    regfile[10] = 64'd10;
    regfile[11] = 64'd11;
    regfile[12] = 64'd12;
    regfile[13] = 64'd13;
    regfile[14] = 64'h7fffffffffffffff;
  end

endmodule

