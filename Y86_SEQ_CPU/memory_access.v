`include "define.v"
module memory_access (
    input wire        clk_i,
    input wire [`ICODE_BUS] icode_i,
    input wire [`DATA_BUS] valE_i,   // alu -> addr
    input wire [`DATA_BUS] valA_i,   // write -> mem
    input wire [`ADDR_BUS] valP_i,   // ret addr

    output wire [`DATA_BUS] valM_o,       // mem -> read
    output wire        dmem_error_o
);

  wire        r_en;
  wire        w_en;
  wire [`ADDR_BUS] mem_addr;
  wire [`DATA_BUS] mem_data; // 写入数据

  assign mem_addr = ((icode_i == `IRMMOVQ | icode_i == `IPUSHQ | icode_i == `ICALL | icode_i == `IMRMOVQ) ? valE_i : 
  (icode_i == `IPOPQ | icode_i == `IRET) ? valA_i : 0);

  assign mem_data = ((icode_i == `IRMMOVQ | icode_i == `IPUSHQ) ? valA_i : (icode_i == `ICALL) ? valP_i : 0);

  assign r_en = (icode_i == `IMRMOVQ | icode_i == `IPOPQ | icode_i == `IRET);
  assign w_en = (icode_i == `IRMMOVQ | icode_i == `IPUSHQ | icode_i == `ICALL);

  // always @(*) begin
  //   case (icode_i)
  //     `IRMMOVQ: begin   
  //       r_en     <= `FALSE;
  //       w_en     <= `TRUE;
  //       mem_addr <= valE_i;
  //       mem_data <= valA_i;
  //     end
  //     `IMRMOVQ: begin
  //       r_en     <= `TRUE;
  //       w_en     <= `FALSE;
  //       mem_addr <= valE_i;
  //     end

  //     `ICALL: begin
  //       r_en     <= `FALSE;
  //       w_en     <= `TRUE;
  //       mem_addr <= valE_i;
  //       mem_data <= valP_i;
  //     end

  //     `IRET: begin
  //       r_en     <= `TRUE;
  //       w_en     <= `FALSE;
  //       mem_addr <= valA_i;
  //     end

  //     `IPUSHQ: begin
  //       r_en     <= `FALSE;
  //       w_en     <= `TRUE;
  //       mem_addr <= valE_i;
  //       mem_data <= valA_i;
  //     end

  //     `IPOPQ: begin
  //       r_en     <= `TRUE;
  //       w_en     <= `FALSE;
  //       mem_addr <= valA_i;
  //     end
  //     default: begin
  //       r_en <= `FALSE;
  //       w_en <= `FALSE;
  //     end
  //   endcase
  // end

  ram ram_moudle (
      .clk_i       (clk_i),
      .r_en        (r_en),
      .w_en        (w_en),
      .addr_i      (mem_addr),
      .wdata_i     (mem_data),
      .rdata_o     (valM_o),
      .dmem_error_o(dmem_error_o)
  );

endmodule
