{
  description = "Cross-compile U-Boot and prepare SD images";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      pkgsFor = crossSystem: import nixpkgs {
        inherit crossSystem;
        system = "x86_64-linux";
        config.allowUnsupportedSystem = true;
      };
    in {
      uboot-armv6   = (pkgsFor { config = "armv6l-unknown-linux-gnueabihf"; }).buildPackages.ubootRaspberryPi;
      uboot-armv7   = (pkgsFor { config = "armv7l-unknown-linux-gnueabihf"; }).buildPackages.ubootRaspberryPi;
      uboot-aarch64 = (pkgsFor { config = "aarch64-unknown-linux-gnu"; }).buildPackages.ubootRaspberryPi;
    };

    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in pkgs.mkShell {
      buildInputs = with pkgs; [
        dtc          # Device Tree Compiler
        mtools       # Tools for manipulating FAT images
        parted       # Disk partitioning
        gcc          # Host compiler
        gnumake      # Build automation
      ];
      shellHook = ''
        echo "Ready to build U-Boot and prepare SD card images."
      '';
    };
  };
}
