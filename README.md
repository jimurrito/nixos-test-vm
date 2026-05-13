# nixos-test-vm

A minimal NixOS flake that provides a reusable baseline VM configuration for testing standalone NixOS module derivations.
The goal of this flake is to allow for easy testing of standalone flakes.

## What it provides

`baselineConfig` — a NixOS module that sets up a headless x86_64 VM with:

- 2 vCPUs, 2 GB RAM, 20 GB disk
- Auto-login as `user`
- Passwordless sudo

## Usage

Add this flake as an input in the flake you want to test:

```nix
inputs = {
  test-vm.url  = "github:jimurrito/nixos-test-vm";
};
```

Then pull `test-vm.baselineConfig` into your `nixosConfigurations` alongside your module under test:

```nix
nixosConfigurations =  {
    test-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # baseline VM setup
        test-vm.baselineConfig
        #
        # Config that should be tested
        {
          services.nginx = {
            enable = true;
            virtualHosts."localhost" = {
              locations."/" = {
                return = "200 'ok'";
              };
            };
          };
          networking.firewall.allowedTCPPorts = [ 80 ];
        };
        #
        #
      ];
    };
  };
```

## Running the VM

```bash
nix run .#nixosConfigurations.test-vm.config.system.build.vm
```

The VM runs headless and attaches directly to your terminal. Your session will be held until the VM is shut down — use `qqq` inside the VM or `Ctrl+A X` to exit QEMU.

## License

See [LICENSE.md](LICENSE.md).
