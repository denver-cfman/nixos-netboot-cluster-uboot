{ pkgs }: 
let
  withUsbEthernet = uboot: uboot.overrideAttrs (old: {
    postConfigure = (old.postConfigure or "") + ''
      cat >> .config <<EOF
      CONFIG_USB_HOST_ETHER=y
      CONFIG_USB_ETHER=y
      CONFIG_USB_ETHER_ASIX=y
      CONFIG_USB_ETHER_ASIX88179=y
      CONFIG_USB_ETHER_ASIX88172=y
      CONFIG_USB_ETHER_MCS7830=y
      CONFIG_USB_ETHER_RTL8152=y
      CONFIG_USB_ETHER_SMSC95XX=y
      CONFIG_PHY_REALTEK=y
      CONFIG_USB_GADGET=y
      CONFIG_USB_GADGET_DWC2_OTG=y
      CONFIG_USB_GADGET_DOWNLOAD=y
      CONFIG_USB_ETHER_GADGET=y
      CONFIG_USB_ETH_RNDIS=y
      CONFIG_USB_ETH_CDC=y
      CONFIG_USB_FUNCTION_MASS_STORAGE=y
      CONFIG_USBNET_DEV_ADDR="de:ad:be:ef:00:01"
      CONFIG_USBNET_HOST_ADDR="de:ad:be:ef:00:00"
      EOF
      make olddefconfig
    '';
  });

  # Define cross-compiled U-Boot versions [cite: 6, 7]
  ubootArmv6 = withUsbEthernet pkgs.pkgsCross.raspberryPi.ubootRaspberryPi;
  ubootArmv7 = withUsbEthernet pkgs.pkgsCross.armv7l-hf-multiplatform.ubootRaspberryPi3_32bit;
  ubootArmv8 = withUsbEthernet pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi3_64bit;
  ubootPi4   = withUsbEthernet pkgs.pkgsCross.aarch64-multiplatform.ubootRaspberryPi4_64bit;

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
      for file in stage/*; do
        ${pkgs.mtools}/bin/mcopy -i $out/sd-image.img "$file" ::
      done
    '';
  };
in {
  image-armv6      = mkSDImage { uboot = ubootArmv6; configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=0\ndtoverlay=dwc2,dr_mode=host"; bootCmd = ./boot.cmd; };
  image-armv7      = mkSDImage { uboot = ubootArmv7; configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=0\ndtoverlay=dwc2,dr_mode=host"; bootCmd = ./boot.cmd; };
  image-armv8-rpi3 = mkSDImage { uboot = ubootArmv8; configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=1\ndtoverlay=dwc2,dr_mode=host"; bootCmd = ./boot.cmd; };
  image-rpi4-5     = mkSDImage { uboot = ubootPi4;   configTxt = "kernel=kernel.img\nenable_uart=1\narm_64bit=1\ndtoverlay=dwc2,dr_mode=host"; bootCmd = ./boot.cmd; };
}
