### 流水线
#### 3.27
把理想流水线部分视频看了一下，书里内容翻看了一下

#### 3.28
除少数特例外，模块接口命名均服从以下规则：
`source_name_i/o`
 source: 信号的来源，大写字母表示流水线寄存器，小写字母表示流水线阶段
 name: 信号的名称，即信号代表的含义
 i/o: 在该模块中信号的方向，i为输入，o为输出

写了大部分的代码
困惑：
1. 执行阶段的stat信号作用？
翻书，控制逻辑阶段实现
![[Pasted image 20230330103541.png]]

2. 访存阶段写入内存的值怎么不需要valP了，call指令怎么办呢？总感觉缺了一部分逻辑。
翻书，在译码阶段实现selectA模块即可
理想阶段先不加前递，只把selectA的一部分加进去，保证可以正常流动，明天开始分阶段测试
![[Pasted image 20230329100657.png]]

#### 3.29
开始进行分阶段测试
用之前单周期测试的指令序列，重点看波形，指令能否正常流通，具体指令的分析等到最后总体测试

测试能否正常流入fetch阶段的信号能否正常流入D reg
因为没有接selectPC模块，还用之前的updatePC来更新
看波形没有发现问题，信号正常流入D reg
![[Pasted image 20230330095609.png]]
![[Pasted image 20230330095234.png]]

再把decode模块加进去，只增加了一个valA值和valP关系的逻辑，相当于实现了部分的selectA，没有加fwd模块
D reg信号正确传递到decode阶段
![[Pasted image 20230330100725.png]]

再连接E reg，正常
![[Pasted image 20230330101934.png]]

连接execute模块
这里实现时暂时没连接用作控制逻辑的stat信号
![[Pasted image 20230330103733.png]]

连接M reg
![[Pasted image 20230330104747.png]]

连接memory_access模块
这里蓝线的高阻态是因为保留了当初单周期的mem_data信号，因为不确定call指令写入内存的逻辑如何更新，直到实现了selectA模块
读内存错误是因为指令的valC没设计好，爆内存了，其余正常
![[Pasted image 20230330105338.png]]

连接W reg
W reg在接线时必须特别小心，注意信号的来源，写这个触发器的时候我才意识到“心中有电路”的重要性
![[Pasted image 20230330110113.png]]

把剩下的F reg和selectPC也连起来
![[Pasted image 20230330110544.png]]



#### 3.30
第一次总体测试，粗略看波形没问题，正常流动起来了
![[Pasted image 20230329205157.png]]
![[Pasted image 20230329205146.png]]

下面还是逐条指令测试一下
1. halt
2. nop
可以流入到W
![[Pasted image 20230331111509.png]]
3. rrmovq %r8, %r9
正确流入，值传递成功
![[Pasted image 20230331113950.png]]
![[Pasted image 20230331114033.png]]
4. irmovq $9, %r8
![[Pasted image 20230331120833.png]]
![[Pasted image 20230331120907.png]]
5. rmmovq %rsp, 0x0000000000000001(%rbx)
![[Pasted image 20230331121834.png]]
![[Pasted image 20230331121726.png]]
6. mrmovq (%rdi), %r10
![[Pasted image 20230331121932.png]]![[Pasted image 20230331122019.png]]
7. addq %rbx, %r14
8. subq %rdx, %rcx 
两条opq指令一起测试
![[Pasted image 20230331122341.png]]
![[Pasted image 20230331122427.png]]
9. jmp 0x2f
取得了正确的pc
![[Pasted image 20230331122604.png]]
10. push %rdx
![[Pasted image 20230331122810.png]]![[Pasted image 20230331122856.png]]
11. pop %rbx
![[Pasted image 20230331122942.png]]![[Pasted image 20230331123008.png]]
12. call %0x87
![[Pasted image 20230331123149.png]]
![[Pasted image 20230331123227.png]]
13. ret
![[Pasted image 20230331123338.png]]
![[Pasted image 20230331123431.png]]
理想状态下的无冲突流水线测试通过

看完剩下的前递和控制逻辑视频，写完代码
#### 3.31

测试前递逻辑

没有加前递之前，测试如下prog，波形如下图
可以看出第三条加法指令流入M寄存器的valE是错误的，因为立即数还没写回rdx，rax
执行阶段的valA和valB取的是两个寄存器的初值
![[Pasted image 20230330221511.png]]
![[Pasted image 20230330223619.png]]

增加前递之后，prog正常通过测试
![[Pasted image 20230330224734.png]]

再测试一个prog，这个prog主要测试前递优先级，rrmovq执行阶段得到了正确的rdx前递值即立即数3，选择了最近产生的寄存器值，被正确写回
![[Pasted image 20230330225145.png]]
![[Pasted image 20230330225811.png]]
![[Pasted image 20230330225933.png]]

流水线控制逻辑
触发
![[Pasted image 20230331100953.png]]
处理
![[Pasted image 20230331101024.png]]
组合
![[Pasted image 20230331101131.png]]

接下来测试
1. 处理ret
![[Pasted image 20230331124630.png]]
![[Pasted image 20230331132442.png]]
出大问题，bubble和stall信号一直为高阻态，显然是初始化出了毛病

考虑wire类型无法inital，那么将controller中的bubble和stall信号改为reg，然后用always来写组合逻辑
![[Pasted image 20230331133636.png]]
这里单独测controller模块，信号可以正常给出
![[Pasted image 20230331134326.png]]

![[Pasted image 20230331134356.png]]
连起来确发现M_stall开始断了，检查发现是M_stall初始化时写错了，写成了M_bubble信号
最后在ret在三个周期stall后取到了正确的返回地址，只不过地址处没有指令，无法正确执行
![[Pasted image 20230331152338.png]]

2. load/use
![[Pasted image 20230331144449.png]]
起初测试时译码阶段取不到正确的valA，结果还是前递模块初始化的问题，最开始设计三条nop即可正常
又出现问题了，E阶段加bubble后值valE丢失了
![[Pasted image 20230331151030.png]]
突然意识到这里是重构controller时新加了异常处理逻辑，这里加完爆了内存，流水线自动加了nop冲掉了
先暂时注释掉异常处理，得到了正确的返回值
![[Pasted image 20230331151822.png]]
3. 分支预测错误
```
xor %rax, %rax
jne 0x10
```
产生两个bubble
![[Pasted image 20230331153837.png]]
得到正确的pc
![[Pasted image 20230331154034.png]]




未完成：
视频中控制逻辑还少了setCC的逻辑，我在控制逻辑里补充了，但还没有连接执行模块
测试冒泡排序等
完善异常处理逻辑
多周期指令，对接存储系统（Cache)

