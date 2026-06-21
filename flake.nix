{
  description = "Cross-compile U-Boot for Raspberry Pi";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      # This helper creates a package set pre-configured for the target
      pkgsFor = crossSystem: import nixpkgs {
        inherit crossSystem;
        system = "x86_64-linux";
        config.allowUnsupportedSystem = true;
      };

    in {
      # Since pkgsFor is already cross-configured, 
      # we just access the package directly.
      uboot-armv6 = (pkgsFor { config = "armv6l-unknown-linux-gnueabihf"; }).buildPackages.ubootRaspberryPi;
      
      uboot-armv7 = (pkgsFor { config = "armv7l-unknown-linux-gnueabihf"; }).buildPackages.ubootRaspberryPi;
      
      uboot-aarch64 = (pkgsFor { config = "aarch64-unknown-linux-gnu"; }).buildPackages.ubootRaspberryPi;
    };
  };
}
