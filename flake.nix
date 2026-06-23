{
  description = "Cross-compile U-Boot and prepare SD images with USB Ethernet support";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnsupportedSystem = true; };
      
      # Function to apply USB Ethernet support to ANY U-Boot package
      withUsbEthernet = uboot: uboot.overrideAttrs (old: {
        postConfigure = (old.postConfigure or "") + ''
          # Enable the core USB Ethernet framework
          echo "CONFIG_USB_HOST_ETHER=y" >> .config
          echo "CONFIG_USB_ETHER=y" >> .config
          
          # Enable your specific drivers
          echo "CONFIG_USB_ETHER_ASIX=y" >> .config
          echo "CONFIG_USB_ETHER_ASIX88179=y" >> .config
          
          # Force the config to resolve dependencies
          make oldconfig
        '';
      });

      mkSDImage = { uboot, configTxt, bootCmd }: pkgs.stdenv.mkDerivation {
        name = "rpi-sd-image-${uboot.name}";
        nativeBuildInputs = [ pkgs.mtools pkgs.ubootTools pkgs.libfaketime ];
        BOOT_CMD = bootCmd;
        buildCommand = ''
          mkdir -p $out
          truncate -s 120M $out/sd-image.img
          ${pkgs.mtools}/bin/mformat -i $out/sd-image.img -F -v "BOOT" ::
          
          mkdir -p stage
          ${pkgs.ubootTools}/bin/mkimage -A arm -O linux -T script -C none -n "Boot Script" -d $BOOT_CMD stage/boot.scr
          
          cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/{bootcode.bin,start.elf,fixup.dat,*.dtb} stage/
          cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays stage/
          cp ${uboot}/u-boot.bin stage/kernel.img
          echo "${configTxt}" > stage/config.txt
          
          set -x
          for file in stage/*; do
            ${pkgs.mtools}/bin/mcopy -i $out/sd-image.img "$file" ::
          done
        '';
      };
    in {
      # Custom U-Boot packages
      uboot-aarch64 = withUsbEthernet pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi4_64bit;
      uboot-armv7   = withUsbEthernet pkgs.pkgsCross.armv7l-hf-multiplatform.ubootRaspberryPi3_32bit;
      uboot-armv6   = withUsbEthernet pkgs.pkgsCross.raspberryPi.ubootRaspberryPi;

      # SD Images using the custom U-Boot
      image-aarch64 = mkSDImage { 
        uboot = self.packages.x86_64-linux.uboot-aarch64;
        configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=1";
        bootCmd = ./boot.cmd;
      };
      image-armv7 = mkSDImage { 
        uboot = self.packages.x86_64-linux.uboot-armv7;
        configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=0";
        bootCmd = ./boot.cmd;
      };
      image-armv6 = mkSDImage { 
        uboot = self.packages.x86_64-linux.uboot-armv6;
        configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=0";
        bootCmd = ./boot.cmd;
      };
    };
  };
}
