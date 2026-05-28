# nixos-test-vm

![Nix](https://img.shields.io/badge/language-Nix-5277C3?logo=nixos&logoColor=white)
![License](https://img.shields.io/badge/license-GPLv3-blue)

A minimal NixOS flake that provides a reusable baseline VM configuration for testing standalone NixOS module derivations. The goal of this flake is to allow easy, isolated testing of other flakes without needing to write boilerplate VM setup each time.

## Table of Contents

- [Requirements](#requirements)
- [Usage](#usage)
- [Running the VM](#running-the-vm)
- [Flake Reference](#flake-reference)
- [License](#license)

## Requirements

- [Nix](https://nixos.org/download/) with flakes enabled (`nix-command` and `flakes` experimental features)
- QEMU (provided automatically at runtime via `nix run`)

## Usage

Add this flake as an input in the flake you want to test:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-<version>";
  test-vm = {
    url  = "github:jimurrito/nixos-test-vm";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

Then pull `test-vm.baselineConfig` into your `nixosConfigurations` alongside the module under test:

```nix
nixosConfigurations = {
  test-vm = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      test-vm.baselineConfig
      # module under test
      { <your-config-here> }
    ];
  };
};
```

### Real Example

Testing an nginx service:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    test-vm = {
      url  = "github:jimurrito/nixos-test-vm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, test-vm, ... }: {
    nixosConfigurations = {
      test-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          test-vm.baselineConfig
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
          }
        ];
      };
    };
  };
}
```

## Running the VM

```bash
nix run .#nixosConfigurations.test-vm.config.system.build.vm
```

The VM runs headless and attaches directly to your terminal. Your session is held until the VM shuts down. Use `qqq` inside the VM or `Ctrl+A X` to exit QEMU.

## Flake Reference

### Available attributes

| Output           | Type         | Description                                                        |
| ---------------- | ------------ | ------------------------------------------------------------------ |
| `baselineConfig` | NixOS module | Baseline VM configuration to include in your `nixosConfigurations` |

### baselineConfig Settings

As of now these are non-configurable.

| Setting                        | Value              | Description                       |
| ------------------------------ | ------------------ | --------------------------------- |
| `virtualisation.memorySize`    | `2048` MB          | VM RAM                            |
| `virtualisation.cores`         | `2`                | vCPU count                        |
| `virtualisation.diskSize`      | `20480` MB (20 GB) | VM disk size                      |
| `virtualisation.graphics`      | `false`            | Headless — no display output      |
| `services.getty.autologinUser` | `user`             | Auto-login user on boot           |
| `security.sudo`                | passwordless       | `user` has full passwordless sudo |
| `networking.hostName`          | `test-vm`          | Default hostname                  |
| `time.timeZone`                | `America/Chicago`  | System timezone                   |
| `environment.systemPackages`   | `fastfetch`        | Pre-installed packages            |

## License

See [LICENSE.md](LICENSE.md).
