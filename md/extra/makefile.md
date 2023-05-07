- # Makefile

## 原理
### 语法  
```sh
target: prerequisites
<TAB> recipe
```

```makefile
say_hello:
	echo "Hello World"
```

输出:  
```sh
echo "Hello World"
Hello World
```

不显示指令，可以使用`@`  
```makefile
say_hello:
	@echo "Hello World"
```

输出:  
```sh
Hello World
```

增加变量: 
```makefile
CC = gcc

all:
	@echo ${CC}
```

输出:  
```
# make
gcc

# make CC=clang
clang
```

### makefile调试  

- #### make -n  
打印指令而不执行  

- #### make SHELL="/bin/bash -vx"  
调试所有shell指令  

```sh
+ for subdir in $list
+ echo 'Making all in htp'
Making all in htp
+ test htp = .
+ local_target=all
+ CDPATH=:
+ cd htp
```

> 类似于shell调试增加`-x`选项  





### 隐式规则(Implicit Rules)  
- `CC`: Program for compiling C programs; default cc
- `CXX`: Program for compiling C++ programs; default g++
- `CFLAGS`: Extra flags to give to the C compiler
- `CXXFLAGS`: Extra flags to give to the C++ compiler
- `CPPFLAGS`: Extra flags to give to the C preprocessor
- `LDFLAGS`: Extra flags to give to compilers when they are supposed to invoke the linker  





## 应用

