#include <stdio.h>
#include <unistd.h>
#include <time.h>

int main() {
    // 1. 打开日志文件。 "a" 表示 append（追加模式），文件不存在会创建
    FILE *log_file = fopen("/var/log/my_service.log", "a");
    
    if (log_file == NULL) {
        // 如果打开失败（比如没有 /var/log 目录），尝试在根目录写
        log_file = fopen("/my_service.log", "a");
    }

    if (log_file == NULL) return 1;

    while (1) {
        // 获取当前系统时间
        time_t now;
        time(&now);
        char *date = ctime(&now);
        date[24] = '\0'; // 去掉换行符

        // 2. 写入日志到文件
        fprintf(log_file, "[%s] [MyService] Alive and kicking...\n", date);
        
        // 3. 强制刷新缓冲区，确保即便掉电也能看到日志
        fflush(log_file);
        
        sleep(5);
    }

    fclose(log_file);
    return 0;
}