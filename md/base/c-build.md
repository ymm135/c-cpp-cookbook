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

> 默认输出可执行文件称为“ a.exe”（Windows）或“ a.out”（Unixes 和 Mac OS X）  

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
- `-o`  指定输出的可执行文件名
- `-Wall`  打印全部警告信息
- `-E`  只激活预处理,这个不生成文件, 你需要把它重定向到一个输出文件里面  `gcc -E test.c -o test.i`  
- `-S`  只激活预处理和编译，就是指把文件编译成为汇编代码  

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

由此可见，gcc确实进行了预处理，它把”stdio.h”的内容插入到hello.i文件中  

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
Gcc首先要检查代码的规范性、是否有语法错误等，以确定代码的实际要做的工作，在检查无误后，Gcc把代码翻译成汇编语言。用户可以使用”-S”选项来进行查看，该选项只进行编译而不进行汇编，生成汇编代码  

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
- `静态库`是指编译链接时，把库文件的代码全部加入到可执行文件中，因此生成的文件比较大，但在运行时也就不再需要库文件了。其后缀名一般为”.a”。  
- `动态库`与之相反，在编译链接时并没有把库文件的代码加入到可执行文件中，而是在程序执行时由运行时链接文件加载库，这样可以节省系统的开销。动态库一般后缀名为”.so”，如前面所述的libc.so.6就是动态库。Gcc在编译时默认使用动态库。

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

## Makefile  
