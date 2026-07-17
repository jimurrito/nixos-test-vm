/*
  Deploys a test VM via QEMU
  TTY will become the TTY of the created VM once invoked

  Flake used must have <path/url>#test-vm as a nixosConfiguration.
*/
{ pkgs, ... }:
{
  environment.shellAliases = {
    nixos-test-vm = pkgs.runCommand "test-vm-builder" { } ''
      cat ${./builder.bash} > $out
      chmod 0555 $out
    '';
  };
}
