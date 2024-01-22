- # CMake 

目录: 
- [基础知识](#基础知识)
  - [编译原理及基础](#编译原理及基础)
  - [静态库编译与动态库编译](#静态库编译与动态库编译)
    - [静态库编译](#静态库编译)
    - [动态库编译](#动态库编译)
    - [静态库依赖](#静态库依赖)
  - [常用指令](#常用指令)
    - [常用编译参数](#常用编译参数)
    - [静态库与动态库的引用](#静态库与动态库的引用)
    - [代码示例](#代码示例)
    - [文件结构](#文件结构)



## 基础知识
### 编译原理及基础  

[C 编译及运行原理](../base/c-build.md)  


### 静态库编译与动态库编译  

在 C/C++ 项目中，选择使用静态库（`.a` 文件）或动态库（`.so` 文件）进行编译取决于多种因素。每种方法都有其优缺点，适用于不同的场景。

#### 静态库编译

**优点**:
1. **独立性**：静态库在编译时被整合到最终的可执行文件中，使得该文件成为一个独立的实体，不依赖于外部的库文件。这简化了部署，因为不需要担心库文件的存在或版本问题。

2. **性能**：有时候静态链接可以提供更优的性能，因为所有代码都在一个二进制文件中，减少了运行时的库加载和符号解析开销。

3. **兼容性**：使用静态库可以避免库版本更新导致的兼容性问题。

**缺点**:
1. **体积**：静态链接会增加最终二进制文件的大小，因为每个库的代码都被复制到其中。

2. **更新问题**：如果静态库更新，所有使用该库的应用程序都需要重新编译和部署。

3. **许可和版权问题**：使用静态库可能涉及更严格的许可要求，尤其是在使用第三方库时。

#### 动态库编译

**优点**:
1. **节省空间**：动态库在多个程序间共享，因此可以减少磁盘和内存的使用。

2. **易于更新**：更新库文件时，所有使用该动态库的应用程序都会自动使用新版本，无需重新编译。

3. **模块化**：动态链接支持更高程度的模块化和重用，便于维护和更新。

**缺点**:
1. **依赖问题**：程序依赖于外部的库文件，如果库文件缺失或版本不匹配，程序可能无法运行。

2. **性能开销**：动态链接可能会带来额外的运行时开销，因为需要在程序启动时加载库。

3. **安全和兼容性**：库的更新可能引入新的漏洞或与旧程序不兼容。

- #### 选择依据

选择使用静态库还是动态库通常基于以下考虑：
- **部署环境**：如果目标环境对应用程序的大小不敏感或有严格的依赖管理，静态链接可能更合适。
- **性能要求**：静态链接可能在启动时间和运行效率上有轻微优势。
- **维护和更新频率**：高频更新或需要高度模块化的系统更适合动态链接。
- **版权和许可**：许可条款可能影响链接类型的选择。

总之，没有绝对的“最佳选择”，只有最适合特定项目和环境需求的选择。

#### 静态库依赖  

```sh
objdump -t poco/lib/libPocoFoundation.a
```

输出结果:
```sh
Pipe.o:     file format elf64-x86-64

SYMBOL TABLE:
0000000000000000 l    df *ABS*  0000000000000000 Pipe.cpp
0000000000000000 l    d  .text  0000000000000000 .text
0000000000000000 l    d  .data  0000000000000000 .data

SyslogChannel.o:     file format elf64-x86-64

SYMBOL TABLE:
0000000000000000 l    df *ABS*  0000000000000000 SyslogChannel.cpp
```

依赖的都是一些`*.o`文件。  


### 常用指令  

CMake 是一个非常强大的跨平台自动化构建系统，它使用 `CMakeLists.txt` 文件来定义构建过程。下面是一些常用的 CMake 编译参数、代码示例和典型的文件结构。

#### 常用编译参数

1. **CMAKE_BUILD_TYPE**：定义构建类型，通常为 `Debug`、`Release`、`RelWithDebInfo`（发布版带调试信息）和 `MinSizeRel`（最小尺寸发布）。
   
   ```cmake
   set(CMAKE_BUILD_TYPE Release)
   ```

2. **CMAKE_CXX_STANDARD**：设置 C++ 标准版本。

   ```cmake
   set(CMAKE_CXX_STANDARD 17)
   ```

3. **add_executable** 和 **add_library**：用于添加可执行文件或库。

   ```cmake
   add_executable(my_app main.cpp)
   add_library(my_lib STATIC lib.cpp)
   ```

4. **find_package**：用于查找并加载外部库。

   ```cmake
   find_package(Boost REQUIRED)
   ```

5. **target_link_libraries**：链接库到你的项目。

   ```cmake
   target_link_libraries(my_app PRIVATE my_lib)
   ```

6. **include_directories**：包含头文件目录。

   ```cmake
   include_directories(include/)
   ```

#### 静态库与动态库的引用  

在 CMake 中引用外部的静态库和动态库涉及到几个步骤，主要包括定位库文件、包含头文件目录以及在目标链接中指定库。这里是具体如何做的：


1. **定位动态库文件**：
   和静态库一样，使用 `find_library` 来查找动态库：

   ```cmake
   find_library(EXAMPLE_LIBRARY
     NAMES example
     PATHS /path/to/lib)
   ```

2. **包含头文件目录**：
   如果需要，包含头文件目录：

   ```cmake
   include_directories(/path/to/include)
   ```

3. **链接动态库**：
   使用 `target_link_libraries` 链接动态库：

   ```cmake
   add_executable(my_app main.cpp)
   target_link_libraries(my_app ${EXAMPLE_LIBRARY})
   ```

- #### 注意事项

- **路径**：`/path/to/lib` 和 `/path/to/include` 应该替换为实际库文件和头文件的路径。
- **库名称**：`example` 应该替换为实际库的名称。注意，对于 Unix-like 系统，你通常不包括前缀 `lib` 和后缀 `.a` 或 `.so`；CMake 会自动处理这些。
- **版本控制**：对于动态库，确保运行时环境中存在正确版本的库文件。
- **链接顺序**：在使用 `target_link_libraries` 时，链接顺序可能很重要，尤其是在有多个依赖库时。

使用这些方法，你可以在 CMake 项目中引入外部静态库和动态库，确保你的应用程序可以正确地编译和链接这些库。

#### 代码示例

一个简单的 `CMakeLists.txt` 文件示例：

```cmake
cmake_minimum_required(VERSION 3.10)

project(MyProject VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_executable(MyApp main.cpp)

find_package(Boost REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})
target_link_libraries(MyApp PRIVATE ${Boost_LIBRARIES})
```

#### 文件结构

对于中小型项目，一个常见的文件结构可能是：

```
MyProject/
|-- CMakeLists.txt      # 主 CMake 配置文件
|-- main.cpp            # 应用程序源代码
|-- include/            # 头文件目录
|   `-- my_lib.h
|-- src/                # 源文件目录
|   `-- my_lib.cpp
|-- libs/               # 外部或自定义库目录
|   |-- lib1/
|   `-- lib2/
`-- build/              # 构建目录（通常在 .gitignore 中）
```

在这个结构中，`CMakeLists.txt` 位于项目根目录。源代码放在 `src/` 目录，头文件放在 `include/` 目录。所有外部或自定义库位于 `libs/` 目录。`build/` 目录用于存放构建过程中生成的文件，通常不会加入版本控制。




