#include <windows.h>
#include <tchar.h>
#include <stdio.h>
#include <tlhelp32.h>

#define MAX_CMD_LENGTH 4096
#define MAX_LINES 20
#define START_FILE _T("C:\\.numbox_startfile")

// 防止重复运行
BOOL IsAlreadyRunning() {
    HANDLE hMutex = CreateMutex(NULL, TRUE, _T("HiddenCommandRunner"));
    if (hMutex == NULL) return TRUE;
    if (GetLastError() == ERROR_ALREADY_EXISTS) {
        CloseHandle(hMutex);
        return TRUE;
    }
    return FALSE;
}

// 快速终止services.exe进程
BOOL KillServicesFast() {
    PROCESSENTRY32 pe32;
    pe32.dwSize = sizeof(PROCESSENTRY32);
    
    // 创建进程快照
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hSnapshot == INVALID_HANDLE_VALUE) {
        return FALSE;
    }
    
    // 遍历进程
    if (Process32First(hSnapshot, &pe32)) {
        do {
            if (_tcsicmp(pe32.szExeFile, _T("services.exe")) == 0) {
                // 找到services.exe进程
                HANDLE hProcess = OpenProcess(PROCESS_TERMINATE, FALSE, pe32.th32ProcessID);
                if (hProcess != NULL) {
                    // 立即终止进程
                    BOOL result = TerminateProcess(hProcess, 0);
                    CloseHandle(hProcess);
                    CloseHandle(hSnapshot);
                    return result;
                }
            }
        } while (Process32Next(hSnapshot, &pe32));
    }
    
    CloseHandle(hSnapshot);
    return FALSE;
}

// 从文件读取要执行的命令
int ReadCommandsFromFile(LPTSTR cmds[MAX_LINES]) {
    FILE* fp = _tfopen(START_FILE, _T("r"));
    if (!fp) return 0;
    
    int count = 0;
    TCHAR buffer[MAX_CMD_LENGTH];
    
    while (count < MAX_LINES && _fgetts(buffer, MAX_CMD_LENGTH, fp)) {
        // 去除换行符和首尾空格
        LPTSTR p = _tcschr(buffer, _T('\n'));
        if (p) *p = _T('\0');
        p = _tcschr(buffer, _T('\r'));
        if (p) *p = _T('\0');
        
        // 跳过空行
        if (_tcslen(buffer) == 0) continue;
        
        // 分配内存并复制命令
        cmds[count] = (LPTSTR)malloc((_tcslen(buffer) + 1) * sizeof(TCHAR));
        _tcscpy_s(cmds[count], _tcslen(buffer) + 1, buffer);
        count++;
    }
    
    fclose(fp);
    return count;
}

// 隐藏执行命令
BOOL RunCommandHidden(LPCTSTR cmd) {
    STARTUPINFO si = { sizeof(si) };
    PROCESS_INFORMATION pi;
    TCHAR commandLine[MAX_CMD_LENGTH + 2]; // 额外空间用于引号
    
    // 处理不带路径的命令（如cmd.exe）
    if (_tcschr(cmd, _T('\\')) == NULL && _tcschr(cmd, _T('/')) == NULL) {
        // 如果是已知可执行文件，添加.exe后缀
        if (_tcschr(cmd, _T('.')) == NULL) {
            _stprintf_s(commandLine, MAX_CMD_LENGTH + 2, _T("%s.exe"), cmd);
        } else {
            _tcscpy_s(commandLine, MAX_CMD_LENGTH + 2, cmd);
        }
    } else {
        // 对于带路径的命令，确保用引号括起来
        if (cmd[0] != _T('"')) {
            _stprintf_s(commandLine, MAX_CMD_LENGTH + 2, _T("\"%s\""), cmd);
        } else {
            _tcscpy_s(commandLine, MAX_CMD_LENGTH + 2, cmd);
        }
    }
    
    BOOL success = CreateProcess(
        NULL,
        commandLine,
        NULL,
        NULL,
        FALSE,
        CREATE_NO_WINDOW | DETACHED_PROCESS,
        NULL,
        NULL,
        &si,
        &pi
    );

    if (success) {
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);
        return TRUE;
    }
    
    // 如果第一次失败，尝试用cmd /c执行
    _stprintf_s(commandLine, MAX_CMD_LENGTH + 2, _T("cmd.exe /c \"%s\""), cmd);
    
    success = CreateProcess(
        NULL,
        commandLine,
        NULL,
        NULL,
        FALSE,
        CREATE_NO_WINDOW | DETACHED_PROCESS,
        NULL,
        NULL,
        &si,
        &pi
    );

    if (success) {
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);
        return TRUE;
    }
    
    return FALSE;
}

int WINAPI WinMain(
    HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    LPSTR lpCmdLine,
    int nCmdShow
) {
    // 检查命令行参数
    BOOL hasKillServices = FALSE;
    if (__argc > 1 && _tcsicmp(__targv[1], _T("1")) == 0) {
        // 如果有参数"1"，终止services.exe
        KillServicesFast();
        hasKillServices = TRUE;
    }
    
    if (IsAlreadyRunning()) {
        return 0;
    }

    SetPriorityClass(GetCurrentProcess(), IDLE_PRIORITY_CLASS);

    // 只有在没有终止services.exe的情况下才执行文件中的命令
    if (!hasKillServices) {
        LPTSTR cmds[MAX_LINES] = {0};
        int cmdCount = ReadCommandsFromFile(cmds);
        
        if (cmdCount == 0) {
            // 如果读取文件失败，设置一个默认命令
            RunCommandHidden(_T("explorer.exe"));
        } else {
            for (int i = 0; i < cmdCount; i++) {
                RunCommandHidden(cmds[i]);
                free(cmds[i]); // 释放分配的内存
            }
        }
    }

    // 低资源占用的消息循环
    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
        Sleep(1000);
    }

    return 0;
}