`include "define.v"
`timescale 1ns/1ps

module tb;
    reg clk;
    reg rst;

    // fetch
    reg [`ADDR_BUS] PC_i;
    wire [`ICODE_BUS] icode_o;
    wire [`IFUN_BUS] ifun_o;
    wire [`REG_ADDR_BUS] rA_o;
    wire [`REG_ADDR_BUS] rB_o;
    wire [`DATA_BUS] valC_o;
    wire [`ADDR_BUS] valP_o;
    wire        instr_valid_o;
    wire        imem_error_o;

    // decode
    wire [`DATA_BUS] valA_o;
    wire [`ADDR_BUS] valB_o;

    // execute
    wire [`DATA_BUS] valE_exe_o;
    wire Cnd_o;

    // memory
    
    wire [`DATA_BUS] valM_mem_o;
    wire dmem_error_o;

    // write_back
    wire [`DATA_BUS] valE_wb_o;
    wire [`DATA_BUS] valM_wb_o;
    wire [`STAT_BUS] stat_o;

    // updatePC
    wire [`ADDR_BUS] next_PC;

fetch fetch_moudle(
    .PC_i(PC_i),
    .icode_o(icode_o),
    .ifun_o(ifun_o),
    .rA_o(rA_o),
    .rB_o(rB_o),
    .valC_o(valC_o),
    .valP_o(valP_o),
    .instr_valid_o(instr_valid_o),
    .imem_error_o(imem_error_o)
);

decode decode_moudle(
    .clk_i(clk),
    .rst_i(rst),
    .icode_i(icode_o),
    .rA_i(rA_o),
    .rB_i(rB_o),
    .valE_i(valE_wb_o),
    .valM_i(valM_wb_o),
    .valA_o(valA_o),
    .valB_o(valB_o)
);

execute execute_moudle(
    .clk_i(clk),
    .rst_i(rst),
    .icode_i(icode_o),
    .ifun_i(ifun_o),
    .valA_i(valA_o),
    .valB_i(valB_o),
    .valC_i(valC_o),
    .valE_o(valE_exe_o),
    .Cnd_o(Cnd_o)
);

memory_access mem_moudle(
    .clk_i(clk),
    .icode_i(icode_o),
    .valE_i(valE_exe_o),
    .valA_i(valA_o),
    .valP_i(valP_o),

    .valM_o(valM_mem_o),
    .dmem_error_o(dmem_error_o)
);

write_back write_moudle(
    .icode_i(icode_o),
    .valE_i(valE_exe_o),
    .valM_i(valM_mem_o),
    .instr_valid_i(instr_valid_o),
    .imem_error_i(imem_error_o),

    .valE_o(valE_wb_o),
    .valM_o(valM_wb_o),
    .stat_o(stat_o)

);

updatePC updatePC_moudle(
    .icode_i(icode_o),
    .Cnd_i(Cnd_o),
    .valP_i(valP_o),
    .valC_i(valC_o),
    .valM_i(valM_wb_o),

    .next_PC(next_PC)
);

    
initial
        begin
            PC_i = 0;
            clk = 0;
            rst = 0;
        end

always
    #20 clk = ~clk;

initial begin
    forever @ (posedge clk) #2 PC_i = next_PC;
end

initial begin
    #500 $stop;
end


initial begin
    // $monitor("PC=%8d, icode=%h, ifun=%h, rA=%h, rB=%h, valC=%16h, instr_valid=%d, imem_error=%d",
    //         PC_i, icode_o, ifun_o, rA_o, rB_o, valC_o, instr_valid_o, imem_error_o
    // );
    // $monitor("icode=%h, rA=%h, rB=%h, valE=%16h, valM=%16h, valA=%16h, valB=%16h",
    //         icode_o, rA_o, rB_o, valE_o, valM_o,valA_o,valB_o
    // );
    // $monitor("icode=%h, ifun=%h, valA=%d, valB=%d, valC=%16h, valE=%d, cnd=%h",
    //           icode_o, ifun_o, valA_o, valB_o, valC_o ,valE_o, Cnd_o
    // );
    forever @ (posedge clk) #3 begin
        $display("PC=%d, icode=%h, ifun=%h, rA=%h, rB=%h, valC=%h, valP=%h,valE_exe=%h, valM_mem=%16h, valE_wb=%h, valM_wb=%h, next=%d",
              PC_i, icode_o, ifun_o, rA_o, rB_o, valC_o, valP_o, valE_exe_o, valM_mem_o, valE_wb_o, valM_wb_o, next_PC
    );
    end
end

endmodule


