{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    flake-parts,
    rust-overlay,
    ...
  } @ inputs: let
    overlays = [(import rust-overlay)];
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {system, ...}: let
        pkgs = import nixpkgs {inherit system overlays;};
      in {
        _module.args.pkgs = pkgs;

        devShells.default = let
          rust = pkgs.rust-bin.stable.latest.default.override {
            extensions = ["rust-src" "rust-analyzer"];
          };
        in
          with pkgs;
            mkShell {
              nativeBuildInputs = [
                pkg-config
                rust
                gtk3
                glib
                webkitgtk_4_1
                cairo
                pango
                gdk-pixbuf

                libappindicator-gtk3
                libayatana-appindicator
                pipewire

                clang
                llvmPackages.libclang
              ];

              LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
              LD_LIBRARY_PATH = lib.makeLibraryPath [
                libayatana-appindicator
                libappindicator-gtk3
                gtk3
                webkitgtk_4_1
                glib
                cairo
                pango
                gdk-pixbuf
                libdbusmenu-gtk3
              ];
            };

          packages.default = pkgs.callPackage ./package.nix  {};
      };
    };
}
