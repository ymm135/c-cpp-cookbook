- # qemu使用及内核调试  

## macos 安装 

```sh
brew install qemu
```

> VirtualBox是一个仅限于x86和amd64架构的虚拟化软件。 

创建虚拟盘，用户安装系统   

```sh
qemu-img create -f qcow2 mydisk.qcow2 20G
```

> qemu-img snapshot 快照相关操作  
> qemu-img resize  调整大小  

安装系统
```sh
qemu-system-aarch64 \
-m 8G \
-smp 6 \
-cdrom /Users/ymm/Downloads/Kylin-Desktop-V10-SP1-General-Release-2203-ARM64.iso \
-drive file=mydisk.qcow2,if=virtio \
-display default,show-cursor=on \
-usb \
-device usb-tablet \
-cpu cortex-a8 \
-machine virt
```

> 查看支持的cpu qemu-system-aarch64 -cpu help   