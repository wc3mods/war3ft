---
title: New Installation
parent: Installation
nav_order: 1
---

# Warcraft 3 Frozen Throne: New Installation Guide

This guide will help you install Warcraft 3 Frozen Throne (war3ft) for Counter-Strike 1.6, Condition Zero, or Day of Defeat gaming servers.

## Requirements

1. **HLDS Installed**
   - [HLDS Installation Guide](../hlds.md)
2. **AMX Mod X Installed**: Version 1.82, 1.9.0 or 1.10.0.
   - [AMX Mod X Downloads](https://www.amxmodx.org/downloads.php)
3. **Warcraft 3 Frozen Throne Downloaded**: Obtain the latest version of the Warcraft 3 Frozen Throne plugin:
   - [Download war3ft](https://github.com/wc3mods/war3ft/releases)

Note: There are packages available on github which have amdxmodx/metamod already configured. You can download that version (i.e. war3ft-v3.0.1-cstrike-amxmodx-1.10.0-git5488.zip), and just drop it into your game folder for the HLDS installation. Then you can skip the below sections.

## File Placement

Place the downloaded files into the appropriate directories within your game server's folder structure:

```
|-- cstrike (or czero)
    |-- addons
        |-- amxmodx
            |-- configs       # Place the 'war3ft' folder containing configuration files here
            |-- plugins       # Place 'war3ft.amxx' here
            |-- scripting     # Optional: Place the war3ft source code here
    |-- sounds                # Place the contents of the 'sounds' folder here
    |-- sprites               # Place the contents of the 'sprites' folder here
```

## AMX Mod X Configuration

### Enable the Plugin

Add the following line to the bottom of `addons/amxmodx/configs/plugins.ini`:

```
war3ft.amxx debug
```

*Note*: For versions prior to 3.0, use `warcraft3FT.amxx debug` instead.

### Enable the Required Modules

Edit `addons/amxmodx/configs/modules.ini` and uncomment (remove the semicolon `;` at the beginning of the line) the following modules:

```
fun
engine
fakemeta
nvault
cstrike
csx
```

If you plan to use MySQL or SQLite support (choose only one), uncomment the corresponding line:

**For MySQL**:

```
mysql
;sqlite
```

**For SQLite**:

```
;mysql
sqlite
```

*Note*: Ensure you have the necessary SQL modules downloaded from [amxmodx.org](https://www.amxmodx.org/).

---

For further configuration details, refer to the [Configuration Guide](../configuration.md).
