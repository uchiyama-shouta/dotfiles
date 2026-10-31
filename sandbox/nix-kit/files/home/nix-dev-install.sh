#!/bin/sh
set -eu
export USER=agent
cd /tmp
curl -fsSL https://releases.nixos.org/nix/nix-2.35.4/nix-2.35.4-x86_64-linux.tar.xz -o nix-test.tar.xz
echo 'ff66236d2f7e2a21f3350e73668e021ac6a8881ef277a38e16e952bfb22718c3  nix-test.tar.xz' | sha256sum -c -
tar -xf nix-test.tar.xz
sh nix-2.35.4-x86_64-linux/install --no-daemon --yes --no-channel-add
