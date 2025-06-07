{
  description = "An minimal NixOS configuration";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
  };

  outputs = inputs:
    let
      lib = inputs.nixpkgs.lib;
      pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
      # https://nixos.wiki/wiki/Qtile
      qtile = (pkgs.qtile-unwrapped.overrideAttrs(_: rec {
      postInstall = let
        qtileSession = ''
        [Desktop Entry]
        Name=Qtile Wayland
        Comment=Qtile on Wayland
        Exec=qtile start -b wayland
        Type=Application
        '';
        in
        ''
      mkdir -p $out/share/wayland-sessions
      echo "${qtileSession}" > $out/share/wayland-sessions/qtile.desktop
      '';
      passthru.providedSessions = [ "qtile" ];
    }));
    in
    {
      nixosConfigurations = {

        mysystem = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              boot.loader.systemd-boot.enable = true; # (for UEFI systems only)
              fileSystems."/".device = "/dev/disk/by-label/nixos";
              environment.systemPackages = with pkgs; [
                qtile
              ];
            }
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}

