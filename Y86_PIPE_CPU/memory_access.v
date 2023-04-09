`include "define.v"
module memory_access (
    input wire        clk_i,
    input wire [`ICODE_BUS] M_icode_i,
    input wire [`DATA_BUS] M_valE_i,   // alu -> addr
    input wire [`DATA_BUS] M_valA_i,   // write -> mem
    input wire [`COND_BUS] M_stat_i,

    output wire [`DATA_BUS] m_valM_o,       // mem -> read
    output wire [`STAT_BUS] m_stat_o
);

  wire        r_en;
  wire        w_en;
  wire [`ADDR_BUS] mem_addr;
  wire [`DATA_BUS] mem_data; // 写入数据
  wire dmem_error;

  assign mem_addr = ((M_icode_i == `IRMMOVQ | M_icode_i == `IPUSHQ | M_icode_i == `ICALL | M_icode_i == `IMRMOVQ) ? M_valE_i : 
  (M_icode_i == `IPOPQ | M_icode_i == `IRET) ? M_valA_i : 0);

  assign r_en = (M_icode_i == `IMRMOVQ | M_icode_i == `IPOPQ | M_icode_i == `IRET);
  assign w_en = (M_icode_i == `IRMMOVQ | M_icode_i == `IPUSHQ | M_icode_i == `ICALL);
  assign m_stat_o = dmem_error ? `SADR : M_stat_i;

  ram ram_moudle (
      .clk_i       (clk_i),
      .r_en        (r_en),
      .w_en        (w_en),
      .addr_i      (mem_addr),
      .wdata_i     (M_valA_i),
      .rdata_o     (m_valM_o),
      .dmem_error_o(dmem_error)
  );

endmodule
