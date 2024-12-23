## Zong
Pong written in Zig with Raylib using Nix to set up the development environment with all the required packages/dependencies installed.

Nix can be installed on any operating system and the flake ensures that the version of dependencies stays the same because the lock files locks down the version unless the flake is updated explicitly.

![[showcase.png]]
### Supported Platforms
Zong will work on any Linux distro running Wayland although you can most likely get it working on other platforms with little to no work.
- Windows
- MacOS
- Linux - Wayland only unless you can build it for X11 yourself which will require you to install the required X11 packages by modifying [[flake.nix]] yourself. Remember that you have to modify [[build.zig]] as well since it's hardcoded to build only for the Wayland backend.
- And any other platforms that Zig and Raylib supports that I'm unaware of.