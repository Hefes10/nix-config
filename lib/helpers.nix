{ inputs, outputs, stateVersion, ... }:
{
  mkDarwin = { hostname, username ? "hefes", system ? "aarch64-darwin", }:
  let
    inherit (inputs.nixpkgs-darwin) lib;
    customConfPath = ./../hosts/darwin/${hostname};
    customConf = if builtins.pathExists (customConfPath) then (customConfPath + "/default.nix") else ./../hosts/common/darwin-common.nix;
    homeConfigPath = ./../home + "/${username}.nix";
  in
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = { inherit system inputs username; };
      modules = [
        ../hosts/common/common-packages.nix
        ../hosts/common/darwin-common.nix
        customConf
        # Add nodejs overlay to fix build issues (https://github.com/NixOS/nixpkgs/issues/402079)
        {
          nixpkgs.overlays = [
            (final: prev: {
              nodejs = prev.nodejs_22;
              nodejs-slim = prev.nodejs-slim_22;
            })
          ];
        }
        inputs.home-manager.darwinModules.home-manager {
            networking.hostName = hostname;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.${username} = { imports = [ homeConfigPath ]; };
        }
        inputs.nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            autoMigrate = true;
            mutableTaps = true;
            user = "${username}";
            taps = with inputs; {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };
          };
        }
      ];
    };
}
