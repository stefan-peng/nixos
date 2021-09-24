#!/bin/sh

mkdir -p ~/.config/nixpkgs
cp -v home.nix ~/.config/nixpkgs/home.nix
cp -v config.nix ~/.config/nixpkgs/config.nix
sudo cp -v configuration.nix /etc/nixos/configuration.nix
