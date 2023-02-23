- # c-vscode

- [在线调试](#在线调试)
  - [插件](#插件)
  - [配置](#配置)
  - [gdb参数配置](#gdb参数配置)
  - [gdb调试c及glibc源码](#gdb调试c及glibc源码)
  - [vscode 阅读c及glibc源码](#vscode-阅读c及glibc源码)
  - [vscode 在线调试c及glibc源码](#vscode-在线调试c及glibc源码)
  - [patchelf 切换bin文件的libc版本](#patchelf-切换bin文件的libc版本)
  - [内核调试](#内核调试)


## 在线调试
[官方文档](https://code.visualstudio.com/docs/cpp/config-linux)  
### 插件
[C/C++ for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)  

依赖
```sh
sudo apt-get install build-essential gdb
```


### 配置

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "gdb debug c/cpp",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}/${fileBasenameNoExtension}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "为 gdb 启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
            ],
            "sourceFileMap":{
                // "remote": "local"
                "/build/glibc-SzIz7B": "/usr/src/glibc" //需要下载glibc的源码文件，修改这里的配置
            },
            "preLaunchTask": "c-cpp-build"
        }
    ]
}
```

### gdb参数配置
- ### [100个gdb小技巧](https://wizardforcel.gitbooks.io/100-gdb-tips/content/print-large-array.html)  

汇编格式配置
```json
{
    "setupCommands": [
                {
                    "description": "为 gdb 启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
}
```

比如gdb指令为:`show debug-file-directory`, 需要再在vscode调试控制台执行:`-exec show debug-file-directory`
```sh
-exec show debug-file-directory
The directory where separate debug symbols are searched for is "/usr/lib/debug".
-exec -enable-pretty-printing
result-class: done
```

gdb执行效果
```sh
(gdb) directory /usr/src/glibc/glibc-2.31
Source directories searched: /usr/src/glibc/glibc-2.31:$cdir:$cwd
```

也可以在gdb配置中增加参数:  
```sh

```

查看内存信息`x/nfu addr`  
gdb中使用“x”命令来打印内存的值，格式为“x/nfu addr”。含义为以f格式打印从addr开始的n个长度单元为u的内存值。参数具体含义如下：
a）n：输出单元的个数。
b）f：是输出格式。比如x是以16进制形式输出，o是以8进制形式输出,等等。  
c）u：标明一个单元的长度。b是一个byte，h是两个byte（halfword），w是四个byte（word），g是八个byte（giant word）。

### gdb调试c及glibc源码

查看glibc版本
```sh
root@matrix:~# ldd --version
ldd (Ubuntu GLIBC 2.31-0ubuntu9.9) 2.31
Copyright (C) 2020 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
Written by Roland McGrath and Ulrich Drepper.
```

- gcc (gnu collect compiler)是一组编译工具的总称。它主要完成的工作任务是“预处理”和“编译”，以及提供了与编译器紧密相关的运行库的支持，如libgcc_s.so、libstdc++.so等。
- libc (C 运行库) Linux下的ANSI C的函数库 
- glibc (C 运行库) Linux下的GUN C函数库 

> ubuntu系统中libc库路径: /usr/lib/x86_64-linux-gnu/libc-2.31.so  


开始调试: 
```sh
sudo apt-get install libc6-dbg
```

> 我们可以通过readelf命令来验证这些共享库确实是带有调试信息的  

```sh
# readelf -S /usr/lib/x86_64-linux-gnu/libc.so.6 | grep -i debug
  [66] .gnu_debuglink    PROGBITS         0000000000000000  001ee294
```

如果出现上面输出结果中以.debug开头的 sections，那么说明是带调试信息的。  

glibc 源码
```sh
sudo apt-get install glibc-source
cd /usr/src/glibc
sudo tar -xvf glibc-2.31.tar.xz
```

目录结构
```sh
root@matrix:/usr/src/glibc# ls -l 
total 17008
drwxr-xr-x 12 root root     4096 Feb 15 14:47 debian
drwxr-xr-x 70 root root     4096 Feb 15 14:48 glibc-2.31
-rw-r--r--  1 root root 17407584 Apr  7  2022 glibc-2.31.tar.xz
```

测试源码
```c
#include <stdio.h>
#include <stdlib.h>

int main (void)
{
	//create char pointer
	char *ptr;

	//ptr is now the memory address of the beginning of this 10 char element array.
	//we used the sizeof() function to make sure that the size of memory allocated is 10 units on any host
	ptr = malloc(10 * sizeof(char));

	//if malloc fails, our ptr pointer will be pointing towards a NULL value, this checks for that
	if (ptr == NULL)
	{
		printf("Memory could not be allocated.");
		return 1;
	}
	else 
	{
		printf("Memory was successfully allocated.");
		//this makes sure we don't keep memory allocated that we're not using.
		free(ptr);
		return 0;
	}
}
```

编译后的关联库:  
```sh
# ldd main
	linux-vdso.so.1 (0x00007fffb3bfb000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fbff2e53000)
	/lib64/ld-linux-x86-64.so.2 (0x00007fbff3054000)
```

```sh
# gdb -q ./main
Reading symbols from ./main...
(gdb) directory /usr/src/glibc/glibc-2.31/malloc
Source directories searched: /usr/src/glibc/glibc-2.31/malloc:$cdir:$cwd
(gdb) show debug-file-directory
The directory where separate debug symbols are searched for is "/usr/lib/debug".
(gdb) b main.c:11
Breakpoint 1 at 0x1195: file /root/work/c-cpp-cookbook/code/test/main.c, line 11.
(gdb) r
Starting program: /root/work/c-cpp-cookbook/code/test/main 

Breakpoint 1, main () at /root/work/c-cpp-cookbook/code/test/main.c:11
11              ptr = malloc(10 * sizeof(char));
(gdb) b malloc
Breakpoint 2 at 0x7ffff7e690e0: malloc. (2 locations)
(gdb) n

Breakpoint 2, __GI___libc_malloc (bytes=10) at malloc.c:3023
3023    {
```

> 还是需要增加到具体源码文件的当前目录  

目前gdb已经可以调试了，但是vscode的`c/c++`插件还是无法进入源码和调试

### vscode 阅读c及glibc源码
`launch.json`配置  
```sh
"sourceFileMap":{
                "/build/glibc-S9d2JN": "/usr/src/glibc"
            },
```



### vscode 在线调试c及glibc源码  

编译指令
```sh
/usr/bin/gcc -g -O0 /root/work/c-cpp-cookbook/code/test/main.c -o /root/work/c-cpp-cookbook/code/test/main
```

可以增加`-Wl,--verbose`, 可以看见编译和链接的过程。但是最终问题还是因为系统的libc库不能调试，我手动编译了glibc，查看调试信息如下:  
```sh
/work/c-cpp-cookbook/code/test/main
Using built-in specs.
COLLECT_GCC=/usr/bin/gcc
COLLECT_LTO_WRAPPER=/usr/lib/gcc/x86_64-linux-gnu/9/lto-wrapper
OFFLOAD_TARGET_NAMES=nvptx-none:hsa
OFFLOAD_TARGET_DEFAULT=1
Target: x86_64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Ubuntu 9.4.0-1ubuntu1~20.04.1' --with-bugurl=file:///usr/share/doc/gcc-9/README.Bugs --enable-languages=c,ada,c++,go,brig,d,fortran,objc,obj-c++,gm2 --prefix=/usr --with-gcc-major-version-only --program-suffix=-9 --program-prefix=x86_64-linux-gnu- --enable-shared --enable-linker-build-id --libexecdir=/usr/lib --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-gnu-unique-object --disable-vtable-verify --enable-plugin --enable-default-pie --with-system-zlib --with-target-system-zlib=auto --enable-objc-gc=auto --enable-multiarch --disable-werror --with-arch-32=i686 --with-abi=m64 --with-multilib-list=m32,m64,mx32 --enable-multilib --with-tune=generic --enable-offload-targets=nvptx-none=/build/gcc-9-Av3uEd/gcc-9-9.4.0/debian/tmp-nvptx/usr,hsa --without-cuda-driver --enable-checking=release --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu
Thread model: posix
gcc version 9.4.0 (Ubuntu 9.4.0-1ubuntu1~20.04.1) 
COLLECT_GCC_OPTIONS='-v' '-g' '-O0' '-o' '/root/work/c-cpp-cookbook/code/test/main' '-mtune=generic' '-march=x86-64'
 /usr/lib/gcc/x86_64-linux-gnu/9/cc1 -quiet -v -imultiarch x86_64-linux-gnu /root/work/c-cpp-cookbook/code/test/main.c -quiet -dumpbase main.c -mtune=generic -march=x86-64 -auxbase main -g -O0 -version -fasynchronous-unwind-tables -fstack-protector-strong -Wformat -Wformat-security -fstack-clash-protection -fcf-protection -o /root/work/c-cpp-cookbook/ccPAb907.s
```

编译指令
```sh
cd /usr/src/glibc/glibc-2.31
mkdir build && cd build
mkdir /usr/local/glibc
apt install bison -y # 安装依赖
CFLAG="-g -g3 -ggdb -gdwarf-4 -Og -Wno-error -fno-stack-protector" ../configure --prefix=/usr/local/glibc
make -j4
```

查看libc的调试信息，这样才是可以调试的:  
```sh
# readelf -S /usr/src/glibc/glibc-2.31/build/libc.so.6 | grep -i debug
  [66] .debug_aranges    PROGBITS         0000000000000000  001bde40
  [67] .debug_info       PROGBITS         0000000000000000  001d18a0
  [68] .debug_abbrev     PROGBITS         0000000000000000  00aeb6c7
  [69] .debug_line       PROGBITS         0000000000000000  00bf4b7b
  [70] .debug_str        PROGBITS         0000000000000000  00de968d
  [71] .debug_loc        PROGBITS         0000000000000000  00e16303
  [72] .debug_ranges     PROGBITS         0000000000000000  010cf64d
```

可以省略`make install`  
```sh
root@matrix:/usr/src/glibc/glibc-2.31/build# ls -l /usr/local/glibc
total 32
drwxr-xr-x  2 root root 4096 Feb 16 15:51 bin
drwxr-xr-x  2 root root 4096 Feb 16 15:51 etc
drwxr-xr-x 22 root root 4096 Feb 16 15:51 include
drwxr-xr-x  3 root root 4096 Feb 16 15:51 lib
drwxr-xr-x  3 root root 4096 Feb 16 15:51 libexec
drwxr-xr-x  2 root root 4096 Feb 16 15:51 sbin
drwxr-xr-x  4 root root 4096 Feb 16 15:51 share
drwxr-xr-x  3 root root 4096 Feb 16 15:51 var
```

> 直接替换系统的libc库，没有成功，可以使用gdb切换库  

```sh
set env LD_LIBRARY_PATH=/usr/local/glibc/lib
```

这就需要替换了，之前`libc.so.6 -> libc-2.31.so`,直接拷贝`cp /usr/src/glibc/glibc-2.31/build/libc.so /usr/lib/x86_64-linux-gnu/libc.so.6`  
如果需要恢复，直接执行`ldconfig -v`  

> 默认搜寻/lilb和/usr/lib，以及配置文件/etc/ld.so.conf内所列的目录下的库文件。  
> 往/lib和/usr/lib里面加东西，是不用修改/etc/ld.so.conf文件的，但是添加完后需要调用下ldconfig，不然添加的library会找不到。  
> 如果添加的library不在/lib和/usr/lib里面的话，就一定要修改/etc/ld.so.conf文件，往该文件追加library所在的路径，然后也需要重新调用下ldconfig命令。  


> 还是不行，既然gdb可以源码调试，那有没有可能不是`libc.so.6`的问题。  


`Unable to open ‘raise.c’: Unable to read file (Error: File not found (/build/glibc-ZN95T4/glibc-2.31/sysdeps/unix/sysv/linux/raise.c))`  

最终发现还是vscode找不到对应的目录`/build/`  

<br>
<div align=center>
    <img src="../../res/image/glic-source.png" width="100%"></img>  
</div>
<br>

修改路劲:
```json
 "sourceFileMap":{
                // "remote": "local"
                "/build/glibc-SzIz7B": "/usr/src/glibc" //需要下载glibc的源码文件，修改这里的配置
            },
```

调试过程中会遇到`<optimized out>`  

添加编译选项`-O0`，意思是不进行编译优化，gdb在默认情况下会使用`-O2`。
使用-O0选项调试的时候就会顺畅了,发布项目的时候不用再使用 -O0参数项，gcc 默认编译或加上-O2优化编译会提高程序运行速度。在muduo源码中使用-O2选项，调试的时候对其Makefile进行修改即可。


最终调试的界面:
<br>
<div align=center>
    <img src="../../res/image/vsdebug-1.png" width="100%"></img>  
</div>
<br>

> 还需要注意，如果有其他依赖库，如何调试呢？还是需要确保依赖库`-g`拥有调试符号表.  


### patchelf 切换bin文件的libc版本 

```sh
apt install patchelf
```

改变链接器+改变搜索路径
```sh
# 编译
/usr/bin/gcc -g3 -O0 /root/work/c-cpp-cookbook/code/test/main.c -o /root/work/c-cpp-cookbook/code/test/main

# 替换ld 
patchelf --set-interpreter /usr/local/glibc/lib/ld-2.31.so target_file

# 替换libc 
patchelf --replace-needed libc.so.6 /usr/local/glibc/lib/libc-2.31.so target_file
```

`target_file` 就是目标的bin文件  


vscode调试时，如果无法进入断点，可以手动输入命令。`-exec b malloc`  


### 内核调试  

- ### [ubuntu20 搭建内核调试环境](https://github.com/ymm135/golang-cookbook/blob/master/md/other/ubuntu-kernel-debug.md)  


Linux 内核中的调试符号包含源代码级别的信息，如函数名称、函数调用约定、以及源代码行号到指令的映射。这些信息在调试或剖析内核的时候非常有用。我们需要获得任何内核的调试符号。  

通常来说，有 2 种方法可以使用调试符号：  
- 使用源码构建带有调试符号的内核源代码，通常适用于自己修改源码编译的场景，构建内核的过程依据编译选项，一般会耗费比较长的时间；  
- 使用现成包含编译好的调试符号包进行安装；  


为了方便，可以使用现成编译好的环境。 可以从[ubuntu官网](https://launchpad.net/ubuntu/impish)下载  

关键字为`linux-image-unsigned-`, 也可以加上内核版本`linux-image-unsigned-5.4.0-135`  

```sh
$ cat /proc/version
Linux version 5.4.0-135-generic (buildd@lcy02-amd64-066) (gcc version 9.4.0 (Ubuntu 9.4.0-1ubuntu1~20.04.1)) #152-Ubuntu SMP Wed Nov 23 20:19:22 UTC 2022
```

[linux-image-unsigned-5.4.0-135-generic-dbgsym](https://launchpad.net/ubuntu/focal/+package/linux-image-unsigned-5.4.0-135-generic-dbgsym)  

或者可以通过系统安装  
```sh
sudo apt-get install linux-image-$(uname -r)-dbgsym
```

> Get:1 http://ddebs.ubuntu.com focal-updates/main amd64 linux-image-unsigned-5.4.0-135-generic-dbgsym amd64 5.4.0-135.152 [970 MB]  

是否安装成功`ls -l /usr/lib/debug/boot`  
```sh
ls -l /usr/lib/debug/boot
total 770816
-rw-r--r-- 1 root root 789310448 Nov 23 19:51 vmlinux-5.4.0-135-generic
```

为了将调试符号与源码关联查看，我们还需要安装源码，然后与安装的 dbgsym 进行关联。  

```sh
$ sudo apt-cache search linux-source
linux-source - Linux kernel source with Ubuntu patches
linux-source-5.4.0 - Linux kernel source for version 5.4.0 with Ubuntu patches
linux-gkeop-source-5.4.0 - Linux kernel source for version 5.4.0 with Ubuntu patches
linux-hwe-5.11-source-5.11.0 - Linux kernel source for version 5.11.0 with Ubuntu patches
linux-hwe-5.13-source-5.13.0 - Linux kernel source for version 5.13.0 with Ubuntu patches
linux-hwe-5.15-source-5.15.0 - Linux kernel source for version 5.15.0 with Ubuntu patches
linux-hwe-5.8-source-5.8.0 - Linux kernel source for version 5.8.0 with Ubuntu patches
linux-intel-5.13-source-5.13.0 - Linux kernel source for version 5.13.0 with Ubuntu patches

$ apt install linux-source-5.4.0
$ cd /usr/src
$ tar -jxvf linux-source-5.4.0.tar.bz2
$ cd /usr/src/linux-source-5.4.0
```

测试效果  
需要 gdb 首先获取到 vmlinux-5.13.0-20-generic 的编译目录，使用 `list *__x64_sys_mount` 会提示对应的编译目录，如果我们在 `/usr/src` 目录已经安装了源码，建立快捷方式可  

```
mkdir -p /build/linux-EI0ZHT
ln -s /usr/src/linux-source-5.4.0 /build/linux-EI0ZHT/linux-5.4.0

$ gdb /usr/lib/debug/boot/vmlinux-5.4.0-135-generic
list *__x64_sys_mount
0xffffffff812fbf00 is in __x64_sys_mount (/build/linux-EI0ZHT/linux-5.4.0/fs/namespace.c:3392).
warning: Source file is more recent than executable.
3387		kfree(kernel_type);
3388	out_type:
3389		return ret;
3390	}
3391	
3392	SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
3393			char __user *, type, unsigned long, flags, void __user *, data)
3394	{
3395		return ksys_mount(dev_name, dir_name, type, flags, data);
3396	}
(gdb) disassemble *__x64_sys_mount
Dump of assembler code for function __x64_sys_mount:
   0xffffffff812fbf00 <+0>:	callq  0xffffffff81c01ab0 <__fentry__>
   0xffffffff812fbf05 <+5>:	push   %rbp
   0xffffffff812fbf06 <+6>:	mov    0x70(%rdi),%r9
   0xffffffff812fbf0a <+10>:	mov    0x38(%rdi),%rcx
   0xffffffff812fbf0e <+14>:	mov    0x60(%rdi),%rdx
   0xffffffff812fbf12 <+18>:	mov    0x68(%rdi),%rsi
   0xffffffff812fbf16 <+22>:	mov    0x48(%rdi),%r8
   0xffffffff812fbf1a <+26>:	mov    %r9,%rdi
   0xffffffff812fbf1d <+29>:	mov    %rsp,%rbp
   0xffffffff812fbf20 <+32>:	callq  0xffffffff812fbe30 <ksys_mount>
   0xffffffff812fbf25 <+37>:	pop    %rbp
   0xffffffff812fbf26 <+38>:	cltq   
   0xffffffff812fbf28 <+40>:	retq   
End of assembler dump.
``` 

这属于调试内核了，也可以使用vscode启动`vmlinux-5.4.0-135-generic` 在线调试  

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "gdb内核启动",
            "type": "cppdbg",
            "request": "launch",
            "miDebuggerServerAddress": "127.0.0.1:1234",
            "program": "${workspaceFolder}/vmlinux",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "为 gdb 启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description":  "将反汇编风格设置为 Intel",
                    "text": "-gdb-set disassembly-flavor intel",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```








