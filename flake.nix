{
  description = "Cross-compile U-Boot and prepare SD images";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnsupportedSystem = true; };
      
      mkSDImage = { uboot, configTxt }: pkgs.stdenv.mkDerivation {
        name = "rpi-sd-image-${uboot.name}";
        nativeBuildInputs = [ pkgs.mtools pkgs.libfaketime ];
         buildCommand = ''
          # 1. Create the output directory first!
          mkdir -p $out
          
          # 2. Now you can write to the file inside $out
          truncate -s 128M $out/sd-image.img
          
          # 3. Format as FAT32
          ${pkgs.mtools}/bin/mformat -i $out/sd-image.img -F -v "BOOT" ::
          
          # 4. Stage files
          mkdir -p stage
          cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bootcode.bin stage/
          cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/start.elf stage/
          cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/fixup.dat stage/
          cp ${uboot}/u-boot.bin stage/
          echo "${configTxt}" > stage/config.txt
          
          # 5. Copy to image
          for file in stage/*; do
            ${pkgs.mtools}/bin/mcopy -i $out/sd-image.img $file ::
          done
        '';
      };
    in {
      # Raw U-Boot binaries
      uboot-aarch64 = pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi4_64bit;
      uboot-armv7   = pkgs.pkgsCross.armv7l-hf-multiplatform.ubootRaspberryPi3_32bit;
      uboot-armv6   = pkgs.pkgsCross.raspberryPi.ubootRaspberryPi;

      # SD Images
      image-aarch64 = mkSDImage { 
        uboot = pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi4_64bit;
        configTxt = "kernel=u-boot.bin\nenable_uart=1\narm_64bit=1";
      };
      image-armv7 = mkSDImage { 
        uboot = pkgs.pkgsCross.armv7l-hf-multiplatform.ubootRaspberryPi3_32bit;
        configTxt = "kernel=u-boot.bin\nenable_uart=1\narm_64bit=0";
      };
      image-armv6 = mkSDImage { 
        uboot = pkgs.pkgsCross.raspberryPi.ubootRaspberryPi;
        configTxt = "kernel=u-boot.bin\nenable_uart=1\narm_64bit=0";
      };
    };

    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in pkgs.mkShell {
      buildInputs = with pkgs; [ dtc mtools parted gcc gnumake ];
      shellHook = "echo 'Ready to build U-Boot and SD images.'";
    };
  };
}
