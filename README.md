# nixos-netboot-cluster-uboot

## Check this flake
```bash
nix flake check -v -L --no-build --no-write-lock-file --all-systems --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main
```

---

## Dev Sell
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main#uboot-armv6l
```

---

## Build u-boot image for armv6l (A, A+, B, B+, Zero, Zero-W)
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main#uboot-armv6l
```

---

## Build u-boot image for armv7l
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main#uboot-armv7l
```

---

## Build u-boot image for aarch64 (3, ,4 ,5, Zero2-W)
```bash
nix build -v -L --refresh github:denver-cfman/nixos-netboot-cluster-uboot?ref=main#uboot-aarch64
```

---
