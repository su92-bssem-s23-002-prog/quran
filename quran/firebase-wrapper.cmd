@echo off
if "%1"=="--version" (
    echo 13.0.0
) else (
    "C:\Users\shazaib\Downloads\firebase-tools-instant-win.exe" %*
)
