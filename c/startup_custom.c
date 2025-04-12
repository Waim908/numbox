#include <windows.h>
#include <tchar.h>
#include <stdio.h>

#define MAX_CMD_LENGTH 1024
#define START_FILE _T("C:\\.numbox_startfile")

// 防止重复运行
BOOL IsAlreadyRunning() {
    HANDLE hMutex = CreateMutex(NULL, TRUE, _T("HiddenCommandRunner"));
    return (GetLastError() == ERROR_ALREADY_EXISTS);
}

// 从文件读取要执行的命令
BOOL ReadCommandFromFile(LPTSTR cmd) {
    FILE* fp = _tfopen(START_FILE, _T("r"));
    if (!fp) return FALSE;
    
    if (_fgetts(cmd, MAX_CMD_LENGTH, fp)) {
        // 去除换行符
        LPTSTR p = _tcschr(cmd, _T('\n'));
        if (p) *p = _T('\0');
        fclose(fp);
        return TRUE;
    }
    
    fclose(fp);
    return FALSE;
}

// 隐藏执行命令
void RunCommandHidden(LPCTSTR cmd) {
    STARTUPINFO si = { sizeof(si) };
    PROCESS_INFORMATION pi;

    CreateProcess(
        NULL,
        (LPTSTR)cmd,  // 使用从文件读取的命令
        NULL,
        NULL,
        FALSE,
        CREATE_NO_WINDOW,
        NULL,
        NULL,
        &si,
        &pi
    );

    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
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

    TCHAR cmd[MAX_CMD_LENGTH] = {0};
    if (ReadCommandFromFile(cmd)) {
        RunCommandHidden(cmd);
    } else {
        // 如果读取文件失败，可以设置一个默认命令
        RunCommandHidden(_T("explorer.exe"));
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
