- # 知识速览
[Learning-C demo实例](https://github.com/h0mbre/Learning-C)  

## helloworld
```c
#include <stdio.h>

int main(void)
{
  printf("Hello, World!\n");
  return 0;
}

```
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

