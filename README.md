# nixos-netboot-cluster-uboot

## Check this flake
```bash
nix flake check -v -L --no-build --no-write-lock-file --all-systems --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main
```

---

## Build u-boot image for armv6l RPi 1 (A/B/B+)
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main#image-armv6
```
### once done, the writeable image will be in .result/sd-image.img


``` sudo dd if=result/sd-image.img of=/dev/sdX bs=4M conv=fsync status=progress ```

---

## Build u-boot image for armv7l
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main#image-armv7
```
### once done, the writeable image will be in .result/sd-image.img


``` sudo dd if=result/sd-image.img of=/dev/sdX bs=4M conv=fsync status=progress ```

---

## Build u-boot image for aarch64 (3, Zero2-W)
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main#image-armv8-rpi3
```

## Build u-boot image for aarch64 (4 ,5)
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main#image-rpi4-5
```

### once done, the writeable image will be in .result/sd-image.img


``` sudo dd if=result/sd-image.img of=/dev/sdX bs=4M conv=fsync status=progress ```

---


Raspberry Pi Model | SoC | Architecture | Nixpkgs Target Key (pkgsCross.<key>)
---|---|---|---
RPi 1 (A/B/B+) | BCM2835 | ARMv6 | image-armv6
RPi Zero / Zero W|BCM2835|ARMv6|image-armv6
RPi 2 (B v1.1)|BCM2836|ARMv7|image-armv7
RPi 2 (B v1.2) / 3|BCM2837|ARMv8 (32-bit mode)|image-armv8-rpi3
RPi 3B+ / 4B|BCM2837B0/BCM2711|ARMv8 (64-bit)|image-rpi4-5
RPi 5|BCM2712|ARMv8 (64-bit)|image-rpi4-5
RPi Zero 2 W|BCM2710A1|ARMv8 (32-bit mode)|image-armv8-rpi3
