#!/usr/bin/env bash
configRepo="$1"
if [[ -z $configRepo ]]; then
    echo "[WARN] Defaulting to local directory as no repo was provided."
    configRepo=".#test-vm"
fi
# split repo and node name
IFS="#" read -r repo host <<< "$configRepo"
# check if a flake file exists in the repo
# get hostname of the VM
# This is needed so we can locate the bin under ./result
hostName=$(nix eval --raw "${repo}#nixosConfigurations.${host}.config.networking.hostName")
#
nixos-rebuild build-vm --refresh --flake "${configRepo}" || exit 1
QEMU_KERNEL_PARAMS=console=ttyS0 result/bin/run-${hostName}-vm
