obj-m += hello_driver.o
# KDIR 指向你编译内核时的源码目录
KDIR := /host/linux-6.1

all:
	make -C $(KDIR) M=/host/drivers modules

clean:
	make -C $(KDIR) M=/host/drivers clean