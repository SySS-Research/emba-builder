#!/usr/bin/env bash

set -eu

cd -- "$(dirname -- "$0")"

# Fetch submodules (i.e. kali-vm repository).
git submodule update --init --recursive

# Apply patches.
for patch in "$(pwd)"/kali-vm-patches/*.patch; do
    git -C kali-vm apply "${patch}"
done
