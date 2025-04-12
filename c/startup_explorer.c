#include <windows.h>
#include <shellapi.h>
#include <tchar.h>

// 隐藏窗口并最小化资源占用的后台服务
void RunHiddenExplorer() {
    // 第一次启动 explorer
    SHELLEXECUTEINFO sei = { sizeof(sei) };
    sei.fMask = SEE_MASK_NOCLOSEPROCESS | SEE_MASK_FLAG_NO_UI;
    sei.lpVerb = _T("open");
    sei.lpFile = _T("explorer.exe");
    sei.nShow = SW_HIDE;
    
    if (ShellExecuteEx(&sei)) {
        CloseHandle(sei.hProcess);
    }

    // 进入低资源占用的消息循环
    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
        Sleep(1000);  // 每秒检查一次，减少CPU占用
    }
}

// 隐藏的控制台程序入口
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    // 可选: 检查是否已经有一个实例在运行
    HANDLE hMutex = CreateMutex(NULL, TRUE, _T("HiddenExplorerRunner"));
    if (GetLastError() == ERROR_ALREADY_EXISTS) {
        CloseHandle(hMutex);
        return 0;  // 已经有一个实例在运行，直接退出
    }

    // 主逻辑
    RunHiddenExplorer();

    // 清理
    ReleaseMutex(hMutex);
    CloseHandle(hMutex);
    
    return 0;
}
