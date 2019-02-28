# Build a GNU bash package installer for Mac

This script automates the process of downloading, building, and packaging `bash` for macOS.

You can provide a different version to download and build as the first argument. The default value is `5.0`. I have _not_ tested this thoroughly with older versions, use at your own risk.

The resulting package installer will install `bash` in `/usr/local/bin` and the supporting files in `/usr/local`.

This script will change the name of the `bash` binary installed in `/usr/local/bin/` to `bash5` or `bash4` to avoid _any_ naming conflicts with the built-in `bash` v3 in `/bin`. You can change this bahavior by setting the `renamebinary` variable in line 13 to `0`. Or you could modify the `postinstall` script to add a symbolic link.

You can get more background to this script in this post on my weblog.