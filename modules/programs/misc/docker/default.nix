{ config, pkgs, ... }:

{
  services.docker = {
    enable = true;
    rootless = false;
    # storageDriver = "overlay2"; # might help if using custom partitions
  };

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];
}
