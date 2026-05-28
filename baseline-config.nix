/*
  Baseline config for the test-vm.
  Enough config to deploy a test VM.
*/
{ config, pkgs, ... }:
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
  # quick quit alias
  environment.shellAliases.qqq = "sudo shutdown 0 0 0";
  # VM specs
  virtualisation.vmVariant.virtualisation = {
    memorySize = 2048;
    cores = 2;
    graphics = false;
    diskSize = 20480;
  };
  # default packages
  environment.systemPackages = with pkgs; [
    fastfetch
  ];
}
