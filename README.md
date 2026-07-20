# lidawake

**Keep your MacBook running with the lid closed — on battery, with nothing plugged in.**

No external display, no keyboard, no charger, no dongle. Close the lid, put it in your bag, and your download, build, or SSH session keeps going.

macOS can already do this — it's just switched off by default behind a power-management flag. `lidawake` flips that flag safely and flips it back when you're done.

## Install

One command, no admin password needed:

```bash
curl -fsSL https://raw.githubusercontent.com/Vasiniks/lidawake/main/install.sh | bash
```

This installs `lidawake` into `~/.local/bin` (which belongs to you), so the install itself never needs `sudo`. If that folder isn't on your `PATH` yet, the installer adds it — just restart Terminal afterward.

## Usage

```bash
lidawake on 90     # stay awake lid-closed, then auto-revert after 90 minutes
lidawake on        # stay awake until you turn it off
lidawake status    # show current state
lidawake off       # back to normal — closing the lid sleeps the Mac
```

Typical flow:

```bash
lidawake on 120    # arm it for 2 hours
# start your task, close the lid, walk away
lidawake off       # done early? turn it off. Otherwise it reverts on its own.
```

The first time you run `lidawake on`, macOS asks for your admin password. That's the **only** time a password is needed — it's required to change the lid-sleep setting. The auto-revert timer (`lidawake on 90`) is recommended so you can't accidentally leave your Mac unable to sleep in a bag.

## How it works

`lidawake` wraps three pieces:

| Piece | What it does |
|-------|--------------|
| `pmset -b disablesleep 1` | Tells macOS to ignore the lid switch while on battery. This is what keeps the Mac awake with the lid shut. |
| `caffeinate -im` | Stops idle sleep, so a quiet task doesn't drop off after the display-off timeout. |
| auto-revert timer | Optional watchdog that turns everything back to normal after N minutes, even if you forget. |

## Caveats

- **Heat.** Lid closed + no external display + a busy CPU traps heat between the screen and keyboard. Fine for light or idle work; risky for sustained heavy jobs sealed in a padded bag. Give it airflow.
- **It really won't sleep.** While it's on, closing the lid does nothing — that's the point. Use the timer so you don't forget it's on.
- **Battery still drains** at whatever your workload needs. This changes the sleep policy, not the power draw.

## Uninstall

```bash
rm ~/.local/bin/lidawake
rm -rf ~/.lidawake
```

## License

MIT. No warranty. You're changing power-management behavior — read the heat caveat above.
