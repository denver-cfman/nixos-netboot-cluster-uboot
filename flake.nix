{
  description = "Cross-compile U-Boot for Raspberry Pi";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnsupportedSystem = true; };
    in {
      # Use specific 64-bit targets for aarch64
      uboot-aarch64 = pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi4_64bit;
      
      # For 32-bit targets, use the appropriate RPi 32-bit defconfigs
      uboot-armv7 = pkgs.pkgsCross.armv7l-hf.ubootRaspberryPi3_32bit;
    };

    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in pkgs.mkShell {
      buildInputs = with pkgs; [ dtc mtools parted ];
    };
  };
}
