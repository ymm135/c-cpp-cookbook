- # C 编译及运行原理  
[参考文章](https://www3.ntu.edu.sg/home/ehchua/programming/cpp/gcc_make.html)  

## GCC编译(GNU Compiler Collection)
[gcc源码](https://github.com/gcc-mirror/gcc)  

gcc 与 g++ 分别是 gnu 的 c & c++ 编译器 gcc/g++ 在执行编译工作的时候，总共需要4步：  
- 1. 预处理,生成 .i 的文件[预处理器cpp]
- 2. 将预处理后的文件转换成汇编语言, 生成文件 .s [编译器egcs]
- 3. 将汇编变为目标代码(机器代码)生成 .o 的文件[汇编器as]
- 4. 连接目标代码, 生成可执行程序 [链接器ld]

### 编译参数

- `-v`  选项查看详细的编译过程,调试时使用
- 

### 编译过程
[参考文章](https://www.cnblogs.com/burner/p/gcc-bian-yiccde-si-ge-guo-cheng.html)  



## BIN运行