# nixos-test-vm

A minimal NixOS flake that provides a reusable baseline VM configuration for testing standalone NixOS module derivations.

## What it provides

`baselineConfig` — a NixOS module that sets up a headless x86_64 VM with:

- 2 vCPUs, 2 GB RAM, 20 GB disk
- Flakes and `nix-command` enabled
- Auto-login as `user` (passwordless sudo)
- `nixos-rebuild` disabled (intentional — use `build-vm` instead)

## Usage

Add this flake as an input in the flake you want to test:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  test-vm.url  = "github:jimurrito/nixos-test-vm";
};
```

Then pull `baselineConfig` into your `nixosConfigurations` alongside your module under test:

```nix
nixosConfigurations =
  let
    testConfig =
      { ... }:
      {
        services.burenix = {
          enable = true;
          keyPath = "/root/backup-key";
          backups =
            let
              cf = {
                enable = true;
                sourceDirs = [ "/var/log" ];
                targetDirs = [
                  "/var/burenix-backup"
                ];
                backupTime = "Tue, 03:00:00";
              };
            in
            {
              varlog_encrypted = cf;
              varlog = cf // {
                noEncrypt = true;
              };
            };
        };
      };
  in
  {
    test-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        test-vm.baselineConfig     # baseline VM setup
        self.nixosModules.default  # your module under test
        testConfig                 # test-specific options
      ];
    };
  };
```

## Running the VM

```bash
nix run .#nixosConfigurations.test-vm.config.system.build.vm
```

## License

See [LICENSE.md](LICENSE.md).
