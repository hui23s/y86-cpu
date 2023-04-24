`include "define.v"
module fetch (
    input wire [`ADDR_BUS] PC_i,

    output wire [`ICODE_BUS] icode_o,
    output wire [`IFUN_BUS] ifun_o,
    output wire [`REG_ADDR_BUS] rA_o,
    output wire [`REG_ADDR_BUS] rB_o,
    output wire [`DATA_BUS] valC_o,
    output wire [`ADDR_BUS] valP_o,
    output wire        instr_valid_o,
    output wire        imem_error_o
);

  reg  [`BYTE0] instr_mem [0:`MEM_SIZE];
  wire [`INST_BUS] instr;
  wire        need_reg;
  wire        need_valC;

  assign imem_error_o  = (PC_i > `MEM_SIZE);
  // fetch 10B
  assign instr         = {instr_mem[PC_i+9], instr_mem[PC_i+8], instr_mem[PC_i+7], instr_mem[PC_i+6], instr_mem[PC_i+5], instr_mem[PC_i+4], instr_mem[PC_i+3], instr_mem[PC_i+2], instr_mem[PC_i+1], instr_mem[PC_i]};
  // split current instruction
  assign icode_o       = instr[`ICODE];
  assign ifun_o        = instr[`IFUN];
  // check icdoe valid
  assign instr_valid_o = (icode_o < 4'hC);
  // set needs
  assign need_reg      = (icode_o == `IRRMOVQ) || (icode_o == `IIRMOVQ) || (icode_o == `IRMMOVQ) || (icode_o == `IMRMOVQ) || (icode_o == `IOPQ) || (icode_o == `IPUSHQ) || (icode_o == `IPOPQ);
  assign need_valC     = (icode_o == `IIRMOVQ) || (icode_o == `IRMMOVQ) || (icode_o == `IMRMOVQ) || (icode_o == `IJXX) || (icode_o == `ICALL);
  // align
  assign rA_o          = need_reg ? instr[`RA] : `NREG;
  assign rB_o          = need_reg ? instr[`RB] : `NREG;
  assign valC_o        = need_valC ? (need_reg ? instr[79:16] : instr[71:8]) : `DATA_ZERO;
  assign valP_o        = PC_i + 1 + 8 * need_valC + need_reg;

  initial begin
    $readmemh("C:/Users/njhsm/Desktop/cpu/Y86_CPU_v1/instr_data.txt", instr_mem); 
    //instr_mem[0] = 8'h30;
    //instr_mem[1] = 8'hf8;
  end

endmodule
