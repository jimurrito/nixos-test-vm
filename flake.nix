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
      baselineConfig.imports = ./baseline-config.nix;
      #
      # test vm for testing the test vm
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
