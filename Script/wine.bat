@echo off
reg add "HKEY_CURRENT_USER\Software\Wine\Direct3D" /f
set D3DKEY=HKEY_CURRENT_USER\Software\Wine\Direct3D
set csmt=
reg add %D3DKEY% /v csmt /t REG_DWORD /d %csmt% /f
set offscreen=
reg add %D3DKEY% /v OffscreenRenderingMode /t REG_SZ /d %offscreen% /f
set renderer=
reg add %D3DKEY% /v renderer /t REG_SZ /d %renderer% /f
set shader_backend=
reg add %D3DKEY% /v shader_backend /t REG_SZ /d %shader_backend% /f
set useglsl=
if %useglsl%==enable (
reg add %D3DKEY% /v UseGLSL /t REG_SZ /d enabled /f
) else (
reg add %D3DKEY% /v UseGLSL /t REG_SZ /d disabled /f
)
set video_mem=
reg add %D3DKEY% /v VideoMemorySize /t REG_SZ /d %video_mem% /f
set gpu_did=
reg add %D3DKEY% /v VideoPciDeviceID /t REG_DWORD /d %gpu_did% /f 
set gpu_vid=
reg add %D3DKEY% /v VideoPciVendorID /t REG_DWORD /d %gpu_vid% /f
set strict_shader_math=
reg add %D3DKEY% /v strict_shader_math /t REG_DWORD /d %strict_shader_math% /f
reg add "HKEY_CURRENT_USER\Software\Wine\DirectInput" /f
set mouse_warp=
reg add HKEY_CURRENT_USER\Software\Wine\DirectInput /v MouseWarpOverride /t REG_SZ /d %mouse_warp% /f
set DRIVER_KEY=HKEY_CURRENT_USER\Software\Wine\Drivers\
set audio_drv=
reg add %DRIVER_KEY% /v Audio /t REG_SZ /d %audio_drv% /f
set graphics_type=
if %graphics_type%==x11_and_wayland (
reg add %DRIVER_KEY% /v Graphics /t REG_SZ /d x11,wayland /f
) else (
reg delete %DRIVER_KEY% /v Graphics /f
)
set windows_ver=
winecfg -v %windows_ver%