#!/usr/bin/env bash
configRepo="$1"
if [[ -z "$configRepo" ]]; then
    echo "[WARN] Defaulting to local directory as no repo was provided."
    configRepo=".#test-vm"
fi
nixos-rebuild build-vm --refresh --flake "${configRepo}" || exit 1
QEMU_KERNEL_PARAMS=console=ttyS0 result/bin/run-test-vm-vm
