- # DOSBox 汇编开发
## 目录 

- [目录](#目录)
- [环境搭建](#环境搭建)
  - [DOSBox mac 配置](#dosbox-mac-配置)
  - [编写helloworld测试DOSBox环境](#编写helloworld测试dosbox环境)
  - [DOSBox调试功能](#dosbox调试功能)
- [1 基础知识](#1-基础知识)
- [2 寄存器](#2-寄存器)
  - [2.1 通用寄存器](#21-通用寄存器)
  - [2.2 字在寄存器中的存储](#22-字在寄存器中的存储)
  - [2.3 几条汇编指令](#23-几条汇编指令)
  - [2.4 物理地址](#24-物理地址)
  - [2.5 十六位结构的CPU](#25-十六位结构的cpu)
  - [2.6 8086CPU 给出物理地址的方法](#26-8086cpu-给出物理地址的方法)
  - [2.7 `段地址x16+偏移地址=物理地址`的本质含义](#27-段地址x16偏移地址物理地址的本质含义)
  - [2.8 段的概念](#28-段的概念)
  - [2.9 段寄存器](#29-段寄存器)
  - [2.10 CS 和 IP](#210-cs-和-ip)
  - [2.12 代码段](#212-代码段)
- [3 寄存器](#3-寄存器)
  - [3.1 内存中字的存储](#31-内存中字的存储)
  - [3.2 DS 和\[address\]](#32-ds-和address)
  - [3.3 字的传送](#33-字的传送)
  - [3.4 mov、add、sub 指令](#34-movaddsub-指令)
  - [3.5 数据段](#35-数据段)
  - [3.6 栈](#36-栈)
  - [3.7 CPU 提供的栈机制](#37-cpu-提供的栈机制)
  - [3.8 栈顶超界的问题](#38-栈顶超界的问题)
  - [3.9 push、pop 指令](#39-pushpop-指令)
  - [3.10 栈段](#310-栈段)
- [4 第一个程序](#4-第一个程序)
  - [4.1 一个源程序从写出到执行的过程](#41-一个源程序从写出到执行的过程)
- [5 \[BX\]和 loop 指令](#5-bx和-loop-指令)
  - [5.1 \[BX\]](#51-bx)
  - [5.2 Loop 指令](#52-loop-指令)
  - [5.3 在 Debug 中跟踪用 loop 指令实现的循环程序](#53-在-debug-中跟踪用-loop-指令实现的循环程序)
  - [5.4 Debug 和汇编编译器 masm 对指令的不同处理](#54-debug-和汇编编译器-masm-对指令的不同处理)
- [第 6 章 包含多个段的程序](#第-6-章-包含多个段的程序)
  - [6.1 在代码段中使用数据](#61-在代码段中使用数据)
  - [6.2 在代码段中使用栈](#62-在代码段中使用栈)
  - [6.3 将数据、代码、栈放入不同的段](#63-将数据代码栈放入不同的段)
  - [实验5 编写、调试具有多个段的程序](#实验5-编写调试具有多个段的程序)
- [7 更灵活的定位内存地址的方法](#7-更灵活的定位内存地址的方法)
  - [7.1 and 和 or 指令](#71-and-和-or-指令)
  - [7.2 关于 ASCII 码](#72-关于-ascii-码)
  - [7.3 以字符形式给出的数据](#73-以字符形式给出的数据)
  - [7.4 大小写转换的问题](#74-大小写转换的问题)
  - [7.5 \[bx+idata\]](#75-bxidata)
  - [7.6 用\[bx+idata\]的方式进行数据的处理](#76-用bxidata的方式进行数据的处理)
  - [7.7 SI 和 DI](#77-si-和-di)
  - [7.8 \[bx+si\]和\[bx+di\]](#78-bxsi和bxdi)
  - [7.9 \[bx+si+idata\]和\[bx+di+idata\]](#79-bxsiidata和bxdiidata)
  - [7.10 不同的寻址方式的灵活应用](#710-不同的寻址方式的灵活应用)
- [8 数据处理的两个基本问题](#8-数据处理的两个基本问题)
  - [8.1 bx、si、di 和 bp](#81-bxsidi-和-bp)
  - [8.2 机器指令处理的数据在什么地方](#82-机器指令处理的数据在什么地方)
  - [8.3 汇编语言中数据位置的表达](#83-汇编语言中数据位置的表达)
  - [8.4 寻址方式](#84-寻址方式)
  - [8.5 指令要处理的数据有多长](#85-指令要处理的数据有多长)
  - [8.6 寻址方式的综合应用](#86-寻址方式的综合应用)
  - [8.7 div 指令](#87-div-指令)
  - [8.8 伪指令 dd](#88-伪指令-dd)
  - [8.9 dup](#89-dup)
- [9 转移指令原理](#9-转移指令原理)
  - [9.1 操作符 offset](#91-操作符-offset)
  - [9.2 jmp 指令](#92-jmp-指令)
  - [9.3 ⭐️️依据位移进行转移的 jmp 指令](#93-️️依据位移进行转移的-jmp-指令)
  - [9.4 转移的目的地址在指令中的 jmp 指令](#94-转移的目的地址在指令中的-jmp-指令)
  - [9.5 转移地址在寄存器中的 jmp 指令](#95-转移地址在寄存器中的-jmp-指令)
  - [9.6 转移地址在内存中的 jmp 指令](#96-转移地址在内存中的-jmp-指令)
  - [9.7 jcxz 指令](#97-jcxz-指令)
- [10 CALL 和 RET 指令](#10-call-和-ret-指令)
- [11 标志寄存器](#11-标志寄存器)
- [12 内中断](#12-内中断)
- [13 int 指令](#13-int-指令)
- [14 端口](#14-端口)
- [15 外中断](#15-外中断)
- [16 直接定址表](#16-直接定址表)
- [17 使用BIOS进行键盘输入和磁盘读写](#17-使用bios进行键盘输入和磁盘读写)



## 环境搭建  
目前汇编的环境搭建，可以使用nasm与masm，我使用的汇编教程为《汇编语言(第4版)》，所以这里使用DOSBox的MASM汇编语法开发。  

[参考文章](https://blog.csdn.net/qq_41855420/article/details/103746234)  

[:books: 返回目录](#目录)
### DOSBox mac 配置

可以在[DOSBox官网](https://www.dosbox.com/download.php?main=1)  进行下载dmg, 然后打开安装包，把`DOSBox.app`放到应用文件夹中。
打开软件之前，需要配置一下。首先下载[配置文件](../../res/files/汇编工具配置文件.zip), 然后放到自己本机的目录下, 自定义即可。  

配置文件内容:
```sh
ls -l /Users/ymm/Downloads/汇编工具配置文件
total 3528
-rw-r--r--  1 ymm  staff    20634  4 14  2008 DEBUG.EXE
-rw-r--r--  1 ymm  staff    72174  5 13  1998 EDIT.COM
-rw-r--r--  1 ymm  staff     3050  4  6  2001 EXE2BIN.EXE
-rw-r--r--  1 ymm  staff    49661  5  2  2011 LIB.EXE
-rw-r--r--  1 ymm  staff    69133  4  6  2001 LINK.EXE
-rw-r--r--  1 ymm  staff   103175  4  6  2001 MASM.EXE
-rw-r--r--  1 ymm  staff  1474560  4  7  2009 masm.IMg
```

增加配置文件路径:  
在访达通过`cmd+shift+G`命令，快速前往`/Users/ymm/Library/Preferences/DOSBox 0.74-3-3 Preferences`文件，通过文本编辑器打开，在末尾增加配置文件路径
```sh
# Lines in this section will be run at startup.
# You can put your MOUNT lines here.
# 挂载~/DOSBox目录为C盘
mount C ~/work/DOSBox
# 进入C盘（~/DOSBox目录）
C:
```

打开DOSBOx.app 界面如下:  

<br>
<div align=center>
    <img src="../../res/image/asm/dosboxd-1.png" width="60%"></img>  
</div>
<br>

> 需要出现`mount C ~/work/DOSBox`与`C:\>`字样才算加载配置成功!  

[:books: 返回目录](#目录)
### 编写helloworld测试DOSBox环境  

新建文件`hello.asm`,内容如下:  
```asm
DATAS SEGMENT
    ;此处输入数据段代码  
    ;13、10都是十进制，分别表示垂直制表符、退格，'$'表示字符串结尾
    STRING  DB  'Hello World!',13,10,'$'
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;此处输入代码段代码
    
    LEA  DX,STRING
    MOV  AH,9
    INT  21H
    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START
```

把asm文件放到`~/work/DOSBox`文件夹下.  


- ### 编译

`MASM.EXE HELLO.ASM`  
> DOS这玩意好像不区分大小写，所以直接敲大写吧。另外源代码需要放到根目录下，不然无法编译。  


<br>
<div align=center>
    <img src="../../res/image/asm/dosboxd-2.png" width="60%"></img>  
</div>
<br>


- ### 链接

`LINK.EXE HELLO.OBJ`  

<br>
<div align=center>
    <img src="../../res/image/asm/dosboxd-3.png" width="60%"></img>  
</div>
<br>

- ### 运行  

`HELLO.EXE`  

输出
```sh
Hello World!
```

### DOSBox调试功能

`DEBUG.EXE HELLO.EXE`
- `-r`  查看寄存器
- `-u [行数]`  查看汇编指令命令
- `-t`  执行下一条汇编指令命令
- `-d 段地址:偏移地址`  查看指定内存单元命令
- `-q`  退出

<br>
<div align=center>
    <img src="../../res/image/asm/dosboxd-4.png" width="60%"></img>  
</div>
<br>

[:books: 返回目录](#目录)
## 1 基础知识
[参考github读书笔记](https://github.com/Ray-56/m-dream/issues/45)  

1. 汇编指令是机器指令的助记符，同机器指令一一对应
2. 每一种 CPU 都由自己的汇编指令集
3. CPU 可以直接使用的信息在`存储器`中存放
4. 在存储器中`指令`和`数据`没有任何区别，都是二进制信息
5. 存储单元从零开始顺序编号
6. 一个存储单元可以存储8个 bit，即8位二进制数
7. 1Byte=8bit 1KB=1024B 1MB=1024KB 1GB=1024MB
8. Byte 字节，bit 比特
9. 1KB = 1024Byte(B) = 8 * 1024bit  

机器码与对应的汇编指令:  
```sh
机器码:        10100001 00000011 00000000
对应的汇编指令:  MOV AX,[3]
含义:          传送3号单元的内容如AX
```

## 2 寄存器
### 2.1 通用寄存器
AX = AH + AL，高字节位，低字节位

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-1.jpg" width="60%"></img>  
</div>
<br>

实例: 
| 寄存器 | 寄存器中的数据 | 所有的值 | 
| ----- | -----------  | ------ |
| AX | 0100 1110 0010 0000 | 20000(4E20H) |
| AH | 0100 1110 | 78(EH)| 
| AL | 0010 0000 | 32(20H) | 


### 2.2 字在寄存器中的存储
十六进制，汇编H结尾，C语言0x开头
Byte 字节， word 字，一个字由两个字节组成

### 2.3 几条汇编指令
AH AL 在使用中都是作为独立的 8 位寄存器  

检测点2.1 
62627 = 0xf4a3

(1). 写出每条汇编指令执行后相关寄存器中的值：
```sh
mov ax,62627; # AX=f4a3h
mov ah,31h;   # AX=31a3h
mov al,23h;   # AX=3123h
add ax,ax;    # AX=6246h
mov bx,826ch; # AX=6246h BX=826ch
mov cx,ax;    # AX=6246h BX=826ch CX=6246h
mov ax,bx;    # AX=826ch
add ax,bx;    # AX=04d8h 这里AX为16位寄存器，只能存放4位16进制的数据，所以最高位的1无法保存
mov al,bh;    # AX=0482h
mov ah,bl;    # AX=6c82h
add ah,ah;    # AX=d882h
add al,6;     # AX=d888h
add al,al;    # AX=d810h
add ax,cx;    # AX=6246h
```

(2). 只能使用目前学过的汇编指令，最多使用4条指令，编程计算2的4次方：
```sh
mov ax,2;     # AX=0002h
add ax,ax;    # AX=0004h
add ax,ax;    # AX=0008h
add ax,ax;    # AX=0016h
```

### 2.4 物理地址
CPU 通过地址总线送入存储器的必须是一个内存单元的物理地址.  

### 2.5 十六位结构的CPU
- 运算器一次最多可以处理16位的数据
- 寄存器的最大宽度为16位
- 寄存器和运算符之间的通路为16位

### 2.6 8086CPU 给出物理地址的方法
- CPU 相关部件提供两个16位的地址，分别为`段地址`、`偏移地址`
- 段地址和偏移地址通过内部总线送入地址加法器的部件
- 地址加法器将两个16位地址合成一个20位的物理地址
- 地址加法器同工内部总线将20位物理地址送入输入输出控制电路
- 输入输出控制电路将20位物理地址送上地址总线
- 20位物理地址被地址总线传送到存储器

地址加法器：物理地址=`段地址`x`16`+`偏移地址 ` 

`段地址x16` 的常用说法是左移4位(通常指二进制位)  

由观察数据`2H`二进制形式`10B`，对其进行左移运算可以得到：一个X进制的数据左移1位，相当于乘以X  

###  2.7 `段地址x16+偏移地址=物理地址`的本质含义

本质含义：CPU 在访问内存时，用一个基础地址（段地址x16）和一个相对于基础地址的偏移地址相加，给出内存单元的物理地址也就是“基础地址+偏移地址=物理地址”  

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-2.png" width="70%"></img>  
</div>
<br>

三种方式表示图书馆的地址：

- 从学校走2826到图书馆。2826可以认为是图书馆的物理地址
- 从学校走2000基础地址到体育馆，再从体育馆走826偏移地址（以基础地址为起点）到图书馆
- 加限制两张三位数据纸条，第一张写上`200`段地址,第二张写上`826`偏移地址，再运算`200`x10+`826`=2826

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-3.png" width="40%"></img>  
</div>
<br>

8086CPU 就相当于提供两张3位数据纸条的 CPU

[:books: 返回目录](#目录)


### 2.8 段的概念

`段地址`这个名称中包含`段`的概念，这种说法可能对一些学习者产生了误导，以为内存被划分成一个一个的段，每一段有一个段地址。 其实内存没有分段，段的划分来自于CPU，由于8086CPU用`基础地址(段地址x16)+偏移地址=物理地址`的方式给出内存单元的物理地址，使得我们可以用分段的方法来管理内存。  

```sh
CPU 可以使用不同的段地址和偏移地址形成同一个物理地址。eg:
    物理地址    段地址  偏移地址
    21F60H      2000H   1F60H
                2100H   0F60H
                21F6H   0000H
                1F00H   2F60H
                
偏移地址 16 位，变化范围为0~FFFFH，仅用偏移地址来寻址最多可寻到 64KB 个内存单元。
```

检测点2.2
公式：`段地址(SA)`x16 + `偏移地址(EA)` = 物理地址
这里的 16 是十进制，计算时需要先进行转换  

(1). 给定段地址为`0001H`, 仅通过变化偏移地址来寻址，CPU的寻址范围为____到____? 

0010H ~ 1000FH  
```sh
由题意可知偏移地址范围 0000H ~ FFFFH
min = 0001H x 16 + 0000H, min = 0010H
max = 0001H x 16 + FFFFH, max = 1000FH
```

### 2.9 段寄存器
8086CPU 有四个段寄存器：`CS`、`DS`、`SS`、`ES`。需要访问内存时提供内存单元的段地址。本章只看 `CS`  

- code segment (CS)  
- data segment (DS)
- stack segment (SS) 
- programmer (ES)  

[:books: 返回目录](#目录)  

### 2.10 CS 和 IP
`CS` 为代码段寄存器，`IP` 为指令指针寄存器  

在内存中，指令和数据没有任何区别，都是二进制信息，CPU 在工作的时候把有的信息看作指令，有的看作数据。**CPU 将 CS、IP 中的内容当作指令的`段地址`和`偏移地址`，用它们合成指令的物理地址，到内存中读取指令码，执行。**如果说，内存中的一段信息曾被 CPU 执行过的话，那么，它所在的内存单元必然被 CS:IP 指向过  


<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-4.png" width="80%"></img>  
</div>
<br>

(1) 8086CPU当前状态, CS中的内容为`2000H`, IP的内容为`0000H`;
(2) 内存20000H~20009H单元存放着可执行的机器码；
(3) 内存20000H~20009H单元中存放的机器码对应的指令如图；  

运行过程: 

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-5.png" width="100%"></img>  
</div>
<br>

`jmp`指令可以修改 `CS`、`IP`。  

- jmp 段地址:偏移地址（段内转移）：用指令中给出的段地址修改 CS，偏移地址修改 IP
- jmp 某一合法寄存器（段间转移）：用寄存器中的值修改 IP

同时修改CS/IP  
```sh
jmp 2AE3:3
# 执行后
CS=2AE3H, IP=0003H, cpu将从2AE33H处读取指令
```

只修改IP
```sh
jmp ax, 指令执行前: ax=1000H, CS=2000H, IP=0003H
        指令执行后: ax=1000H, CS=2000H, IP=1000H
```

[:books: 返回目录](#目录)
### 2.12 代码段
对于 8086PC 机，可以根据需求，将一组内存单元定义为一个段。
我们可以将长度为 N(N<=64KB) 的一组代码，存在一组地址连续、起始地址为 16 的倍数的内存单元中，我们可以认为，这段内存是用来存放代码的，从而定义了一个代码段。

比如:
```sh
mov ax,0000         (B8 00 00)
add zx,0123H        (05 23 01)
mov bx,ax           (8B D8)
jmp bx              (FF E3)
```

这段长度为10个字节的指令，存放在`123B0H~123B9H`的一组内存单元中，我们就可以认为`123B0H~123B9H`这段内存是用来存放代码的，是一个代码段

[:books: 返回目录](#目录)

## 3 寄存器
### 3.1 内存中字的存储
任何两个地址连续的内存单元，N 号单元和 N+1 号单元，可以将它们看成两个内存单元，也可以看成一个地址为 N 的字单元中的`低位`字节单元和`高位`字节单元

例如：AX = 4E20H，AH = 4EH(高位)，AL = 20H(低位)，AX 存放在2地址字单元（2单元+3单元）中，2单元存放低位20H，3单元存放高位4EH  

[:books: 返回目录](#目录)
### 3.2 DS 和[address]

```
mov bx,1000H
mov ds,bx
mov al,[0]
```
上面三条指令将10000H(1000:0)中的数据读取到al中  

- 8086CPU 自定取`ds`中的数据作为内存单元的段地址  
- [···]表示一个内存单元，[0]中的 0 表示内存单元的偏移地址  

物理地址=`ds`x16 + `偏移量`,分析：10000H = 1000H x 16 + 0H 可以表示为 1000:0，地址段 1000H，偏移地址 0  

[:books: 返回目录](#目录)
### 3.3 字的传送

```sh
mov bx,1000h
mov ds,bx
mov ax,[0]    ;1000:0 处的字型数据送入 ax
mov [0],cx    ;cx 中的 16 位数据送到 1000:0 处
```

> 8086 CPU是16位结构，有16根数据线，可以一次性传送16位的数据。  

[:books: 返回目录](#目录)
### 3.4 mov、add、sub 指令

mov 寄存器，数据 例如：mov ax,8
mov 寄存器，寄存器 例如：mov ax,bx
mov 寄存器，内存单元 例如：mov ax,[0]
mov 内存单元，寄存器 例如：mov [0],ax
mov 段寄存器，寄存器 例如：mov ds,ax

add,sub 不能对`段寄存器`进行操作，其它与 mov 一致  

[:books: 返回目录](#目录)
### 3.5 数据段
将一组长度为 N(N<=64KB)、地址连续、起始地址为 16 倍数的内存单元当作专门储存数据的内存单元，从而定义一个数据段

比如，将 `123B0H~123B9H` 的内存单元定义为数据段。现在要累加这个数据段中的前 3 个单元中的数据，代码如下：
```sh
mov ax,123BH
mov ds,ax           ; 将 123BH 送入 ds 中，做为数据段的段地址
mov al,0            ; 用 al 存放累加结果
add al,[0]          ; 将数据段的第一个单元（偏移地址为0）中的数值加到 al 中
add al,[1]          ; 将数据段的第二个单元（偏移地址为1）中的数值加到 al 中
add al,[2]          ; 将数据段的第三个单元（偏移地址为2）中的数值加到 al 中
```

小节:
> 1. 字在内存中存储时，要用两个地址连续的内存单元来存放，字的低位字节存放在低地址单元中，高位字节存放在高地址单元中  
> 2. 用 mov 指令访问内存单元，可以在 mov 指令中只给出单元的偏移地址，此时，段地址默认在 DS 寄存器中  
> 3. [address] 表示一个偏移地址为 address 的内存单元
在内存和寄存器之间传送字型数据时，高地址单元和高 8 位寄存器、低地址单元和低 8 位寄存器相对应  
> 4. mov、add、sub 是具有两个操作对象的指令。jmp 是具有一个操作对象的指令  

[:books: 返回目录](#目录)
### 3.6 栈
LIFO（Last In First Out，后进先出)  

[:books: 返回目录](#目录)
### 3.7 CPU 提供的栈机制
`PUSH`入栈，`POP`出栈，8086CPU 的入栈和出栈都是以`字`为单位进行的。
字型数据用两个单元存放，高地址单元存放高 8 位，低地址单元存放低 8 位。
任意时刻，SS:SP 指向栈顶元素。 `SS` 段寄存器存放段地址，`SP` 寄存器存放偏移地址

[:books: 返回目录](#目录)
### 3.8 栈顶超界的问题
8086CPU不保证我们对栈的操作不会超界。它只知道栈顶在何处（由 SS:SP 指示），而不知道栈空间有多大。这点就好像它只知道当前要执行的指令在何处（由 CS:IP 指示），而不知道要执行的指令有多少。

从这两点可以看出 8086CPU 的工作机理，只考虑当前的情况：当前栈顶在何处、要执行的指令是哪一条  

[:books: 返回目录](#目录)
### 3.9 push、pop 指令

可以在寄存器和内存（栈空间也是内存空间的一部分，它只是一段可以以一种特殊方式进行访问的内存空间）之间传递数据  

```sh
push 寄存器     ; 将一个寄存器中的数据入栈
pop 寄存器      ; 出栈，用一个寄存器接收出栈的数据
push 段寄存器   ; 将一个段寄存器中的数据入栈
pop 段寄存器    ; 出栈，用一个段寄存器接收出栈的数据
push 内存单元   ; 将一个内存字单元处的字入栈（注意：栈操作都是以字为单位的）
pop 内存单元    ; 出栈，用一个内存字单元接收出栈的数据

; 比如：
mov ax,1000H
mov ds,ax       ; 内存单元的段地址要放在 ds 中
push [0]        ; 将 1000:0 处的字入栈
pop [2]         ; 出栈，出栈的数据送如 1000:2 处
```

> 指令执行时，CPU 要知道内存单元的地址，可以在 push、pop 指令中只给出内存单元的`偏移地址`，`段地址`在指令执行时，CPU 从 ds 中取得  

编程：
1. 将 10000H~1000FH 这段空间当作栈，初始状态栈为空
2. 设置 AX=001AH，BX=001BH
3. 将 AX、BX 中的数据入栈
4. 然后将 AX、BX 清零
5. 从栈中恢复 AX、BX 原来的内容

```sh
mov ax,1000H
mov ds,ax
mov sp,0010H    ; 栈顶为空，sp=栈底(栈空间高位)+16=000FH=+16=0010H
mov ax,001AH
mov bx,001BH
push ax
push bx

sub ax,ax       
sub bx,bx       ; 清零也可以使用 mov bx,0
                ; sub bx,bx 的机器码为 2 个字节
                ; mov bx,0 的机器码为 3 个字节
pop bx          ; 后进先出，所以先送入 bx
pop ax
```
[:books: 返回目录](#目录)
### 3.10 栈段

我们可以将长度为 N(N<=64KB)的一组地址连续、起始地址为 16 的倍数的内存单元，当作栈空间来用，从而定义了一个栈段  

将一段内存定义为一个段，用一个段地址指示段，用偏移地址访问段内的单元。

- 用一个段存放数据，将它定义为“数据段”；
- 用一个段存放代码，将它定义为“代码段”；
- 用一个段当作栈，将它定义为“栈段”；

若要让 CPU 按照我们的安排来访问这些段，就要

- 数据段，将它的段地址放在 DS 中，用 mov、add、sub 等访问内存单元的指令时，CPU 就将我们定义的数据段中的内容当作数据来访问
- 代码段，将它的段地址放在 CS 中，将段中的第一条指令的偏移地址放在 IP 中，这样 CPU 就将执行我们定义的代码段中的指令；
- 栈段，将它的段地址放在 SS 中，将栈顶单元的偏移地址放在 SP 中，这样 CPU 在需要执行栈操作时，比如执行 push、pop 指令等，就将我们定义的栈段当作栈空间来用；

> 由上可见：CS:IP 指向地址当作代码，SS:SP 指向地址当作栈  


- ### 检测点 3.2
补全下面的程序，使其可以将 10000H~1000FH 中的 8 个字，逆序复制到 20000H~2000FH 中。逆序复制的含义如下图所示：  

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-6.png" width="60%"></img>  
</div>
<br>

```sh
mov ax,1000H
mov ds,ax
; ----补全代码开始----
mov ax,1000H
mov ss,ax
mov sp,0010H

; ----补全代码结束----
push [0]
push [2]
push [4]
push [6]
push [8]
push [A]
push [C]
push [E]
```
[:books: 返回目录](#目录)

## 4 第一个程序
### 4.1 一个源程序从写出到执行的过程
<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-7.png" width="50%"></img>  
</div>
<br>

1. 编写汇编源程序  

使用文本编辑器，用汇编语言编写汇编源程序。  
工作结果：产生了一个存储源程序的文本文件  

2. 对源程序进行编译连接  

使用汇编语言编译程序对源程序文件中的源程序进行编译，产生目标文件：再用连接程序对目标文件进行连接，生成可在操作系统中直接运行的可执行文件（包含下面两部分内容）。
工作结果：产生了一个可在操作系统中运行的可执行文件

3. 执行可执行文件中的程序  

操作系统依照可执行文件中的描述信息，将可执行文件中的机器码和数据加载入内存，并进行相关的初始化（比如设置 CS:IP 执行第一条要执行的指令），然后由 CPU 执行程序  

[:books: 返回目录](#目录)
## 5 [BX]和 loop 指令

(1). [bx]和内存单元的描述
- [0]表示内存单元，它的偏移地址为 0。
- [bx]同样也表示一个内存单元，它的偏移地址在 `bx` 中。

```sh
mov ax,[0]  ; 将一个内存单元的内容送入 ax，这个内存单元的长度为 2 字节（字单元），存放一个字，偏移地址为 0，段地址在 ds 中。
mov al,[0]  ; 将一个内存单元的内容送入 al，这个内存单元的长度为 1 字节（字节单元），存放一个字节，偏移地址为 0，段地址在 ds 中。
mov ax,[bx] ; 将一个内存单元的内容送入 ax，这个内存单元的长度为 2 字节（字单元），存放一个字，偏移地址在 bx 中，段地址在 ds 中。
mov al,[bx] ; 将一个内存单元的内容送入 ax，这个内存单元的长度为 1 字节（字节单元），存放一个字节，偏移地址在 bx 中，段地址在 ds 中。
```



(2). loop
这个指令和循环有关

(3). 我们定义的描述性符号：`()`
以后我们将使用一个描述性符号“()”来表示一个寄存器或一个内存单元中的内容。比如：
- `(ax)`表示 ax 中的内容、`(al)`表示 al 中的内容  
- 20000H表示内存 20000H 的内容（`()`中的内存单元地址为物理地址）
- `((ds)*16+(bx))`表示为
  - ds 中的内容为 ADR1，bx 中的内容为 ADR2，内存 ADR1x16+ADR2 单元的内容
  - 也可以理解为：ds 中的 ADR1 作为段地址，bx 中的 ADR2 作为偏移地址，内存 ADR1:ADR2 单元的内容
注意："()"中的元素可以有 3 中类型：1、寄存器名；2、段寄存器名；3、内存单元的物理地址（一个 20 位数据）。比如：

### 5.1 [BX]
```sh
mov ax,[bx] ; bx 中存放的数据作为一个偏移地址 EA，段地址 SA 默认在 ds 中，将 SA:EA 处的数据送入 ax 中。(ax)=((ds)*16+(bx))
mov [bx],ax ; bx 中存放的数据作为一个偏移地址 EA，段地址 SA 默认在 ds 中，将 ax 中的数据送入内存 SA:EA 中。((ds)*16+(bx))=(ax)
```

[:books: 返回目录](#目录)
### 5.2 Loop 指令
格式是：loop 标号，CPU 执行 loop 指令的时候，要进行两步操作：
- 1. (cx)=(cx)-1
- 2. 判断 cx 中的值，不为零则转至标号处执行程序，如果为零则向下执行

通常我们用 loop 指令来实现循环功能，cx 中存放循环次数  
- 编程计算 2^3  
```sh
assume cs:code
code segment
    mov ax,2
    add ax,ax
    add ax,ax
    
    mov ax,4c00h
    int 21h
code ends
end
```

- 编程计算 2^12

```sh
assume cs:code
code segment
    mov ax,2
    
    mov cx,11        ; cx 循环次数  
s: add ax,ax
    loop s
    
    mov ax,4c00h
    int 21h
code ends
end
```

[:books: 返回目录](#目录)

### 5.3 在 Debug 中跟踪用 loop 指令实现的循环程序
- 计算 ffff:0006 单元中的数乘以 3，结果存储在 dx 中。  

```sh
assume cs:code
code segment
    mov ax,0ffffh
    mov ds,ax
    mov bx,6        ; 以上，设置 ds:bx 指向 ffff:6
    mov al,[bx]
    mov ah,0        ; 以上，设置 (al)=((ds)*16+(bx)), (ah)=0
    mov dx,0        ; 累加寄存器清零
    mov cx,3        ; 循环 3 次
s:add dx,ax
    loop s          ; 以上累加计算 (ax)*3
    mov ax,4c00h
    int 21h         ; 程序返回
code ends
end
```
编译: `masm hello.asm`, `link hello.obj`  
调试: `debug hello.exe`

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-8.png" width="60%"></img>  
</div>
<br>

> cs 代码段，将它的段地址放在 CS 中，将段中的第一条指令的偏移地址放在 IP 中  
> ds 数据段，将它的段地址放在 DS 中，用 mov、add、sub 等访问内存单元的指令时，CPU 就将我们定义的数据段中的内容当作数据来访问  

从图看一看出代码执行的地址为`076A:0000`,偏移量为0，也就是代码`MOV AX,FFFF`  

本机CPU的汇编指令，也是通过段地址+偏移量实现的:  
```sh
-exec disas 0x555555557fd0
Dump of assembler code for function __isoc99_scanf@got.plt:
   0x0000555555557fd0 <+0>:	mov    al,0x20
   0x0000555555557fd2 <+2>:	jrcxz  0x555555557fcb <printf@got.plt+3>        # RCX=0 跳转
   0x0000555555557fd4 <+4>:	(bad)  
   0x0000555555557fd5 <+5>:	jg     0x555555557fd7 <__isoc99_scanf@got.plt+7> # 大于跳转  
   0x0000555555557fd7 <+7>:	add    BYTE PTR [rax],al
End of assembler dump.
```

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-9.png" width="60%"></img>  
</div>
<br>

通过`-d`查看`076A:0000`地址的内容为`B8 FF FF`, 也就是`MOV AX,FFFF`. 另外执行`-t`,执行下一条汇编，这时IP地址切换为:`IP=0003`, 也就是上一条指令占用3个字节，当前指令的地址为`076A:0003`, 内容为: `MOV DS,AX`  

等待代码执行到`076A:0014`, 代码为:`LOOP 0012`, 这时寄存器的状态为:  

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-10.png" width="60%"></img>  
</div>
<br>

[:books: 返回目录](#目录)

### 5.4 Debug 和汇编编译器 masm 对指令的不同处理



[:books: 返回目录](#目录)


## 第 6 章 包含多个段的程序  

在操作系统环境中，合法地通过操作系统取得的空间都是安全的，因为操作系统不会让一个程序所用的空间和其它程序以及系统自己的空间相冲突。取得空间的方法有两种：

- 在加载程序的时候为程序分配  
- 程序在执行的过程中相系统申请（课程中不讨论此方法）  


一个程序在被加载的时候取得所需的空间，则必须要在源程序中做出说明。我们通过在源程序中定义段来进行内存空间的获取。  

上面是从内存空间获取的角度上谈定义段的问题。我们再从程序规划的角度来谈一下定义段的问题。大多数有用的程序，都要处理数据，使用栈空间，当然也都必须有指令，为了程序设计上的清晰和方便，也都定义不同的段来存放它们  

### 6.1 在代码段中使用数据
考虑一个问题，编程计算以下 8 个数据的和，结果存在 ax 寄存器中：0123h、0456h、0789h、0abch、0defh、0fedh、0cbah、0987h  

```sh
assume cs:code
code segment
    dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
    mov bx,0
    mov ax,0
    mov cx,9
s:  add ax,cs:[bx]
    add bx,2
    loop s
    mov ax,4c00h
    int 21h
code ends
end
```

`dw`的含义是定义字型数据，即`define word`。在这里，定义了 8 个字型数据，占用空间大小为 16 个字节  

程序中的指令就要对这 8 个数据进行累加 **可这 8 个数据在哪里？** 由于它们在代码段中，程序在运行的时候 CS 中存放代码段的段地址，所以可以从 CS 中得到它们的段地址。 **它们的偏移地址是多少呢？** 因为用 dw 定义的数据处于代码段的最开始，所以偏移地址为 0，这 8 个数据就在代码段的偏移 0、2、4、6、8、A、C、E 处。程序运行时，它们的地址就是段前缀+偏移，也就是 CS:0、CS:2 等。  

程序中，用 bx 存放 2 递增的偏移地址，用循环来进行累加。  

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-11.png" width="60%"></img>  
</div>
<br>

图中，通过`DS=075A`，得知程序从 `CS:IP=076a:0` 开始存放。用 u 命令查看程序，看到一些读不懂的指令。

在源程序中，在汇编指令前，有 16 个字节是用 dw 定义的数据，从 16 个字节后才是汇编指令对应的机器码。

用 d 命令清楚的查看程序中前 16 个字节的内容：  
<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-12.png" width="60%"></img>  
</div>
<br>


**怎样执行程序中的指令呢？** 用 Debug 加载后，可以将 `IP` 设置为 `10H`，从而使 `CS:IP` 指向程序中的第一条指令。让后再用 t、p 或 g 命令执行。因为程序编译后的入口处不是所希望执行的指令，所以只能使用 Debug 来执行程序，正确的做法是指明程序中的入口所在，具体的做法：  

```sh
assume cs:code
code segment
    dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
    start:  mov bx,0
            mov ax,0
            mov cx,9
        s:  add ax,cs:[bx]
            add bx,2
            loop s
            mov ax,4c00h
            int 21h
code ends
end start
```

在程序的第一条指令的前面加上了一个标号 `start`，而这个标号在伪指令 end 的后面出现。 **end 除了通知编译器程序结束外，还可以通知编译器程序的入口在什么地方。** 程序中用 end 指令指明了程序的入口在标号 start 处，也就是说 `mov bx,0`  是第一条指令。

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-13.png" width="60%"></img>  
</div>
<br>

这样显示就对了  

[:books: 返回目录](#目录)

### 6.2 在代码段中使用栈

利用栈将定义的数据逆序存放`dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h`  

思路如下：
1. 程序运行时，定义的数据存放在 `cs:0~cs:F` 单元中，共 8 个字单元
2. 依次将这 8 个字单元中的数据入栈
3. 再依次出栈到这 8 个字单元中

问题是，首先要有一段可以当作栈的内存空间。如前所述，这段空间应该由系统来分配。可以在程序中通过定义数据来取得一段空间，然后将这段空间当作栈空间来用。程序如下：
```sh
assume cs:codesg
codesg segment
    dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
    ; 用 dw 定义 16 个字型数据，在程序加载后，将取得 16 个字的内存空间，存放这 16 个数据。在后面的程序中将这段空间当作栈来使用
start:  mov ax,cs
        mov ss,ax
        mov sp,30h      ; 将设置栈顶 ss:sp 指向 cs:30
        
        mov bx,0
        mov cx,8
    s:  push cs:[bx]
        add bx,2
        loop s          ; 以上将代码段 0~15 单元中的 8 个字型数据依次入栈
        
        mov bx,0
        mov cx,8
    s0: pop cs:[bx]
        add bx,2
        loop s0         ; 以上依次出栈 8 个字型数据到代码段 0~15 单元中
        
        mov ax,4c00h
        int 21h
codesg ends
end start               ; 指明程序的入口在 start 处
```

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-14.png" width="60%"></img>  
</div>
<br>

代码段中定义了 `16` 个字型数据，它们的数值都是 `0`。这 16 个字型数据的值是多少，对程序来说没有意义。我们用 dw 定义 16 个数据，即在程序中写入了 16 个字型数据，而程序在加载后，将用 32 个字节的内存空间来存放它们。这段内存空间是我们所需要的，程序将它用作栈空间。可见，定义这些数据的最终目的是，通过它们取得一定容量的内存空间。所以在描述 dw 的作用时，可以说它定义数据，也可以说用它开辟内存空间  


下面的程序实现依次用内存 `0:0~0:15` 单元中的内容改写程序中的数据，数据的传送用栈来进行。栈空间设置在程序内。补全程序：  
```sh
assume cs:codesg
codesg segment
    dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
    dw 0,0,0,0,0,0,0,0,0,0      ; 10 个字单元用作栈空间
start:  mov ax,______       ; cs
        mov ss,ax
        mov sp,______       ; 24H = 18 个字单元 = 36 个字节单元
        
        mov ax,0
        mov ds,ax
        mov bx,0
        mov cx,8
    s:  push [bx]
        __________          ; pop ss:[bx]
        add bx,2
        loop s
        
        mov ax,4c00h
        int 21h
codesg ends
end start
```

[:books: 返回目录](#目录)


### 6.3 将数据、代码、栈放入不同的段
前面的内容中，在程序中用到了`数据`和`栈`，将数据、栈和代码都放到一个段内。这样做有两个问题：  

- 放在一个段内使程序显得混乱
- 前面的程序中处理的数据很少，用到的栈空间也小，加上代码量也不多，放在一个段内没有问题。如果数据、栈和代码需要的空间超过 64KB，就不能放在一个段中（一个段的容量不能大于 64 KB，是我们在学习中所用到的 8086 模式的限制，并不是所有的处理器都是这样）  

程序 6.4:
```sh
assume cs:code,ds:data,ss:stack

data segment
    dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
data ends

stack segment
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
stack ends

code segment
start:  mov ax,stack
        mov ss,ax
        mov sp,20h      ; 设置栈顶 ss:sp 指向 stack:20
        
        mov ax,data
        mov ds,ax       ; ds 指向 data 段
        
        mov bx,0        ; ds:bx 指向 data 段中的第一个单元
        
        mov cx,8
    s:  push [bx]
        add bx,2
        loop s          ; 以上将 data 段中的 0~15 单元中的 8 个字型数据依次入栈
        
        mov bx,0
        
        mov cx,8
    s0: pop [bx]
        add bx,2
        loop s0         ; 以上依次出栈 8 个字型数据到 data 段的 0~15 单元中
        
        mov ax,4c00h
        int 21h
code ends
end start
```

下面对程序 6.4 做出说明  
（1）定义多个段的方法  
定义一个段的方法和前面讲的定义代码段的方法没有区别，只是对于不同的段，要有不同的段名  

（2）对段地址的引用
- 程序中有多个段了，如何访问段中的数据呢？
    - 通过地址，而地址分为两部分，即段地址和偏移地址
- 如何指明要访问数据的段地址呢？
  - 段名就相当于一个标号，它代表了段地址
- 偏移地址呢
  - 偏移地址要看它在段中的位置。程序中的“data”段中的数据“0abch”的地址就是：data:6

（3）“代码段”、“数据段”、“栈段”完全是开发者的安排
以一个具体的程序再次讨论一下所谓的`代码段`、`数据段`、`栈段`。在汇编程序中，可以定义许多的段，比如在程序 6.4 中，定义了 3 个段，`code`、`data`和`stack`。我们可以分别安排它们存放代码、数据和栈。那么如何让 CPU 按照我们的这种安排来执行这个程序呢？看看源程序中对这 3 个段所做的处理：  

1. 在源程序中为这 3 个段起了具有含义的名称，用来存放数据的段 data，存放代码的段 code，用作栈空间的段 stack
这样命名了后 CPU 是否就去执行 code 段中的内容，处理 data 段中的数据，将 stack 当作栈了呢？
当然不是，我们这样命名，仅仅是为了使程序便于阅读。这些名词同 start、s、s0 等标号一样，仅在源程序中存在，CPU 并不知道它们。  

2. 在源程序中用伪指令assume cs:code,ds:data,ss:stack将 cs、ds 和 ss 分别和 code、data、stack 段相连。这样做了后，CPU 是否会将 cs 指向 code，ds 指向 data，ss 指向 stack，从而按照我们的意图来处理这些段呢？
当然也不是，要知道 assume 是伪指令，是由编译器执行的，也是仅在源程序中存在的信息，CPU 并不知道它们。不必深究 assume 的作用，只要知道需要用它将你定义的具有一定用途的段和相关寄存器联系起来就可以了

3. 若要 CPU 按照开发者的安排行事，就要用机器指令控制它，源程序中的汇编指令是 CPU 要执行的内容。CPU 如何知道去执行它们？
我们在源程序的最后用end start说明了程序的入口，这个入口将被写入可执行文件的描述信息，可执行文件中的程序被加载入内存后，CPU 的 `CS:IP` 被设置指向这个入口，从而开始执行程序中的第一条指令。标号`start`在 `code` 段中，这样 CPU 就将 code 段中的内容当作指令来执行了。我们在 code 段中，使用指令：

    ```sh
    mov ax,stack
    mov ss,ax
    mov sp,20h
    ```
    设置 ss 指向 stack，设置 `ss:sp` 指向 stack:20，CPU 执行这些指令后，将把 stack 段当作栈空间使用。CPU 若要访问 data 段中的数据，则可用 ds 指向 data 段，用其它的寄存器（如 bx）来存放 data 段数据的偏移地址。

总之，CPU 到底如何处理我们定义的段中的内容，完全是靠程序中具体的`汇编指令`，和汇编指令对 `CS:IP`、`SS:SP`、`DS` 等寄存器的设置来决定的


### 实验5 编写、调试具有多个段的程序
这一章内容较少，有些知识需要在实践中掌握。必须完成这个实验。

（1）将下面程序编译、连接，用 Debug 加载、跟踪，然后回答问题
```sh
assume cs:code,ds:data,ss:stack

data segment
    dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
data ends

stack segment
    dw 0,0,0,0,0,0,0,0
stack ends

code segment
start:  mov ax,stack
        mov ss,ax
        mov sp,16
        
        mov ax,data
        mov ds,ax
        
        push ds:[0]
        push ds:[2]
        pop ds:[2]
        pop ds:[0]
        
        mov ax,4c00h
        int 21h
code ends
end start
```

1. CPU 执行程序，程序返回前，`data` 段中的数据为多少？  

data 段中的数据不变, 一直是`075Ax16=076A`  

2. CPU 执行程序，程序返回前，cs=______ ss=______ ds=______。
也就是执行`int 21h`前，这时cs=`076CH`,ss=`076BH`,ds=`076A`  

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-15.png" width="60%"></img>  
</div>
<br>

3. 设程序加载后，code 段的段地址为 X，则 data 段的段地址为______，stack 段的段地址为______。  

data=ds=cs-2  , stack=ss=cs-1  

对应真实地址为:`ds=076A`, `ss=076B`,`cs=076C`  

4. 对于如下定义的段

```sh
name segment
 .
 .
 .
name ends
```

如果段中的数据占 N 个字节，则程序加载后，该段实际占有的空间为______  

实际占用的空间为: `(N/16取整 + 1) * 16`; 详解：  
虽然上面代码 data 段和 stack 段只初始化了 4 个字节的内存，但是在汇编中还是直接分配 16 个字节的空间，不足的按 `00` 补全  

## 7 更灵活的定位内存地址的方法
### 7.1 and 和 or 指令

- and 指令：逻辑与指令，按位进行与运算  

```sh
mov al,01100011B
and al,00111011B      ; al = 00100011B 得到的值
```

通过该指令可将操作对象的相应位设为 0，其它位不变, 相应位都为 1，得 1  

- or 指令：逻辑或指令，按位进行或运算  

```sh
mov al,01100011B
or  al,00111011B      ; al = 01111011B 得到的值
```

通过该指令可将操作对象的相应位设为 1，其它位不变,相应位都为 0，得 0.  

### 7.2 关于 ASCII 码
ASCII编码是世界上众多编码的其中一种

在文本编辑过程中，我们按下键盘中的 `a` 键，就会在屏幕中看到`a`的过程：

1. 按下键盘的 `a` 键，这个按键信息被送入计算机，计算机用 ASCII 码的规则对其进行编码，将其转化为 `61H` 存储在内存的指定空间中  
2. 文本编辑软件从内存中取出 `61H`，将其送入显卡的内存中  
3. 工作在文本模式下的显卡，用 ASCII 码的规则解释显存中的内容，`61H` 被当作字符`a`，显卡驱动显示器，将字符`a`的图像画在屏幕上
显卡在处理文本信息的时候，是按照 ASCII 码的规则进行的。也就是说要想在显示器看到`a`，就要给显卡的显存中写入`a`的 ASCII 码，`61H`  

[:books: 返回目录](#目录)

### 7.3 以字符形式给出的数据
汇编程序中，用`...`的方式指明数据是以字符的形式给出的，编译器将它们转化为相对应的 ASCII 码。如下面程序  

```sh
assume cs:code,ds:data
data segment
    db 'unIX'
    db 'foRK'
data ends
code segment
start:  mov al,'a'
        mov bl,'b'
        mov ax,4c00h
        int 21h
code ends
end start
```

在上面程序中： 
- db 'unIX' 相当于 db `75h,6eh,49h,58h`
- db 'foRK' 相当于 db `66h,6fh,52h,4bh`
- mov al,'a' 相当于 mov al,`61h`
- mov bl,'b' 相当于 mov bl,`62h`

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-16.png" width="60%"></img>  
</div>
<br>

从图中可以看到 `ds=075a`，所以程序是从 `076aH` 段开始的，data 段又是程序中的第一个段，所以 `data` 段的段地址为 `076ah`

程序从 DS 开始，前 256 个字节（100H）是 DOS 系统用来和程序通信用的，所以 `075ah+100h=076aH` 才是程序开始的地址  

[:books: 返回目录](#目录)

### 7.4 大小写转换的问题
在 codesg 中填写代码，将 datasg 中的第一个字符串转化为大写，第二个字符串转化为小写  

```sh
assume cs:codesg,ds:datasg
datasg segment
    db 'BaSiC'
    db 'InfOrMaTiOn'
datasg ends
codesg segment

; ****** 写入程序开始 ******
start:  mov ax,datasg
        mov ds,ax           ; 设置 ds 指向 datasg 段
        
        mov bx,0            ; 设置 (bx)=0, ds:bx 指向'BsAiC'的第一个字母
        mov cx,5            ; 设置循环次数，因为'BsAiC'有 5 个字母
    s:  mov al,[bx]         ; 将 ASCII 码从 ds:bx 所指向的单元中取出
        and al,11011111B    ; 将 al 中的 ASCII 码的第 5 位，置为 0，变为大写字母
        mov [bx],al         ; 将转变后的 ASCII 码写回原单元
        inc bx              ; (bx) 加 1，ds:bx 指向下一个字母
        loop s

        mov bx,5            ; 设置 (bx)=5,ds:bx 指向 'InfOrMaTiOn' 的第一个字母
        mov cx,11           ; 设置循环次数，因为 'InfOrMaTiOn' 有 11 个字母
    s0: mov al,[bx]
        or al,00100000B     ; 将 al 中的 ASCII 码的第 5 位，置为 1，变为小写字母
        mov [bx],al
        inc bx
        loop s0
        
        mov ax,4c00h
        int 21h
; ****** 写入程序结束 ******

codesg ends
end start
```

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-17.png" width="60%"></img>  
</div>
<br>

由ASCII 码对应 `'A'=41h=01000001b`，`'a'=61h=01100001b` 可得大小写之间十六进制相差 `20h`，二进制的第 5 位是否为 0，为 0 则大写，为 1 则小写

如果我们使用十六进制则还需要判断字母是否为大写或小写，所以使用二进制第 5 位与 and、or 的特性：

将第一个字符串中的字母都用 and 来把第 5 位，置为 0
将第二个字符串中的字母都用 or 来吧第 5 位，置为 1
and：相应位都为 1，得 1
or ：相应位都为 0，的 0

[:books: 返回目录](#目录)
### 7.5 [bx+idata]
在前面，我们用 [bx] 的方式来指明一个内存单元，还可以用一种更为灵活的方式来指明内存单元：`[bx+idata]`，它的偏移地址为 (bx)+idata（也就是 bx 中的数值加上常量 idata）。  

指令 `mov ax,[bx+200]` 的含义：
将一个内存单元的内存送入 ax，这个内存单元的长度为 2 个字节（字单元），存放一个字，偏移地址为 `bx` 中的数值加上 `200`，段地址在 `ds` 中。

数学化描述为：(ax)=((ds)*16+(bx)+200)

也可以写成：
```sh
mov ax,[200+bx]
mov ax,200[bx]
mov ax,[bx].200
```
[:books: 返回目录](#目录)
### 7.6 用[bx+idata]的方式进行数据的处理

在 codesg 中填写代码，将 datasg 中定义第一个字符串转化为大写，第二个字符串转化为小写  

```sh
assume cs:codesg,ds:datasg
datasg segment
    db 'BaSiC'
    db 'MinIX'
datasg ends

codesg segment
; ****** 填入代码开始 ******
start:  mov ax,datasg
        mov ds,ax
        mov bx,0
        mov cx,5
    s:  mov al,[bx]         ; 定位第一个字符串中的字符
        ; 上面也可以改成 mov al,0[bx]
        and al,11011111b
        mov [bx],al
        mov al,[5+bx]       ; 定位第二个字符串中的字符
        ; 上面也可以改成 mov al,5[bx]
        or al,00100000b
        mov [5+bx],al
        ; 上面也可以改成 mov 5[bx],al
        inc bx
        loop s
; ****** 填入代码结束 ******
codesg ends

end start
```

如果用高级语言，比如 C 语言来描述上面的程序，大致是这样：
```c
char a[5]="BaSiC";
char b[5]="MinIX";

main () {
    int i;
    i = 0;
    do {
        a[i] = a[i] & 0xDF;
        b[i] = b[i] | 0x20;
    } while (i < 5);
}
```

通过比较可以看到，[bx+idata] 的方式为高级语言实现数组提供了便利机制  

[:books: 返回目录](#目录)
### 7.7 SI 和 DI

`si`（Source Index）和 `di`（Destination Index）是 8086CPU 中和 bx 功能相近的寄存器，`si` 和 `di` 不能够分成两个 8 位寄存器来使用。  

```sh
; 下面三组指令功能相同
mov bx,0
mov ax,[bx]

mov si,0
mov di,0

mov ax,[si]
mov ax,[di]

; 下面三组指令功能也相同
mov bx,0
mov ax,[bx+123]

mov si,0
mov ax,[si+123]

mov di,0
mov ax,[di+123]
```

### 7.8 [bx+si]和[bx+di]
前面，我们用[bx(si或di)]和[bx(si或di)+idata]的方式来指明一个内存单元，还可以用更为灵活的方式：[bx+si]或[bx+di]

[bx+si]表示一个内存单元，它的偏移地址为`(bx)+(si)`，也就是 bx 中的数值加上 si 中的数值。

指令`mov ax,[bx+si]`的含义如下：

将一个内存单元的内容送入 ax，这个内存单元的长度为 2 字节（字单元），存放一个字，偏移地址为 `bx` 中的数值加上 `si` 中的数值，段地址在 `ds` 中。

数学化的描述为：`(ax)=((ds)*16+(bx)+(si))`

也可以写成常用格式：`mov ax,[bx][si]`  

[:books: 返回目录](#目录)
### 7.9 [bx+si+idata]和[bx+di+idata]

[bx+si+idata] 表示一个内存单元，它的偏移地址为(bx)+(si)+idata，也就是 bx 中的数值加上 si 中的数值再加上 idata。

指令mov,[bx+si+idata]的含义：将一个内存单元的内容送入 ax，这个内存单元的长度为 2 字节（字单元），存放一个字，偏移地址为 bx 中的数值加上 si 中的数值再加上 idata，段地址在 ds 中。

数学化描述为：`(ax)=((ds)*16+(bx)+(si)+idata)`

常用格式：
```sh
mov ax,[bx+200+si]
mov ax,[200+bx+si]
mov ax,200[bx][si]
mov ax,[bx].200[si]
mov ax,[bx][si].200
```
[:books: 返回目录](#目录)


### 7.10 不同的寻址方式的灵活应用
比较一下前面用到的几种定位内存地址的方法（可称为寻址方式），就可以发现：

1. [idata] 用一个常量来表是内存地址，可用于直接定位一个内存单元
2. [bx] 用一个变量表示内存地址，可用于间接定位一个内存单元
3. [bx+idata] 用一个变量和常量表示地址，可在一个起始地址的基础上用变量间接定位一个内存单元
4. [bx+si] 用两个变量表示地址
5. [bx+si+idata] 用两个变量和一个常量表示地址


编程，将 datasg 段中的每个单词的前 4 个字母改为大写字母  

```sh
assume cs:codesg,ss:stacksg,ds:datasg

stacksg segment
    dw 0,0,0,0,0,0,0,0
stacksg ends

datasg segment
    db '1. display      '
    db '2. brows        '
    db '3. replace      '
    db '4. modify       '
datasg ends

codesg segment
start:  mov ax,datasg
        mov ds,ax
        mov bx,0            ; 作为基本偏移地址

        mov ax,stacksg
        mov ss,ax           ; 栈寄存器地址指向
        mov sp,16           ; 将 ss:sp 指向栈顶

        mov cx,4            ; 外层循环 4 次
    s0: push cx             ; 外层循环计数器保护起来，内存循环时也需要用到 cx
        mov si,0            ; si 作为每个字符串的偏移地址

        mov cx,4            ; 内层循环次数，修改前四个字母为大写
    s1: mov al,[bx+si+3]    ; 使用[bx+si+3]寻址方式，并送入 al
        add al,11011111b    ; 转换大写字母
        mov [bx+si+3],al    ; 回写内存
        inc si
        loop s1

        add bx,16           ; 4 个字符串长度一致，都是 16 字节，增量为 16
        pop cx              ; 将外层循环计数器恢复
        loop s0

        mov ax,4c00h
        int 21h
codesg ends
end start
```

dagasg 中数据存储结构，如图：

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-18.png" width="80%"></img>  
</div>
<br>

[:books: 返回目录](#目录)

## 8 数据处理的两个基本问题

（1）处理的数据在什么地方？
（2）要处理的数据有多长？

这两个问题，在机器指令中必须给出明确或隐含的说明，否则计算机就无法工作。本章中针对 8086CPU 对着两个基本问题进行讨论

后面的课程中使用 `reg` 来表示一个寄存器，`sreg` 表示一个段寄存器

`reg` 的集合包括：ax、bx、cx、dx、ah、al、bh、bl、ch、cl、dh、dl、sp、bp、si、di  
`sreg` 的集合包括：ds、ss、cs、es  

### 8.1 bx、si、di 和 bp  

在 8086CPU 中，中有这 4 个寄存器可以用在“[...]”中来进行内存单元的寻址。比如下面指令都是正确的：  

```sh
mov ax,[bx]
mov ax,[bx+si]
mov ax,[bx+di]
mov ax,[bp]
mov ax,[bp+si]
mov ax,[bp+di]
```  

在[...]中，这 4 个寄存器可以单个出现，或只能以 4 种组合出现：  
```sh
bx 和 si
bx 和 di
bp 和 si
bp 和 di
```

只要在[...]中使用寄存器 bp，而指令中没有显性地给出段地址，段地址就默认在 ss 中。比如下面指令：  

```sh
mov ax,[bp]             ; 含义：(ax)=((ss)*16+(bp))
mov ax,[bp+idata]       ; 含义：(ax)=((ss)*16+(bp)+idata)
mov ax,[bp+si]          ; 含义：(ax)=((ss)*16+(bp)+(si))
mov ax,[bp+si+idata]    ; 含义：(ax)=((ss)*16+(bp)+(si)+idata)
```

### 8.2 机器指令处理的数据在什么地方

绝大部分机器指令都是进行数据处理的指令，处理大致可分为 3 类：`读取`、`写入`、`运算`。

在机器指令着一层来讲，并不关心数据的值是多少，而关心指令执行前一刻，它将要处理的数据所在的位置。

指令在执行前，索要处理的数据可以在 3 个地方：`CPU 内部`、`内存`、`端口`（端口在后面的课程中进行讨论）  

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-19.png" width="60%"></img>  
</div>
<br>

[:books: 返回目录](#目录)
### 8.3 汇编语言中数据位置的表达

汇编语言中用 3 个概念来表达数据的位置

（1）立即数（idata）

对于直接包含在机器指令中的数据（执行前在 CPU 的指令缓冲器中），在汇编语言中称为：立即数，在汇编指令中直接给出。例如：
```sh
mov ax,1
add bx,2000h
or bx,00010000b
mov al,'a'
```
（2）寄存器

指令要处理的数据在寄存器中，在汇编指令中给出相应的寄存器名。例如：
```sh
mov ax,bx
mov ds,ax
push bx
mov ds:[0],bx
push ds
mov ss,ax
mov sp,ax
```
（3）段地址（SA）和偏移地址（EA）

指令要处理的数据在内存中，在汇编指令中可用[X]的格式给出 EA，SA 在某个段寄存器中。

存放段地址的寄存器可以使默认的，例如：

```sh
; 下面指令段地址默认在 ds 中
mov ax,[0]
mov ax,[di]
mov ax,[bx,si+8]

; 下面指令段地址默认在 ss 中
mov ax,[bp]
mov ax,[bp+si+8]

; 下面指令，存放段地址的寄存器显性给出
mov ax,ds:[bp]
mov ax,es:[bx]
mov ax,cs:[bx+si+8]
```

[:books: 返回目录](#目录)

### 8.4 寻址方式
当数据存放在内存中的时候，我们可以用多种方式来给定这个内存单元的偏移地址，这种定位内存单元的方法一般被称为寻址方式  

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-20.png" width="80%"></img>  
</div>
<br>

[:books: 返回目录](#目录)

### 8.5 指令要处理的数据有多长
8086CPU 的指令，可以处理两种尺寸的数据，`byte` 和 `word`。所以在机器指令中要指明，指令进行的是字操作还是字节操作。  

1. 通过寄存器名指令要处理的数据的尺寸  

```sh
; 以下为字操作
mov ax,1
mov bx,ds:[0]
mov ds,ax
mov ds:[0],ax
inc ax
add ax,1000

; 以下为字节操作
mov al,1
mov al,bl
mov al,ds:[0]
mov ds:[0],al
inc al
add al,100
```

2. 在没有寄存器名存在的情况下，用操作符X ptr指明内存单元的长度，X在汇编指令中可以为 word 或 byte  

```sh
; 下面指令中，用 word ptr 指明了指令访问的内存单元是一个字单元
mov word ptr ds:[0],1
inc word ptr [bx]
inc word ptr ds:[0]
add word ptr [bx],2

; 下面指令中，用 byte ptr 指明了指令访问的内存单元是一个字节单元
mov byte ptr ds:[0],1
inc byte ptr [bx]
int byte ptr ds:[0]
add byte ptr [bx],2
```

3. 其他方法。有些指令默认了访问的是字单元还是字节单元

- 比如 `push [1000h]` 就不用指明，因为 push 指令只进行字操作  

### 8.6 寻址方式的综合应用
下面通过一个问题来进一步讨论各种寻址方式的作用

关于 DEC 公司的一条记录（1982年）如下。  

```sh
公司名称: DEC
总裁姓名: Ken Olsen
排    名: 137
收    入: 40(40 亿美元)
著名产品: PDP(小型机)
```

可以看到，这些数据被存放在 seg 段中从偏移地址 60h 起始的位置：

- seg:60起始以 ASCII 字符的形式存储了 3 个字节的公司名称
- seg:60+3起始以 ASCII 字符的形式存储了 9 个字节的总裁姓名
- seg:60+0c起始存放了一个字型数据，总裁在富豪榜上的排名
- seg:60+0e起始存放了一个字型数据，公司的收入
- seg:60+10起始以 ASCII 字符形式存储了 3 个字节的产品名称  


<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-21.png" width="40%"></img>  
</div>
<br>

[:books: 返回目录](#目录)

### 8.7 div 指令

div 是`除法`指令，是用 div 做除法的时候应该注意以下问题：

- 除数：有 8 位和 16 位两种，在一个 reg 或内存单元中
- 被除数：默认放在 AX 或 DX 和 AX 中。
    - 如果除数为 8 位，被除数则为 16 位，默认在 AX 中存放
    - 如果除数为 16 位，被除数则为 32 位，在 DX 和 AX 从存放，DX 存放高 16 位，AX 存放低 16 位  
- 结果：  
    - 如果除数为 8 位，则 `AL` 存储除法操作的商，`AH` 存储除法操作的余数
    - 如果除数为 16 位，则 `AX` 存储除法操作的商，`DX` 存储除法操作的余数  


格式如下：
```sh
div reg
div 内存单元
```

现在，我们可以用多种方法来表示一个内存单元了，比如下面例子：  

```sh
div byte ptr ds:[0]
; 含义:  (al)=(ax)/((ds)*16+0) 的商
;       (ah)=(ax)/((ds)*16+0) 的余数

div word ptr es:[0]
; 含义:  (ax)=[(dx)*10000H+(ax)]/((es)*16+0) 的商
;       (ah)=[(ds)*10000H+(ax)]/((es)*16+0) 的余数

div byte ptr [bx+si+8]
; 含义: (al)=(ax)/((ds)*16+(bx)+(si)+8) 的商
;      (ah)=(ax)/((ds)*16+(bx)+(si)+8) 的余数
```

数学中`[]`中括号表示为：一个式子中有了小括号，再要用括号的话，外面就要用中括号  

### 8.8 伪指令 dd
前面我们用 db 和 dw 定义字节型数据和字型数据。`dd` 用来定义 `dword`（doubleword，双字）型数据的。  

### 8.9 dup
`dup` 是一个操作符，在汇编语言中同 db、dw、dd 等一样，也是由编译器识别处理的符号。它是和 db、dw、dd 等数据定义伪指令配合使用的，用来进行数据的重复。比如：

- `db 3 dup (0)` 定义了 3 个字节，它们的值都是 0，相当于db 0,0,0  
- `db 3 dup (0,1,2)` 定义了 9 个字节，它们是 0、1、2、0、1、2、0、1、2，相当于db 0,1,2,0,1,2,0,1,2  

dup 使用的格式为：db 重复的次数 dup (重复的字节型数据)  

## 9 转移指令原理  

**可以修改 IP，或同时修改 CS 和 IP 的指令统称为转移指令。** 也就是说转移指令就是可以控制 CPU 执行内存中某处代码的指令。

8086CPU 的转移行为有以下几类：

- 段内转移 - 只修改 IP，比如：jmp ax
由于转移指令对 IP 的修改范围不同，段内转移又分为：
  - 短转移 - 修改 IP 的范围为 -128~127
  - 近转移 - 修改 IP 的范围为 -32768~32767
- 段间转移 - 同时修改 CS 和 IP，也被称为远转移，比如：jmp 1000:0  

8086CPU 的转移指令分为一下几类：    

- 无条件转移指令，比如：`jmp`
- 条件转移指令 比如: `JE/JZ`  Jump Equal or Jump Zero
- 循环指令，比如：`loop`
- 过程 
- 中断 比如:`INT；0～127`

这些转移指令的前提条件可能不同，但转移的基本原理是相同的。我们主要通过深入学习- 无条件转移指令 jmp 来理解 CPU 执行转移指令的基本原理    

### 9.1 操作符 offset

操作符 `offset` 在汇编语言中是由编译器处理的符号，它的功能是`取得标号的偏移地址`。比如下面程序：

```sh
assume cs:codesg
codesg segment
    start: mov ax,offset start  ; 相当于 mov ax,0; 
        s: mov ax,offset s      ; 相当于 mov ax,3; 因为前面一条指令长度为 3 个字节
codesg ends
end start
```


[:books: 返回目录](#目录)
### 9.2 jmp 指令
jmp 为无条件转移指令，可以只修改 IP，也可以同时修改 CS 和 IP  

- 转移的目的地址
- 转移的距离
  - 段间转移
  - 段内短转移
  - 段内近转移  

### 9.3 ⭐️️依据位移进行转移的 jmp 指令  
`jmp short 标号`(转到标号处执行指令)这种格式是段内短转移，它对 `IP` 的修改范围为 `-128~127`

- short - 符号说明指令进行的是短转移
- 标号 - 是代码段中的标号，指明了指令要转移的目的地，转移指令结束后，CS:IP 应该指向标号处的指令  


程序 9.1:  
```sh
assume cs:codesg
codesg segment              ; 偏移地址  机器码
    start:  mov ax,0        ; 0000     B80000
            jmp short s     ; 0003     EB03
            add ax,1        ; 0005     050100
        s:  inc ax          ; 0008     40
codesg ends
end start
```

程序 9.2:
```sh
assume cs:codesg
codesg segment              ; 偏移地址  机器码
    start:  mov ax,0        ; 0000     B80000
            mov bx,0        ; 0003     BB0000
            jmp short s     ; 0006     EB03
            add ax,1        ; 0008     050100
        s:  inc ax          ; 000B     40
codesg ends
end start
```

比较程序 9.1 和 9.2 用 Debug 查看结果

注意，两个程序中的 `jmp` 指令都要使 `IP` 指向`inc ax` 指令，但是程序 9.1 的 `inc ax` 指令的偏移地址为0008H，而程序 9.2 的 `inc ax` 指令的偏移地址为`000BH`。再看对应的机器码都为`EB 03`，这说明CPU 在执行 `jmp `指令的时候并不需要转移的目的地址

两个程序中的 `jmp` 指令的转移目的地址并不一样（cs:0008 和 cs:000B），如果机器中包含了转移的目的地址的话，那么它们对应的机器码应该是不同的。可是它们对应的机器码都是`EB 03`，这说明在机器指令中并不包含转移的目的地址，也就是说CPU 不需要这个目的地址就可以实现对 `IP` 的修改  

[:books: 返回目录](#目录)

### 9.4 转移的目的地址在指令中的 jmp 指令

`jmp far ptr` 标号实现的是段间转移，又称为远转移。功能：(CS)=标号所在段的段地址；(IP)=标号在段中的偏移地址

程序 9.3  
```sh
assume cs:codesg
codesg segment
    start:  mov ax,0
            mov bx,0
            jmp far ptr s
            db 256 dup (0)
        s:  add ax,1
            inc ax
codesg ends
end start
```

在 Debug 中讲程序 9.3 翻译成机器码，看到结果如下：  
<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-22.jpg" width="85%"></img>  
</div>
<br>


如图所示，源程序中的`db 256 dup (0)`，被 Debug 解释为相应的若干条汇编指令，这不是关键。我们要注意一下`jmp far ptr s`所对应的机器码：`EA 0B 01 6A 07`，其中包含转移的目标地址。`EA 0B 01 6A 07` 的目的地址在指令中的存储顺序，高地址的`6A 07`是转移的段地址：076AH，低地址的0B 01是偏移地址：010BH

### 9.5 转移地址在寄存器中的 jmp 指令
指令格式：jmp 16位reg

功能：(IP)=(16位reg)


### 9.6 转移地址在内存中的 jmp 指令
转移地址在内存中的 jmp 指令的两种格式：

（1）jmp word ptr 内存单元地址（段内转移）  

功能：从内存单元地址处开始存放着一个字，是转移的目的偏移地址。内存单元地址可用寻址方式的任一格式给出  
```sh
mov ax,0123h
mov ds:[0],ax
jmp word ptr ds:[0] ; 执行后，(IP)=0123h

; 或下面格式
mov ax,0123h
mov [bx],ax
jmp word ptr [bx] ; 执行后，(IP)=0123h
```
（2）jmp dword ptr 内存单元地址（段间转移）

功能：从内存单元地址处开始存放着两个字，高地址处的字是转移的目的段地址，低地址处是转移的目的偏移地址。内存单元地址可用寻址方式的任一格式给出

(CS)=(内存单元地址+2)；(IP)=(内存单元地址)
```sh
mov ax,0123h
mov ds:[0],ax
mov word ptr ds:[2],0
jmp dword ptr ds:[0]    ; 执行后 (CS)=0，(IP)=0123H, CS:IP 指向 0000:0123

; 或下面格式
mov ax,0123h
mov [bx],ax
mov word ptr [bx+2],0
jmp dword ptr [bx]      ; 执行后 (CS)=0，(IP)=0123H，CS:IP 指向 0000:0123
```

[:books: 返回目录](#目录)

### 9.7 jcxz 指令
`jcxz` 指令为有条件转移指令，所有的有条件转移指令都是短转移，在对应的机器码中包含转移的位移，而不是目的地址。对 IP 的修改范围都为：-128~127

指令格式：jcxz 标号；如果(cx)=0)，转移到标号处执行

操作：当 (cx)=0 时，(IP)=(IP)+8位位移

- 8位位移=标号处的地址-jcxz指令后的第一个字节的地址
- 8位位移的范围为-128~127
- 8位位移由编译程序在编译时算出  


当 (cx)≠0 时，什么也不做（程序向下执行）。

从 jcxz 的功能中可以看出，jcxz 标号的功能相当于：`if((cx)==0) jmp short 标号`。（这种用 C 语言和汇编进行的综合描述，或许对理解有条件转移指令更加清楚）

[:books: 返回目录](#目录)


## 10 CALL 和 RET 指令
`call` 和 `ret` 指令都是转移指令用来修改 IP，或同时修改 CS 和 IP。经常被共同用来实现子程序的设计  

### 10.1 ret 和 retf
- ret 指令用栈中的数据，修改 IP 的内容，实现近转移

CPU 执行时进行下面两步操作
- (IP)=((ss)*16+(sp))
- (sp)=(sp)+2

用汇编语法来解释
```sh
pop IP
```

- retf 指令用栈中的数据，修改 CS 和 IP 的内容，实现远转移

CPU 执行时进行下面四步操作（先入栈 cs，后入栈 ip）
- 1. (IP)=((ss)*16+(sp))
- 2. (sp)=(sp)+2
- 3. (CS)=((ss)*16+(sp))
- 4. (sp)=(sp)+2  

用汇编语法来解释
```sh
pop IP
pop CS
```

例：下面程序中，`ret` 指令执行后，`(IP)=0，CS:IP` 指向代码段的第一条指令  
```sh
assume cs:code
stack segment
    db 16 dup (0)
stack ends
code segment
    mov ax,4c00h
    int 21h
    
start:
    mov ax,stack
    mov ss,ax
    mov sp,16
    mov ax,0
    push ax
    mov bx,0    ; TODO: 这里的指令感觉没有作用
    ret
code ends
end start
```

[:books: 返回目录](#目录)  

### 10.2 call 指令
CPU 执行 call 指令时，进行两步操作：

- 将当前的 `IP` 或 `CS` 和 `IP` 压入栈
- 转移  
- 
call 指令不能实现短转移，除此之外 `call` 指令实现转移的方法和 `jmp` 指令的原理相同


[:books: 返回目录](#目录)  

## 11 标志寄存器
8086CPU 的标志寄存器（以下简称为 flag）有 `16` 位，其中存储的信息通常被称为程序状态字（PSW），有以下三种作用：

- 用来存储相关指令的某些执行结果
- 用来为 CPU 执行相关指令提供行为依据
- 用来控制 CPU 的相关工作方式

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-23.png" width="85%"></img>  
</div>
<br>

- ZF(Zero Flag) 零标志位  
ZF零标志位，记录相关指令执行后，结果是否为0。通常一位bit的布尔变量1表示真，0表示假。ZF零标志位在指令执行的结果为0时，值为真(ZF=1);不为0时；不为0时，值为假(ZF=0)。

- PF(Parity Flag) 奇偶标志位  
PF奇偶校验位，记录相关指令执行后，结果中bit位中1的个数是否为偶数。若1的个数为偶数，则PF=1；反之，若1的个数为奇数，则PF=0。

- SF(Sign Flag) 符号标志位  
SF符号标志位，记录相关指令执行后，结果是否为负。若结果为负，SF=1；若结果为非负，SF=0。

- CF(Carry Flag) 进位标志位  
CF进位标志位，一般在无符号数运算时，记录最高位是否产生了进位(例如加法指令)，或是否从最高位借位(例如减法指令)。  

  正是因为存在了CF进位标志位，8086CPU的寄存器虽然只有16位，虽然在硬件上无法直接进行更大范围的数的运算(超过2^16)，但可以通过软件的方式，将运算分为多步，将一个更大的数据(例如两个64位的数的加法可以分解为4个16位数的相加)，通过CF进位标志位完成运算(adc指令 带进位的加法指令)。在理论上可以完成任意位数据的运算。

- OF(Overflow Flag) 溢出标志位  
OF溢出标志位，一般在有符号运算时，记录结果是否产生了溢出。若发生了溢出，则OF=1；若没有发生溢出，则OF=0。

- DF(Direction Flag) 方向标志位  
方向标志位用于指定字符串处理时的方向，DF=1，以递减顺序处理字符串，即地址以从高到低顺序递减。反之，DF=0时则以递增顺序处理。

- IF(Interrupt enable Flag) 中断允许标志位  
中断标志位用于标识中断是否启用。IF=1,表示CPU允许接受中断；IF=0，表示当前CPU不接受中断。

- TF(Trap Flag) 跟踪标志位  
跟踪标志位用于标识CPU是否允许单步中断，以进行程序调试。TF=0时，8086CPU处于正常状态；TF=1时，8086CPU处于单步状态，每执行一条指令就自动产生一次单步中断。

  8086的debug功能依赖于8086CPU的单步调试功能。更进一步，CPU单步中断的硬件功能，是所有软件级别的debug单步调试的基础，只不过通常高级语言中的单步执行对应的是多条机器硬件指令的执行。

  IF、TF在8086中断控制中起到了非常关键的作用，在后面的中断部分会进一步的详细介绍。

## 11.1 ZF 标志
零标志位，第 6 位。它记录相关指令执行后，结果是否为 0  

注意，在 8086CPU 的指令集中：

有的指令执行是影响标志寄存器的，比如：`add`、`sub`、`mul`、`div`、`inc`、`and` 等，它们大都是运算指令（进行逻辑或算数运算）  

有的指令执行对标志寄存器没有影响，比如：`mov`、`push`、`pop` 等，它们大都是传送指令  
在使用一条指令的时候，要注意这条指令的全部功能，其中包括，执行结果对标志寄存器的哪些标志位造成影响

[:books: 返回目录](#目录)  

### 11.2 PF 标志
奇偶标志位，第 2 位。它记录相关指令执行后，结果的所有 bit 位中 1 的个数是否为偶数

bit 为中 1 的个数为：

- 偶数，pf=1
- 奇数，pf=0


### 11.3 SF 标志
符号标志位，第 7 位。它记录相关指令执行后，结果是否为负  

```sh
; 写出下面每条指令执行后，ZF、PF、SF 等标志位的值
sub al,al       ; ZF=1 ；PF=1 ；SF=0 ；
mov al,1        ; ZF=1 ；PF=1 ；SF=0 ；
push ax         ; ZF=1 ；PF=1 ；SF=0 ；
pop bx          ; ZF=1 ；PF=1 ；SF=0 ；
add al,bl       ; ZF=0 ；PF=0 ；SF=0 ；
add al,10       ; ZF=0 ；PF=1 ；SF=0 ；
mul al          ; ZF=0 ；PF=1 ；SF=0 ；
```

`mov`、`push`、`pop` 传送指令不影响标志位    

[:books: 返回目录](#目录)  

### 11.4 CF 标志  
进位标志位，第 0 位。一般情况下，在进行「无符号数」运算的时候，它记录了运算结果的最高有效位向更高位的进位值，或从更高位的借位值

### 11.5 OF 标志
溢出标志位，第 11 位。一般情况下，记录了「有符号数」运算的结果是否发生了溢出。

### 11.6 adc 指令
adc 是带进位加法指令，它利用了 CF 位上记录的进位值  

指令格式：`adc 操作对象1, 操作对象2`  
功能：操作对象1 = 操作对象1 + 操作对象2 + CF  
比如指令`adc ax,bx`实现的功能是：(ax)=(ax)+(bx)+CF  

例如：
```sh
mov al,98H
add al,al
adc al,3 ; (ax)=34H，相当于计算：(al)+3+CF=30H+3+1=34H，这里 (al)=30H，因为 98H+98H=130H，al 只能存 8 位，进位 1 不保存，存在 CF 中
```

[:books: 返回目录](#目录)  
### 11.7 sbb 指令
`sbb` 是带借位减法指令，它利用 `CF` 位上记录的借位值。

指令格式：sbb 操作对象1, 操作对象2
功能：操作对象1 = 操作对象1 - 操作对象2 - CF
比如指令：sub ax,bx实现的功能是：(ax)=(ax)-(bx)-CF

sbb 指令执行后，将对 CF 进行设置。利用 sbb 指令可以对任意大的数据进行减法运算。例如，计算 003E1000H-00202000H，结果放在 ax，bx 中，程序如下：  

```sh
mov bx 1000H
mov ax 003EH
sub bx,2000H
sbb ax,0020H
```

[:books: 返回目录](#目录)  

### 11.8 cmp 指令

`cmp` 是比较指令，`cmp` 的功能相当于减法指令，只是不保存结果。cmp 指令执行后，将对标志寄存器产生影响。其它相关指令通过识别这些被影响的标志寄存器位来得知比较结果。

指令格式：`cmp 操作对象1, 操作对象2`  
功能：计算 操作对象1-操作对象2 但并不保存结果，仅仅根据计算结果对标志寄存器进行设置  
比如，指令`cmp ax,ax`做 (ax)-(ax) 的运算，结果为 0，但并不在 ax 中保存，进影响 `flag` 的相关各位。指令执行后：zf=1, pf=1, sf=0, cf=0, of=0  

下面指令：
```sh
mov ax,8
mov bx,3
cmp ax,bx   ; 执行后：(ax)=8, zf=0, pf=1, sf=0, cf=0, of=0
```

通过 cmp 指令执行后，相关标志位的值就可以看出比较的结果，`cmp ax,bx`

- 如果 (ax)=(bx) 则 (ax)-(bx)=0，所以：zf=1
- 如果 (ax)≠(bx) 则 (ax)-(bx)≠0，所以：zf=0
- 如果 (ax)<(bx) 则 (ax)-(bx) 将产生借位，所以：cf=1
- 如果 (ax)≥(bx) 则 (ax)-(bx) 将不必借位，所以：cf=0
- 如果 (ax)>(bx) 则 (ax)-(bx) 既不必借位，结果又不为 0，所以：cf=0 并且 zf=0
- 如果 (ax)≤(bx) 则 (ax)-(bx) 既可能借位，结果可能为 0，所以：cf=1 或 zf=1  

现在可以看出比较指令的设计思路，即：通过做减法运算，影响标志寄存器，标志寄存器的相关位记录了比较的结果  

### 11.9 检测比较结果的条件转移指令
`转`移指的是它能够修改 `IP`，`条件`指的是它可以根据某种条件决定是否修改 `IP`

下面是常用的根据无符号数的比较结果进行转移的条件转移指令，第一个字母都是 j，表示 `jump`  

| 指令 | 含义 | 记忆 | 检测的相关标志位 | 
| ---- | --- | --- | ------------- | 
| je | 等于则转移 | e: equal | zf=1 | 
| jne | 不等于则转移 | ne: not equal | zf=0 | 
| jb | 低于则转移 | b: below | cf=1 | 
| jnb | 不低于则转移 | nb: not below | cf=0 | 
| ja | 高于则转移 | a: above | cf=0 且 zf=0 | 
| jna | 不高于则转移 | na: not above | cf=1 或 zf=1 | 

观察得到，它们所检测的标志位，都是 cmp 指令进行无符号数比较的时候，记录比较结果的标志位。  

编程实现功能：如果 (ah)=(bh) 则 (ah)=(ah)+(ah)，否则 (ah)=(ah)+(bh)  

```sh
cmp ah,bh       ; 比较 ah bh 是否相等
je s            ; 相等则转移到标号 s 处执行；体现了 je 指令的逻辑含义（相等则转移）
add ah,bh
jmp short ok
s: add ah,ah
ok: ...
```
[:books: 返回目录](#目录)  

### 11.10 DF 标志和串传送指令
方向标志位，在 flag 第 10 位。在串处理指令中，控制每次操作后 si、di 的增减

- df=0：每次操作后 si、di 递增
- df=1：每次操作后 si、di 递减

格式：`movsb`
功能：执行 `movsb` 指令相当于进行下面几步操作

1. ((es)*16+(di))=((ds)*16+(si))
2. 如果 df=0 则：
```sh
(si)=(si)+1
(di)=(di)+1
```
如果 df=1 则：  
```sh
(si)=(si)-1
(di)=(di)-1
```
用汇编语法描述的话：
```sh
mov es:[di],byte ptr ds:[si]    ; 8086 并不支持这样的指令，这里是是做为描述。伪代码

如果 df=0:
inc si
inc di

如果 df=1:
dec si
dec di
```  

可以看出，`movsb` 的功能是将 `ds:si` 指向的内存单元中的字节送入 `es:di` 中，然后根据标志寄存器 `df` 位的值，将 `si` 和 `di` 递增或递减  

### 11.11 pushf 和 popf
pushf 的功能是将标志寄存器的值压栈，popf 是从栈中弹出数据，送入标志寄存器中

pushf 和 popf，为直接访问标志寄存器提供了一种方法

### 11.12 标志寄存器在 Debug 中的表示
在 Debug 中，标志寄存器是按照有意义的各个标志位单独表示的

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-24.png" width="80%"></img>  
</div>
<br>

## 12 内中断

任何一个通用的 CPU 都具备一种能力，可以在执行完当前正在执行的指令后，检测到从 CPU 外部发送过来的或内部产生的一种特殊信息（中断信息），并且可以立即对所接受到的信息进行处理。中断的意思是：`CPU 不再接着（刚执行完的指令）向下执行，而是转去处理这个特殊信息`  

中断信息可以来自 CPU 的内部和外部，本章中，主要讨论来自 CPU 内部的中断信息

### 12.1 内中断的产生
8086CPU 用称为中断类型码的数据来标识中断信息的来源。中断类型码为一个字节型数据，可以表示 256 种中断信息的来源。以后我们将产生中断信息的事件，即**中断信息的来源，简称为中断源**。

1. 除法错误，中断类型码`0`
2. 单步执行，中断类型码`1`
3. 执行 `into` 指令，中断类型码`4`
4. 执行 `int` 指令，格式为`int n`，n为字节型立即数，是提供给 CPU 的中断类型码

[:books: 返回目录](#目录)  

### 12.2 中断处理程序
用来处理中断信息的程序被称为中断处理程序。一般来说，需要对不同的中断信息编写不同的处理程序。

根据 CPU 的设计，中断类型码的作用就是用来定位中断处理程序。比如 CPU 根据中断类型码4，可以可找到 `4` 号中断的处理程序。

[:books: 返回目录](#目录)  

### 12.3 中断向量表

`中断向量表`就是中断处理程序的入口地址的列表  

中断向量表在内存中保存，其中存放着 `256` 个中断源所对应的中断处理程序的入口，如图 12.1 所示

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-25.png" width="50%"></img>  
</div>
<br>

可见，CPU 用中断类型码，通过查找中断向量表，就可以得到中断程序的入口地址

对于 8086PC 机，中断向量表指定放在内存地址 0 处。从内存 `0000:0000` 到 `0000:03FF` 的 1024 个单元中存放着中断向量表。一个表项存放一个中断向量（中断处理程序的入口地址）占两个字，高地址存放段地址，低地址存放偏移地址

[:books: 返回目录](#目录)  

### 12.4 中断过程

从上面的讲解中，我们知道，可以用中断类型码，在中断向量表中找到中断处理程序的入口。找到这个入口地址的最终目的是用它设置 `CS` 和 `IP`，使 CPU 执行中断处理程序。用中断类型码找到中断向量，并用它设置 `CS` 和 `IP`，这个工作是由 CPU 的硬件自动完成的。CPU 硬件完成这个工作的过程被称为中断过程。

1. 从中断信息中取得中断类型码 N；
2. pushf；标志寄存器的值入栈（因为在中断过程中要改变标志寄存器的值，所以先将其保存在栈中）
3. TF=0，IF=0；设置第 8 位 TF 和第 9 位 IF的值为 0（这一步的目的后面将介绍到）
4. push CS
5. push IP
6. (IP)=(N*4), (CS)=(N*4+2)；从内存地址为中断类型码*4 和中断类型码\4+2 的两个字单元中读取中断处理程序的入口地址设置 IP 和 CS  


在最后一步完成后，CPU 开始执行有程序员编写的中断处理程序

[:books: 返回目录](#目录)  

### 12.5 中断处理成讯和 iret 指令
由于 CPU 随时都可能执行中断处理程序，所以中断处理程序必须一直存储在内存某段空间之中。而中断处理程序的入口地址，即中断向量，必须存储在对应的中断向量表表项中。

中断处理程序的编写方法和子程序的比较相似，下面的常规步骤：

1. 保存用到的寄存器
2. 处理中断
3. 恢复用到的寄存器
4. 用 `iret` 指令返回

```sh
; iret 指令的功能用汇编语法描述为下面
pop IP
pop CS
popf    ; 入栈 标志寄存器
```

### 12.6 除法错误中断的处理  

```sh
assume cs:code
code segment

start:
    mov ax,1000h
    mov bh,1
    div bh
code ends
end start
```

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-26.png" width="70%"></img>  
</div>
<br>

可以看到，当 CPU 执行 `div bh` 时，发生了出发溢出错误，产生了 0 号中断信息，从而引发中断过程，CPU 执行 0 号中断处理程序。从图中可是看出系统中的 0 号中断处理程序的功能：显示提示信息`Divide overflow`后，返回到操作系统中。

### 12.7 编程处理 `0` 号中断  

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-27.png" width="70%"></img>  
</div> 
<br> 

编程：当发生除法溢出时，在屏幕中间显示`overflow!`，返回 DOS。

首先我们进行分析：

（1）当发生除法溢出的时候，产生 `0` 号中断信息，从而引发中断过程。此处，CPU 将进行一下工作。  

1. 取得中断类型码 0
2. 标志寄存器入栈，TF、IF 设置为 0
3. CS、IP 入栈
4. (IP)=(0*4), (CS)=(0*4+2)  


（2）可见，当中断 0 发生时，CPU 将转去执行中断处理程序。只要按照如下步骤编写中断处理程序，当中断 0 发生时，即可显示`overflow!`  

1. 相关处理  
2. 向现实缓冲器送字符串`overflow!`  
3. 返回 DOS  

我们将这段程序称为：`do0`  

（3）现在问题是：do0 应存放在内存中。因为除法溢出随时可能发生，CPU 随时都可能将 `CS:IP` 指向 do0 的入口，执行程序

由于我们是在操作系统之上使用计算机，所有的硬件资源都在操作系统的管理之下，所以我们要想得到一块内存区存放 do0，应该向操作系统申请。

但这里处于两个原因我们不想这样做：

1. 过多的讨论申请内存将偏离问题的主线
2. 我们学习汇编的一个重要目的就是要获得对计算机底层的编程体验。所以，在可能的情况下，我们不去理会操作系统，而直接面向硬件资源  


问题变得简单而直接，我们只需要找到一块别的程序不会用到的内存区，将 do0 传送到其中即可。

前面讲到，内存 `0000:0000~0000:03FF`，大小为 1KB 的空间是系统存放中断处理程序入口地址的中断向量表。8086 支持 256 个中断，实际上系统中要处理的中断事件远没有达到 256 个。所以在中断向量表中，有许多单元是空的。

中断向量表是 PC 系统中最重要的内存区，只有来存放中断处理程序的入口地址，DOS 系统和其它应用都不会随便使用这段空间。一般情况下，从 `0000:02000` 至 `0000:02FF` 的 256 个字节的空间所对应的中断向量表都是空的，操作系统和其他应用程序都不占用。前面的课程中使用过（参见 5.7 节）

根据以前的编程经验，可以估计出，do0 的长度不可能超过 256 个字节。结论：可以将 do0 传送到内存 `0000:0200` 处

（4）将中断处理程序 do0 放到 `0000:0200` 后，若要使得除法溢出发生的时候 CPU 转去执行 do0，则必须将 do0 段入口地址 `0000:0200` 登记在中断向量表的对应表项中。因为除法溢出对应的中断类型码为 0，它的中断处理程序的入口地址应该从 0*4 地址单元开始存放，段地址存放在 0*4+2 字单元（`0000:0002`）中，偏移地址存放在 0*4 字单元（`0000:0000`）中。总结上面分析，我们要做一下几件事情

1. 编写可以显示“overflow!”的中断处理程序：do0
2. 将 do0 送入内存 `0000:0200` 处
3. 将 do0 的入口地址 `0000:0200` 存储在中断向量表 0 号表项中

程序框架如下，程序 12.1:
```sh
assume cs:code
code segment
start:
    do0 安装程序
    设置中断向量表
    mov ax,40cch
    int 21h
    
do0:显示字符串“overflow!”
    mov ax,4c00h    ; do0 中最后两条指令是用来返回 DOS 的
    int 21h
code ends
end start
```

上面程序分为两部分：

1. 安装 do0，设置中断向量的程序
2. do0

程序 12.1 执行时，do0 的代码是不执行的，它只是作为 do0 安装程序所要传送的数据。程序 12.1 执行时，首先执行 do0 安装程序，将 do0 的代码复制到内存 0:200 处，然后设置中断向量表，将 do0 的入口地址，即偏移地址 200H 和段地址 0，保存在 0 号表项中。这两部分工作完成后，程序就返回了。do0 是在除法溢出发生的时候才得以执行的中断处理程序。  

do0 变成 0 号中断的中断处理程序的过程：  

1. 程序执行时，被加载到内存中，此时 do0 的代码在程序 12.1 所在的内存空间中，他只是存放在程序的代码段中的一段要被传送到其它单元中的数据，我们不能说它是 0 号中断的中断处理程序  

2. 安装 do0 的代码执行完后，do0 的代码从代码段中复制到 0:200 处，此时，也不能说它是 0 号中断的中断处理程序，它只不过是存放在 0:200 处的一些数据
程序中设置中断向量表的代码执行完后，在 0 号表项中填入了 do0 的入口地址 0:200，此时 0:200 处的信息，即 do0 的代码，就变成了 0 号中断的中断处理程序。因为当除法溢出（即 0 号中断）发生时，CPU 将执行 0:200 处的代码  


回忆一下：

如何让一个内存单元成为栈顶？将它的地址放入 SS、SP 中
如何让一个内存单元中的信息被 CPU 当作执行来执行？将它的地址放入 CS、IP 中
如何让一段程序称为 N 号中断的中断处理程序？将它的入口地址放入中断向量表的 N 号表项中

### 12.10 设置中断向量

下面，将 `do0` 的入口地址 `0:200`，写入中断向量表的 `0` 号表项中，使 `do0` 成为 `0` 号中断的中断处理程序

0 号表项的地址为 `0:0`，其中 `0:0` 字单元存放偏移地址，`0:2` 字单元存放段地址。程序如下：  

```sh
mov ax,0
mov es,ax
mov word ptr es:[0*4],200h
mov word ptr es:[0*4+2],0
```

触发中断后，需要读取中断函数的地址，然后执行中断函数  

### 12.11 单步中断
基本上，`CPU` 在执行完一条指令之后，如果检测到标志寄存器的 `TF` 位为 `1`，则产生单步中断，引发中断过程。

1. 取得中断类型码 `N`
2. 标志寄存器入栈，TF、IF 设置为 0；如果不对 TF 设置为 0，就成为了一个永远不能结束的循环
3. CS、IP 入栈
4. (IP)=(N*4), (CS)=(N*4+2)  


CPU 提供单步中断功能的原因就是，为单步跟踪程序的执行过程，提供了实现机制  

[:books: 返回目录](#目录)  

### 12.12 响应中断的特殊情况

有些情况下，CPU 在执行完当前指令后，即便发生中断，也不会响应。下面用一种情况来进行说明

在执行完向 `ss` 寄存器传送数据的指令后，即便是发生中断，CPU 也不会响应。`ss:sp` 联合指向栈顶，对它们的设置应该是连续完成。否则 `ss` 改变 `sp` 为改变，指向的不是正确的栈顶，将引起错误。

[:books: 返回目录](#目录)  


### 实验 12 编写 0 号中断的处理程序

写 0 号中断的处理程序，使得在除法溢出发生时，在屏幕中间显示字符串`divide error!`，然后返回到 DOS  
要求：要求仔细跟踪调试，在理解整个过程之前，不要进行后面课程的学习。

```sh
assume cs:code  
data segment  
  
data ends  
  
code segment  
start: mov ax,code  
mov ds,ax  
mov si,offset do0       ; 设置源地址  
mov ax,0  
mov es,ax  
mov di,200h             ; 设置目标地址  
  
mov cx,offset do0end-offset do0     ; 设置长度  
  
cld         ; 方向为正  
rep movsb  
  
mov ax,0  
mov ds,ax  
mov word ptr ds:[0*4],200h  
mov word ptr ds:[0*4+2],0  
  
mov ax,1000h  
mov bh,1  
div bh              ; 除法溢出程序  
  
mov ax,4c00h  
int 21h  
  
do0: jmp short do0_start  
db "divide error!"  
do0_start: mov ax,cs  
mov ds,ax  
mov si,202h  
  
mov ax,0b800h  
mov es,ax  
mov di,12*160+36*2  
  
mov cx,13  
s: mov al,ds:[si]  
mov es:[di],al  
inc si  
add di,2  
loop s  
  
mov ax,4c00h  
int 21h  
do0end: nop  
  
code ends  
end start 
```

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-28.png" width="70%"></img>  
</div> 
<br> 


[:books: 返回目录](#目录)  


## 13 int 指令  

### 13.1 int 指令  
int 指令的格式：`int n`，n 为中断码类型，功能是引发中断过程

1. 取得中断类型码 n
2. 标志寄存器入栈，IF=0，TF=0
3. CS、IP入栈
4. `(IP)=(n*4)`, `(CS)=(n*4+2)`；此后转去执行 n 号中断的中断处理程序

例如，下面的程序：
```sh
assume cs:code
code segment
start:
    mov ax,0b800h
    mov es,ax
    mov byte ptr es:[12*160+40*2],'!'
    int 0
code ends
end start
```

程序在 Windows 2000 中的 DOS 方式下执行时，将在屏幕中间显示一个“!”，然后显示`Divide overflow`后返回到系统中。虽然程序没有做除法，但是在结尾使用了int 0指令，执行 0 号`中断处理程序`。

可见，`int` 指令的最终功能和 `call` 指令相似，都是调用一段程序

一般情况下，系统将一些具有一定功能的子程序，以中断处理程序的方式提供给应用程序调用。我们在编程的时候，可以用 `int` 指令调用这些子程序。当然，也可以自己编写一些中断处理程序供别人使用。以后，我们可以将中断处理程序简称为中断例程  


[:books: 返回目录](#目录)  

### 13.3 对 int、iret 和栈的深入理解
问题：用 `7ch` 中断例程完成 `loop` 指令的功能  

`loop s` 的执行需要两个信息，循环次数和到 `s` 的位移，所以 `7ch` 中断例程要完成 `loop` 指令的功能，也需要这两个信息作为参数。我们用 `cx` 存放循环次数，用 `bx` 存放位移。  

应用举例：在屏幕中间显示 80 个`!`  

```sh
assume cs:code
code segment
    start:
        mov ax,0b800h
        mov es,ax
        mov di,160*12
        
        mov bx,offset s-offset se   ; 设置从标号 se 到标号 s 的转移位移
        mov cx,80
    s:  mov byte ptr es:[di],'!'
        add di,2
        int 7ch                     ; 如果 (cx)不等于0，转移到标号 s 处
    se: nop
    
    mov ax,4c00h
    int 21h
code ends
end start
```

在上面的程序中，用 `int 7ch` 调用中断例程进行转移，用 `bx` 传递转移的位移

分析：为了模拟 `loop` 指令，`7ch` 中断例程应具备下面的功能  

1. dec cs
2. 如果 (cs)不等于0，转到标号 s 处执行，否则向下执行  


下面分析一下 7ch 中断例程如何实现到目的地址的转移

（1）转到标号 s 显然应设 (CS)=标号 s 的段地址，(IP)=标号 s 的偏移地址  
（2）那么，中断例程如何取到标号 s 的段地址和偏移地址呢  

`int 7ch` 引发中断过程后，进入中断例程，在中断过程中，当前的标号寄存器、`CS` 和 `IP` 都要压栈，此时压入的 `CS` 和 `IP` 中的内容，分别是调用程序的段地址（可以认为是标号 s 的段地址）和`int 7ch`后一条指令的偏移地址（即标号 se 的偏移地址）

可见，在中断例程中，可以从栈里取得标号 `s` 的段地址和标号 `se` 的偏移地址，而用标号 `se` 的偏移地址加上 bx中存放的转移位移就可以得到标号 `s` 的偏移地址

（3）现在知道，可以从栈中直接和间接地取得标号 `s` 的段地址和偏移地址，那么如何用它们设置 `CS:IP` 呢？  

可以利用 iret 指令，将栈中 se 的偏移地址加上 bx 中的转移位移，则栈中的 se 的偏移地址就变为了 s 的偏移地址。再使用 iret 指令，用栈中的内容设置 CS、IP，从而实现转移到标号 s 处  

7ch 中断例程如下  

```sh
lp: push bp         ; 保护，下面使用了 bp
    mov bp,sp
    dec cx
    jcxz lpret
    add [bp+2],bx
lpret:
    pop bp          ; 恢复
    iret
```

[:books: 返回目录](#目录)  

### 13.4 BIOS 和 DOS 所提供的中断例程

在系统版的 `ROM` 中存放着一套程序，成为 `BIOS`（基本输入输出系统），主要包含以下部分内容：

- 硬件系统的检测和初始化程序  
- 外部中断（第 15章中进行讲解）和内部中断的中断例程  
- 用以对硬件设备进行 I/O 操作的中断例程  
- 其它和硬件系统相关的中断例程  

操作系统 `DOS` 也提供了中断例程，从操作系统的角度来看，DOS 的中断例程就是操作系统向程序员所提供的编程资源

`BIOS` 和 `DOS` 在所提供的中断例程中包含了许多子程序，这些子程序实现了程序员在编程的时候经常需要用到的功能。程序员在编程的时候，可以用 int 指令直接调用 BIOS 和 DOS 通过的中断例程，来完成某些工作  

和硬件设备相关的 `DOS` 中断例程中，一般都调用了 `BIOS` 的中断例程  

> BIOS是什么？BIOS全拼为`BasicInputOutputSystem`,即基本输入/输出系统，是计算机中非常基础而且重要的程序。把这一段程序存放在一个不需要电源的记忆体(芯片)中，就是平时所说的BIOS。它为工业计算机提供`最低级、最直接`的硬件控制，计算机的原始操作都是依照固化在BIOS里的内容来完成的。准确地说,BIOS是硬件与软件程序之间的一个“转换器”或者说是接口，它负责开机时对系统的各项硬件进行初始化设置和测试，以确保系统能够正常工作。用户在使用计算机的过程中，如果硬件不正常则立即停止工作，并把出错的设备信息反馈给用户，  

[:books: 返回目录](#目录)  

### 13.5 BIOS 和 DOS 中断例程的安装过程

1. 开机后，CPU 一加电，初始化 (CS)=0FFFFH, (IP)=0，自动从 FFFF:0 单元开始执行程序。FFFF:0 处有一条跳转指令，CPU 执行该指令后，转去执行 BIOS 中的硬件系统检测和初始化程序  
2. 初始化程序将建立 BIOS 所支持的中断向量，即将 BIOS 提供的中断例程的入口登记在中断向量表中。注意，对于 BIOS 所提供的中断例程，只需要将入口地址登记在中断向量表中即可，因为它们是固化到 ROM 中的程序，一直在内存中存在
3. 硬件系统检测和初始化完成后，调用`int 19h`进行操作系统的引导。从此将计算机交由操作系统控制
4. DOS 启动后，除完成其它工作外，还将它所提供的中断例程装入内存，并建立相应的中断向量


### 13.6 BIOS 中断例程应用

`int 10h`中断例程中包含了多个和屏幕输出的相关子程序

一般来说，一个供程序员调用的中断例程中往往包含多个子程序，中断例程内部用传递进来的参数决定执行哪一个子程序。`BOIS` 和 `DOS` 提供的中断例程，都用 `ah` 来传递内部子程序的编号

下面看一下 `int 10h` 中断例程的设置光标位置功能

```sh
mov ah,2    ; 置光标
mov bh,0    ; 第 0 页
mov dh,5    ; dh 中存放行号
mov dl,12   ; dl 中存放列号
int 10h
```

(ah)=2表示调用 `10h` 号中断例程的 `2` 号子程序，功能为设置光标位置，可以提供光标所在行号（80*25 字符模式下：024）、列号（80*25 字符模式下：079），和页号作为参数。  

`bh` 中页号的含义：内存地址空间中，`B8000H~BFFFFH` 共 32KB 的空间，为 80*25 彩色字符模式的显示缓冲区。一屏的内容在显示缓冲区中共占 `4000` 个字节

显示缓冲区分为 `8` 页，每页 4KB(≈4000B)，显示器可以显示任意一页的内容。一般情况下，显示第 0 页的内容。也就是说通常情况下，`B8000H~B8F9FH` 中的 4000 个字节的内容将出现在显示器上。

在看一下int 10h中断例程的在光标位置显示字符功能
```sh
assume cs:code
code segment
start:
    mov ah,9    ; 在光标位置显示字符
    mov al,'a'  ; 字符
    mov bl,7    ; 颜色属性
    mov bh,0    ; 第 0 页
    mov cx,3    ; 字符重复个数
    int 10h
code ends
end start
```

(ah)=9表示调用第 `10h` 号中断例程的第 `9` 号子程序，功能：在光标位置显示字符，可以提供要显示的字符、颜色属性、页号、字符重复个数作为参数  


### 13.7 DOS 中断例程应用
`int 21h`中断例程是 `DOS` 提供的中断例程，其中包含了 `DOS` 提供给程序员在编程时调用的子程序

我们前面一直使用的是`int 21h`中断例程的`4ch`号功能，即程序返回功能，如下：
```sh
mov ah,4ch  ; 程序返回
mov al,0    ; 返回值
int 21h

; 上面功能我们经常写作
mov ax,4c00h
int 21h
```

我们看一下 `int 21h` 中断例程在光标位置显示字符串的功能：
```sh
ds:ax 指向字符串    ; 要显示的字符串需用“$”作为结束符，提供给 9 号显示字符串的参数
mov ah,9            ; 功能号 9，表示在光标位置显示字符串
int 21h
```

编程：在屏幕的 5 行 12 列显示字符串`Welcome to masm!`  

```sh
assume cs:code
data segment
  db 'Welcome to masm','$'
data ends
code segment
  start:
    mov ah,2    ; 置光标
    mov bh,0    ; 第 0 页
    mov dh,5    ; dh 中放行号
    mov dl,12   ; dl 中放列号
    int 10h

    mov ax,data
    mov ds,ax
    mov dx,0    ; ds:ax 指向字符串的首地址 data:0
    mov ah,9

    int 21h

    mov ax,4c00h
    int 21h
code ends
end start   ; 执行完后会在屏幕的 5 行 12 列显示字符串“Welcome to masm!”，直到遇见“$”（本身并不显示，只起到边界的作用）
```

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-29.png" width="70%"></img>  
</div> 
<br> 


## 14 端口  
在 PC 系统中，和 CPU 通过总线相连的芯片除各种`存储器`外，还有一下 3 中芯片：

- 各种接口卡（比如，网卡、显卡）上的接口芯片，它们控制接口卡进行工作
- 主板上的接口芯片，CPU 通过它们对部分外设进行访问
- 其他芯片，用来存储相关的系统信息，或进行相关的输入输出处理  


这些芯片中，都由一组可以由 CPU 读写的寄存器。这些寄存器，它们在物理上可能处于不同的芯片中，但是它们在一下两点上相同

- 都和 CPU 的总线相连，当然这种连接是通过它们所在的芯片进行的  
- CPU 对它们进行读或写的时候都通过控制线向它们所在的芯片发出端口读写命令  


可见，从 CPU 的角度，将这些寄存器都当作`端口`，对它们进行统一编址，从而建立了一个统一的端口地址空间。每一个端口在地址空间上都有一个地址

CPU 可以直接读写以下 3 个地方的数据

- CPU 内部的寄存器
- 内存单元
- 端口

[:books: 返回目录](#目录)  

### 14.1 端口的读写
在访问端口的时候，CPU 通过`端口地址`来定位端口。因为端口所在的芯片和 CPU 通过总线相连，所以，端口地址和内存地址一样，通过地址总线来传送。在 PC 系统中 CPU 最多可以定位 `64KB` 个不同的端口。则端口的地址范围为：`0~65535`

对端口的读写不能用 `mov`、`push`、`pop` 等内存读写指令。端口的读写指令只有两条：`in` 和 `out`，分别用于从端口读取和往端口写入  

我们看一下 CPU 执行内存访问指令和端口访问指令时，总线上的信息：

（1）访问内存
```sh
mov ax,ds:[8]   ; 假设执行前 (ds)=0
```

执行时于总线相关的操作如下所示：

- CPU 通过地址线将地址信息 8 发出
- CPU 通过控制线发出内存读命令，选中存储器芯片，并通知它，将要从中读取数据
- 存储器将 8 号单元中的数据通过数据线送入 CPU  


（2）访问端口  
```sh
in al,60h   ; 从 60h 号端口读入一个字节
```

执行时于总线相关的操作如下：

- CPU 通过地址线将地址信息 60h 发出
- CPU 通过控制线发出端口读命令，选中端口所在的芯片，并通知它，将要从中读取数据
- 端口所在的芯片将 60h 端口中的数据通过数据线送入 CPU  


注意，在in和out指令中，只能使用 ax 或 al 来存放端口中读入的数据或要发送到端口中的数据。8 位端口使用 al，16 位端口使用 ax  

```sh  
; 对 0~255 以内的端口进行段写时
in al,20h   ; 从 20h 端口读出一个字节到 al
out 20h,al  ; 往 20h 端口写入一个字节

; 对 256~65535 的端口进行读写时，端口号放在 dx 中
mov dx,3f8h
int al,dx   ; 从 308h 端口读出一个字节送入 al
out dx,al   ; 向 308h 端口写入一个字节
```

[:books: 返回目录](#目录)  

### 14.2 CMOS RAM 芯片

PC 机中，有一个 `CMOS RAM` 芯片，一般简称为 `CMOS`。特征如下：

1. 包含一个实时钟和一个有 128 个存储单元的 RAM 存储器（早期计算机为 64 个字节）
2. 该芯片靠电池供电。所以，关机后其内部的实时钟扔可正常工作，RAM 中的信息不丢失
3. 128 个字节的 RAM 中，内部实时钟占用 `0~0dh` 单元来保存时间信息，其余大部分单元用于保存配置信息，供系统启动时 `BIOS` 程序读取。`BIOS` 也提供了相关的程序，使我们可以在开机的时候配置 `CMOS RAM` 中的系统信息
4. 该芯片内部有两个端口，端口地址为 `70h` 和 `71h`。CPU 通过这两个端口来读写 `CMOS RAM`
5. `70h` 为地址端口，存放要访问的 `CMOS RAM` 单元的地址；`71h` 为数据端口，存放从选定的 `CMOS RAM` 单元中读取的数据，或要写入到其中段数据。可见，CPU 对 CMOS RAM 的读写分两步进行，比如，读 2 号单元：  
    - 1. 将 `2` 送入端口 `70h`  
    - 2. 从端口 71h 读出 2号单元的内容  

检测点 14.1
（1）编程，读取 CMOS RAM 的 2 号单元的内容

```sh
mov al,2
out 70h,al
in al,71h
```

（2）编程，向 CMOS RAM 的 2 号单元写入 0
```sh
mov al,2
out 70h,al
mov al,0
out 71h,al
```

wiki:  
互补式金属氧化物半导体（英语：Complementary Metal-Oxide-Semiconductor，缩写作 CMOS；简称互补式金氧半导体），是一种集成电路的设计工艺，可以在硅质晶圆模板上制出NMOS（n-type MOSFET）和PMOS（p-type MOSFET）的基本器件，由于NMOS与PMOS在物理特性上为互补性，因此被称为CMOS。此一般的工艺上，可用来制作电脑电器的`静态随机存取内存`、`微控制器`、`微处理器`与其他`数字逻辑电路系统`、以及除此之外，经过一些不同的加工处理后，可以实现比较特别的技术特性，使它可以用于光学仪器上，例如互补式金氧半图像传感装置在一些高级数码相机中变得很常见，反而使得CMOS现在主要是感光器件的代名词。  

[:books: 返回目录](#目录)  

### 14.3 shl 和 shr 指令
`shl` 和 `shr` 是逻辑移位指令。Shift Logical Left | Rifht

`shl` 是逻辑左移指令，它的功能为：

1. 将一个寄存器或内存单元中的数据向左移位
2. 将最后移出的一位写入 CF 中
3. 最低为用 0 补充  

```sh
mov al,01001000b
shl al,1        ; 将 al 中的数据左移一位
; 执行后 (al)=10010000b  CF=0
```

[:books: 返回目录](#目录)  


## 15 外中断  

CPU 除了有运算能力外，还要有 I/O 能力。  

### 15.1 接口芯片和端口
CPU 通过端口和外部设备进行联系

### 15.2 外中断信息
当 CPU 外部有需要处理的事情发生的时候，比如说，外设的输入到达，相关芯片将向 CPU 发出相应的中断信息。CPU 在执行完当前指令后，可以检测到发送过来的中断信息，引发中断过程，处理外设的输入。外中断源一共有以下两类

- **可屏蔽中断**  
CPU 可以不响应的外中断。当检测到可屏蔽中断信息时，如果 IF=1，则 执行完当前指令后响应中断，引发中断过程，如果 IF=0，则不响应可屏蔽中断。

内中断的过程：  

1. 去中断类型码 n
2. 标志寄存器入栈，IF=0，TF=0
3. CS、IP 入栈
4. (IP)=(n*4), (CS)=(n*4+2)  


可屏蔽中断所引发的中断过程，除第 1 步的实现上有所不同外，基本和内中断的中断过程一致。因为可屏蔽中断信息来自有 CPU 外部，中断类型码是通过数据总线送入的；而内中断的类型码是在内部产生的

中断过程中将 `IF` 置为 `0` 的原因是：在进入中断处理程序后，禁止其它的可屏蔽中断

如果在中断处理程序中需要处理可屏蔽中断，可以用指令将 `IF` 置为 `1`。8086CPU 提供的设置 IF 的指令如下：

- sti，设置 IF=1
- cli，设置 IF=0  

----

- **不可屏蔽中断**  

CPU 必须响应的外中断。当检测到不可屏蔽中断信息时，则在执行完当前指令后，立即响应，引发中断过程。

对于 8086CPU，不可屏蔽中断的中断类型码固定为 `2`，所以中断过程中，不需要取中断类型码。则不可屏蔽中断的中断过程为：

1. 标志寄存器入栈，IF=0，TF=0
2. CS、IP 入栈
3. (IP)=(8)，(CS)=(0ah)  


几乎所有由外设引发的外中断，都是可屏蔽中断。

[:books: 返回目录](#目录)  

### 15.3 PC 机键盘的处理过程

#### 1. 键盘输入  

键盘上的每一个键都相当于一个开关，键盘中有一个芯片对键盘上的每一个键的开关状态进行扫描

按下一个键时，开关接通，该芯片就产生一个`扫描码`，扫描码说明了按下的键在键盘中的位置。扫描码被送入主板上的相关接口芯片的寄存器中，该寄存器的端口地址为 `60h`。

松开按下的键时，也产生一个扫描码，扫描码说明了松开的键在键盘中的位置。松开按键时产生的扫描码也被送入 `60h` 端口中。

按下键时产生的扫描码被称为通码，松开键产生的扫描码被称为断码。扫描码长度为一个字节，通码的第 `7` 位是 `0`，断码的第 `7` 位是 `1`。即：断码=通码+80h。

表 15.1 是键盘上部分键的扫描码，只列出通码  

<br>
<div align=center>
    <img src="../../res/image/asm/asm-learn-30.png" width="70%"></img>  
</div> 
<br> 

#### 2. 引发 9 号中断  

键盘的输入到达 60h 端口时，相关的芯片就会向 CPU 发出中断类型码为 9 的可屏蔽中断信息。CPU 检测到该中断信息后，如果 IF=1，则响应中断，引发中断过程，转去执行int 9中断例程

#### 3. 执行 int 9 中断例程  

BIOS 提供了 `int 9` 中断例程，用来进行基本的键盘输入处理，主要工作如下：

1. 读出 60h 端口中的扫描码
2. 分为两种情况  
    - 1. 如果是字符键的扫描码，将该扫描码和它所对应的字符码（ASCII码）送入内存中的 BIOS 键盘缓冲区
    - 2. 如果是控制键（比如 Ctrl）和切换键（比如 CapsLock）的扫描码，则将其转变为状态字节（用二进制记录控制键和切换键状态的字节）写入内存中存储状态字节的单元
3. 对键盘系统进行相关的控制，比如说，向相关芯片发出应答信息
BIOS 键盘缓冲区是系统启动后，用于存放int 9中断例程所接收的键盘输入的内存区。该内存区可以存储 15 个键盘输入，因为int 9中断例程除了接收扫描码外，还要产生和扫描码对应的字符码，所以在键盘缓冲区中，一个键盘输入用一个字单元存放，高位字节存放扫描码，低位字节存放字符码  

`0040:17`单元存储键盘状态字节，该字节记录了控制键和切换键的状态。键盘状态字节各位记录的信息如下：

- 0: 右 Shift 状态，置 1 表示按下
- 1: 左 Shift 状态，置 1 表示按下
- 2: Ctrl 状态，置 1 表示按下
- 3: Alt 状态，置 1 表示按下
- 4: ScrollLock 状态，置 1 表示 Scroll 指示灯亮
- 5: NumLock 状态，置 1 表示小键盘输入的是数字
- 6: CapsLock 状态，置 1 表示输入大写字母
- 7: Insert 状态，值 1 表示处于删除态


## 16 直接定址表  
> 如何有效的组织数据，以及相关的编程技术    



[:books: 返回目录](#目录)  

## 17 使用BIOS进行键盘输入和磁盘读写  

`键盘`输入是最基本的输入，`磁盘`是最常用的存储设为。`BIOS` 为这两种外设的 `I/O` 提供了最基本的中断例程

[:books: 返回目录](#目录)  























