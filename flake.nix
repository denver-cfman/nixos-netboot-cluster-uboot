{
  description = "Cross-compile U-Boot for Raspberry Pi";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      # Create a custom pkgs instance for the specific cross-target
      pkgsFor = crossSystem: import nixpkgs {
        inherit crossSystem;
        system = "x86_64-linux";
        config.allowUnsupportedSystem = true;
      };

    in {
      # Access the specific U-Boot derivation for each architecture
      # We use .pkgsCross.<target>.ubootRaspberryPi
      uboot-armv6 = (pkgsFor { config = "armv6l-unknown-linux-gnueabihf"; }).pkgsCross.armv6l-hf.ubootRaspberryPi;
      
      uboot-armv7 = (pkgsFor { config = "armv7l-unknown-linux-gnueabihf"; }).pkgsCross.armv7l-hf.ubootRaspberryPi;
      
      uboot-aarch64 = (pkgsFor { config = "aarch64-unknown-linux-gnu"; }).pkgsCross.aarch64-multiplatform.ubootRaspberryPi;
    };
  };
}
