# lidawake

Keep an Apple Silicon MacBook running with the **lid closed**, on **battery**, with **no external display, keyboard, mouse, or power** — no dongle required.

This is the open-source, software-only answer to the "MacBook Lid Lock" idea. It turns out you don't need to emulate a fake monitor. macOS already has the capability built in; it just gates it behind a policy flag. `lidawake` flips that flag safely.

## Why this exists

- **Amphetamine** does this but is **closed-source**.
- **KeepingYouAwake** is open source but only runs `caffeinate`, which does **not** override the lid switch — close the lid and it still sleeps.
- The actual mechanism is one built-in command: `sudo pmset -b disablesleep 1`. `lidawake` wraps it with an idle-sleep guard and an auto-revert safety net.

## How it works

| Piece | What it does |
|-------|--------------|
| `pmset -b disablesleep 1` | Tells the power manager to ignore the lid switch **on battery** (`-b`). This is the part that actually keeps the Mac awake with the lid shut. |
| `caffeinate -im` | Prevents *idle* system sleep so a quiet task (download, build, SSH session) doesn't drop off after the display-off timeout. |
| watchdog (`lidawake on 90`) | Optional auto-revert after N minutes so you can't accidentally leave the Mac unable to sleep — important if it's in a bag. |

## Install

There's nothing to install. Make it executable and run it in place:

```bash
chmod +x lidawake
./lidawake on
```

It asks for your admin password once, because the one command that overrides the
lid switch — `pmset -b disablesleep` — is root-only in macOS. You don't run the
script as root; it calls `sudo` itself, only around that single line.

**Optional:** if you'd rather type `lidawake` from anywhere instead of `./lidawake`,
copy it onto your PATH (this is just convenience, not a requirement):

```bash
sudo cp lidawake /usr/local/bin/   # then: lidawake on
```

## Usage

```bash
lidawake on          # keep running lid-closed until you turn it off
lidawake on 90       # ...but auto-revert after 90 minutes (recommended)
lidawake status      # check current state
lidawake off         # back to normal — closing the lid sleeps the Mac
```

Typical flow:

```bash
lidawake on 120      # arm it
# start your Claude Code / script / download
# close the lid, put it away
# ...later...
lidawake off         # or let the 120-min timer revert it for you
```

It asks for your admin password because `pmset` needs `sudo`.

## ⚠ Real caveats (no hardware fixes these)

- **Heat.** Lid closed + no external display + busy CPU = heat trapped between screen and keyboard. Fine for light/idle work; risky for sustained heavy jobs sealed in a padded bag. Give it airflow.
- **It really won't sleep.** While ON, closing the lid does nothing. That's the point — but don't forget it's on. Use the timer (`lidawake on 90`) as a habit.
- **Battery drains** at whatever your workload demands; this tool changes sleep policy, not power draw.

## Uninstall

```bash
sudo rm /usr/local/bin/lidawake
rm -rf ~/.lidawake
```

## License

MIT. No warranty. You're changing power-management behavior; understand the heat caveat above.
