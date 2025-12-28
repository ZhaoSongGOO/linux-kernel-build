#include <linux/module.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/device.h> // 必须包含这个头文件

#define DEVICE_NAME "hello_device"
#define CLASS_NAME  "my_class"
#define MAJOR_NUM 240

static struct class* my_class  = NULL; 
static struct device* my_device = NULL; 

static int device_open(struct inode *inode, struct file *file) {
    printk(KERN_INFO "Device opened\n");
    return 0;
}

static ssize_t device_read(struct file *file, char __user *buffer, size_t length, loff_t *offset) {
    char *msg = "Hello from Auto-Device!\n";
    int len = 25;
    if (*offset > 0) return 0;
    if (copy_to_user(buffer, msg, len)) return -EFAULT;
    *offset += len;
    return len;
}

static struct file_operations fops = {
    .read = device_read,
    .open = device_open,
};

static int __init my_init(void) {
    // 1. 注册主设备号
    int retval = register_chrdev(MAJOR_NUM, DEVICE_NAME, &fops);
    if (retval < 0) return retval;

    // 2. 创建设备类 (在 /sys/class/ 下可见)
    my_class = class_create(THIS_MODULE, CLASS_NAME);
    if (IS_ERR(my_class)) {
        unregister_chrdev(MAJOR_NUM, DEVICE_NAME);
        return PTR_ERR(my_class);
    }

    // 3. 创建设备节点 (在 /dev/ 下自动生成)
    my_device = device_create(my_class, NULL, MKDEV(MAJOR_NUM, 0), NULL, DEVICE_NAME);
    if (IS_ERR(my_device)) {
        class_destroy(my_class);
        unregister_chrdev(MAJOR_NUM, DEVICE_NAME);
        return PTR_ERR(my_device);
    }

    printk(KERN_INFO "Driver loaded and /dev/%s created\n", DEVICE_NAME);
    return 0;
}

static void __exit my_exit(void) {
    // 顺序必须与初始化相反
    device_destroy(my_class, MKDEV(MAJOR_NUM, 0)); // 删除设备
    class_destroy(my_class);                       // 删除类
    unregister_chrdev(MAJOR_NUM, DEVICE_NAME);      // 注销设备号
    printk(KERN_INFO "Driver unloaded\n");
}

module_init(my_init);
module_exit(my_exit);
MODULE_LICENSE("GPL");