# env_setup.ps1
# 使用 xwin 提供的 Windows SDK 和 MSVC CRT 库设置环境变量
# 使用前请修改 $XWIN_OUTPUT 变量指向你的 xwin 输出目录

$XWIN_OUTPUT = "D:\softwares\winlibs"   # <-- 改成你的 xwin 输出路径

$env:INCLUDE = "$XWIN_OUTPUT\crt\include;" +
               "$XWIN_OUTPUT\sdk\include\ucrt;" +
               "$XWIN_OUTPUT\sdk\include\um;" +
               "$XWIN_OUTPUT\sdk\include\shared"

$env:LIB = "$XWIN_OUTPUT\crt\lib\x86_64;" +
           "$XWIN_OUTPUT\sdk\lib\ucrt\x86_64;" +
           "$XWIN_OUTPUT\sdk\lib\um\x86_64"

Write-Host "[+] Environment set for xwin libraries at $XWIN_OUTPUT"