/*
  Deploys a test VM via QEMU
  TTY will become the TTY of the created VM once invoked

  Flake used must have <path/url>#test-vm as a nixosConfiguration.
*/
{ lib, pkgs, ... }:
with lib;
let
  bash = getExe pkgs.bash;
in
{
  environment.shellAliases = {
    nixos-test-vm = "${bash} ${./builder.bash}";
  };
}
