# War3FT (Warcraft 3: Frozen Throne) Plugin for Counter-Strike 1.6, Day of Defeat and Condition Zero

This is an AMX MOD X plugin that implements Warcraft 3: Frozen Throne RPG elements into the game. Players can level up, choose races, use skills, and gain experience during gameplay.

## Features

- Multiple races with unique abilities
- Experience and leveling system
- Special skills and ultimate abilities
- Item shop system
- Customizable configurations
- Web interface for stats

## Prerequisites

To use this plugin, you need:

1. AMX Mod X 1.8.2 or later (1.10+ is recommended)
2. Metamod

## Running a server

Saving XP to MySQL (`wc3_save_xp_db`) needs the mysql module: uncomment `mysql` in `addons/amxmodx/configs/modules.ini` (the v3.0.1 `git5488` bundles and later do this for you). Without it War3FT falls back to SQLite. Set `wc3_sql_dbhost`, `wc3_sql_dbuser`, `wc3_sql_dbpass` and `wc3_sql_dbname`; the password can be at most 31 characters.

On newer Linux distributions (glibc 2.41+, e.g. Ubuntu 26.04), Metamod cannot load AMX Mod X because its binaries request an executable stack, and AMX Mod X silently doesn't start. Clear the flag with `patchelf --clear-execstack addons/amxmodx/dlls/amxmodx_mm_i386.so`.

## Documentation

[You can find all documentation right here on github](https://wc3mods.github.io/war3ft/)!

## Support

For issues, bug reports, or feature requests, please create an issue in the repository.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and updates.

## License

This project is licensed under the terms specified in the license file.

## Credits

Thanks to the AMX Mod X team and the Counter-Strike modding community for making this possible. 
