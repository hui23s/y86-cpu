## Y86-64简介
### 指令集

        0x00                        halt
        0x10                        nop

        0x20rArB                    rrmovq

        0x30FrB0000000000000000     irmovq

        0x40rArB0000000000000000    rmmovq
        0x50rArB0000000000000000    mrmovq

        0x60rArB                    addq
        0x61rArB                    subq
        0x62rArB                    andq
        0x63rArB                    xorq

        0x700000000000000000        jmp
        0x710000000000000000        jle
        0x720000000000000000        jl
        0x730000000000000000        je
        0x740000000000000000        jne
        0x750000000000000000        jge
        0x760000000000000000        jg

        0x800000000000000000        call
        0x90                        ret
        0xA0rAF                     pushq
        0xB0rAF                     popq

### 寄存器

Y86-64共有15个64位寄存器，编号从0x0到0xE，0xF则表示不使用寄存器
```
0   rax
1   rcx
2   rdx
3   rbx
4   rsp
5   rbp
6   rsi
7   rdi
8   r8
9   r9
A   r10
B   r11
C   r12
D   r13
E   r14
F   NONE

```
		
### 五级流水线

Y86的指令执行被划分为五个阶段：取址、译码、执行、访存、写回。
* 取值
根据之前的执行结果选择PC值并据此从内存中取出将要执行的指令，同时根据指令码将解析指令中的源寄存器、目的寄存器、立即数等。
* 译码
根据指令码选择将要送到执行阶段的操作数，包括使用数据转发机制处理数据冒险。
* 执行
ALU根据指令码执行相应的计算并设置标志位和条件码。
* 访存
若指令需要读写内存，则在本阶段进行。
* 写回
将ALU的运算结果和访存阶段取出的数据（如果有的话）写回到目的寄存器。

### Y86-64结构图
Y86单周期结构如图
![[Pasted image 20230331110015.png]]

Y86流水线的最终结构如图：
![[PIPE_CPU.png]]




## 学习记录

### 单周期
#### 3.14-3.22
hdlbits刷了90+题，熟悉了verilog基本语法
重读csapp第三第四章，并读了官方给的Y86 CPU设计文档
配置vscode、modelsim等环境
初步实现了单周期各阶段模块，测试时没有分阶段测过，全部连接时出现bug，决定重构并记录过程

#### 3.22
重构取值阶段，并测试如下指令
| Y86代码                            | 汇编                          | PC  |
| ---------------------------------- | ----------------------------- | --- |
| halt                               | 00                            | 0   | 
| nop                                | 10                            | 1   |
| rrmovq %r8, %r9                    | 20 89                         | 2   |
| irmovq $8, %r8                     | 30 f8 08 00 00 00 00 00 00 00 | 4   |
| rmmovq %rsp, 0x123456789abcd(%rbx) | 40 43 cd ab 89 67 45 23 01 00 | 14    |
| mrmovq (%rdi), %r10                | 50 a7 00 00 00 00 00 00 00 00 | 24    |
| xorq %rax, %rax                    | 63 00                         | 34    |
| jmp 0x87                           | 70 87 00 00 00 00 00 00 00    | 36    |
| call 0x87                          | 80 87 00 00 00 00 00 00 00    |  45   |
| ret                                | 90                            | 54    |
| push %rdx                          | a0 2f                         | 55    |
| pop %rbx                           | b0 3f                         | 57    |

观察log信息和波形图，没有发现错误（更正PC后）
![[fetch_log.png]]

![[fetch_tb.png]]

