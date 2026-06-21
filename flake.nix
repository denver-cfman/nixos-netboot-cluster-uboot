{
  description = "Cross-compile U-Boot and prepare SD images";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnsupportedSystem = true; };
      pkgsFor = crossSystem: import nixpkgs {
        inherit crossSystem;
        system = "x86_64-linux";
        config.allowUnsupportedSystem = true;
      };
    in {
      uboot-aarch64 = pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi4_64bit;
        # Correct key for 32-bit ARM multiplatform
      uboot-armv7   = pkgs.pkgsCross.armv7l-hf-multiplatform.ubootRaspberryPi3_32bit;
  
      # For older ARMv6 (Pi 1/Zero), use this target:
      uboot-armv6   = pkgs.pkgsCross.armv6l-hf-multiplatform.ubootRaspberryPi;
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
