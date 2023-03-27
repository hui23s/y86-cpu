// Instruction Codes 
`define IHALT 4'H0    
`define INOP 4'H1   
`define IRRMOVQ 4'H2  
`define IIRMOVQ 4'H3
`define IRMMOVQ 4'H4
`define IMRMOVQ 4'H5
`define IOPQ 4'H6
`define IJXX 4'H7
`define ICALL 4'H8
`define IRET 4'H9
`define IPUSHQ 4'HA
`define IPOPQ 4'HB

/* Function codes */
`define FNONE 4'H0  
// INOP
`define FADDQ 4'H0  
`define FSUBQ 4'H1
`define FANDQ 4'H2
`define FXORQ 4'H3
// IJXX
`define FJMP 4'H0
`define FJLE 4'H1
`define FJL 4'H2
`define FJE 4'H3
`define FJNE 4'H4
`define FJGE 4'H5
`define FJG 4'H6
// FRRMOVL
`define FRRMOVQ 4'H0
// ICMOVXX (FRRMOVL)
`define FCMOVLE 4'H1
`define FCMOVL 4'H2
`define FCMOVE 4'H3
`define FCMOVNE 4'H4
`define FCMOVGE 4'H5
`define FCMOVG 4'H6

/* Status Codes */
`define SAOK 4'H1
`define SADR 4'H2
`define SINS 4'H3
`define SHLT 4'H4

/* Other Codes */
`define RST_EN 1'B1
`define TRUE 1'B1
`define FALSE 1'B0
`define ENABLE 1'b1
`define DISABLE 1'b0
`define ALUADD 4'H0
`define ALUSUB 4'H1
`define ALUAND 4'H2
`define ALUXOR 4'H3

// Registers
`define RAX 4'H0
`define RBX 4'H3
`define RCX 4'H1
`define RDX 4'H2
`define RSP 4'H4
`define RBP 4'H5
`define RSI 4'H6
`define RDI 4'H7
`define R8 4'H8
`define R9 4'H9
`define R10 4'HA
`define R11 4'HB
`define R12 4'HC
`define R13 4'HD
`define R14 4'HE
`define NREG 4'HF

// Data width
`define ICODE_WIDTH 4
`define IFUN_WIDTH 4
`define BYTE_WIDTH 8
`define ADDR_WIDTH 64
`define DATA_WIDTH 64
`define INST_WIDTH 80

// Buses
`define IFUN_BUS 3:0
`define ICODE_BUS 3:0
`define REG_ADDR_BUS 3:0
`define ADDR_BUS 63:0
`define INST_BUS 79:0
`define DATA_BUS 63:0
`define STAT_BUS 2:0
`define COND_BUS 2:0

// Instruction parts
`define ICODE 7:4
`define IFUN 3:0
`define RA 15:12
`define RB 11:8
`define BYTE8 71:64
`define BYTE7 63:56
`define BYTE6 55:48
`define BYTE5 47:40
`define BYTE4 39:32
`define BYTE3 31:24
`define BYTE2 23:16
`define BYTE1 15:8
`define BYTE0 7:0

// Memory size
`define MEM_SIZE 1023

// Default values
`define ICODE_ZERO `ICODE_WIDTH'H0
`define IFUN_ZERO `IFUN_WIDTH'H0
`define DATA_ZERO `DATA_WIDTH'H0
`define ADDR_ZERO `ADDR_WIDTH'H0
`define NONE_INST `INST_WIDTH'H0
`define BYTE_ZERO `BYTE_WIDTH'H0

// cond signal
`define C_YES 4'H0
`define C_LE 4'H1
`define C_L 4'H2
`define C_E 4'H3
`define C_NE 4'H4
`define C_GE 4'H5
`define C_G 4'H6
