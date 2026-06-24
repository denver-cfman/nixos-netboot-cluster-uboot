{
  description = "Unified Build System for iPXE and U-Boot SD Images";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { 
        inherit system; 
        config.allowUnsupportedSystem = true; 
      };

      # 1. iPXE Build Logic
      embedScript = pkgs.writeText "boot.ipxe" ''
        #!ipxe
        dhcp
        chain http://10.0.85.75/netboot.xyz.efi
      '';

      customIpxe = pkgs.ipxe.override { embedScript = embedScript; };

      ipxeIso = pkgs.stdenv.mkDerivation {
        name = "custom-ipxe-iso";
        buildInputs = [ customIpxe ];
        buildCommand = ''
          mkdir -p $out
          cp ${customIpxe}/ipxe.iso $out/ipxe.iso
          cp ${customIpxe}/undionly.kpxe $out/undionly.kpxe
        '';
      };

      # 2. U-Boot/SD Image Logic (imported from your provided structure)
      rpiPackages = import ./rpi-images.nix { inherit pkgs; };

    in {
      packages.${system} = {
        inherit ipxeIso;
      } // rpiPackages;
    };
}
