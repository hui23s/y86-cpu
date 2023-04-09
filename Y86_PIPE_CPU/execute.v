`include "define.v"
module execute (
    input wire clk_i,
    input wire rst_i,

    input wire [`REG_ADDR_BUS] E_dstE_i,
    input wire [   `ICODE_BUS] E_icode_i,
    input wire [    `IFUN_BUS] E_ifun_i,

    input wire signed [`DATA_BUS] E_valA_i,
    input wire signed [`DATA_BUS] E_valB_i,
    input wire signed [`DATA_BUS] E_valC_i,

    input wire [`STAT_BUS] m_stat_i,
    input wire [`STAT_BUS] W_stat_i,

    output wire signed [    `DATA_BUS] e_valE_o,
    output wire        [`REG_ADDR_BUS] e_dstE_o,
    output wire                        e_Cnd_o
);
  wire [`IFUN_BUS] alu_fun;
  wire [`DATA_BUS] aluA;
  wire [`DATA_BUS] aluB;
  reg  [`COND_BUS] new_cc;
  reg  [`COND_BUS] cc;
  wire             set_cc;

  assign alu_fun = (E_icode_i == `IOPQ) ? E_ifun_i : `ALUADD;

  assign e_valE_o  = alu_fun == `ALUSUB ? aluB - aluA : alu_fun == `ALUAND ? aluB & aluA : alu_fun == `ALUXOR ? aluB ^ aluA : aluB + aluA;

  assign aluA    = ((E_icode_i == `IRRMOVQ | E_icode_i == `IOPQ) ? E_valA_i : (E_icode_i == `IIRMOVQ | E_icode_i == `IRMMOVQ | E_icode_i == `IMRMOVQ) ? E_valC_i : (E_icode_i == `ICALL | E_icode_i == `IPUSHQ) ? -8 : (E_icode_i == `IRET | E_icode_i == `IPOPQ) ? 8 : 0);
  assign aluB    = ((E_icode_i == `IRMMOVQ | E_icode_i == `IMRMOVQ | E_icode_i == `IOPQ | E_icode_i == `ICALL | E_icode_i == `IPUSHQ | E_icode_i == `IRET | E_icode_i == `IPOPQ) ? E_valB_i : (E_icode_i == `IRRMOVQ | E_icode_i == `IIRMOVQ) ? 0 : 0);

  always @(*) begin
    if (rst_i) begin
      new_cc[2] = 1;  //zf = 1
      new_cc[1] = 0;  //sf
      new_cc[0] = 0;  //cf
    end else if (E_icode_i == `IOPQ) begin
      new_cc[2] = (e_valE_o == 0) ? 1 : 0;
      new_cc[1] = e_valE_o[63];
      new_cc[0] = (alu_fun == `ALUADD) ? (aluA[63] == aluB[63]) & (aluA[63] != e_valE_o[63]) : (alu_fun == `ALUSUB) ? (~aluA[63] == aluB[63]) & (aluB[63] != e_valE_o[63]) : 0;
    end
  end

  // cond reg
  assign set_cc = (E_icode_i == `IOPQ) ? 1 : 0;  // enable sign
  always @(posedge clk_i) begin
    if (rst_i) cc <= 3'b100;
    else if (set_cc) cc <= new_cc;
  end

  //branch cond logic

  wire zf = cc[2];
  wire sf = cc[1];
  wire of = cc[0];

  assign e_Cnd_o  = (E_ifun_i == `C_YES) | (E_ifun_i == `C_LE & ((sf ^ of) | zf)) |  // <=
 (E_ifun_i == `C_L & (sf ^ of)) |  // <
 (E_ifun_i == `C_E & zf) |  // ==
 (E_ifun_i == `C_NE & ~zf) |  //!=
 (E_ifun_i == `C_GE & ~(sf ^ of)) |  // >=
 (E_ifun_i == `C_G & (~(sf ^ of) | ~zf));  // >

  assign e_dstE_o = ((E_icode_i == `IRRMOVQ) && !e_Cnd_o) ? `NREG : E_dstE_i;

endmodule
