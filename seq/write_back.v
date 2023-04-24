`include "define.v"
module write_back (
    input wire [`ICODE_BUS] icode_i,
    input wire [`DATA_BUS] valE_i,
    input wire [`DATA_BUS] valM_i,

    input wire instr_valid_i,
    input wire imem_error_i,
    input wire dmem_error_i,

    output wire [`DATA_BUS] valE_o,
    output wire [`DATA_BUS] valM_o,

    output wire [`STAT_BUS] stat_o
);

assign valE_o = valE_i;
assign valM_o = valM_i;

stat stat_moudle(
    .instr_valid_i(instr_valid_i),
    .imem_error_i(imem_error_i),
    .dmem_error_i(dmem_error_i),
    .icode_i(icode_i),
    .stat_o(stat_o)
);
    
endmodule
