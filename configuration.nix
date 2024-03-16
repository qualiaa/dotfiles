# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-24dc2aad-a0de-4412-bd1e-3ccf96550e8b".device = "/dev/disk/by-uuid/24dc2aad-a0de-4412-bd1e-3ccf96550e8b";
  networking.hostName = "jamie-xps-nixos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Make backlight accessible to video group
  #services.udev.path = [ pkgs.coreutils ];
  services.udev.extraRules = ''
    SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="${pkgs.coreutils}/bin/chmod 660 /sys/class/backlight/%k/brightness"
  '';

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "gb";
    xkbVariant = "";
    xkb.options = "caps:escape";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [pkgs.cups-brother-hll2350dw];

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jamie = {
    isNormalUser = true;
    description = "Jamie Bayne";
    extraGroups = [ "networkmanager" "wheel" "video" ];

    shell = pkgs.zsh;

    packages = with pkgs; [
      firefox
      rofi
      element-desktop
    ];
  };

  users.users.mina = {
    isNormalUser = true;
    description = "Mina";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      vivaldi
      vscode
      R
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    ## Networking
    openvpn
    networkmanager-openvpn
    networkmanagerapplet
    bluez
    
    ## File sync & Backup
    restic
    nextcloud-client

    ## Editors and productivity tools
    (rxvt-unicode.override { configure = _: { perlDeps = with perl538Packages; [ commonsense LinuxFD SubExporter SubInstall DataOptList ParamsUtil ]; };})
    emacs
    vim-full
    git
    zotero

    ## Languages
    cbqn
    python3  # NB: pythonFull includes tcl etc, but this is just for basic support
    texliveFull

    # C/C++
    clang
    gcc
    mold
    gdb
    cmake

    ## Applications
    discord
    strawberry
    libreoffice
    gimp
    inkscape

    ## Fonts
    inconsolata  # FIXME: this package doesn't add inconsolata to fc-cache
    powerline-fonts
    bqn386  # For BQN
    noto-fonts  # For other scripts

    ## Utilities
    dunst
    pavucontrol
    (redshift.override { withGeolocation = false; })
    zsh

    # Nix tools
    nix-prefetch-scripts

    # CLI tools
    comma
    feh
    fzf
    p7zip
    pandoc
    ripgrep
    screenfetch
    scrot
    wget
    xsel
    xorg.xev
    xorg.xprop
    zathura
    zenith
  ];

  programs.zsh.enable = true;

  programs.ssh.extraConfig = ''
    Host gh
      Hostname github.com
      User git
    
    Host crucible
      Hostname crucible.luffy.ai
      User git

    Host piserve
      Hostname piserve
      User jamie

    Host backups
      Hostname piserve
      User backups
  '';

  programs.nm-applet.enable = true;
  programs.nm-applet.indicator = false;

  location.latitude = 51.;
  location.longitude = -1.;
  services.redshift = {
    enable = true;
    temperature.day = 6700;
    temperature.night = 3000;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedTCPPortRanges = [ 
    { from = 5757; to = 5768; }
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}