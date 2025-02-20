#!/usr/bin/env bash

set -eu

cd -- "$(dirname -- "$0")"

WARN=
NORMAL=
if [[ -t 1 ]] && command -v tput &>/dev/null; then
    WARN="$(tput setaf 3)"
    NORMAL="$(tput op)"
fi

# Fetch submodules (i.e. kali-vm repository).
git submodule update --init --recursive

# Apply patches.
failed_patches=()
for patch in "$(pwd)"/kali-vm-patches/*.patch; do
    if ! git -C kali-vm apply "${patch}"; then
        failed_patches+=( "${patch##*/}" )
    fi
done
if [[ "${#failed_patches[@]}" -gt 0 ]]; then
    printf '%sWarning: The following %d patches failed to apply. Check if this is expected!%s\n' "${WARN}" "${#failed_patches[@]}" "${NORMAL}"
    for patch in "${failed_patches[@]}"; do
        printf '%s* %s%s\n' "${WARN}" "${patch}" "${NORMAL}"
    done
fi

# Generate persistent SSH host keys.
mkdir -p kali-vm/overlays/ssh-keys/etc/ssh/
ssh-keygen -A -f kali-vm/overlays/ssh-keys/
