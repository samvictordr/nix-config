{
  lib,
  pkgs,
  config,
  ...
}: let
  nvidiaDriverChannel = config.boot.kernelPackages.nvidiaPackages.latest; # stable, latest, beta, etc.
in {
  environment.sessionVariables = lib.optionalAttrs config.programs.hyprland.enable {
    NVD_BACKEND = "direct";
    GBM_BACKEND = "nvidia-drm";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = "1"; # GSync
    __NV_PRIME_RENDER_OFFLOAD = "1";

    # Force Hyprland to Intel (card1) by default
    WLR_DRM_DEVICES = "/dev/dri/card1"; # NEW
  };

  services.thermald.enable = true;
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  boot.kernelParams = lib.optionals (lib.elem "nvidia" config.services.xserver.videoDrivers) [
    "nvidia-drm.modeset=1"
    "nvidia_drm.fbdev=1"
  ];

  hardware = {
    nvidia = {
      open = false;
      # nvidiaPersistenced = true;
      nvidiaSettings = false;
      powerManagement.enable = true; # This can cause sleep/suspend to fail.
      modesetting.enable = true;
      package = nvidiaDriverChannel;

      # PRIME offloading block
      prime = {                        # NEW
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0:2:0";     # Change if lspci shows different
        nvidiaBusId = "PCI:1:0:0";    # Change if lspci shows different
      };
    };

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  nixpkgs.config = {
    nvidia.acceptLicense = true;
    cudaSupport = true;
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "cudatoolkit"
        "nvidia-persistenced"
        "nvidia-settings"
        "nvidia-x11"
      ];
  };

  nix.settings = {
    substituters = ["https://cuda-maintainers.cachix.org"];
    trusted-public-keys = ["cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="];
  };
}
