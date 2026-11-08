@echo off
title Roblox RC Radio Setup
echo.
echo   ROBLOX RC RADIO SETUP
echo   =====================
echo   Lets Roblox games read your RC transmitter (DJI, FrSky, EMAX, Radiomaster, Jumper...).
echo   You only need to do this once.
echo.
echo   1. Plug in and switch on your radio (USB joystick mode).
echo   2. Close Roblox if it is open.
echo.
pause
if not exist "%~dp0setup-radio.ps1" (
  echo   ERROR: setup-radio.ps1 is missing.
  echo   You probably opened SETUP.bat from inside the ZIP.
  echo   Right-click roblox-rc-radio-main.zip, choose "Extract All", then run SETUP.bat from the new folder.
  echo.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-radio.ps1"
echo.
echo   Now restart your PC, open Roblox and calibrate your radio inside the game.
echo.
pause
