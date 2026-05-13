{
  description = "Simple test VM built to test standalone flake derivations ";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };
  #
  outputs =
    { self, nixpkgs }:
    {
      #
      # baseline config for VM
      baselineConfig =
        { config, ... }:
        {
          # Nix configs
          system.stateVersion = config.system.nixos.release;
          nixpkgs.config.allowUnfree = true;
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          # general OS configs
          networking.hostName = "test-vm";
          time.timeZone = "America/Chicago";
          environment.shellAliases.nixos-rebuild = ''echo "nixos-rebuild is disabled on 'build-vm' VMs."'';
          users.users.user = {
            isNormalUser = true;
            #initialHashedPassword = "$y$j9T$Cnmeqk6vSrqCaMy6h2KHq0$rENTiHBIrUoACiGaoty3BZEJrkytOucpdzBJbtaL6Q0";
            extraGroups = [ "wheel" ];
          };
          security.sudo.extraRules = [
            {
              users = [ "user" ];
              commands = [
                {
                  command = "ALL";
                  options = [
                    "NOPASSWD"
                    "SETENV"
                  ];
                }
              ];
            }
          ];
          programs.bash.shellInit = "export HISTCONTROL=ignoreboth:erasedups";
          services.getty.autologinUser = "user";
          environment.shellAliases.qqq = "sudo shutdown 0 0 0";
          # VM specs
          virtualisation.vmVariant.virtualisation = {
            memorySize = 2048;
            cores = 2;
            graphics = false;
            diskSize = 20480;
          };
        };
      #
      #
      nixosConfigurations = {
        test-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.baselineConfig
          ];
        };
      };
      #
      #
    };
}
