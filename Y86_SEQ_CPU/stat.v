`include "define.v"
module stat (
    input wire instr_valid_i,
    input wire imem_error_i,
    input wire dmem_error_i,
    input wire [`ICODE_BUS] icode_i,

    output wire [`STAT_BUS] stat_o
);

  assign stat_o = (imem_error_i ? `SADR : !instr_valid_i ? `SINS : (icode_i == `IHALT) ? `SHLT : `SAOK);
endmodule