优化：
1. 没有引入fetch_reg前，valC没有初值0，即使指令不需要valC，也会被赋值
`assign valC_o= need_valC ? (need_reg ? instr[79:16] : instr[71:8]) : 64'b0;
2. 用readmemh将txt读入instr_mem，不需要手动设置指令，后续将指令读入转移到外围模块，不对核心模块代码进行多次更改
`$readmemh("C:/Users/njhsm/Desktop/cpu/Y86_CPU_v1/instr_data.txt", instr_mem);
3. 代码中增加大量宏定义来降低耦合度，比如增加位宽等，具体可见define.v
```
// Data width
`define ICODE_WIDTH     4
`define IFUN_WIDTH      4
`define BYTE_WIDTH      8
`define ADDR_WIDTH      64
`define DATA_WIDTH      64
`define INST_WIDTH      80
// Buses
`define IFUN_BUS        3:0
`define ICODE_BUS       3:0
`define REG_ADDR_BUS    3:0
`define ADDR_BUS        63:0
`define INST_BUS        79:0
`define DATA_BUS        63:0
`define STAT_BUS        2:0
```

#### 3.23
重构译码阶段，寄存器初值
| 寄存器 | 编号 | 初值 |    
| ------ | ---- | ---- |
| %rax   | 0    | 0    |
| %rcx   | 1    | 1    |
| %rdx   | 2    | 2    |
| %rbx   | 3    | 3    |
| %rsp   | 4    | 4    |
| %rbp   | 5    | 5    |
| %rsi   | 6    | 6    |
| %rdi   | 7    | 7    |
| %r8    | 8    | 8    |
| %r9    | 9    | 9    |
| %r10   | 10   | 10   |
| %r11   | 11   | 11   |
| %r12   | 12   | 12   |
| %r13   | 13   | 13   |
| %r14   | 14   | 14     |

用测试fetch的指令序列进行测试，时钟先始终置为0，read正常
| Y86代码                            | 汇编                          | PC  |
| ---------------------------------- | ----------------------------- | --- |
| halt                               | 00                            | 0   | 
| nop                                | 10                            | 1   |
| rrmovq %r8, %r9                    | 20 89                         | 2   |
| irmovq $8, %r8                     | 30 f8 08 00 00 00 00 00 00 00 | 4   |
| rmmovq %rsp, 0x123456789abcd(%rbx) | 40 43 cd ab 89 67 45 23 01 00 | 14    |
| mrmovq (%rdi), %r10                | 50 a7 00 00 00 00 00 00 00 00 | 24    |
| xorq %rax, %rax                    | 63 00                         | 34    |
| jmp 0x87                           | 70 87 00 00 00 00 00 00 00    | 36    |
| call 0x87                          | 80 87 00 00 00 00 00 00 00    |  45   |
| ret                                | 90                            | 54    |
| push %rdx                          | a0 2f                         | 55    |
| pop %rbx                           | b0 3f                         | 57    |
![[decode_log.png]]
![[decode_tb.png]]

逐条指令分析从寄存器读功能：
1. nop
2. halt
3. rrmovq %r8, %r9 
valA从r8中正确取出，值为0x8，不需要用到valB，等到执行阶段将valE设置为valA后写入目的寄存器r9，dstE成功设置为了0x9，但valE暂时为0
4. irmovq $8, %r8 
该指令不需要从寄存器读数，需要在执行阶段将valC（0x8）传入valE写回r8，dst为8，正确
5. rmmovq %rsp, 0x123456789abcd(%rbx)
该指令源寄存器%rsp编号为4，目的为变址寻址，基址%rbx编号为3，读出的valA和valB也分别为0x4，0x3，正确
6. mrmovq (%rdi), %r10  注意该指令格式 mrmovq D(rB), rA即mrmovq (7), a
该指令不需要valA，valB为0x7，从内存读出数据valM写入dstM为a的寄存器，正确
7. xorq %rax, %rax
rA，rB正确，valA，valB正确，dstE为rax编号0，正确
8. jmp 0x87
9. call 0x87
将栈顶指针即rsp内容保存到valB，执行阶段valB-8后得到的valE更新rsp，故dstE为4，正确
10. ret
栈顶指针保存到valA和valB中，执行阶段valB+8，得到valE更新rsp，dstE为4，正确
访存时要通过valA找到内存中的返回地址，来更新PC，valM应该有值。
11. push %rdx
valA为rA（rdx）值0x2，valB为rsp值0x4，将valB-8后得到的valE更新rsp，dstE为4，正确
12. pop %rbx
valA，valB为rsp值0x4，valB+8得到的valE更新rsp，dstE为4，valM更新rA，dstE为rbx编号3，正确。

优化：
1. 将大量always块改为占用资源更少的assign

发现bug：
1. ~~fetch阶段设计的测试指令序列中jmp和call指令长度多了一个Byte，但手动设置PC地址，加上小端转换时，多的一个0Byte被转化成了高位的0，所以暂时没影响。

#### 3.24
重构execute模块，为防止溢出，rsp初值重设为0x40，同样尽可能的把always块改为assign语句

暂时不引入时钟，对之前指令序列进行测试
![[exe_log_nclk.png]]
![[exe_tb_nclk.png]]
逐条分析
1. nop
2. halt
3. rrmovq %r8, %r9 
valA直接赋给valE即可，正确
4. irmovq $8, %r8 
valC（0x8）赋给valE写回r8，正确
5. rmmovq %rsp, 0x123456789abcd(%rbx)
valE为基址rbx中的0x3加上valC，得0x123456789abd0，正确
6. mrmovq (%rdi), %r10  注意该指令格式 mrmovq D(rB), rA即mrmovq (7), a
valE为基址rdi中的0x7加上valC0，得0x7，正确
7. 原来的xorq %rax, %rax会引起cnd变为不定态（控制逻辑不完善），换用add %rcx，%rdx测试
valA，valB分别为0x1，0x2，valE得0x3，setCC也被置为1，正确
8. jmp 0x87
9. call 0x87
将栈顶指针即rsp值0x4保存到valB，执行阶段valB-8后得到的valE发生溢出，将rsp初值调整为0x40，新的valE为0x38，正确
10. ret
rsp值保存到valA和valB中，执行阶段valB+8，得到valE为0x48，正确
访存时要通过valA找到内存中的返回地址，来更新PC，valM应该有值
11. push %rdx
valA为rA（rdx）值0x2，valB为rsp值0x40，valE-8后得valE为0x38，正确
12. pop %rbx
valA，valB为rsp值0x40，valB+8得到的valE为0x48，正确

加时钟后，暂时看起来正常，但是由于rst信号始终为1，newcc的值没有更新过
![[exe_tb.png]]

把rst，设置为clk间隔的一半，加进去，new_cc正常，但没有写入cc，因为cc只能在下一个时钟上升沿写入，而rst信号正好也到了上升沿，又把cc重置了，newcc无法传递进去
![[Pasted image 20230324183605.png]]

这里取巧，把rst设置为12个时间间隔变化一次，看到cc可以正常更新，证明代码逻辑上没问题，但重置时又出了问题，cc只能在每个周期开始时被重置
如果把rst间隔设置过小，比如说4，那么newcc又会重置
看视频里单周期的阶段不涉及复位信号，所以暂时留下一个bug，看看等到流水线阶段怎么解决
![[Pasted image 20230324185012.png]]

设计几条IOPQ指令测试一下newcc的逻辑是否正常，这里没有接decode的写回逻辑
把r14初值设置为0x7fffffffffffffff，即有符号数最大值
测试两条60 2e 和 61 65
第一条valE发生正溢出，看到newcc的sf和cf被置为1，正常
第二条得到valE为负，只有sf为1，正常，可以看出newcc的逻辑没有问题
![[Pasted image 20230324201927.png]]

bug：
1. ~~rst与cc更新问题
2. ~~测试newcc时如果decode阶段有valE写回值，会出现bug

#### 3.25
重构剩下三部分，访存，写回与更新PC
其中ram部分的初值也用readmemh来读文件，将内存的对应的byte设置为从00开始递增的值
由于访存阶段只是模块调用，写回部分涉及到前面的decode阶段，加上更新PC比较简单，直接对整个单周期CPU进行测试

对之前测试指令序列进行一些小改动
| Y86代码                            | 汇编                          | PC  |
| ---------------------------------- | ----------------------------- | --- |
| halt                               | 00                            | 0   |
| nop                                | 10                            | 1   |
| rrmovq %r8, %r9                    | 20 89                         | 2   |
| irmovq $9, %r8                     | 30 f8 09 00 00 00 00 00 00 00 | 4   |
| rmmovq %rsp, 0x0000000000000001(%rbx) | 40 43 01 00 00 00 00 00 00 00 | 14  |
| mrmovq (%rdi), %r10                | 50 a7 00 00 00 00 00 00 00 00 | 24  |
| addq %rbx, %r14                    | 60 3e                         | 34  |
| subq %rdx, %rcx                              | 61 21                         | 36   |
| jmp 0x87                           | 70 87 00 00 00 00 00 00 00    | 38  |
| push %rdx                          | a0 2f                         | 47  |
| pop %rbx                           | b0 3f                         | 49  |
| call 0x2f                          | 80 2f 00 00 00 00 00 00 00    |  51   |
| ret                                | 90                            | 54    |                            

#### 3.26
整个单周期cpu的测试，初看波形没有发现大的bug，再看log信息，指令可以正常执行
![[seq_tb.png]]
![[seq_log.png]]
下面分析每条指令
1. halt
2. nop
3. rrmovq %r8, %r9
valE_exe正确取到了rA的值为0x8，要写回到寄存器r9，比较奇怪的是log的valE_wb是0，但查看波形的valE_wb有正确的值
![[Pasted image 20230327125644.png]]
![[Pasted image 20230327125715.png]]

单独抽出这条指令进行测试，可以看到valE正确写回到了寄存器
![[Pasted image 20230327130642.png]]

4. irmovq $8, %r8 由于r8初值本来就为0x8，更改一下irmovq $9, %r8
这里的log也没有正常打印，波形正常，寄存器正确写入
![[Pasted image 20230327131444.png]]
![[Pasted image 20230327131255.png]]
![[Pasted image 20230327131401.png]]
5. rmmovq %rsp, 0x123456789abcd(%rbx)
更改一个容易找的内存位置 rmmovq %rsp, 0x0000000000000001(%rbx)单独测试一下

将rsp的值0x40写入到内存地址为rbx值0x3加上valC值0x1得valE0x4的内存地址，正确写入
![[Pasted image 20230327142015.png]]
![[Pasted image 20230327142043.png]]
6. mrmovq (%rdi), %r10
rdi的值为7，看内存对应位置开始值被正确读入到r10
![[Pasted image 20230327132149.png]]
7. addq %rbx, %r14
r14初值为0x7fffffffffffffff，是当初为了测试溢出时特意设计的，rbx初值为3，相加得0x8000000000000002，发生溢出
![[Pasted image 20230327132753.png]]
再看这里的波形，newcc的sf of位被正确置1，cc在下个clk上升沿到来时被正确写入
![[Pasted image 20230327133027.png]]
8. subq %rdx, %rcx                 61 21
subq为rb-ra值即0x1-0x2得0xfffffffffffffff（-1），被正确写入到rb对应的%rcx中，看上图波形，cc也被正确设置，只有sf为1
![[Pasted image 20230327133200.png]]
![[Pasted image 20230327133446.png]]
9. jmp 0x87
这里pc更新的的逻辑好像有些问题，nextPC取了valP而不是无条件跳转应该的的valC
发现更新逻辑里参考了网站流水线阶段的逻辑，多了一个对cnd的取反，更正后正确

写完流水线之后回来补充一下取反逻辑
流水线部分有取反，是因为一条分支预测错误的指令进入了流水线，要取回原来的valP
这里单周期的话，更新的是需要跳转的指令

由于0x87处没有预设的指令，所以后续没有波形，暂时将valc改为下一条指令地址0x2f
![[Pasted image 20230327135311.png]]
10. push %rdx
rdx初值为2，栈指针rsp初值为0x40，减8后的rsp为0x38，也就是即将写入内存的地址，被正确写回
![[Pasted image 20230327140015.png]]
内存的值好像有点不对，可能是后续指令影响
![[Pasted image 20230327140512.png]]
单独测试一下，正确写入到内存中
![[Pasted image 20230327140733.png]]
11. pop %rbx
同样单独测试一下
![[Pasted image 20230327140936.png]]
![[Pasted image 20230327141120.png]]
看到首先把rsp值+8得到了valE为0x48，接着把内存地址0x48前的值读出8个byte，正确写回到了寄存器rbx，正确
12. call %0x87
call指令的话，nextPC正确取到了valC的值，下一条指令地址被压到栈内，正确
![[Pasted image 20230328104843.png]]
![[Pasted image 20230328104907.png]]
13. ret
看波形可以看出，ret指令成功把rsp为0x40指向的内存地址中保存的8个byte内容赋值给nextPC，然后栈指针加8，表示将栈顶存的返回地址弹出，新的栈顶写回到寄存器rsp中，正确
![[Pasted image 20230327143333.png]]
![[Pasted image 20230327143459.png]]

到这里耗时两周左右，完成了单周期CPU的设计与初步测试




