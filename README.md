# Linux Kernel build

## 第一步 运行 build_linux_kernel.sh

这一步会编译 linux 内核。

## 第二步 运行 build_busybox.sh

这一步会构建一个根文件系统，内核启动后会加载它。

## 第三步 运行 run_qemu.sh

在模拟器中加载刚才的内核，并使用第二步构造的根文件系统。


<img src="./image.png" />

