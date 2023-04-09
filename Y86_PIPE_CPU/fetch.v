`include "define.v"
module fetch (
    input wire [`ADDR_BUS] f_pc_i,

    output wire [   `ICODE_BUS] f_icode_o,
    output wire [    `IFUN_BUS] f_ifun_o,
    output wire [`REG_ADDR_BUS] f_rA_o,
    output wire [`REG_ADDR_BUS] f_rB_o,
    output wire [    `DATA_BUS] f_valC_o,
    output wire [    `ADDR_BUS] f_valP_o,
    output wire [    `ADDR_BUS] f_predPC_o,
    output wire [    `STAT_BUS] f_stat_o
);

  reg  [   `BYTE0] instr_mem   [0:`MEM_SIZE];
  wire [`INST_BUS] instr;
  wire             need_reg;
  wire             need_valC;

  wire             imem_error;
  wire             instr_valid;

  assign imem_error  = (f_pc_i > `MEM_SIZE);

  // fetch 10B
  assign instr       = {instr_mem[f_pc_i+9], instr_mem[f_pc_i+8], instr_mem[f_pc_i+7], instr_mem[f_pc_i+6], instr_mem[f_pc_i+5], instr_mem[f_pc_i+4], instr_mem[f_pc_i+3], instr_mem[f_pc_i+2], instr_mem[f_pc_i+1], instr_mem[f_pc_i]};
  // split current instruction
  assign f_icode_o   = instr[`ICODE];
  assign f_ifun_o    = instr[`IFUN];

  assign instr_valid = (f_icode_o < 4'hC);

  // set needs
  assign need_reg    = (f_icode_o == `IRRMOVQ) || (f_icode_o == `IIRMOVQ) || (f_icode_o == `IRMMOVQ) || (f_icode_o == `IMRMOVQ) || (f_icode_o == `IOPQ) || (f_icode_o == `IPUSHQ) || (f_icode_o == `IPOPQ);
  assign need_valC   = (f_icode_o == `IIRMOVQ) || (f_icode_o == `IRMMOVQ) || (f_icode_o == `IMRMOVQ) || (f_icode_o == `IJXX) || (f_icode_o == `ICALL);
  // align
  assign f_rA_o      = need_reg ? instr[`RA] : `NREG;
  assign f_rB_o      = need_reg ? instr[`RB] : `NREG;
  assign f_valC_o    = need_valC ? (need_reg ? instr[79:16] : instr[71:8]) : `DATA_ZERO;
  assign f_valP_o    = f_pc_i + 1 + 8 * need_valC + need_reg;

  assign f_stat_o    = (imem_error ? `SADR : !instr_valid ? `SINS : (f_icode_o == `IHALT) ? `SHLT : `SAOK);
  assign f_predPC_o  = (f_icode_o == `IJXX || f_icode_o == `ICALL) ? f_valC_o : f_valP_o;

  initial begin
    $readmemh("C:/Users/njhsm/Desktop/cpu/Y86_CPU_v2/instr_data.txt", instr_mem);
    //instr_mem[0] = 8'h30;
    //instr_mem[1] = 8'hf8;
  end

endmodule
