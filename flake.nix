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
      # Use specific 64-bit targets for aarch64
      uboot-aarch64 = pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi4_64bit;
      # For 32-bit targets, use the appropriate RPi 32-bit defconfigs
      uboot-armv7 = pkgs.pkgsCross.armv7l-hf.ubootRaspberryPi3_32bit;
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
