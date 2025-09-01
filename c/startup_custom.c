#include <windows.h>
#include <tchar.h>
#include <stdio.h>

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
    if (IsAlreadyRunning()) {
        return 0;
    }

    SetPriorityClass(GetCurrentProcess(), IDLE_PRIORITY_CLASS);

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

    // 低资源占用的消息循环
    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
        Sleep(1000);
    }

    return 0;
}