{
  description = "Cross-compile U-Boot for Raspberry Pi";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      # Create a custom pkgs instance with the configuration override
      pkgsFor = crossSystem: import nixpkgs {
        inherit crossSystem;
        system = "x86_64-linux";
        config.allowUnsupportedSystem = true; 
      };

      # Use the correct attribute for Raspberry Pi U-Boot
      # Note: ubootRaspberryPi is a function that takes an argument
      mkUBoot = crossSystem: 
        (pkgsFor crossSystem).buildPackages.pkgsCross.aarch64-multiplatform.ubootRaspberryPi { };
        
    in {
      # Use specific cross-configs
      uboot-armv6   = mkUBoot { config = "armv6l-unknown-linux-gnueabihf"; };
      uboot-armv7   = mkUBoot { config = "armv7l-unknown-linux-gnueabihf"; };
      uboot-aarch64 = mkUBoot { config = "aarch64-unknown-linux-gnu"; };
    };
  };
}
