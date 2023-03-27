`include "define.v"
module ram (
    input wire clk_i,

    input wire r_en,
    input wire w_en,

    input wire [`ADDR_BUS] addr_i,
    input wire [`DATA_BUS] wdata_i,

    output wire [`DATA_BUS] rdata_o,
    output wire        dmem_error_o
);

  reg [`BYTE0] mem[0:`MEM_SIZE];
  assign dmem_error_o = (addr_i > `MEM_SIZE);
  assign rdata_o      = (r_en == `TRUE) ? ({mem[addr_i+7], mem[addr_i+6], mem[addr_i+5], mem[addr_i+4], mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i+0]}) : `DATA_ZERO;

  always @(posedge clk_i) begin
    if (w_en) {mem[addr_i+7], mem[addr_i+6], mem[addr_i+5], mem[addr_i+4], mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i+0]} <= wdata_i;
  end

  initial begin
    $readmemh("C:/Users/njhsm/Desktop/cpu/Y86_CPU_v1/mem_data.txt", mem); 
  end

endmodule
