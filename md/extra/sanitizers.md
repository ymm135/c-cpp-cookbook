- # Sanitizers工具包  

https://github.com/google/sanitizers   

- AddressSanitizer：检测内存错误，例如释放已经释放的内存、再次access已经释放后的内存等；  
- LeakSanitizer：检测内存泄露，例如未释放的内存；  
- MemorySanitizer：检测未初始化的内存，例如stack或者heap等在写入之前就使用。  

Sanitizers目前已经默认加到了GCC和LLVM中，因此无需额外安装。  

> GCC：并不只是编译器，更是编译器套件,基于 Make开发，使用LD作为链接器，使用gdb调试  
> Clang/LLVM  基于CMake开发，使用lld作为链接器，使用LLDB调试  

# AddressSanitizer  
## 安装/编译  

依赖环境:  
AddressSanitizer is a part of `LLVM` starting with version `3.1` and a part of `GCC` starting with version `4.8` If you prefer to build from source, see AddressSanitizerHowToBuild.  


编译参数:  
```sh
-fsanitize=<check>      Turn on runtime checks for various forms of undefined or suspicious behavior. See user manual for available checks
```

运行启用:  
```sh
make CFLAGS+="-g -fsanitize=address" LDFLAGS+="-fsanitize=address" 
```

> `-g` 选项不是必须的  

查看依赖库:  
```sh
readelf -d src/redis-server | grep -i asan
 0x0000000000000001 (NEEDED)             Shared library: [libasan.so.5]
```

```c
4222 int *p;
4223 int main(int argc, char **argv) {
4224     struct timeval tv;
4225     int j;
4226 
4227     printf("haha-----------------\n");
4228     p = malloc(100);
4229     p[0]=1;
4230     p[99]=100;
4231     p=0;
4232 
4233 #ifdef REDIS_TEST
```

在redis的server.c中增加内存泄漏的代码，启动时会报错:  
```sh
==17594==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x60b00000027c at pc 0x5597d3ea7988 bp 0x7fff5d164880 sp 0x7fff5d164870
WRITE of size 4 at 0x60b00000027c thread T0
    #0 0x5597d3ea7987 in main /root/test-redis/redis-5.0.14/src/server.c:4230
    #1 0x7f3bbf47a082 in __libc_start_main ../csu/libc-start.c:308
    #2 0x5597d3ea920d in _start (/root/test-redis/redis-5.0.14/src/redis-server+0x9720d)

Address 0x60b00000027c is a wild pointer.
SUMMARY: AddressSanitizer: heap-buffer-overflow /root/test-redis/redis-5.0.14/src/server.c:4230 in main
Shadow bytes around the buggy address:
  0x0c167fff7ff0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c167fff8000: fa fa fa fa fa fa fa fa fd fd fd fd fd fd fd fd
  0x0c167fff8010: fd fd fd fd fd fa fa fa fa fa fa fa fa fa 00 00
  0x0c167fff8020: 00 00 00 00 00 00 00 00 00 00 04 fa fa fa fa fa
  0x0c167fff8030: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
=>0x0c167fff8040: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa[fa]
  0x0c167fff8050: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c167fff8060: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c167fff8070: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c167fff8080: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c167fff8090: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07 
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
  Shadow gap:              cc
==17594==ABORTING
```

问题: `==59647==ASan runtime does not come first in initial library list; you should either link runtime to your application or manually preload it with LD_PRELOAD.`  

增加编译参数:``

这里出现了一个问题,使用ldd查看ELF文件，可以看到`libasan.so.5 => /lib/x86_64-linux-gnu/libasan.so.5 (0x00007f427ecc2000)`, 但是使用`readelf -d`却看不到`libasan`  



## 网络环境模拟及Bug复现  



