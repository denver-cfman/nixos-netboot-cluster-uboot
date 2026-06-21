# nixos-netboot-cluster-uboot

## Check this flake
```bash
nix flake check -v -L --no-build --no-write-lock-file --all-systems --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main
```

---

## Dev Sell
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main
```

---

## Build u-boot image for armv6l (A, A+, B, B+, Zero, Zero-W)
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main#uboot-armv6l
```
### once done, the writeable image will be in .result/u-boot.bin

``` sudo dd if=result/u-boot.bin of=/dev/sdX bs=4M conv=fsync status=progress ```
---

## Build u-boot image for armv7l
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main#uboot-armv7l
```
### once done, the writeable image will be in .result/u-boot.bin

``` sudo dd if=result/u-boot.bin of=/dev/sdX bs=4M conv=fsync status=progress ```
---

## Build u-boot image for aarch64 (3, ,4 ,5, Zero2-W)
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main#uboot-aarch64
```
### once done, the writeable image will be in .result/u-boot.bin

``` sudo dd if=result/u-boot.bin of=/dev/sdX bs=4M conv=fsync status=progress ```
---

Raspberry Pi Model | SoC|Architecture | Nixpkgs Target Key (pkgsCross.<key>)
|---|---|
RPi 1 (A/B/B+) | BCM2835 | ARMv6 | raspberryPi
RPi Zero / Zero W|BCM2835|ARMv6|raspberryPi
RPi 2 (B v1.1)|BCM2836|ARMv7|armv7l-hf-multiplatform
RPi 2 (B v1.2) / 3|BCM2837|ARMv8 (32-bit mode)|armv7l-hf-multiplatform
RPi 3B+ / 4B|BCM2837B0/BCM2711|ARMv8 (64-bit)|aarch64-multiplatform
RPi 5|BCM2712|ARMv8 (64-bit)|aarch64-multiplatform
RPi Zero 2 W|BCM2710A1|ARMv8 (32-bit mode)|armv7l-hf-multiplatform
