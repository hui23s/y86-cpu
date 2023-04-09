`include "define.v"
`timescale 1ns/1ps

module tb;
    reg clk;
    reg rst;

    // select pc
    wire F_stall;
    wire F_bubble;
    wire [`ADDR_BUS] F_predPC;

    // fetch
    wire [`ADDR_BUS] f_pc;
    wire [`STAT_BUS] f_stat;
    wire [`ICODE_BUS] f_icode;
    wire [`IFUN_BUS] f_ifun;
    wire [`REG_ADDR_BUS] f_rA;
    wire [`REG_ADDR_BUS] f_rB;
    wire [`DATA_BUS] f_valC;
    wire [`ADDR_BUS] f_valP;
    wire [`ADDR_BUS] f_predPC;

    // decode
    wire D_stall;
    wire D_bubble;
    
    wire [`ADDR_BUS] D_pc;
    wire [`STAT_BUS] D_stat;
    wire [`ICODE_BUS] D_icode;
    wire [`IFUN_BUS] D_ifun;
    wire [`REG_ADDR_BUS] D_rA;
    wire [`REG_ADDR_BUS] D_rB;
    wire [`DATA_BUS] D_valC;
    wire [`ADDR_BUS] D_valP;

    wire [`DATA_BUS] d_valA;
    wire [`DATA_BUS] d_valB;
    wire [`REG_ADDR_BUS] d_srcA;
    wire [`REG_ADDR_BUS] d_srcB;
    wire [`REG_ADDR_BUS] d_dstE;
    wire [`REG_ADDR_BUS] d_dstM;
    

    // execute
    wire E_stall;
    wire E_bubble;
    wire set_cc;

    wire [`STAT_BUS] E_stat;
    wire [`ADDR_BUS] E_pc;
    wire [`ICODE_BUS] E_icode;
    wire [`IFUN_BUS] E_ifun;
    wire [`DATA_BUS] E_valC;
    wire [`DATA_BUS] E_valA;
    wire [`DATA_BUS] E_valB;
    wire [`REG_ADDR_BUS] E_dstE;
    wire [`REG_ADDR_BUS] E_dstM;
    wire [`REG_ADDR_BUS] E_srcA;
    wire [`REG_ADDR_BUS] E_srcB;

    wire [`DATA_BUS] e_valE;
    wire [`REG_ADDR_BUS] e_dstE;
    wire e_Cnd;

    // memory
    wire M_bubble;
    wire M_stall;

    wire [`STAT_BUS] M_stat;
    wire [`ADDR_BUS] M_pc;
    wire [`ICODE_BUS] M_icode;
    wire [`IFUN_BUS] M_ifun;
    wire M_Cnd;
    wire [`DATA_BUS] M_valC;
    wire [`DATA_BUS] M_valA;
    wire [`DATA_BUS] M_valE;
    wire [`REG_ADDR_BUS] M_dstE;
    wire [`REG_ADDR_BUS] M_dstM;

    wire [`DATA_BUS] m_valM;
    wire [`STAT_BUS] m_stat;

    // write_back
    wire W_stall;
    wire W_bubble;
    
    wire [`STAT_BUS] W_stat;
    wire [`ADDR_BUS] W_pc;
    wire [`ICODE_BUS] W_icode;
    wire [`DATA_BUS] W_valE;
    wire [`DATA_BUS] W_valM;
    wire [`REG_ADDR_BUS] W_dstE;
    wire [`REG_ADDR_BUS] W_dstM;


assign F_bubble = `FALSE;
assign E_stall = `FALSE;
assign M_stall = `FALSE;
assign W_bubble = `FALSE;

controller controller_moudle(
    .D_icode_i(D_icode),
    .d_srcA_i(d_srcA),
    .d_srcB_i(d_srcB),
    .E_icode_i(E_icode),
    .E_dstM_i(E_dstM),
    .e_Cnd_i(e_Cnd),
    .M_icode_i(M_icode),
    .m_stat_i(m_stat),
    .W_stat_i(W_stat),
    .F_stall_o(F_stall),
    .D_bubble_o(D_bubble),
    .D_stall_o(D_stall),
    .E_bubble_o(E_bubble),
    .set_cc_o(set_cc),
    .M_bubble_o(M_bubble),
    .W_stall_o(W_stall)
);

fetch_reg fetch_reg(
    .clk_i(clk),
    .F_stall_i(F_stall),
    .F_bubble_i(F_bubble),
    .f_predPC_i(f_predPC),
    .F_predPC_o(F_predPC)
);

updatePC updatePC_moudle(
    .F_predPC_i(F_predPC),
    .M_icode_i(M_icode),
    .W_icode_i(W_icode),
    .M_valA_i(M_valA),
    .W_valM_i(W_valM),
    .M_Cnd_i(M_Cnd),
    .f_pc_o(f_pc)
);

fetch fetch_moudle(
    .f_pc_i(f_pc),
    .f_icode_o(f_icode),
    .f_ifun_o(f_ifun),
    .f_rA_o(f_rA),
    .f_rB_o(f_rB),
    .f_valC_o(f_valC),
    .f_valP_o(f_valP),
    .f_predPC_o(f_predPC),
    .f_stat_o(f_stat)
);

decode_reg decode_reg(
    .clk_i(clk),
    .D_stall_i(D_stall),
    .D_bubble_i(D_bubble),
    
    .f_pc_i(f_pc),
    .f_stat_i(f_stat),
    .f_icode_i(f_icode),
    .f_ifun_i(f_ifun),
    .f_rA_i(f_rA),
    .f_rB_i(f_rB),
    .f_valC_i(f_valC),
    .f_valP_i(f_valP),

    .D_pc_o(D_pc),
    .D_stat_o(D_stat),
    .D_icode_o(D_icode),
    .D_ifun_o(D_ifun),
    .D_rA_o(D_rA),
    .D_rB_o(D_rB),
    .D_valC_o(D_valC),
    .D_valP_o(D_valP)
);

decode decode_moudle(
    .clk_i(clk),
    .D_icode_i(D_icode),
    .D_rA_i(D_rA),
    .D_rB_i(D_rB),
    .D_valP_i(D_valP),

    .e_dstE_i(e_dstE),
    .e_valE_i(e_valE),
    .M_dstM_i(M_dstM),
    .m_valM_i(m_valM),
    .M_dstE_i(M_dstE),
    .M_valE_i(M_valE),
    .W_dstE_i(W_dstE),
    .W_valE_i(W_valE),
    .W_dstM_i(W_dstM),
    .W_valM_i(W_valM),

    .d_valA_o(d_valA),
    .d_valB_o(d_valB),
    .d_srcA_o(d_srcA),
    .d_srcB_o(d_srcB),
    .d_dstE_o(d_dstE),
    .d_dstM_o(d_dstM)
);

execute_reg execute_reg(
    .clk_i(clk),
    .E_stall_i(E_stall),
    .E_bubble_i(E_bubble),

    .d_stat_i(D_stat),
    .d_pc_i(D_pc),
    .d_icode_i(D_icode),
    .d_ifun_i(D_ifun),
    .d_valC_i(D_valC),
    .d_valA_i(d_valA),
    .d_valB_i(d_valB),
    .d_dstE_i(d_dstE),
    .d_dstM_i(d_dstM),
    .d_srcA_i(d_srcA),
    .d_srcB_i(d_srcB),

    .E_stat_o(E_stat),
    .E_pc_o(E_pc),
    .E_icode_o(E_icode),
    .E_ifun_o(E_ifun),
    .E_valC_o(E_valC),
    .E_valA_o(E_valA),
    .E_valB_o(E_valB),
    .E_dstE_o(E_dstE),
    .E_dstM_o(E_dstM),
    .E_srcA_o(E_srcA),
    .E_srcB_o(E_srcB)
);

execute execute_moudle(
    .clk_i(clk),
    .rst_i(rst),
    .E_dstE_i(E_dstE),
    .E_icode_i(E_icode),
    .E_ifun_i(E_ifun),
    .E_valA_i(E_valA),
    .E_valB_i(E_valB),
    .E_valC_i(E_valC),
    .m_stat_i(m_stat),
    .W_stat_i(W_stat),

    .e_valE_o(e_valE),
    .e_dstE_o(e_dstE),
    .e_Cnd_o(e_Cnd)
);

memory_reg memory_reg(
    .clk_i(clk),
    .M_stall_i(M_stall),
    .M_bubble_i(M_bubble),

    .e_stat_i(E_stat),
    .e_pc_i(E_pc),
    .e_icode_i(E_icode),
    .e_ifun_i(E_ifun),
    .e_Cnd_i(e_Cnd),
    .e_valE_i(e_valE),
    .e_valA_i(E_valA),
    .e_dstE_i(e_dstE),
    .e_dstM_i(E_dstM),

    .M_stat_o(M_stat),
    .M_pc_o(M_pc),
    .M_icode_o(M_icode),
    .M_ifun_o(M_ifun),
    .M_Cnd_o(M_Cnd),
    .M_valE_o(M_valE),
    .M_valA_o(M_valA),
    .M_dstE_o(M_dstE),
    .M_dstM_o(M_dstM)
);

memory_access mem_moudle(
    .clk_i(clk),
    .M_icode_i(M_icode),
    .M_valE_i(M_valE),
    .M_valA_i(M_valA),
    .M_stat_i(M_stat),

    .m_valM_o(m_valM),
    .m_stat_o(m_stat)
);

write_reg write_reg(
    .clk_i(clk),
    .W_stall_i(W_stall),
    .W_bubble_i(W_bubble),
    
    .m_stat_i(m_stat),
    .m_pc_i(M_pc),
    .m_icode_i(M_icode),
    .M_valE_i(M_valE),
    .m_valM_i(m_valM),
    .M_dstE_i(M_dstE),
    .M_dstM_i(M_dstM),
    
    .W_stat_o(W_stat),
    .W_pc_o(W_pc),
    .W_icode_o(W_icode),
    .W_valE_o(W_valE),
    .W_valM_o(W_valM),
    .W_dstE_o(W_dstE),
    .W_dstM_o(W_dstM)
);
    
initial
        begin
            clk = 0;
            rst = 0;
        end

always
    #20 clk = ~clk;

// initial begin
//     forever @ (posedge clk) #2 PC_i = next_PC;
// end

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
    //     $display("PC=%d, icode=%h, ifun=%h, rA=%h, rB=%h, valC=%h, valP=%h,valE_exe=%h, valM_mem=%16h, valE_wb=%h, valM_wb=%h, next=%d",
    //           PC_i, icode_o, ifun_o, rA_o, rB_o, valC_o, valP_o, valE_exe_o, valM_mem_o, valE_wb_o, valM_wb_o, next_PC
    // );
    end
end

endmodule


