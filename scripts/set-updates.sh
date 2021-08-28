#!/bin/sh

mkdir -p ~/.config/nixpkgs
cp home.nix ~/.config/nixpkgs/home.nix
cp config.nix ~/.config/nixpkgs/config.nix
sudo cp configuration.nix /etc/nixos/configuration.nix
