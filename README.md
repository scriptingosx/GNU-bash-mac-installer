# Build a GNU bash package installer for Mac

This script automates the process of downloading, building, and packaging `bash` for macOS.

You can provide a different version to download and build as the first argument. The default value is `5.0`. I have _not_ tested this thoroughly with older versions, use at your own risk.

The resulting package installer will install `bash` in `/usr/local/bin` and the supporting files in `/usr/local`.

This script will change the name of the `bash` binary installed in `/usr/local/bin/` to `bash5` or `bash4` to avoid _any_ naming conflicts with the built-in `bash` v3 in `/bin`. This also allows you to have both bash v4 and bash v5 installed on the same system.

You can change this behavior by setting [the `renamebinary` variable to `0`](https://github.com/scriptingosx/GNU-bash-mac-installer/blob/b6f4190a95849015771fbcc8cff4392fa7239666/buildGNUbashPkg.sh#L18). Or you can modify the `postinstall` script to add a symbolic link.

The path to the `bash` binary will be added to `/etc/shells` on the target system, so that users can use `chsh` to switch their default shell.

You can get more background to this script in [this post on my weblog](https://scriptingosx.com/?p=849).
