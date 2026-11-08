@echo off
title Roblox RC Radio Setup - Uninstall
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-radio.ps1" -Uninstall
pause
