- # C 编译及运行原理  
[参考文章](https://www3.ntu.edu.sg/home/ehchua/programming/cpp/gcc_make.html)  

- [简介](#简介)
    - [入门](#入门)
    - [编译和链接多个源文件](#编译和链接多个源文件)
- [GCC编译(GNU Compiler Collection)](#gcc编译gnu-compiler-collection)
  - [编译参数](#编译参数)
  - [编译过程](#编译过程)
    - [预处理](#预处理)
    - [编译阶段](#编译阶段)
    - [汇编阶段](#汇编阶段)
    - [链接阶段](#链接阶段)
- [检查编译文件](#检查编译文件)
  - [文件基本信息`file`](#文件基本信息file)
  - [查看符号表`nm`](#查看符号表nm)
  - [列出动态链接库`ldd`](#列出动态链接库ldd)
- [Makefile](#makefile)
  - [入门](#入门-1)
  - [makefile的规则](#makefile的规则)
  - [示例](#示例)
  - [make是如何工作的](#make是如何工作的)
  - [makefile中使用变量](#makefile中使用变量)
  - [让make自动推导](#让make自动推导)
  - [清空目标文件的规则](#清空目标文件的规则)
  - [make的工作方式](#make的工作方式)


## 简介
#### 入门
[参考文章](https://www.cnblogs.com/burner/p/gcc-bian-yiccde-si-ge-guo-cheng.html)  

```c
// hello.c
#include <stdio.h>
 
int main() {
    printf("Hello, world!\n");
    return 0;
}
```

编译`hello.c`  
```sh
# Compile and link source file hello.c into executable a.exe (Windows) or a (Unixes)
gcc hello.c
```

> 默认输出可执行文件称为` a.exe`（Windows）或` a.out`（Unixes 和 Mac OS X）  

```sh
$ chmod a+x a.out
$ ./a.out
```

要指定输出文件名，请使用`-o`选项
```sh
$ gcc -o hello hello.c 
$ chmod a+x hello 
$ ./hello
```

#### 编译和链接多个源文件

1. 多个文件一起编译
```sh
$ gcc testfun.c test.c -o test
```
将testfun.c和test.c分别编译后链接成test可执行文件。  

2. 分别编译各个源文件，之后对编译后输出的目标文件链接。
```sh
$ gcc -c testfun.c                 # 将testfun.c编译成testfun.o
$ gcc -c test.c                    # 将test.c编译成test.o
$ gcc -o testfun.o test.o -o test  # 将testfun.o和test.o链接成test
```

> 以上两种方法相比较，第一中方法编译时需要所有文件重新编译，而第二种方法可以只重新编译修改的文件，未修改的文件不用重新编译。  
## GCC编译(GNU Compiler Collection)
[gcc源码](https://github.com/gcc-mirror/gcc)  

gcc 与 g++ 分别是 gnu 的 c & c++ 编译器 gcc/g++ 在执行编译工作的时候，总共需要4步：  
- 1. 预处理,生成 .i 的文件[预处理器cpp]
- 2. 将预处理后的文件转换成汇编语言, 生成文件 .s [编译器egcs]
- 3. 将汇编变为目标代码(机器代码)生成 .o 的文件[汇编器as]
- 4. 连接目标代码, 生成可执行程序 [链接器ld]

<br>
<div align=center>
    <img src="../../res/image/GCC_CompilationProcess.png" width="80%"></img>  
</div>
<br>

### 编译参数

- `-v`  选项查看详细的编译过程,调试时使用
- `-g`  生成额外的符号调试信息以供gdb调试器使用
- `-o`  指定输出的可执行文件名 Place the output into <file>.
- `-Wall`  打印全部警告信息
- `-E`  只激活预处理,这个不生成文件, 你需要把它重定向到一个输出文件里面  `gcc -E test.c -o test.i`  
- `-S`  只激活预处理和编译，就是指把文件编译成为汇编代码  
- `-c`  Compile and assemble, but do not link.

### 编译过程

#### 预处理
通过 GNU C 预处理器，其中包括标头 ( #include) 并扩展宏 ( #define)  

```sh
gcc -E hello.c -o hello.i
```

`hello.i`文件部分内容  
```sh
extern int printf (const char *__restrict __format, ...);
...
extern void funlockfile (FILE *__stream) __attribute__ ((__nothrow__ , __leaf__));
# 858 "/usr/include/stdio.h" 3 4
extern int __uflow (FILE *);
extern int __overflow (FILE *, int);
# 873 "/usr/include/stdio.h" 3 4

# 3 "hello.c" 2


# 4 "hello.c"
int main() {
    printf("Hello, world!\n");
    return 0;
}
```

由此可见，gcc确实进行了预处理，它把`stdio.h`的内容插入到hello.i文件中  

增加`-v`参数，可以看到详细信息`gcc -E hello.c -o hello.i -v`    
```sh
COLLECT_GCC=gcc
OFFLOAD_TARGET_NAMES=nvptx-none:hsa
OFFLOAD_TARGET_DEFAULT=1
Target: x86_64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Ubuntu 9.4.0-1ubuntu1~20.04.1' --with-bugurl=file:///usr/share/doc/gcc-9/README.Bugs --enable-languages=c,ada,c++,go,brig,d,fortran,objc,obj-c++,gm2 --prefix=/usr --with-gcc-major-version-only --program-suffix=-9 --program-prefix=x86_64-linux-gnu- --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-vtable-verify --enable-plugin --enable-default-pie --with-system-zlib --with-target-system-zlib=auto --enable-objc-gc=auto --enable-multiarch --disable-werror --with-arch-32=i686 --with-abi=m64 --with-multilib-list=m32,m64,mx32 --enable-multilib --with-tune=generic --enable-offload-targets=nvptx-none=/build/gcc-9-Av3uEd/gcc-9-9.4.0/debian/tmp-nvptx/usr,hsa --without-cuda-driver --enable-checking=release --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu
Thread model: posix
gcc version 9.4.0 (Ubuntu 9.4.0-1ubuntu1~20.04.1) 
COLLECT_GCC_OPTIONS='-E' '-o' 'hello.i' '-v' '-mtune=generic' '-march=x86-64'
 /usr/lib/gcc/x86_64-linux-gnu/9/cc1 -E -quiet -v -imultiarch x86_64-linux-gnu hello.c -o hello.i -mtune=generic -march=x86-64 -fasynchronous-unwind-tables -fstack-protector-strong -Wformat -Wformat-security -fstack-clash-protection -fcf-protection
ignoring nonexistent directory "/usr/local/include/x86_64-linux-gnu"
ignoring nonexistent directory "/usr/lib/gcc/x86_64-linux-gnu/9/include-fixed"
ignoring nonexistent directory "/usr/lib/gcc/x86_64-linux-gnu/9/../../../../x86_64-linux-gnu/include"
#include "..." search starts here:
#include <...> search starts here:
 /usr/lib/gcc/x86_64-linux-gnu/9/include
 /usr/local/include
 /usr/include/x86_64-linux-gnu
 /usr/include
End of search list.
COMPILER_PATH=/usr/lib/gcc/x86_64-linux-gnu/9/:/usr/lib/gcc/x86_64-linux-gnu/9/:/usr/lib/gcc/x86_64-linux-gnu/:/usr/lib/gcc/x86_64-linux-gnu/9/:/usr/lib/gcc/x86_64-linux-gnu/
LIBRARY_PATH=/usr/lib/gcc/x86_64-linux-gnu/9/:/usr/lib/gcc/x86_64-linux-gnu/9/../../../x86_64-linux-gnu/:/usr/lib/gcc/x86_64-linux-gnu/9/../../../../lib/:/lib/x86_64-linux-gnu/:/lib/../lib/:/usr/lib/x86_64-linux-gnu/:/usr/lib/../lib/:/usr/lib/gcc/x86_64-linux-gnu/9/../../../:/lib/:/usr/lib/
COLLECT_GCC_OPTIONS='-E' '-o' 'hello.i' '-v' '-mtune=generic' '-march=x86-64'
```
#### 编译阶段  
Gcc首先要检查代码的规范性、是否有语法错误等，以确定代码的实际要做的工作，在检查无误后，Gcc把代码翻译成汇编语言。用户可以使用`-S`选项来进行查看，该选项只进行编译而不进行汇编，生成汇编代码  

```sh
gcc -S hello.i -o hello.s
```

汇编内容
```sh
        .file   "hello.c"
        .text
        .section        .rodata
.LC0:
        .string "Hello, world!"
        .text
        .globl  main
        .type   main, @function
main:
.LFB0:
        .cfi_startproc
        endbr64
        pushq   %rbp
        .cfi_def_cfa_offset 16
        .cfi_offset 6, -16
        movq    %rsp, %rbp
        .cfi_def_cfa_register 6
        leaq    .LC0(%rip), %rdi
        call    puts@PLT
        movl    $0, %eax
        popq    %rbp
        .cfi_def_cfa 7, 8
        ret
        .cfi_endproc
.LFE0:
        .size   main, .-main
        .ident  "GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
        .section        .note.GNU-stack,"",@progbits
        .section        .note.gnu.property,"a"
        .align 8
        .long    1f - 0f
        .long    4f - 1f
        .long    5
0:
        .string  "GNU"
1:
        .align 8
        .long    0xc0000002
        .long    3f - 2f
2:
        .long    0x3
3:
        .align 8
4:
```

#### 汇编阶段  

汇编阶段是把编译阶段生成的`.s`文件转成目标文件，读者在此可使用选项`-c`就可看到汇编代码已转化为`.o`的二进制目标代码了  

```sh
gcc -c hello.c -o hello.o
```

#### 链接阶段

在成功编译之后，就进入了链接阶段。在这里涉及到一个重要的概念：`函数库`。

可以重新查看这个小程序，在这个程序中并没有定义`printf`的函数实现，且在预编译中包含进的`stdio.h`中也只有该函数的声明，而没有定义函数的实现，那么，是在哪里实现`printf`函数的呢？答案是：系统把这些函数实现都被做到名为`libc.so.6`的库文件中去了，在没有特别指定时，Gcc会到系统默认的搜索路径`/usr/lib`下进行查找，也就是链接到`libc.so.6`库函数中去，这样就能实现函数`printf`了，而这也就是链接的作用。  

函数库一般分为`静态库`和`动态库`两种:
- `静态库`是指编译链接时，把库文件的代码全部加入到可执行文件中，因此生成的文件比较大，但在运行时也就不再需要库文件了。其后缀名一般为`.a`。  
- `动态库`与之相反，在编译链接时并没有把库文件的代码加入到可执行文件中，而是在程序执行时由运行时链接文件加载库，这样可以节省系统的开销。动态库一般后缀名为`.so`，如前面所述的libc.so.6就是动态库。Gcc在编译时默认使用动态库。

说下生成静态库的方法：  
就是把file1.o和file2.o打包生成libxxx.a静态库  
```sh
	ar cr libxxx.a file1.o file2.o
	gcc test.c -L/path -lxxx -o test
```

动态库的话：
```sh 
	gcc -fPIC -shared file1.c -o libxxx.so

# 也可以分成两部来写
	gcc -fPIC file1.c -c #这一步生成file1.o
	gcc -shared file1.o -o libtest.so
```

链接的指令:  
```sh
gcc hello.o -o hello
```

可执行文件的部分内容
```sh
@libc.so.6^@puts^@__cxa_finalize^@__libc_start_main^@GLIBC_2.2.5^@_ITM_deregisterTMCloneTable^@__gmon_start__^@_ITM_registerTMCloneTable^@
```





## 检查编译文件
### 文件基本信息`file`
```sh
file hello.s 
hello.s: assembler source, ASCII text

$ file hello.o 
hello.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped

$ file hello
hello: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=61598e48dc6550a995c3bc0a6ee539bf5263ea02, for GNU/Linux 3.2.0, not stripped
```

### 查看符号表`nm`

`nm`通常用于检查目标文件中是否定义了特定函数。
- `T` 已定义的是函数， 
- `U` 未定义且应由链接器解析的函数

`nm hello.o`  
```sh
                 U _GLOBAL_OFFSET_TABLE_
0000000000000000 T main
                 U puts
```

`nm hello`
```sh
0000000000004010 B __bss_start
0000000000004010 b completed.8061
                 w __cxa_finalize@@GLIBC_2.2.5
0000000000004000 D __data_start
0000000000004000 W data_start
0000000000001090 t deregister_tm_clones
0000000000001100 t __do_global_dtors_aux
0000000000003dc0 d __do_global_dtors_aux_fini_array_entry
0000000000004008 D __dso_handle
0000000000003dc8 d _DYNAMIC
0000000000004010 D _edata
0000000000004018 B _end
00000000000011e8 T _fini
0000000000001140 t frame_dummy
0000000000003db8 d __frame_dummy_init_array_entry
000000000000215c r __FRAME_END__
0000000000003fb8 d _GLOBAL_OFFSET_TABLE_
                 w __gmon_start__
0000000000002014 r __GNU_EH_FRAME_HDR
0000000000001000 t _init
0000000000003dc0 d __init_array_end
0000000000003db8 d __init_array_start
0000000000002000 R _IO_stdin_used
                 w _ITM_deregisterTMCloneTable
                 w _ITM_registerTMCloneTable
00000000000011e0 T __libc_csu_fini
0000000000001170 T __libc_csu_init
                 U __libc_start_main@@GLIBC_2.2.5
0000000000001149 T main
                 U puts@@GLIBC_2.2.5
00000000000010c0 t register_tm_clones
0000000000001060 T _start
0000000000004010 D __TMC_END__
```

`-a` --debug-syms 显示调试符号  
`nm -a hello.o `  
```sh
0000000000000000 b .bss
0000000000000000 n .comment
0000000000000000 d .data
0000000000000000 r .eh_frame
                 U _GLOBAL_OFFSET_TABLE_
0000000000000000 a hello.c
0000000000000000 T main
0000000000000000 r .note.gnu.property
0000000000000000 n .note.GNU-stack
                 U puts
0000000000000000 r .rodata
0000000000000000 t .text
```

### 列出动态链接库`ldd`  
`ldd hello`
```sh
        linux-vdso.so.1 (0x00007ffd9bfd7000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1b7ae4b000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f1b7b04c000)
```

`-v` 打印所有信息
```sh
ldd -v hello
	linux-vdso.so.1 (0x00007ffd72ec9000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f66e657e000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f66e677f000)

	Version information:
	./hello:
		libc.so.6 (GLIBC_2.2.5) => /lib/x86_64-linux-gnu/libc.so.6
	/lib/x86_64-linux-gnu/libc.so.6:
		ld-linux-x86-64.so.2 (GLIBC_2.3) => /lib64/ld-linux-x86-64.so.2
		ld-linux-x86-64.so.2 (GLIBC_PRIVATE) => /lib64/ld-linux-x86-64.so.2
```

### `objdump`
- `-x`  --all-headers        Display the contents of all headers
- `-t`  --syms               Display the contents of the symbol table(s)
- `-T`  -T, --dynamic-syms       Display the contents of the dynamic symbol table
- `-d`  --disassemble        Display assembler contents of executable sections
- `-D`  --disassemble-all    Display assembler contents of all sections
- `-g`  --debugging          Display debug information in object file
- `-M`  with the -M switch (multiple options should be separated by commas):  `att         Display instruction in AT&T syntax`,`intel       Display instruction in Intel syntax`

查看intel汇编`objdump -M intel -d hello.o`
```sh
hello.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
   0:	f3 0f 1e fa          	endbr64 
   4:	55                   	push   rbp
   5:	48 89 e5             	mov    rbp,rsp
   8:	48 8d 3d 00 00 00 00 	lea    rdi,[rip+0x0]        # f <main+0xf>
   f:	e8 00 00 00 00       	call   14 <main+0x14>
  14:	b8 00 00 00 00       	mov    eax,0x0
  19:	5d                   	pop    rbp
  1a:	c3                   	ret   
```

还没有链接地

调试表`objdump -g hello.o`  
```sh
hello.o:     file format elf64-x86-64

Contents of the .eh_frame section (loaded from hello.o):


00000000 0000000000000014 00000000 CIE
  Version:               1
  Augmentation:          "zR"
  Code alignment factor: 1
  Data alignment factor: -8
  Return address column: 16
  Augmentation data:     1b
  DW_CFA_def_cfa: r7 (rsp) ofs 8
  DW_CFA_offset: r16 (rip) at cfa-8
  DW_CFA_nop
  DW_CFA_nop

00000018 000000000000001c 0000001c FDE cie=00000000 pc=0000000000000000..000000000000001b
  DW_CFA_advance_loc: 5 to 0000000000000005
  DW_CFA_def_cfa_offset: 16
  DW_CFA_offset: r6 (rbp) at cfa-16
  DW_CFA_advance_loc: 3 to 0000000000000008
  DW_CFA_def_cfa_register: r6 (rbp)
  DW_CFA_advance_loc: 18 to 000000000000001a
  DW_CFA_def_cfa: r7 (rsp) ofs 8
  DW_CFA_nop
  DW_CFA_nop
  DW_CFA_nop
```

头文件`objdump -x hello.o`  
```sh
hello.o:     file format elf64-x86-64
hello.o
architecture: i386:x86-64, flags 0x00000011:
HAS_RELOC, HAS_SYMS
start address 0x0000000000000000

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         0000001b  0000000000000000  0000000000000000  00000040  2**0
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  1 .data         00000000  0000000000000000  0000000000000000  0000005b  2**0
                  CONTENTS, ALLOC, LOAD, DATA
  2 .bss          00000000  0000000000000000  0000000000000000  0000005b  2**0
                  ALLOC
  3 .rodata       0000000e  0000000000000000  0000000000000000  0000005b  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .comment      0000002c  0000000000000000  0000000000000000  00000069  2**0
                  CONTENTS, READONLY
  5 .note.GNU-stack 00000000  0000000000000000  0000000000000000  00000095  2**0
                  CONTENTS, READONLY
  6 .note.gnu.property 00000020  0000000000000000  0000000000000000  00000098  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  7 .eh_frame     00000038  0000000000000000  0000000000000000  000000b8  2**3
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, DATA
SYMBOL TABLE:
0000000000000000 l    df *ABS*	0000000000000000 hello.c
0000000000000000 l    d  .text	0000000000000000 .text
0000000000000000 l    d  .data	0000000000000000 .data
0000000000000000 l    d  .bss	0000000000000000 .bss
0000000000000000 l    d  .rodata	0000000000000000 .rodata
0000000000000000 l    d  .note.GNU-stack	0000000000000000 .note.GNU-stack
0000000000000000 l    d  .note.gnu.property	0000000000000000 .note.gnu.property
0000000000000000 l    d  .eh_frame	0000000000000000 .eh_frame
0000000000000000 l    d  .comment	0000000000000000 .comment
0000000000000000 g     F .text	000000000000001b main
0000000000000000         *UND*	0000000000000000 _GLOBAL_OFFSET_TABLE_
0000000000000000         *UND*	0000000000000000 puts


RELOCATION RECORDS FOR [.text]:
OFFSET           TYPE              VALUE 
000000000000000b R_X86_64_PC32     .rodata-0x0000000000000004
0000000000000010 R_X86_64_PLT32    puts-0x0000000000000004


RELOCATION RECORDS FOR [.eh_frame]:
OFFSET           TYPE              VALUE 
0000000000000020 R_X86_64_PC32     .text
```

链接后的文件`objdump -x hello`  
```sh
hello:     file format elf64-x86-64
hello
architecture: i386:x86-64, flags 0x00000150:
HAS_SYMS, DYNAMIC, D_PAGED
start address 0x0000000000001060

Program Header:
    PHDR off    0x0000000000000040 vaddr 0x0000000000000040 paddr 0x0000000000000040 align 2**3
         filesz 0x00000000000002d8 memsz 0x00000000000002d8 flags r--
  INTERP off    0x0000000000000318 vaddr 0x0000000000000318 paddr 0x0000000000000318 align 2**0
         filesz 0x000000000000001c memsz 0x000000000000001c flags r--
    LOAD off    0x0000000000000000 vaddr 0x0000000000000000 paddr 0x0000000000000000 align 2**12
         filesz 0x00000000000005f8 memsz 0x00000000000005f8 flags r--
    LOAD off    0x0000000000001000 vaddr 0x0000000000001000 paddr 0x0000000000001000 align 2**12
         filesz 0x00000000000001f5 memsz 0x00000000000001f5 flags r-x
    LOAD off    0x0000000000002000 vaddr 0x0000000000002000 paddr 0x0000000000002000 align 2**12
         filesz 0x0000000000000160 memsz 0x0000000000000160 flags r--
    LOAD off    0x0000000000002db8 vaddr 0x0000000000003db8 paddr 0x0000000000003db8 align 2**12
         filesz 0x0000000000000258 memsz 0x0000000000000260 flags rw-
 DYNAMIC off    0x0000000000002dc8 vaddr 0x0000000000003dc8 paddr 0x0000000000003dc8 align 2**3
         filesz 0x00000000000001f0 memsz 0x00000000000001f0 flags rw-
    NOTE off    0x0000000000000338 vaddr 0x0000000000000338 paddr 0x0000000000000338 align 2**3
         filesz 0x0000000000000020 memsz 0x0000000000000020 flags r--
    NOTE off    0x0000000000000358 vaddr 0x0000000000000358 paddr 0x0000000000000358 align 2**2
         filesz 0x0000000000000044 memsz 0x0000000000000044 flags r--
0x6474e553 off    0x0000000000000338 vaddr 0x0000000000000338 paddr 0x0000000000000338 align 2**3
         filesz 0x0000000000000020 memsz 0x0000000000000020 flags r--
EH_FRAME off    0x0000000000002014 vaddr 0x0000000000002014 paddr 0x0000000000002014 align 2**2
         filesz 0x0000000000000044 memsz 0x0000000000000044 flags r--
   STACK off    0x0000000000000000 vaddr 0x0000000000000000 paddr 0x0000000000000000 align 2**4
         filesz 0x0000000000000000 memsz 0x0000000000000000 flags rw-
   RELRO off    0x0000000000002db8 vaddr 0x0000000000003db8 paddr 0x0000000000003db8 align 2**0
         filesz 0x0000000000000248 memsz 0x0000000000000248 flags r--

Dynamic Section:
  NEEDED               libc.so.6
  INIT                 0x0000000000001000
  FINI                 0x00000000000011e8
  INIT_ARRAY           0x0000000000003db8
  INIT_ARRAYSZ         0x0000000000000008
  FINI_ARRAY           0x0000000000003dc0
  FINI_ARRAYSZ         0x0000000000000008
  GNU_HASH             0x00000000000003a0
  STRTAB               0x0000000000000470
  SYMTAB               0x00000000000003c8
  STRSZ                0x0000000000000082
  SYMENT               0x0000000000000018
  DEBUG                0x0000000000000000
  PLTGOT               0x0000000000003fb8
  PLTRELSZ             0x0000000000000018
  PLTREL               0x0000000000000007
  JMPREL               0x00000000000005e0
  RELA                 0x0000000000000520
  RELASZ               0x00000000000000c0
  RELAENT              0x0000000000000018
  FLAGS                0x0000000000000008
  FLAGS_1              0x0000000008000001
  VERNEED              0x0000000000000500
  VERNEEDNUM           0x0000000000000001
  VERSYM               0x00000000000004f2
  RELACOUNT            0x0000000000000003

Version References:
  required from libc.so.6:
    0x09691a75 0x00 02 GLIBC_2.2.5

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .interp       0000001c  0000000000000318  0000000000000318  00000318  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  1 .note.gnu.property 00000020  0000000000000338  0000000000000338  00000338  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .note.gnu.build-id 00000024  0000000000000358  0000000000000358  00000358  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .note.ABI-tag 00000020  000000000000037c  000000000000037c  0000037c  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .gnu.hash     00000024  00000000000003a0  00000000000003a0  000003a0  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  5 .dynsym       000000a8  00000000000003c8  00000000000003c8  000003c8  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  6 .dynstr       00000082  0000000000000470  0000000000000470  00000470  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  7 .gnu.version  0000000e  00000000000004f2  00000000000004f2  000004f2  2**1
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  8 .gnu.version_r 00000020  0000000000000500  0000000000000500  00000500  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  9 .rela.dyn     000000c0  0000000000000520  0000000000000520  00000520  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 10 .rela.plt     00000018  00000000000005e0  00000000000005e0  000005e0  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 11 .init         0000001b  0000000000001000  0000000000001000  00001000  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 12 .plt          00000020  0000000000001020  0000000000001020  00001020  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 13 .plt.got      00000010  0000000000001040  0000000000001040  00001040  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 14 .plt.sec      00000010  0000000000001050  0000000000001050  00001050  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 15 .text         00000185  0000000000001060  0000000000001060  00001060  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 16 .fini         0000000d  00000000000011e8  00000000000011e8  000011e8  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
 17 .rodata       00000012  0000000000002000  0000000000002000  00002000  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 18 .eh_frame_hdr 00000044  0000000000002014  0000000000002014  00002014  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 19 .eh_frame     00000108  0000000000002058  0000000000002058  00002058  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
 20 .init_array   00000008  0000000000003db8  0000000000003db8  00002db8  2**3
                  CONTENTS, ALLOC, LOAD, DATA
 21 .fini_array   00000008  0000000000003dc0  0000000000003dc0  00002dc0  2**3
                  CONTENTS, ALLOC, LOAD, DATA
 22 .dynamic      000001f0  0000000000003dc8  0000000000003dc8  00002dc8  2**3
                  CONTENTS, ALLOC, LOAD, DATA
 23 .got          00000048  0000000000003fb8  0000000000003fb8  00002fb8  2**3
                  CONTENTS, ALLOC, LOAD, DATA
 24 .data         00000010  0000000000004000  0000000000004000  00003000  2**3
                  CONTENTS, ALLOC, LOAD, DATA
 25 .bss          00000008  0000000000004010  0000000000004010  00003010  2**0
                  ALLOC
 26 .comment      0000002b  0000000000000000  0000000000000000  00003010  2**0
                  CONTENTS, READONLY
SYMBOL TABLE:
0000000000000318 l    d  .interp	0000000000000000              .interp
0000000000000338 l    d  .note.gnu.property	0000000000000000              .note.gnu.property
0000000000000358 l    d  .note.gnu.build-id	0000000000000000              .note.gnu.build-id
000000000000037c l    d  .note.ABI-tag	0000000000000000              .note.ABI-tag
00000000000003a0 l    d  .gnu.hash	0000000000000000              .gnu.hash
00000000000003c8 l    d  .dynsym	0000000000000000              .dynsym
0000000000000470 l    d  .dynstr	0000000000000000              .dynstr
00000000000004f2 l    d  .gnu.version	0000000000000000              .gnu.version
0000000000000500 l    d  .gnu.version_r	0000000000000000              .gnu.version_r
0000000000000520 l    d  .rela.dyn	0000000000000000              .rela.dyn
00000000000005e0 l    d  .rela.plt	0000000000000000              .rela.plt
0000000000001000 l    d  .init	0000000000000000              .init
0000000000001020 l    d  .plt	0000000000000000              .plt
0000000000001040 l    d  .plt.got	0000000000000000              .plt.got
0000000000001050 l    d  .plt.sec	0000000000000000              .plt.sec
0000000000001060 l    d  .text	0000000000000000              .text
00000000000011e8 l    d  .fini	0000000000000000              .fini
0000000000002000 l    d  .rodata	0000000000000000              .rodata
0000000000002014 l    d  .eh_frame_hdr	0000000000000000              .eh_frame_hdr
0000000000002058 l    d  .eh_frame	0000000000000000              .eh_frame
0000000000003db8 l    d  .init_array	0000000000000000              .init_array
0000000000003dc0 l    d  .fini_array	0000000000000000              .fini_array
0000000000003dc8 l    d  .dynamic	0000000000000000              .dynamic
0000000000003fb8 l    d  .got	0000000000000000              .got
0000000000004000 l    d  .data	0000000000000000              .data
0000000000004010 l    d  .bss	0000000000000000              .bss
0000000000000000 l    d  .comment	0000000000000000              .comment
0000000000000000 l    df *ABS*	0000000000000000              crtstuff.c
0000000000001090 l     F .text	0000000000000000              deregister_tm_clones
00000000000010c0 l     F .text	0000000000000000              register_tm_clones
0000000000001100 l     F .text	0000000000000000              __do_global_dtors_aux
0000000000004010 l     O .bss	0000000000000001              completed.8061
0000000000003dc0 l     O .fini_array	0000000000000000              __do_global_dtors_aux_fini_array_entry
0000000000001140 l     F .text	0000000000000000              frame_dummy
0000000000003db8 l     O .init_array	0000000000000000              __frame_dummy_init_array_entry
0000000000000000 l    df *ABS*	0000000000000000              hello.c
0000000000000000 l    df *ABS*	0000000000000000              crtstuff.c
000000000000215c l     O .eh_frame	0000000000000000              __FRAME_END__
0000000000000000 l    df *ABS*	0000000000000000              
0000000000003dc0 l       .init_array	0000000000000000              __init_array_end
0000000000003dc8 l     O .dynamic	0000000000000000              _DYNAMIC
0000000000003db8 l       .init_array	0000000000000000              __init_array_start
0000000000002014 l       .eh_frame_hdr	0000000000000000              __GNU_EH_FRAME_HDR
0000000000003fb8 l     O .got	0000000000000000              _GLOBAL_OFFSET_TABLE_
0000000000001000 l     F .init	0000000000000000              _init
00000000000011e0 g     F .text	0000000000000005              __libc_csu_fini
0000000000000000  w      *UND*	0000000000000000              _ITM_deregisterTMCloneTable
0000000000004000  w      .data	0000000000000000              data_start
0000000000000000       F *UND*	0000000000000000              puts@@GLIBC_2.2.5
0000000000004010 g       .data	0000000000000000              _edata
00000000000011e8 g     F .fini	0000000000000000              .hidden _fini
0000000000000000       F *UND*	0000000000000000              __libc_start_main@@GLIBC_2.2.5
0000000000004000 g       .data	0000000000000000              __data_start
0000000000000000  w      *UND*	0000000000000000              __gmon_start__
0000000000004008 g     O .data	0000000000000000              .hidden __dso_handle
0000000000002000 g     O .rodata	0000000000000004              _IO_stdin_used
0000000000001170 g     F .text	0000000000000065              __libc_csu_init
0000000000004018 g       .bss	0000000000000000              _end
0000000000001060 g     F .text	000000000000002f              _start
0000000000004010 g       .bss	0000000000000000              __bss_start
0000000000001149 g     F .text	000000000000001b              main
0000000000004010 g     O .data	0000000000000000              .hidden __TMC_END__
0000000000000000  w      *UND*	0000000000000000              _ITM_registerTMCloneTable
0000000000000000  w    F *UND*	0000000000000000              __cxa_finalize@@GLIBC_2.2.5
```

## Makefile  
make命令执行时，需要一个makefile文件，以告诉make命令需要怎么样的去编译和链接程序。  

- ### [跟我一起写Makefile](https://seisman.github.io/how-to-write-makefile/index.html)  


### 入门
`Makefile`
```makefile
all: hello

hello: hello.o
	 gcc -o hello hello.o

hello.o: hello.c
	 gcc -c hello.c
     
clean:
	 rm hello.o hello
```

执行
```sh
$ make
gcc -c hello.c
gcc -o hello hello.o
```

### makefile的规则

```sh
target ... : prerequisites ...
    command
    ...
    ...
```

- `target`  可以是一个object file（目标文件），也可以是一个执行文件，还可以是一个标签（label）。对于标签这种特性，在后续的`伪目标`章节中会有叙述。  
- `prerequisites`  生成该target所依赖的文件和/或target
- `command`  该target要执行的命令（任意的shell命令）
  
这是一个文件的依赖关系，也就是说，target这一个或多个的目标文件依赖于prerequisites中的文件，其生成规则定义在command中。说白一点就是说:  
> prerequisites中如果有一个以上的文件比target文件要新的话，command所定义的命令就会被执行。

这就是makefile的规则，也就是makefile中最核心的内容。  


### 示例  
如果一个工程有`3`个头文件和`8`个c文件，为了完成前面所述的那三个规则，我们的makefile 应该是下面的这个样子的。  

```makefile
edit : main.o kbd.o command.o display.o \
        insert.o search.o files.o utils.o
    cc -o edit main.o kbd.o command.o display.o \
        insert.o search.o files.o utils.o

main.o : main.c defs.h
    cc -c main.c
kbd.o : kbd.c defs.h command.h
    cc -c kbd.c
command.o : command.c defs.h command.h
    cc -c command.c
display.o : display.c defs.h buffer.h
    cc -c display.c
insert.o : insert.c defs.h buffer.h
    cc -c insert.c
search.o : search.c defs.h buffer.h
    cc -c search.c
files.o : files.c defs.h buffer.h command.h
    cc -c files.c
utils.o : utils.c defs.h
    cc -c utils.c
clean :
    rm edit main.o kbd.o command.o display.o \
        insert.o search.o files.o utils.o
```

> 反斜杠（ \ ）是换行符的意思,这样比较便于makefile的阅读  

我们可以把这个内容保存在名字为`makefile`或`Makefile`的文件中，然后在该目录下直接输入命令 `make` 就可以生成执行文件 `edit`。如果要删除执行文件和所有的中间目标文件，那么，只要简单地执行一下 `make clean` 就可以了 

后续的那一行定义了如何生成目标文件的操作系统命令，一定要以一个 `Tab` 键作为开头。记住，make并不管命令是怎么工作的，他只管执行所定义的命令。make会比较targets文件和prerequisites文件的修改日期，如果prerequisites文件的日期要比targets文件的日期要新，或者target不存在的话，那么，make就会执行后续定义的命令  

> 如果把`Tab`换成四个空格，会报错`Makefile:4: *** missing separator.  Stop.`  

### make是如何工作的

在默认的方式下，也就是我们只输入 make 命令。那么，

1. make会在当前目录下找名字叫`Makefile`或`makefile`的文件。

2. 如果找到，它会找文件中的第一个目标文件（`target`），在上面的例子中，他会找到`edit`这个文件，并把这个文件作为最终的目标文件。

3. 如果`edit`文件不存在，或是edit所依赖的后面的 `.o` 文件的文件修改时间要比 `edit` 这个文件新，那么，他就会执行后面所定义的命令来生成 `edit` 这个文件。

4. 如果 `edit` 所依赖的 `.o` 文件也不存在，那么make会在当前文件中找目标为 `.o` 文件的依赖性，如果找到则再根据那一个规则生成 `.o` 文件。（这有点像一个堆栈的过程）

当然，你的C文件和H文件是存在的啦，于是make会生成 `.o` 文件，然后再用 .o 文件生成make的终极任务，也就是执行文件 `edit` 了。  

这就是整个make的依赖性，make会一层又一层地去找文件的依赖关系，直到最终编译出第一个目标文件。在找寻的过程中，如果出现错误，比如最后被依赖的文件找不到，那么make就会直接退出，并报错  

### makefile中使用变量

在上面的例子中，先让我们看看edit的规则：  
```makefile
edit : main.o kbd.o command.o display.o \
        insert.o search.o files.o utils.o
    cc -o edit main.o kbd.o command.o display.o \
        insert.o search.o files.o utils.o
```

我们可以看到 `.o` 文件的字符串被重复了两次，如果我们的工程需要加入一个新的 `.o` 文件，那么我们需要在两个地方加（应该是三个地方，还有一个地方在clean中）。当然，我们的makefile并不复杂，所以在两个地方加也不累，但如果makefile变得复杂，那么我们就有可能会忘掉一个需要加入的地方，而导致编译失败。所以，为了makefile的易维护，在makefile中我们可以使用变量。makefile的变量也就是一个字符串，理解成C语言中的宏可能会更好。  

比如，我们声明一个变量，叫 `objects` ， `OBJECTS` ， `objs` ， `OBJS` ， `obj` 或是 `OBJ` ，反正不管什么啦，只要能够表示obj文件就行了。我们在makefile一开始就这样定义：  

```makefile
objects = main.o kbd.o command.o display.o \
     insert.o search.o files.o utils.o
```

于是，我们就可以很方便地在我们的makefile中以 `$(objects)` 的方式来使用这个变量了，于是我们的改良版makefile就变成下面这个样子：
```makefile
objects = main.o kbd.o command.o display.o \
    insert.o search.o files.o utils.o

edit : $(objects)
    cc -o edit $(objects)
main.o : main.c defs.h
    cc -c main.c
kbd.o : kbd.c defs.h command.h
    cc -c kbd.c
command.o : command.c defs.h command.h
    cc -c command.c
display.o : display.c defs.h buffer.h
    cc -c display.c
insert.o : insert.c defs.h buffer.h
    cc -c insert.c
search.o : search.c defs.h buffer.h
    cc -c search.c
files.o : files.c defs.h buffer.h command.h
    cc -c files.c
utils.o : utils.c defs.h
    cc -c utils.c
clean :
    rm edit $(objects)
```

于是如果有新的 `.o` 文件加入，我们只需简单地修改一下 `objects` 变量就可以了。  

### 让make自动推导
GNU的make很强大，它可以自动推导文件以及文件依赖关系后面的命令，于是我们就没必要去在每一个 `.o` 文件后都写上类似的命令，因为，我们的make会自动识别，并自己推导命令。

只要make看到一个 `.o` 文件，它就会自动的把 `.c` 文件加在依赖关系中，如果make找到一个 `whatever.o` ，那么 `whatever.c` 就会是 `whatever.o` 的依赖文件。并且 `cc -c whatever.c` 也会被推导出来，于是，我们的makefile再也不用写得这么复杂。我们的新makefile又出炉了。
```makefile
objects = main.o kbd.o command.o display.o \
    insert.o search.o files.o utils.o

edit : $(objects)
    cc -o edit $(objects)

main.o : defs.h
kbd.o : defs.h command.h
command.o : defs.h command.h
display.o : defs.h buffer.h
insert.o : defs.h buffer.h
search.o : defs.h buffer.h
files.o : defs.h buffer.h command.h
utils.o : defs.h

.PHONY : clean
clean :
    rm edit $(objects)
```

> `.PHONY` 表示 `clean` 是个伪目标文件  

### 清空目标文件的规则
每个Makefile中都应该写一个清空目标文件（ `.o` 和执行文件）的规则，这不仅便于重编译，也很利于保持文件的清洁。这是一个“修养”,一般的风格都是：
```makefile
clean:
    rm edit $(objects)
```
更为稳健的做法是：  
```makefile
.PHONY : clean
clean :
    -rm edit $(objects)
```
前面说过， `.PHONY` 表示 `clean` 是一个`伪目标`。而在 `rm` 命令前面加了一个小减号的意思就是，也许某些文件出现问题，但不要管，继续做后面的事。当然， clean 的规则不要放在文件的开头，不然，这就会变成make的默认目标，相信谁也不愿意这样。不成文的规矩是——“clean从来都是放在文件的最后”。  

### make的工作方式
GNU的make工作时的执行步骤如下：（其它的make也是类似）

1. 读入所有的Makefile。
2. 读入被include的其它Makefile。
3. 初始化文件中的变量。
4. 推导隐晦规则，并分析所有规则。
5. 为所有的目标文件创建依赖关系链。
6. 根据依赖关系，决定哪些目标要重新生成。
7. 执行生成命令。

1-5步为第一个阶段，6-7为第二个阶段。第一个阶段中，如果定义的变量被使用了，那么，make会把其展开在使用的位置。但make并不会完全马上展开，make使用的是拖延战术，如果变量出现在依赖关系的规则中，那么仅当这条依赖被决定要使用了，变量才会在其内部展开。




















