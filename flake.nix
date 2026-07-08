{
  description = "Simple test VM built to test standalone flake derivations ";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };
  #
  outputs =
    { self, nixpkgs }:
    {
      #
      # baseline config for VM
      baselineConfig = ./baseline-config.nix;
      #
      # Cli alias
      cli.imports = [ ./cli.nix ];
      #
      # test vm for testing the test vm
      nixosConfigurations = {
        test-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (import self.baselineConfig { })
            self.cli
            # nginx server for testing
            {
              services.nginx = {
                enable = true;
                virtualHosts."localhost" = {
                  forceSSL = false;
                  enableACME = false;
                  locations."/".extraConfig = ''
                    return 200 "Nginx is running successfully!";
                    add_header Content-Type text/plain;
                  '';
                };
              };
            }
          ];
        };
      };
      #
      #
    };
}
