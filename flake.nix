{
  description = "Cross-compile U-Boot and prepare SD images with USB Ethernet support";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnsupportedSystem = true; };
      
      # Driver configuration helper
      withUsbEthernet = uboot: uboot.overrideAttrs (old: {
        postConfigure = (old.postConfigure or "") + ''
          cat >> .config <<EOF
          CONFIG_USB_HOST_ETHER=y
          CONFIG_USB_ETHER=y
          CONFIG_USB_ETHER_ASIX=y
          CONFIG_USB_ETHER_ASIX88179=y
          CONFIG_USB_DWC2=y
          CONFIG_USB_XHCI_HCD=y
          CONFIG_USB_XHCI_PCI=y
          EOF
          make olddefconfig
        '';
      });

      # Architecture specific U-Boot targets
      ubootArmv6  = withUsbEthernet pkgs.pkgsCross.raspberryPi.ubootRaspberryPi;
      ubootArmv7  = withUsbEthernet pkgs.pkgsCross.armv7l-hf-multiplatform.ubootRaspberryPi3_32bit;
      ubootArmv8  = withUsbEthernet pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi3_64bit; # Pi Zero 2 W / Pi 3
      ubootPi4    = withUsbEthernet pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi4_64bit; # Pi 4 / 5

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
      # Export SD Images
      image-armv6      = mkSDImage { uboot = ubootArmv6; configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=0\ndtoverlay=dwc2,dr_mode=host"; bootCmd = ./boot.cmd; };
      image-armv7      = mkSDImage { uboot = ubootArmv7; configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=0\ndtoverlay=dwc2,dr_mode=host"; bootCmd = ./boot.cmd; };
      image-armv8-rpi3 = mkSDImage { uboot = ubootArmv8; configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=1\ndtoverlay=dwc2,dr_mode=host"; bootCmd = ./boot.cmd; };
      image-rpi4-5     = mkSDImage { uboot = ubootPi4;   configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=1\ndtoverlay=dwc2,dr_mode=host"; bootCmd = ./boot.cmd; };
    };
  };
}
