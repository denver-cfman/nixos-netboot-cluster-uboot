{
  description = "Cross-compile U-Boot for Raspberry Pi";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    # Define build environments for different targets
    packages.x86_64-linux = let
      # Function to create a build environment for a specific cross-target
      mkUBoot = crossSystem: 
        let pkgs = import nixpkgs {
          inherit crossSystem;
          localSystem = "x86_64-linux";
        };
        in pkgs.buildPackages.ubootRaspberryPi; # Adjust based on specific Pi model needs
    in {
      uboot-armv6  = mkUBoot { config = "armv6l-unknown-linux-gnueabihf"; };
      uboot-armv7  = mkUBoot { config = "armv7l-unknown-linux-gnueabihf"; };
      uboot-aarch64 = mkUBoot { config = "aarch64-unknown-linux-gnu"; };
    };

    # Development shell for manual building or tweaking
    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in pkgs.mkShell {
      buildInputs = [
        pkgs.pkgsCross.aarch64-multiplatform.buildPackages.gcc
        pkgs.bison
        pkgs.flex
        pkgs.ncurses
      ];
    };
  };
}
