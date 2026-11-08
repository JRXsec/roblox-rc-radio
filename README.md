# 🎮 Roblox RC Radio Setup

**Fly Roblox drone games with your real RC transmitter** — DJI FPV Remote Controller, FrSky, EMAX, Radiomaster, Jumper, BetaFPV and any other radio that works as a USB joystick.

One double-click, done for good. No drivers, no x360ce, no Steam.

---

## Why your radio doesn't work in Roblox

Windows sees your radio as a game controller, but **Roblox doesn't**. Roblox reads controllers through the [SDL](https://www.libsdl.org/) library and only accepts the devices in its built-in controller list ([SDL_GameControllerDB](https://github.com/mdqinc/SDL_GameControllerDB)). Xbox and PlayStation pads are on that list; RC transmitters aren't. So Roblox silently ignores them, in every game.

SDL lets you add extra devices through the `SDL_GAMECONTROLLERCONFIG` environment variable. This tool detects every radio you plug in and adds a mapping for it. That's it.

**Tested:** DJI FPV Remote Controller 2. Before: Roblox sees 0 gamepads. After: it shows up as `Gamepad1` with live stick input.

## Install

1. Plug your radio in over USB and pick **USB Joystick (HID)** mode.
2. Close Roblox.
3. Double-click **`SETUP.bat`**.
4. Open Roblox again and calibrate your radio inside the game.

Windows may say *"Windows protected your PC"* because `.bat` files run commands. Click **More info → Run anyway**. Both files are plain text, so you can open them in Notepad and read exactly what they do.

Got more than one radio? Plug in the next one and run `SETUP.bat` again. Every radio is kept.

## Uninstall

Double-click **`UNINSTALL.bat`**. It deletes the variable and nothing else.

## What exactly it changes

| | |
|---|---|
| Changes | One environment variable for your Windows user: `SDL_GAMECONTROLLERCONFIG` |
| Doesn't touch | Roblox files, drivers, the registry outside your user environment, admin rights |
| Survives Roblox updates | Yes |
| Platform | Windows 10 / 11 |

## How the mapping works (for game developers)

The radio's axes become a standard gamepad: `a0..a3` go to the two thumbsticks and `a4..a5` to the triggers. The first 12 buttons go to A/B/X/Y, L1/R1, the D-pad and L3/R3.

Start and Back are deliberately left unmapped, so a radio switch can't open the Roblox menu.

RC radios don't share a channel order, so your game should **calibrate**. Ask the player to move each stick and use `UserInputService:GetGamepadState()` to see which axis moved and in which direction. Throttle is easy to spot because it doesn't spring back to centre.

## The real fix

All of this would be unnecessary if Roblox's controller list included RC radios. If you'd like that too, upvote or comment on this feature request: [Native support for USB HID / DirectInput controllers](https://devforum.roblox.com/t/native-support-for-usb-hid-directinput-controllers-in-userinputservice/4374462).

## License

MIT
