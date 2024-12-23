{
  # Flake dependencies
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Flake actions/outputs
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ ];
      };
    in with pkgs; {
      devShells.default = mkShell {
        nativeBuildInputs = [
        ];
        buildInputs = [
          zig
          pkg-config wayland wayland-scanner libxkbcommon libGL
        ];
        shellHook = ''
          # Change bash shell prompt
          export PS1="\w - <Zong> "
        '';
      };
    }
  );
}
