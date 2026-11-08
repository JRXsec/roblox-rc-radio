# roblox-rc-radio: make Roblox recognise your RC transmitter (DJI, FrSky, EMAX, Radiomaster, Jumper...)
#
# Why this is needed
#   Roblox reads controllers through the SDL library and only accepts devices listed in its controller
#   database. RC transmitters are not in that list, so Roblox ignores them even though Windows sees them.
#   SDL lets you add devices through the SDL_GAMECONTROLLERCONFIG environment variable. This script detects
#   the transmitters/joysticks plugged in and adds a mapping for each one to that variable (current user only).
#   Tested with a DJI FPV Remote Controller 2: Roblox goes from 0 gamepads to seeing it as Gamepad1.
#   Because it is a user variable, it keeps working after Roblox updates.
#
# Usage: plug in your radio in USB joystick mode, close Roblox and run:
#   powershell -ExecutionPolicy Bypass -File setup-radio.ps1
# Run it again to add another radio (every connected radio is added).
# To undo: powershell -ExecutionPolicy Bypass -File setup-radio.ps1 -Uninstall

param([switch]$Uninstall)

$ErrorActionPreference = "Stop"
$VAR = "SDL_GAMECONTROLLERCONFIG"

if ($Uninstall) {
	[Environment]::SetEnvironmentVariable($VAR, $null, "User")
	Write-Host "Done: Roblox will no longer use the radio mappings." -ForegroundColor Green
	exit 0
}

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class RcJoy {
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
  public struct JOYCAPS {
    public ushort wMid; public ushort wPid;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string szPname;
    public uint wXmin, wXmax, wYmin, wYmax, wZmin, wZmax, wNumButtons, wPeriodMin, wPeriodMax, wRmin, wRmax, wUmin, wUmax, wVmin, wVmax, wCaps, wMaxAxes, wNumAxes, wMaxButtons;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string szRegKey;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=260)] public string szOEMVxD;
  }
  [DllImport("winmm.dll", CharSet=CharSet.Unicode)] public static extern int joyGetDevCapsW(IntPtr id, ref JOYCAPS caps, int size);
}
'@

# Controllers Roblox already supports (Xbox, PlayStation) are left alone
$skipVendors = @(0x045E, 0x054C)

$devices = @()
for ($i = 0; $i -lt 16; $i++) {
	$c = New-Object RcJoy+JOYCAPS
	if ([RcJoy]::joyGetDevCapsW([IntPtr]$i, [ref]$c, [Runtime.InteropServices.Marshal]::SizeOf($c)) -ne 0) { continue }
	if ($skipVendors -contains [int]$c.wMid) { continue }
	if ($devices | Where-Object { $_.Vid -eq $c.wMid -and $_.Pid -eq $c.wPid }) { continue }
	$devices += [pscustomobject]@{ Vid = [int]$c.wMid; Pid = [int]$c.wPid; Axes = [int]$c.wNumAxes; Buttons = [int]$c.wNumButtons }
}

if ($devices.Count -eq 0) {
	Write-Host "No radio found. Plug it in over USB in joystick mode and run this again." -ForegroundColor Yellow
	exit 1
}

function LE16([int]$v) { "{0:x2}{1:x2}" -f ($v -band 0xFF), (($v -shr 8) -band 0xFF) }

# 6 radio axes -> 2 sticks + 2 triggers (the game works out which channel is which when you calibrate).
# Buttons -> A B X Y, L1 R1, d-pad and stick clicks. Start/Back are not mapped so a switch can't open the Roblox menu.
$body = "a:b0,b:b1,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpup:b6,dpdown:b7,dpleft:b8,dpright:b9,leftstick:b10,rightstick:b11," +
	"leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:a4,righttrigger:a5,platform:Windows,"

# keep radios that were already configured
$existing = [Environment]::GetEnvironmentVariable($VAR, "User")
$lines = New-Object System.Collections.Generic.List[string]
if ($existing) {
	foreach ($l in ($existing -split "`n")) { if ($l.Trim() -ne "") { $lines.Add($l.Trim()) } }
}

foreach ($d in $devices) {
	$name = "RC Radio {0:X4}-{1:X4}" -f $d.Vid, $d.Pid
	$v = LE16 $d.Vid
	$p = LE16 $d.Pid
	foreach ($guid in @("03000000$($v)0000$($p)000000000000", "$($v)$($p)000000000000504944564944")) {
		$lines = [System.Collections.Generic.List[string]]@($lines | Where-Object { -not $_.StartsWith($guid) })
		$lines.Add("$guid,$name,$body")
	}
	Write-Host ("Radio found: VID {0:X4} PID {1:X4} - {2} axes - {3} buttons" -f $d.Vid, $d.Pid, $d.Axes, $d.Buttons) -ForegroundColor Cyan
}

[Environment]::SetEnvironmentVariable($VAR, ($lines -join "`n"), "User")

Write-Host ""
Write-Host "Done. Close Roblox / Roblox Studio completely and open it again." -ForegroundColor Green
Write-Host "If Roblox is launched from an app that was already open (e.g. your browser), restart that app or sign out of Windows."
