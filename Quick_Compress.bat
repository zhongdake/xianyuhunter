@echo off
chcp 65001 >nul
title Docker VHDX 磁盘压缩工具
echo ============================================
echo   Docker ext4.vhdx 虚拟磁盘压缩脚本
echo ============================================
echo.

echo [1/4] 关闭 WSL 引擎...
wsl --shutdown
timeout /t 3 /nobreak >nul
echo      完成。

echo [2/4] 生成 diskpart 临时脚本...
set "DPSCRIPT=%TEMP%\compact_vhdx.txt"
(
    echo select vdisk file="E:\wsldocker\DockerDesktopWSL\main\ext4.vhdx"
    echo attach vdisk readonly
    echo compact vdisk
    echo detach vdisk
) > "%DPSCRIPT%"
echo      完成: %DPSCRIPT%

echo [3/4] 执行 diskpart 压缩（这可能需要几分钟）...
diskpart /s "%DPSCRIPT%"

echo [4/4] 清理临时文件...
del "%DPSCRIPT%" 2>nul
echo      完成。

echo.
echo ============================================
echo   压缩完成！请检查 E 盘剩余空间。
echo ============================================
pause
