`include "define.v"
module decode (
    input wire                 clk_i,
    input wire                 rst_i,
    input wire [   `ICODE_BUS] icode_i,
    input wire [`REG_ADDR_BUS] rA_i,
    input wire [`REG_ADDR_BUS] rB_i,

    input wire [`DATA_BUS] valE_i,  // ALU output
    input wire [`DATA_BUS] valM_i,  // mem -> reg

    //input wire cnd_i,
    output wire [`DATA_BUS] valA_o,
    output wire [`DATA_BUS] valB_o
);

  wire [`REG_ADDR_BUS] srcA;
  wire [`REG_ADDR_BUS] srcB;
  wire [`REG_ADDR_BUS] dstE;
  wire [`REG_ADDR_BUS] dstM;

  assign srcA = ((icode_i == `IRRMOVQ | icode_i == `IRMMOVQ | icode_i == `IOPQ | icode_i == `IPUSHQ) ? rA_i : (icode_i == `IPOPQ | icode_i == `IRET) ? `RSP : `NREG);

  assign srcB = ((icode_i == `IOPQ | icode_i == `IRMMOVQ | icode_i == `IMRMOVQ) ? rB_i : (icode_i == `IPUSHQ | icode_i == `IPOPQ | icode_i == `ICALL | icode_i == `IRET) ? `RSP : `NREG);

  assign dstE = ((icode_i == `IRRMOVQ | icode_i == `IIRMOVQ | icode_i == `IOPQ) ? rB_i : (icode_i == `IPUSHQ | icode_i == `IPOPQ | icode_i == `ICALL | icode_i == `IRET) ? `RSP : `NREG);

  assign dstM = ((icode_i == `IMRMOVQ | icode_i == `IPOPQ) ? rA_i : `NREG);

  reg [`DATA_BUS] regfile[14:0];

  assign valA_o = (srcA == `NREG) ? `DATA_ZERO : regfile[srcA];
  assign valB_o = (srcB == `NREG) ? `DATA_ZERO : regfile[srcB];

  always @(posedge clk_i) begin
    if (dstE != `NREG) begin
      regfile[dstE] <= valE_i;
    end

    if (dstM != `NREG) begin
      regfile[dstM] <= valM_i;
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

