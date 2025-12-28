# 定义变量
CC = gcc
CFLAGS = -static
TARGET = hello
SRC = hello.c
BIN_DIR = out

# 默认目标
all: $(TARGET)

# 编译：必须使用 -static 确保不依赖动态库
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(BIN_DIR)/$(TARGET)

# 清理
clean:
	rm -f $(TARGET)
	rm -f $(BIN_DIR)/$(TARGET)