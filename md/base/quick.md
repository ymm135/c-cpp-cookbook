- # 知识速览
- ### [Learning-C demo实例](https://github.com/h0mbre/Learning-C)  
## 目录
- [helloworld](#helloworld)
- [变量声明](#变量声明)
- [输入与输出](#输入与输出)
  - [简易模式](#简易模式)
  - [重定向](#重定向)
  - [拓展模式](#拓展模式)
- [宏定义](#宏定义)


## helloworld
```c
#include <stdio.h>

int main(void)
{
  printf("Hello, World!\n");
  return 0;
}

```
[:books: 返回目录](#目录)
## 变量声明
```c
#include <stdio.h>

int main(void)
{
  int integer = 5;
  float floatvar = 3.14;
  char string[] = "Hello, World!";

  printf("%d is an integer!\n", integer);
  printf("%f is a float!\n", floatvar);
  printf("%s is a char!\n", string);

}
```

输出
```sh
5 is an integer!
3.140000 is a float!
Hello, World! is a char!
```
[:books: 返回目录](#目录)
## 输入与输出
### 简易模式  
固定长度的数组  

```c
#include <stdio.h>

int main(void)
{
  //initialize vars
  char first[20];
  char last[20];

  //prompt user to input first and last name and use scanf() to store those to the initiliazed vars
  printf("Enter your first name: ");
  scanf("%s", &first);
  printf("Enter your last name: ");
  scanf("%s", &last);

  //print the welcome message!
  printf("Hello %s %s!\n", first, last);
}
```

缓冲区溢出的问题:  

<br>
<div align=center>
    <img src="../../res/image/in-out-1.png" width="80%"></img>  
</div>
<br>

### 重定向  
`重定向`(relocations), 简单来说就是二进制文件中留下的"坑", 预留给外部变量或函数.  
这里的变量和函数统称为`符号`(symbols). 在编译期我们通常只知道外部符号的类型
(变量类型和函数原型), 而不需要知道具体的值(变量值和函数实现). 而这些预留的"坑",
会在用到之前(链接期间或者运行期间)填上. 在链接期间填上主要通过工具链中的连接器,
比如GNU链接器`ld`; 在运行期间填上则通过动态连接器, 或者说解释器(interpreter)来实现.  

首先查看一下动态符号表`objdump -T main`  
```sh
objdump -T main

main:     file format elf64-x86-64

DYNAMIC SYMBOL TABLE:
0000000000000000  w   D  *UND*	0000000000000000              _ITM_deregisterTMCloneTable
0000000000000000      DF *UND*	0000000000000000  GLIBC_2.4   __stack_chk_fail
0000000000000000      DF *UND*	0000000000000000  GLIBC_2.2.5 printf
0000000000000000      DF *UND*	0000000000000000  GLIBC_2.2.5 __libc_start_main
0000000000000000  w   D  *UND*	0000000000000000              __gmon_start__
0000000000000000      DF *UND*	0000000000000000  GLIBC_2.7   __isoc99_scanf
0000000000000000  w   D  *UND*	0000000000000000              _ITM_registerTMCloneTable
0000000000000000  w   DF *UND*	0000000000000000  GLIBC_2.2.5 __cxa_finalize
```

查看一下plt表  
```sh
$ objdump -M intel -d -j .plt main

main:     file format elf64-x86-64


Disassembly of section .plt:

0000000000001020 <.plt>:
    1020:	ff 35 8a 2f 00 00    	push   QWORD PTR [rip+0x2f8a]        # 3fb0 <_GLOBAL_OFFSET_TABLE_+0x8>
    1026:	f2 ff 25 8b 2f 00 00 	bnd jmp QWORD PTR [rip+0x2f8b]        # 3fb8 <_GLOBAL_OFFSET_TABLE_+0x10>
    102d:	0f 1f 00             	nop    DWORD PTR [rax]
    1030:	f3 0f 1e fa          	endbr64 
    1034:	68 00 00 00 00       	push   0x0
    1039:	f2 e9 e1 ff ff ff    	bnd jmp 1020 <.plt>
    103f:	90                   	nop
    1040:	f3 0f 1e fa          	endbr64 
    1044:	68 01 00 00 00       	push   0x1
    1049:	f2 e9 d1 ff ff ff    	bnd jmp 1020 <.plt>
    104f:	90                   	nop
    1050:	f3 0f 1e fa          	endbr64 
    1054:	68 02 00 00 00       	push   0x2
    1059:	f2 e9 c1 ff ff ff    	bnd jmp 1020 <.plt>
    105f:	90                   	nop
```

查看汇编`-exec disassemble /m`
```sh
5	  //initialize vars
6	  char first[20];
7	  char last[20];
8	
9	  //prompt user to input first and last name and use scanf() to store those to the initiliazed vars
10	  printf("Enter your first name: ");
=> 0x00005555555551a4 <+27>:	lea    rdi,[rip+0xe59]        # 0x555555556004
   0x00005555555551ab <+34>:	mov    eax,0x0
   0x00005555555551b0 <+39>:	call   0x555555555080 <printf@plt>

11	  scanf("%s", &first);
   0x00005555555551b5 <+44>:	lea    rax,[rbp-0x40]         # Load Effective Address 声明变量first
   0x00005555555551b9 <+48>:	mov    rsi,rax                # Move
   0x00005555555551bc <+51>:	lea    rdi,[rip+0xe59]        # 0x55555555601c 
   0x00005555555551c3 <+58>:	mov    eax,0x0
   0x00005555555551c8 <+63>:	call   0x555555555090 <__isoc99_scanf@plt>  # Call Procedure
```

查看地址内容`0x555555555090 <__isoc99_scanf@plt>`
```sh
-exec disas 0x555555555090
Dump of assembler code for function __isoc99_scanf@plt:
   0x0000555555555090 <+0>:	endbr64 
   0x0000555555555094 <+4>:	bnd jmp QWORD PTR [rip+0x2f35]        # 0x555555557fd0 <__isoc99_scanf@got.plt>    # jmp 无条件跳转
   0x000055555555509b <+11>:	nop    DWORD PTR [rax+rax*1+0x0]
End of assembler dump.
```

查看`0x555555557fd0 <__isoc99_scanf@got.plt>`
```
-exec disas 0x555555557fd0
Dump of assembler code for function __isoc99_scanf@got.plt:
   0x0000555555557fd0 <+0>:	mov    al,0x20
   0x0000555555557fd2 <+2>:	jrcxz  0x555555557fcb <printf@got.plt+3>        # RCX=0 跳转
   0x0000555555557fd4 <+4>:	(bad)  
   0x0000555555557fd5 <+5>:	jg     0x555555557fd7 <__isoc99_scanf@got.plt+7> # 大于跳转  
   0x0000555555557fd7 <+7>:	add    BYTE PTR [rax],al
End of assembler dump.
```

查看`0x555555557fd7 <__isoc99_scanf@got.plt+7>`  
```sh
-exec disas 0x555555557fd7
Dump of assembler code for function __isoc99_scanf@got.plt:
   0x0000555555557fd0 <+0>:	mov    al,0x20
   0x0000555555557fd2 <+2>:	jrcxz  0x555555557fcb <printf@got.plt+3>
   0x0000555555557fd4 <+4>:	(bad)  
   0x0000555555557fd5 <+5>:	jg     0x555555557fd7 <__isoc99_scanf@got.plt+7>
   0x0000555555557fd7 <+7>:	add    BYTE PTR [rax],al
End of assembler dump.
```

在其中没有看到got指向最终glibc中scanf的实现。但是可以通过objdump 反汇编查看`objdump -d  main`
```sh
0000000000001189 <main>:
    11c3:   b8 00 00 00 00          mov    $0x0,%eax
    11c8:   e8 c3 fe ff ff          callq  1090 <__isoc99_scanf@plt>

0000000000001090 <__isoc99_scanf@plt>:
    1090:   f3 0f 1e fa             endbr64 
    1094:   f2 ff 25 35 2f 00 00    bnd jmpq *0x2f35(%rip)        # 3fd0 <__isoc99_scanf@GLIBC_2.7>
    109b:   0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
```

`objdump`查看一下got表  
```sh
Sections:
Idx Name          Size      VMA               LMA               File off  Algn
 12 .plt          00000040  0000000000001020  0000000000001020  00001020  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 13 .plt.got      00000010  0000000000001060  0000000000001060  00001060  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 14 .plt.sec      00000030  0000000000001070  0000000000001070  00001070  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 22 .dynamic      000001f0  0000000000003db8  0000000000003db8  00002db8  2**3
                  CONTENTS, ALLOC, LOAD, DATA
 23 .got          00000058  0000000000003fa8  0000000000003fa8  00002fa8  2**3
                  CONTENTS, ALLOC, LOAD, DATA
 24 .data         00000010  0000000000004000  0000000000004000  00003000  2**3
                  CONTENTS, ALLOC, LOAD, DATA
```

查看.got的内容`objdump -M intel -d -j .got main`
```sh
objdump -M intel -d -j .got main

main:     file format elf64-x86-64


Disassembly of section .got:

0000000000003fa8 <_GLOBAL_OFFSET_TABLE_>:
    3fa8:	b8 3d 00 00 00 00 00 00 00 00 00 00 00 00 00 00     .=..............
	...
    3fc0:	30 10 00 00 00 00 00 00 40 10 00 00 00 00 00 00     0.......@.......
    3fd0:	50 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00     P...............
	...
```

`-exec disass __isoc99_scanf`
```sh
-exec disass __isoc99_scanf
Dump of assembler code for function __isoc99_scanf:
   0x00007ffff7e320b0 <+0>:	endbr64 
   0x00007ffff7e320b4 <+4>:	sub    rsp,0xd8
   0x00007ffff7e320bb <+11>:	mov    r10,rdi
   0x00007ffff7e320be <+14>:	mov    QWORD PTR [rsp+0x28],rsi
   0x00007ffff7e320c3 <+19>:	mov    QWORD PTR [rsp+0x30],rdx
   0x00007ffff7e320c8 <+24>:	mov    QWORD PTR [rsp+0x38],rcx
   0x00007ffff7e320cd <+29>:	mov    QWORD PTR [rsp+0x40],r8
   0x00007ffff7e320d2 <+34>:	mov    QWORD PTR [rsp+0x48],r9
   0x00007ffff7e320d7 <+39>:	test   al,al
   0x00007ffff7e320d9 <+41>:	je     0x7ffff7e32112 <__isoc99_scanf+98>
```
`__isoc99_scanf`地址为:`0x00007ffff7e320b0`  


目前发现call调用时，调用流程是`call scanf —> scanf的plt表 —>scanf的got表`  

我们就把获取数据段存放函数地址的那一小段代码称为`PLT（Procedure Linkage Table）`过程链接表存放函数地址的数据段称为`GOT（Global Offset Table）`全局偏移表。  

再次查看`0x555555557fd0 <__isoc99_scanf@plt>`
```sh
-exec x/32x 0x555555557fd0
0x555555557fd0 <__isoc99_scanf@got.plt>:	0xb0	0x20	0xe3	0xf7	0xff	0x7f	0x00	0x00
0x555555557fd8:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
0x555555557fe0:	0x90	0x2f	0xdf	0xf7	0xff	0x7f	0x00	0x00
0x555555557fe8:	0x00	0x00	0x00	0x00	0x00	0x00	0x00	0x00
-exec x/32i 0x555555557fd0
   0x555555557fd0 <__isoc99_scanf@got.plt>:	mov    al,0x20
   0x555555557fd2 <__isoc99_scanf@got.plt+2>:	jrcxz  0x555555557fcb <printf@got.plt+3>
   0x555555557fd4 <__isoc99_scanf@got.plt+4>:	(bad)  
   0x555555557fd5 <__isoc99_scanf@got.plt+5>:	jg     0x555555557fd7 <__isoc99_scanf@got.plt+7>
   0x555555557fd7 <__isoc99_scanf@got.plt+7>:	add    BYTE PTR [rax],al
```
[参考文章](https://www.jianshu.com/p/0ac63c3744dd)  

运行后加载动态库，把动态库中的相应函数地址填入GOT表，由于PLT表是跳转到GOT表的，这就构成了运行时重定位

也就是说在函数第一次调用时，才通过连接器动态解析并加载到`.got.plt`中，而这个过程称之为延时加载或者惰性加载。

到这里，也要接近尾声了，当第二次调用同一个函数的时候，就不会与第一次一样那么麻烦了，因为`got[n]`中已经有了真实地址，直接jmp该地址即可。  

<br>
<div align=center>
    <img src="../../res/image/got-plt.jpg" width="70%"></img>  
</div>
<br>

[:books: 返回目录](#目录)

### 拓展模式
根据用户输入的长度动态分配 char 变量的数组大小。  
```c
#include <stdio.h>
#include <stdlib.h>

int main(void)
{
  //initialize vars
  char *first;
  char *last;

  //prompt user to input first and last name and use scanf() to store those to the initiliazed vars
  printf("Enter your first name: ");
  scanf("%ms", &first);
  printf("Enter your last name: ");
  scanf("%ms", &last);

  //print the welcome message!
  printf("Hello %s %s!\n", first, last);

  free(first);
  free(last);
}
```

汇编指令
```sh
6	  //initialize vars
7	  char *first;
8	  char *last;
9	
10	  //prompt user to input first and last name and use scanf() to store those to the initiliazed vars
11	  printf("Enter your first name: ");
=> 0x00005555555551c4 <+27>:	lea    rdi,[rip+0xe39]        # 0x555555556004
   0x00005555555551cb <+34>:	mov    eax,0x0
   0x00005555555551d0 <+39>:	call   0x5555555550a0 <printf@plt>

12	  scanf("%ms", &first);
   0x00005555555551d5 <+44>:	lea    rax,[rbp-0x18]
   0x00005555555551d9 <+48>:	mov    rsi,rax
   0x00005555555551dc <+51>:	lea    rdi,[rip+0xe39]        # 0x55555555601c
   0x00005555555551e3 <+58>:	mov    eax,0x0
   0x00005555555551e8 <+63>:	call   0x5555555550b0 <__isoc99_scanf@plt>

19	  free(first);
   0x0000555555555232 <+137>:	mov    rax,QWORD PTR [rbp-0x18]
   0x0000555555555236 <+141>:	mov    rdi,rax
   0x0000555555555239 <+144>:	call   0x555555555080 <free@plt>
```

查看`0x5555555550b0 <__isoc99_scanf@plt>`
```sh
-exec disas 0x5555555550b0
Dump of assembler code for function __isoc99_scanf@plt:
   0x00005555555550b0 <+0>:	endbr64 
   0x00005555555550b4 <+4>:	bnd jmp QWORD PTR [rip+0x2f15]        # 0x555555557fd0 <__isoc99_scanf@got.plt>
   0x00005555555550bb <+11>:	nop    DWORD PTR [rax+rax*1+0x0]
End of assembler dump.
```

查看具体函数实现`disas __isoc99_scanf`  
```sh
-exec disas __isoc99_scanf
Dump of assembler code for function __isoc99_scanf:
   0x00007ffff7e320b0 <+0>:   endbr64 
   0x00007ffff7e320b4 <+4>:   sub    rsp,0xd8
   0x00007ffff7e320bb <+11>:  mov    r10,rdi
   0x00007ffff7e320be <+14>:  mov    QWORD PTR [rsp+0x28],rsi
   0x00007ffff7e320c3 <+19>:  mov    QWORD PTR [rsp+0x30],rdx
   0x00007ffff7e320c8 <+24>:  mov    QWORD PTR [rsp+0x38],rcx
   0x00007ffff7e320cd <+29>:  mov    QWORD PTR [rsp+0x40],r8
   0x00007ffff7e320d2 <+34>:  mov    QWORD PTR [rsp+0x48],r9
   0x00007ffff7e320d7 <+39>:  test   al,al
   0x00007ffff7e320d9 <+41>:  je     0x7ffff7e32112 <__isoc99_scanf+98>
   0x00007ffff7e320db <+43>:  movaps XMMWORD PTR [rsp+0x50],xmm0
   0x00007ffff7e320e0 <+48>:  movaps XMMWORD PTR [rsp+0x60],xmm1
   0x00007ffff7e320e5 <+53>:  movaps XMMWORD PTR [rsp+0x70],xmm2
   0x00007ffff7e320ea <+58>:  movaps XMMWORD PTR [rsp+0x80],xmm3
   0x00007ffff7e320f2 <+66>:  movaps XMMWORD PTR [rsp+0x90],xmm4
   0x00007ffff7e320fa <+74>:  movaps XMMWORD PTR [rsp+0xa0],xmm5
   0x00007ffff7e32102 <+82>:  movaps XMMWORD PTR [rsp+0xb0],xmm6
   0x00007ffff7e3210a <+90>:  movaps XMMWORD PTR [rsp+0xc0],xmm7
   0x00007ffff7e32112 <+98>:  mov    rax,QWORD PTR fs:0x28
   0x00007ffff7e3211b <+107>: mov    QWORD PTR [rsp+0x18],rax
   0x00007ffff7e32120 <+112>: xor    eax,eax
   0x00007ffff7e32122 <+114>: lea    rax,[rsp+0xe0]
   0x00007ffff7e3212a <+122>: mov    rdx,rsp
   0x00007ffff7e3212d <+125>: mov    rsi,r10
   0x00007ffff7e32130 <+128>: mov    QWORD PTR [rsp+0x8],rax
   0x00007ffff7e32135 <+133>: lea    rax,[rsp+0x20]
   0x00007ffff7e3213a <+138>: mov    ecx,0x2
   0x00007ffff7e3213f <+143>: mov    QWORD PTR [rsp+0x10],rax
   0x00007ffff7e32144 <+148>: mov    rax,QWORD PTR [rip+0x188e75]        # 0x7ffff7fbafc0
   0x00007ffff7e3214b <+155>: mov    DWORD PTR [rsp],0x8
   0x00007ffff7e32152 <+162>: mov    rdi,QWORD PTR [rax]
   0x00007ffff7e32155 <+165>: mov    DWORD PTR [rsp+0x4],0x30
   0x00007ffff7e3215d <+173>: call   0x7ffff7e32a00 <__vfscanf_internal>
   0x00007ffff7e32162 <+178>: mov    rcx,QWORD PTR [rsp+0x18]
   0x00007ffff7e32167 <+183>: xor    rcx,QWORD PTR fs:0x28
   0x00007ffff7e32170 <+192>: jne    0x7ffff7e3217a <__isoc99_scanf+202>
   0x00007ffff7e32172 <+194>: add    rsp,0xd8
   0x00007ffff7e32179 <+201>: ret    
   0x00007ffff7e3217a <+202>: call   0x7ffff7efea70 <__stack_chk_fail>
End of assembler dump.
```

[:books: 返回目录](#目录)

## 宏定义

```c
#include <stdio.h>
//define a value for PIE
#define PIE 3.14

int main(void)
{
  //initialize variable
  float radius;

  //get user input and store it
  printf("Enter the radius of your circle: ");
  scanf("%f", &radius);

  //do the maths
  float area;
  area = PIE * (radius * radius);

  printf("The area of your circle is %f", area);
}
```

查看预处理结果`gcc -E main.c -o main.i`, 查看`main.i`中main函数的信息  
```sh
# 5 "main.c"
int main(void)
{

  float radius;


  printf("Enter the radius of your circle: ");
  scanf("%f", &radius);


  float area;
  area = 3.14 * (radius * radius);

  printf("The area of your circle is %f", area);
}
```

另外还有一种方式:修改编译参数为`-g3`, 使用`macro exp`指令查看  
```sh
-exec macro exp PIE
expands to: 3.14
```

反汇编结果
```sh
7    //initialize variable
8    float radius;
9  
10   //get user input and store it
11   printf("Enter the radius of your circle: ");
   0x00005555555551a4 <+27>:  lea    rdi,[rip+0xe5d]        # 0x555555556008
   0x00005555555551ab <+34>:  mov    eax,0x0
   0x00005555555551b0 <+39>:  call   0x555555555080 <printf@plt>

12   scanf("%f", &radius);
=> 0x00005555555551b5 <+44>:  lea    rax,[rbp-0x10]         # radius 变量栈地址
   0x00005555555551b9 <+48>:  mov    rsi,rax
   0x00005555555551bc <+51>:  lea    rdi,[rip+0xe67]        # 0x55555555602a  %f
   0x00005555555551c3 <+58>:  mov    eax,0x0
   0x00005555555551c8 <+63>:  call   0x555555555090 <__isoc99_scanf@plt>

13 
14   //do the maths
15   float area;
16   area = PIE * (radius * radius);
   0x00005555555551cd <+68>:  movss  xmm1,DWORD PTR [rbp-0x10]
   0x00005555555551d2 <+73>:  movss  xmm0,DWORD PTR [rbp-0x10]
   0x00005555555551d7 <+78>:  mulss  xmm0,xmm1
   0x00005555555551db <+82>:  cvtss2sd xmm1,xmm0
   0x00005555555551df <+86>:  movsd  xmm0,QWORD PTR [rip+0xe69]        # 0x555555556050
   0x00005555555551e7 <+94>:  mulsd  xmm0,xmm1
   0x00005555555551eb <+98>:  cvtsd2ss xmm0,xmm0
   0x00005555555551ef <+102>: movss  DWORD PTR [rbp-0xc],xmm0

```

变量还是需要初始化的，不然就是位置数据
```sh
-exec p area
$1 = 4.59163468e-41
```

查看寄存器`rip`内容  
```sh
-exec i registers
rip            0x5555555551df      0x5555555551df <main+86>
```

## 运算符  
```c
#include <stdio.h>


int main(void)
{
  //initialize var
  float seconds;
  
  //get value for var
  printf("Enter the amount of seconds: ");
  scanf("%f", &seconds);

  //initialize our arithmetic vars
  float hours;
  float mins;
  float remaining_seconds;

  //make sure the hours value is a whole number that doesn't consider the decimal by using the (int) operation. 
  //for instance, 1.2 hours will be stored in hours as 1.0 here
  hours = (int)(seconds / 3600);
  
  //repeat for mins
  mins = (int)((seconds - (hours * 3600))/60);
  
  //remaining_seconds is simply what's leftover
  remaining_seconds = (seconds - (hours * 3600) - (mins * 60));
  printf("%0.0f seconds is equal to %0.0f hours, %0.0f minutes, and %0.0f seconds.", seconds, hours, mins, remaining_seconds);

  return 0;
}
```

反汇编结果
```sh

6   //initialize var
7   float seconds;
8   
9   //get value for var
10    printf("Enter the amount of seconds: ");
   0x00005555555551a4 <+27>:  lea    rdi,[rip+0xe5d]        # 0x555555556008
   0x00005555555551ab <+34>:  mov    eax,0x0
   0x00005555555551b0 <+39>:  call   0x555555555080 <printf@plt>

11    scanf("%f", &seconds);
   0x00005555555551b5 <+44>:  lea    rax,[rbp-0x18]
   0x00005555555551b9 <+48>:  mov    rsi,rax
   0x00005555555551bc <+51>:  lea    rdi,[rip+0xe63]        # 0x555555556026
   0x00005555555551c3 <+58>:  mov    eax,0x0
   0x00005555555551c8 <+63>:  call   0x555555555090 <__isoc99_scanf@plt>

12  
13    //initialize our arithmetic vars
14    float hours;
15    float mins;
16    float remaining_seconds;
17  
18    //make sure the hours value is a whole number that doesn't consider the decimal by using the (int) operation. 
19    //for instance, 1.2 hours will be stored in hours as 1.0 here
20    hours = (int)(seconds / 3600);
=> 0x00005555555551cd <+68>:  movss  xmm0,DWORD PTR [rbp-0x18]
   0x00005555555551d2 <+73>:  movss  xmm1,DWORD PTR [rip+0xea2]        # 0x55555555607c
   0x00005555555551da <+81>:  divss  xmm0,xmm1
   0x00005555555551de <+85>:  cvttss2si eax,xmm0
   0x00005555555551e2 <+89>:  cvtsi2ss xmm0,eax
   0x00005555555551e6 <+93>:  movss  DWORD PTR [rbp-0x14],xmm0

21    
22    //repeat for mins
23    mins = (int)((seconds - (hours * 3600))/60);
   0x00005555555551eb <+98>:  movss  xmm0,DWORD PTR [rbp-0x18]
   0x00005555555551f0 <+103>: movss  xmm2,DWORD PTR [rbp-0x14]
   0x00005555555551f5 <+108>: movss  xmm1,DWORD PTR [rip+0xe7f]        # 0x55555555607c
   0x00005555555551fd <+116>: mulss  xmm1,xmm2
   0x0000555555555201 <+120>: subss  xmm0,xmm1
   0x0000555555555205 <+124>: movss  xmm1,DWORD PTR [rip+0xe73]        # 0x555555556080
   0x000055555555520d <+132>: divss  xmm0,xmm1
   0x0000555555555211 <+136>: cvttss2si eax,xmm0
   0x0000555555555215 <+140>: cvtsi2ss xmm0,eax
   0x0000555555555219 <+144>: movss  DWORD PTR [rbp-0x10],xmm0

24    
25    //remaining_seconds is simply what's leftover
26    remaining_seconds = (seconds - (hours * 3600) - (mins * 60));
   0x000055555555521e <+149>: movss  xmm0,DWORD PTR [rbp-0x18]
   0x0000555555555223 <+154>: movss  xmm2,DWORD PTR [rbp-0x14]
   0x0000555555555228 <+159>: movss  xmm1,DWORD PTR [rip+0xe4c]        # 0x55555555607c
   0x0000555555555230 <+167>: mulss  xmm1,xmm2
   0x0000555555555234 <+171>: subss  xmm0,xmm1
   0x0000555555555238 <+175>: movss  xmm2,DWORD PTR [rbp-0x10]
   0x000055555555523d <+180>: movss  xmm1,DWORD PTR [rip+0xe3b]        # 0x555555556080
   0x0000555555555245 <+188>: mulss  xmm1,xmm2
   0x0000555555555249 <+192>: subss  xmm0,xmm1
   0x000055555555524d <+196>: movss  DWORD PTR [rbp-0xc],xmm0
```

## 条件语句`if`  

```c
#include <stdio.h>

int main(void)
{
  
  //initialize our vars and get values for them
  int numerator, denominator;
  printf("Enter a numerator: ");
  scanf("%d", &numerator);
  printf("Enter a denominator: ");
  scanf("%d", &denominator);

  if (numerator % denominator == 0)
  {
  	printf("There is NOT a remainder!");
  }
  else
  {
  	printf("There is a remainder!");
  }

  return 0;
}

```
32位CPU所含有的寄存器有：  
8个32位通用寄存器：  
4个数据寄存器(EAX、EBX、ECX和EDX)  
2个变址和指针寄存器(ESI和EDI) 2个指针寄存器(ESP和EBP)  
6个段寄存器(ES、CS、SS、DS、FS和GS)  
1个指令指针寄存器(EIP)  
1个标志寄存器(EFlags)  


反汇编结果
```sh
6   
7   //initialize our vars and get values for them
8   int numerator, denominator;
9   printf("Enter a numerator: ");
   0x00005555555551a4 <+27>:  lea    rdi,[rip+0xe59]        # 0x555555556004
   0x00005555555551ab <+34>:  mov    eax,0x0
   0x00005555555551b0 <+39>:  call   0x555555555080 <printf@plt>

10    scanf("%d", &numerator);
   0x00005555555551b5 <+44>:  lea    rax,[rbp-0x10]
   0x00005555555551b9 <+48>:  mov    rsi,rax
   0x00005555555551bc <+51>:  lea    rdi,[rip+0xe55]        # 0x555555556018
   0x00005555555551c3 <+58>:  mov    eax,0x0
   0x00005555555551c8 <+63>:  call   0x555555555090 <__isoc99_scanf@plt>

11    printf("Enter a denominator: ");
   0x00005555555551cd <+68>:  lea    rdi,[rip+0xe47]        # 0x55555555601b
   0x00005555555551d4 <+75>:  mov    eax,0x0
   0x00005555555551d9 <+80>:  call   0x555555555080 <printf@plt>

12    scanf("%d", &denominator);
   0x00005555555551de <+85>:  lea    rax,[rbp-0xc]
   0x00005555555551e2 <+89>:  mov    rsi,rax
   0x00005555555551e5 <+92>:  lea    rdi,[rip+0xe2c]        # 0x555555556018
   0x00005555555551ec <+99>:  mov    eax,0x0
   0x00005555555551f1 <+104>: call   0x555555555090 <__isoc99_scanf@plt>

13  
14    if (numerator % denominator == 0)
=> 0x00005555555551f6 <+109>: mov    eax,DWORD PTR [rbp-0x10]       # numerator
   0x00005555555551f9 <+112>: mov    ecx,DWORD PTR [rbp-0xc]        # denominator
   0x00005555555551fc <+115>: cdq                                   # Convert Word to Doubleword， 结果存储到edx中
   0x00005555555551fd <+116>: idiv   ecx                            # Signed Divide， idiv src 结果存到eax中
   0x00005555555551ff <+118>: mov    eax,edx                        # 把0放到eax中, 64位操作系统有两个EAX,两个个EAX组成为RAX(64bit)
   0x0000555555555201 <+120>: test   eax,eax
   0x0000555555555203 <+122>: jne    0x555555555218 <main+143>      # 不跳转就顺序执行  

15    {
16      printf("There is NOT a remainder!");
   0x0000555555555205 <+124>: lea    rdi,[rip+0xe25]        # 0x555555556031
   0x000055555555520c <+131>: mov    eax,0x0
   0x0000555555555211 <+136>: call   0x555555555080 <printf@plt>
   0x0000555555555216 <+141>: jmp    0x555555555229 <main+160>       # 跳转到条件语句结束的地方  Jump  

17    }
18    else
19    {
20      printf("There is a remainder!");
   0x0000555555555218 <+143>: lea    rdi,[rip+0xe2c]        # 0x55555555604b    # "There is a remainder!"  地址
   0x000055555555521f <+150>: mov    eax,0x0
   0x0000555555555224 <+155>: call   0x555555555080 <printf@plt>

21    }
22  
```

字符串内容  
```sh
-exec x/32s 0x55555555604b
0x55555555604b:	"There is a remainder!"
```

## main函数参数 
```c
#include <stdio.h>

int main(int argc, char *argv[])
{
  
  if(argc < 3 || argc > 3)
  {
  	printf("Usage: ./assignment9 Firstname Lastname");
  }
  else
  {
  	printf("Hello, %s %s", argv[1], argv[2]);
  }
  return 0;
}
```

反汇编输出:  
```sh
-exec disas /m
Dump of assembler code for function main:
4 {
   0x0000555555555149 <+0>: endbr64 
   0x000055555555514d <+4>: push   rbp
   0x000055555555514e <+5>: mov    rbp,rsp
   0x0000555555555151 <+8>: sub    rsp,0x10
   0x0000555555555155 <+12>:  mov    DWORD PTR [rbp-0x4],edi
   0x0000555555555158 <+15>:  mov    QWORD PTR [rbp-0x10],rsi

5   
6   if(argc < 3 || argc > 3)
=> 0x000055555555515c <+19>:  cmp    DWORD PTR [rbp-0x4],0x2
   0x0000555555555160 <+23>:  jle    0x555555555168 <main+31>
   0x0000555555555162 <+25>:  cmp    DWORD PTR [rbp-0x4],0x3
   0x0000555555555166 <+29>:  jle    0x55555555517b <main+50>

7   {
8     printf("Usage: ./assignment9 Firstname Lastname");
   0x0000555555555168 <+31>:  lea    rdi,[rip+0xe99]        # 0x555555556008
   0x000055555555516f <+38>:  mov    eax,0x0
   0x0000555555555174 <+43>:  call   0x555555555050 <printf@plt>
   0x0000555555555179 <+48>:  jmp    0x5555555551a5 <main+92>

9   }
10    else
11    {
12      printf("Hello, %s %s", argv[1], argv[2]);
   0x000055555555517b <+50>:  mov    rax,QWORD PTR [rbp-0x10]               # [rbp-0x10] 是变量argv的地址
   0x000055555555517f <+54>:  add    rax,0x10                               # 偏移16 byte，也就是argv[2]  
   0x0000555555555183 <+58>:  mov    rdx,QWORD PTR [rax]
   0x0000555555555186 <+61>:  mov    rax,QWORD PTR [rbp-0x10]
   0x000055555555518a <+65>:  add    rax,0x8                                # 偏移8 byte，也就是argv[1] 
   0x000055555555518e <+69>:  mov    rax,QWORD PTR [rax]
   0x0000555555555191 <+72>:  mov    rsi,rax
   0x0000555555555194 <+75>:  lea    rdi,[rip+0xe95]        # 0x555555556030
   0x000055555555519b <+82>:  mov    eax,0x0
   0x00005555555551a0 <+87>:  call   0x555555555050 <printf@plt>

13    }
14    return 0;
   0x00005555555551a5 <+92>:  mov    eax,0x0
```

查看`argv`数组内容的大小
```sh
-exec call sizeof(argv[0])
$6 = 8
```

## 数组

```c
#include <stdio.h>

int main()
{
    int array[10] = {0,1,2,3,4,5,6,7,8,9};

    printf("The array has %d elements.\n",sizeof(array) / sizeof(array[0]));

    return 0;
}
```

输出
```sh
The array has 10 elements.
```

反汇编结果
```sh
5     int array[10] = {0,1,2,3,4,5,6,7,8,9};
   0x0000555555555184 <+27>:  mov    DWORD PTR [rbp-0x30],0x0                # [rbp-0x30] 数组的首地址
   0x000055555555518b <+34>:  mov    DWORD PTR [rbp-0x2c],0x1
   0x0000555555555192 <+41>:  mov    DWORD PTR [rbp-0x28],0x2
   0x0000555555555199 <+48>:  mov    DWORD PTR [rbp-0x24],0x3
   0x00005555555551a0 <+55>:  mov    DWORD PTR [rbp-0x20],0x4
   0x00005555555551a7 <+62>:  mov    DWORD PTR [rbp-0x1c],0x5
   0x00005555555551ae <+69>:  mov    DWORD PTR [rbp-0x18],0x6
   0x00005555555551b5 <+76>:  mov    DWORD PTR [rbp-0x14],0x7
   0x00005555555551bc <+83>:  mov    DWORD PTR [rbp-0x10],0x8
   0x00005555555551c3 <+90>:  mov    DWORD PTR [rbp-0xc],0x9

6 
7     printf("The array has %d elements.\n",sizeof(array) / sizeof(array[0]));
   0x00005555555551ca <+97>:  mov    esi,0xa                                  # 结果是10  
   0x00005555555551cf <+102>: lea    rdi,[rip+0xe2e]        # 0x555555556004
   0x00005555555551d6 <+109>: mov    eax,0x0
   0x00005555555551db <+114>: call   0x555555555070 <printf@plt>
```

> 此处看到`sizeof` 不是系统函数，已经预编译出来，通过`宏定义`实现的  ``


## malloc和free
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INITIAL_CAPACITY 3

int main(void)
{
  char answer[] = "y";

  //allocate store for 3 scores
  double *scores = malloc(INITIAL_CAPACITY * sizeof(double));
  if(!scores)
  {
    fprintf(stderr, "Failed to allocate scores array.\n");
    return 1;
  }

  int capacity = INITIAL_CAPACITY;

  //initialize a variable to increase and iterate through our array to store scores
  int numScores;

  for(numScores = 0; strcmp(answer, "y") == 0; ++numScores)
  {
    //dynamically
    if(numScores == capacity)
    {
      capacity *= 2;
      scores = realloc(scores, capacity * sizeof(double));
      if(!scores)
      {
        fprintf(stderr, "Failed to reallocate scores array.\n");
        return 1;
      }
    }

    //store input in our array
    printf("Enter a test score: ");
    scanf("%lf", &scores[numScores]);

    //ask the user if they would like to continue
    printf("Would you like to continue? y/n ");
    scanf("%s", &answer);
  }

  double sum = 0;

  //start a loop that will start at 0, and then it'll iterate through our scores array until it reaches the end
  //each element in the array will be added to the sum so that we can find the average
  for(int loop = 0; loop < numScores; loop++)
  {
    sum += scores[loop];
  }

  printf("%.2f is the average.\n", sum / numScores);

  free(scores);

  return 0;
}

```


反汇编结果
```sh
11    //allocate store for 3 scores
12    double *scores = malloc(INITIAL_CAPACITY * sizeof(double));
   0x000055555555524a <+33>:  mov    edi,0x18                    # 
   0x000055555555524f <+38>:  call   0x555555555100 <malloc@plt>
   0x0000555555555254 <+43>:  mov    QWORD PTR [rbp-0x20],rax

57  
58    free(scores);
   0x00005555555553dc <+435>: mov    rax,QWORD PTR [rbp-0x20]
   0x00005555555553e0 <+439>: mov    rdi,rax
   0x00005555555553e3 <+442>: call   0x5555555550c0 <free@plt>
```

查看源码: 
```c
-exec directory /usr/src/glibc/glibc-2.31/malloc/
Source directories searched: /usr/src/glibc/glibc-2.31/malloc:$cdir:$cwd

-exec b main.c:12
-exec r
-exec b malloc
-exec b malloc.c:32

-exec l malloc.c:3021, malloc.c:3082
3021  void *
3022  __libc_malloc (size_t bytes)
3023  {
3024    mstate ar_ptr;
3025    void *victim;
3026  
3027    _Static_assert (PTRDIFF_MAX <= SIZE_MAX / 2,
3028                    "PTRDIFF_MAX is not more than half of SIZE_MAX");
3029  
3030    void *(*hook) (size_t, const void *)
3031      = atomic_forced_read (__malloc_hook);
3032    if (__builtin_expect (hook != NULL, 0))
3033      return (*hook)(bytes, RETURN_ADDRESS (0));
3034  #if USE_TCACHE
3035    /* int_free also calls request2size, be careful to not pad twice.  */
3036    size_t tbytes;
3037    if (!checked_request2size (bytes, &tbytes))
3038      {
3039        __set_errno (ENOMEM);
3040        return NULL;
3041      }
3042    size_t tc_idx = csize2tidx (tbytes);
3043  
3044    MAYBE_INIT_TCACHE ();
3045  
3046    DIAG_PUSH_NEEDS_COMMENT;
3047    if (tc_idx < mp_.tcache_bins
3048        && tcache
3049        && tcache->counts[tc_idx] > 0)
3050      {
3051        return tcache_get (tc_idx);
3052      }
3053    DIAG_POP_NEEDS_COMMENT;
3054  #endif
3055  
3056    if (SINGLE_THREAD_P)
3057      {
3058        victim = _int_malloc (&main_arena, bytes);
3059        assert (!victim || chunk_is_mmapped (mem2chunk (victim)) ||
3060           &main_arena == arena_for_chunk (mem2chunk (victim)));
3061        return victim;
3062      }
3063  
3064    arena_get (ar_ptr, bytes);
3065  
3066    victim = _int_malloc (ar_ptr, bytes);
3067    /* Retry with another arena only if we were able to find a usable arena
3068       before.  */
3069    if (!victim && ar_ptr != NULL)
3070      {
3071        LIBC_PROBE (memory_malloc_retry, 1, bytes);
3072        ar_ptr = arena_get_retry (ar_ptr, bytes);
3073        victim = _int_malloc (ar_ptr, bytes);
3074      }
3075  
3076    if (ar_ptr != NULL)
3077      __libc_lock_unlock (ar_ptr->mutex);
3078  
3079    assert (!victim || chunk_is_mmapped (mem2chunk (victim)) ||
3080            ar_ptr == arena_for_chunk (mem2chunk (victim)));
3081    return victim;
3082  }
```

可以使用`patchelf` 替换debug版本的`glibc`  


查看malloc与free的实现  
```sh
-exec disas malloc
Dump of assembler code for function malloc:
   0x00007ffff7fec4a0 <+0>:   endbr64 
   0x00007ffff7fec4a4 <+4>:   push   rbp
   0x00007ffff7fec4a5 <+5>:   push   rbx
   0x00007ffff7fec4a6 <+6>:   mov    rbx,rdi
   0x00007ffff7fec4a9 <+9>:   sub    rsp,0x8
   0x00007ffff7fec4ad <+13>:  mov    rdx,QWORD PTR [rip+0x11c3c]        # 0x7ffff7ffe0f0 <alloc_end>
   0x00007ffff7fec4b4 <+20>:  mov    rax,QWORD PTR [rip+0x11c3d]        # 0x7ffff7ffe0f8 <alloc_ptr>
   0x00007ffff7fec4bb <+27>:  test   rdx,rdx
   0x00007ffff7fec4be <+30>:  je     0x7ffff7fec568 <malloc+200>
   0x00007ffff7fec4c4 <+36>:  add    rax,0xf
   0x00007ffff7fec4c8 <+40>:  and    rax,0xfffffffffffffff0
   0x00007ffff7fec4cc <+44>:  lea    rcx,[rax+rbx*1]
   0x00007ffff7fec4d0 <+48>:  mov    QWORD PTR [rip+0x11c21],rax        # 0x7ffff7ffe0f8 <alloc_ptr>
   0x00007ffff7fec4d7 <+55>:  cmp    rcx,rdx
   0x00007ffff7fec4da <+58>:  jae    0x7ffff7fec500 <malloc+96>
   0x00007ffff7fec4dc <+60>:  mov    rdx,rax
   0x00007ffff7fec4df <+63>:  neg    rdx
   0x00007ffff7fec4e2 <+66>:  cmp    rdx,rbx
   0x00007ffff7fec4e5 <+69>:  jbe    0x7ffff7fec500 <malloc+96>
   0x00007ffff7fec4e7 <+71>:  mov    QWORD PTR [rip+0x11bfa],rax        # 0x7ffff7ffe0e8 <alloc_last_block>
   0x00007ffff7fec4ee <+78>:  mov    QWORD PTR [rip+0x11c03],rcx        # 0x7ffff7ffe0f8 <alloc_ptr>
   0x00007ffff7fec4f5 <+85>:  add    rsp,0x8
   0x00007ffff7fec4f9 <+89>:  pop    rbx
   0x00007ffff7fec4fa <+90>:  pop    rbp
   0x00007ffff7fec4fb <+91>:  ret    
   0x00007ffff7fec4fc <+92>:  nop    DWORD PTR [rax+0x0]
   0x00007ffff7fec500 <+96>:  mov    rcx,QWORD PTR [rip+0x10131]        # 0x7ffff7ffc638 <_rtld_global_ro+24>
   0x00007ffff7fec507 <+103>: mov    rdx,rcx
   0x00007ffff7fec50a <+106>: lea    rbp,[rcx+rbx*1-0x1]
   0x00007ffff7fec50f <+111>: neg    rdx
   0x00007ffff7fec512 <+114>: and    rbp,rdx
   0x00007ffff7fec515 <+117>: jne    0x7ffff7fec520 <malloc+128>
   0x00007ffff7fec517 <+119>: test   rbx,rbx
   0x00007ffff7fec51a <+122>: jne    0x7ffff7fec5b0 <malloc+272>
   0x00007ffff7fec520 <+128>: add    rbp,rcx
   0x00007ffff7fec523 <+131>: mov    edx,0x3
   0x00007ffff7fec528 <+136>: xor    r9d,r9d
   0x00007ffff7fec52b <+139>: mov    ecx,0x22
   0x00007ffff7fec530 <+144>: mov    r8d,0xffffffff
   0x00007ffff7fec536 <+150>: mov    rsi,rbp
   0x00007ffff7fec539 <+153>: xor    edi,edi
   0x00007ffff7fec53b <+155>: call   0x7ffff7fee160 <__mmap64>
   0x00007ffff7fec540 <+160>: mov    rdx,rax
   0x00007ffff7fec543 <+163>: cmp    rax,0xffffffffffffffff
   0x00007ffff7fec547 <+167>: je     0x7ffff7fec5b0 <malloc+272>
   0x00007ffff7fec549 <+169>: cmp    QWORD PTR [rip+0x11ba0],rax        # 0x7ffff7ffe0f0 <alloc_end>
   0x00007ffff7fec550 <+176>: je     0x7ffff7fec590 <malloc+240>
   0x00007ffff7fec552 <+178>: add    rdx,rbp
   0x00007ffff7fec555 <+181>: lea    rcx,[rax+rbx*1]
   0x00007ffff7fec559 <+185>: mov    QWORD PTR [rip+0x11b90],rdx        # 0x7ffff7ffe0f0 <alloc_end>
   0x00007ffff7fec560 <+192>: jmp    0x7ffff7fec4e7 <malloc+71>
   0x00007ffff7fec562 <+194>: nop    WORD PTR [rax+rax*1+0x0]
   0x00007ffff7fec568 <+200>: mov    rcx,QWORD PTR [rip+0x100c9]        # 0x7ffff7ffc638 <_rtld_global_ro+24>
   0x00007ffff7fec56f <+207>: lea    rax,[rip+0x11c1a]        # 0x7ffff7ffe190
   0x00007ffff7fec576 <+214>: lea    rdx,[rcx+rax*1-0x1]
   0x00007ffff7fec57b <+219>: neg    rcx
   0x00007ffff7fec57e <+222>: and    rdx,rcx
   0x00007ffff7fec581 <+225>: mov    QWORD PTR [rip+0x11b68],rdx        # 0x7ffff7ffe0f0 <alloc_end>
   0x00007ffff7fec588 <+232>: jmp    0x7ffff7fec4c4 <malloc+36>
   0x00007ffff7fec58d <+237>: nop    DWORD PTR [rax]
   0x00007ffff7fec590 <+240>: mov    rax,QWORD PTR [rip+0x11b61]        # 0x7ffff7ffe0f8 <alloc_ptr>
   0x00007ffff7fec597 <+247>: add    rdx,rbp
   0x00007ffff7fec59a <+250>: mov    QWORD PTR [rip+0x11b4f],rdx        # 0x7ffff7ffe0f0 <alloc_end>
   0x00007ffff7fec5a1 <+257>: lea    rcx,[rax+rbx*1]
   0x00007ffff7fec5a5 <+261>: jmp    0x7ffff7fec4e7 <malloc+71>
   0x00007ffff7fec5aa <+266>: nop    WORD PTR [rax+rax*1+0x0]
   0x00007ffff7fec5b0 <+272>: add    rsp,0x8
   0x00007ffff7fec5b4 <+276>: xor    eax,eax
   0x00007ffff7fec5b6 <+278>: pop    rbx
   0x00007ffff7fec5b7 <+279>: pop    rbp
   0x00007ffff7fec5b8 <+280>: ret    
End of assembler dump.
-exec disas free
Dump of assembler code for function free:
   0x00007ffff7fec600 <+0>:   endbr64 
   0x00007ffff7fec604 <+4>:   mov    rcx,QWORD PTR [rip+0x11add]        # 0x7ffff7ffe0e8 <alloc_last_block>
   0x00007ffff7fec60b <+11>:  cmp    rcx,rdi
   0x00007ffff7fec60e <+14>:  je     0x7ffff7fec618 <free+24>
   0x00007ffff7fec610 <+16>:  ret    
   0x00007ffff7fec611 <+17>:  nop    DWORD PTR [rax+0x0]
   0x00007ffff7fec618 <+24>:  sub    rsp,0x8
   0x00007ffff7fec61c <+28>:  mov    rdx,QWORD PTR [rip+0x11ad5]        # 0x7ffff7ffe0f8 <alloc_ptr>
   0x00007ffff7fec623 <+35>:  xor    esi,esi
   0x00007ffff7fec625 <+37>:  mov    rdi,rcx
   0x00007ffff7fec628 <+40>:  sub    rdx,rcx
   0x00007ffff7fec62b <+43>:  call   0x7ffff7ff2580 <memset>
   0x00007ffff7fec630 <+48>:  mov    QWORD PTR [rip+0x11ac1],rax        # 0x7ffff7ffe0f8 <alloc_ptr>
   0x00007ffff7fec637 <+55>:  add    rsp,0x8
   0x00007ffff7fec63b <+59>:  ret    
End of assembler dump.
```

## srand/rand随机  

```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void main(void)
{
	//setting upper and lower range (1 = heads, 2 = tails)
	int lower, upper;
	lower = 1;
	upper = 2;
	srand(time(0)); //initializing randomization *once*
	
	//find out how many times to flip coin
	int count;
	printf("How many times would you like to flip the coin? ");
	scanf("%d", &count);

	//flip coin and track results
	int i, result; 
	int heads = 0;
	int tails = 0;
	for (i = 0; i < count; i++) 
	{
		result = (rand() % (upper - lower + 1)) + lower;
		if (result == 1) 
		{
			heads++;
		}
		else if (result == 2)
		{
			tails++;
		}
	}

	printf("After flipping the coin %d times, the results were\n%d heads\n%d tails\n", count, heads, tails);

}
```

输出
```sh
How many times would you like to flip the coin? 90
After flipping the coin 90 times, the results were
42 heads
48 tails
```

反汇编结果
```sh
7     //setting upper and lower range (1 = heads, 2 = tails)
8     int lower, upper;
9     lower = 1;
   0x0000555555555204 <+27>:  mov    DWORD PTR [rbp-0x14],0x1

10    upper = 2;
   0x000055555555520b <+34>:  mov    DWORD PTR [rbp-0x10],0x2

11    srand(time(0)); //initializing randomization *once*
   0x0000555555555212 <+41>:  mov    edi,0x0
   0x0000555555555217 <+46>:  call   0x5555555550d0 <time@plt>
   0x000055555555521c <+51>:  mov    edi,eax
   0x000055555555521e <+53>:  call   0x5555555550c0 <srand@plt>

23    {
24       result = (rand() % (upper - lower + 1)) + lower;
   0x0000555555555263 <+122>: call   0x5555555550f0 <rand@plt>
   0x0000555555555268 <+127>: mov    edx,DWORD PTR [rbp-0x10]
   0x000055555555526b <+130>: sub    edx,DWORD PTR [rbp-0x14]
   0x000055555555526e <+133>: lea    ecx,[rdx+0x1]
   0x0000555555555271 <+136>: cdq    
   0x0000555555555272 <+137>: idiv   ecx
   0x0000555555555274 <+139>: mov    eax,DWORD PTR [rbp-0x14]
   0x0000555555555277 <+142>: add    eax,edx
   0x0000555555555279 <+144>: mov    DWORD PTR [rbp-0xc],eax
```

## 


