`include "define.v"
module execute (
    input wire clk_i,
    input wire rst_i,

    input wire [`ICODE_BUS] icode_i,
    input wire [`IFUN_BUS] ifun_i,

    input wire signed [`DATA_BUS] valA_i,
    input wire signed [`DATA_BUS] valB_i,
    input wire signed [`DATA_BUS] valC_i,

    output wire signed [`DATA_BUS] valE_o,
    output wire               Cnd_o
);
  wire [`IFUN_BUS] alu_fun;
  wire [`DATA_BUS] aluA;
  wire [`DATA_BUS] aluB;
  reg [`COND_BUS] new_cc;
  reg [`COND_BUS] cc;
  wire set_cc;

  assign alu_fun = (icode_i == `IOPQ) ? ifun_i : `ALUADD;

  assign valE_o =
      alu_fun == `ALUSUB ? aluB - aluA :
      alu_fun == `ALUAND ? aluB & aluA :
      alu_fun == `ALUXOR ? aluB ^ aluA :  aluB + aluA;

  assign aluA = ((icode_i == `IRRMOVQ | icode_i == `IOPQ) ? valA_i : 
                 (icode_i == `IIRMOVQ | icode_i == `IRMMOVQ | icode_i == `IMRMOVQ) ? valC_i : 
                 (icode_i == `ICALL | icode_i == `IPUSHQ) ? -8 : 
                 (icode_i == `IRET | icode_i == `IPOPQ ) ? 8 : 0);
  assign aluB = ((icode_i == `IRMMOVQ | icode_i == `IMRMOVQ | icode_i == `IOPQ | icode_i == `ICALL | icode_i == `IPUSHQ | icode_i == `IRET | icode_i == `IPOPQ) ? valB_i : 
                 (icode_i == `IRRMOVQ | icode_i == `IIRMOVQ) ? 0 : 0);

  always @(*) begin
    if (rst_i) begin
      new_cc[2] = 1;  //zf = 1
      new_cc[1] = 0;  //sf
      new_cc[0] = 0;  //cf
    end else if (icode_i == `IOPQ) begin
      new_cc[2] = (valE_o == 0) ? 1 : 0;
      new_cc[1] = valE_o[63];
      new_cc[0] = (alu_fun == `ALUADD) ? (aluA[63] == aluB[63]) & (aluA[63] != valE_o[63]) : (alu_fun == `ALUSUB) ? (~aluA[63] == aluB[63]) & (aluB[63] != valE_o[63]) : 0;
    end
  end

  // cond reg
  assign set_cc = (icode_i == `IOPQ) ? 1 : 0; // enable sign
  always @(posedge clk_i) begin
    if (rst_i) cc <= 3'b100;
    else if (set_cc) cc <= new_cc;
  end

  //branch cond logic

  wire zf = cc[2];
  wire sf = cc[1];
  wire of = cc[0];

  assign Cnd_o = (ifun_i == `C_YES) | (ifun_i == `C_LE & ((sf ^ of) | zf)) |  // <=
      (ifun_i == `C_L & (sf ^ of)) |  // <
      (ifun_i == `C_E & zf) |  // ==
      (ifun_i == `C_NE & ~zf) |  //!=
      (ifun_i == `C_GE & ~(sf ^ of)) |  // >=
      (ifun_i == `C_G & (~(sf ^ of) | ~zf));  // >

endmodule
