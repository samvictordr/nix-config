{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    flightgear
  ];
}
