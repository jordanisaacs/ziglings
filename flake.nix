{
  description = "A flake for Zig development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    neovim-flake.url = "github:jordanisaacs/neovim-flake";
    zig.url = "github:mitchellh/zig-overlay";

    zls.url = "github:zigtools/zls";
    zls.inputs.nixpkgs.follows = "nixpkgs";
    zls.inputs.flake-utils.follows = "flake-utils";
    zls.inputs.zig-overlay.follows = "zig";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    neovim-flake,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [
          (self: prev: {
            zig = inputs.zig.packages.${prev.system}.master;
            zls = inputs.zls.packages.${prev.system}.zls;
            # zls = prev.zls.overrideAttrs (oa: {
            #   version = "master";
            #   nativeBuildInputs = [self.zig];
            #   src = inputs.zls;
            # });
          })
        ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        editor = neovim-flake.packages.${system}.nix.extendConfiguration {
          modules = [
            {
              vim.languages.zig.enable = true;
              vim.git.gitsigns.codeActions = false;
            }
          ];
          inherit pkgs;
        };
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [zig editor zls];

          hardeningDisable = ["all"];
        };
        # For compatibility with older versions of the `nix` binary
        devShell = self.devShells.${system}.default;

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "zig";
          # TODO: Fix the output of `zig version`.
          version = "0.10.0-dev";
          src = self;

          nativeBuildInputs = with pkgs; [zig];

          preBuild = ''
            export HOME=$TMPDIR;
          '';

          cmakeFlags = [
            # https://github.com/ziglang/zig/issues/12069
            "-DZIG_STATIC_ZLIB=on"
          ];
        };
      }
    );
}
