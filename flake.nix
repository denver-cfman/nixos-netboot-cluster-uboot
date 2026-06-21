{
  description = "Cross-compile U-Boot and prepare SD images";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
  packages.x86_64-linux = let
      pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnsupportedSystem = true; };
    in {
      # Accessing the pre-configured cross-compiled packages directly
      uboot-armv6   = pkgs.pkgsCross.armv6l-hf.ubootRaspberryPi;
      uboot-armv7   = pkgs.pkgsCross.armv7l-hf.ubootRaspberryPi;
      uboot-aarch64 = pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi;
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
