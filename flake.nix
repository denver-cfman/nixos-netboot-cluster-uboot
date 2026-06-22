{
  description = "Cross-compile U-Boot and prepare SD images";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnsupportedSystem = true; };
      
mkSDImage = { uboot, configTxt, bootCmd }: pkgs.stdenv.mkDerivation {
        name = "rpi-sd-image-${uboot.name}";
        nativeBuildInputs = [ pkgs.mtools pkgs.ubootTools pkgs.libfaketime ];
        # Pass the bootCmd file as an environment variable to the builder
        BOOT_CMD = bootCmd; 
        buildCommand = ''
          mkdir -p $out
          truncate -s 120M $out/sd-image.img
          ${pkgs.mtools}/bin/mformat -i $out/sd-image.img -F -v "BOOT" ::
          
          mkdir -p stage
          # Compile the script provided in the BOOT_CMD variable
          ${pkgs.ubootTools}/bin/mkimage -A arm -O linux -T script -C none -n "Boot Script" -d $BOOT_CMD stage/boot.scr
          
          cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bootcode.bin stage/
          cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/start.elf stage/
          cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/fixup.dat stage/
          cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/*.dtb stage/
          cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays stage/
          cp ${uboot}/u-boot.bin stage/kernel.img
          echo "${configTxt}" > stage/config.txt
          
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
        bootCmd = ./boot.cmd;
      };
      image-armv7 = mkSDImage { 
        uboot = pkgs.pkgsCross.armv7l-hf-multiplatform.ubootRaspberryPi3_32bit;
        configTxt = "kernel=u-boot.bin\nenable_uart=1\narm_64bit=0";
        bootCmd = ./boot.cmd;
      };
      image-armv6 = mkSDImage { 
        uboot = pkgs.pkgsCross.raspberryPi.ubootRaspberryPi;
        configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=0";
        bootCmd = ./boot.cmd;
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
