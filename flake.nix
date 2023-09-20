{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    lib = pkgs.lib;
    libs = with pkgs; [
          pkg-config
          wayland
          wayland-protocols
          xwayland
          udev
          libseat
          pipewire
          libinput
          libxkbcommon
          mesa
    ];
  in {

    packages.x86_64-linux.hello = pkgs.rustPlatform.buildRustPackage {
        pname = "niri";
        version = "0.1.0";
        src = ./.;
        buildInputs = libs;
        nativeBuildInputs = libs ++ (with pkgs; [
          makeWrapper
        ]);
        buildFeatures = [];
        cargoLock = {
            lockFile = ./Cargo.lock;
            allowBuiltinFetchGit = true;
        };
        postInstall = ''
          wrapProgram "$out/bin/niri" --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libs}"
        '';
    };

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

  };
}
