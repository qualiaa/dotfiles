{ pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

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

    # Viewers
    feh
    zathura
    vlc

    ## Fonts
    inconsolata  # FIXME: this package doesn't add inconsolata to fc-cache
    powerline-fonts
    bqn386  # For BQN
    noto-fonts  # For other scripts

    ## Utilities
    dunst
    libnotify
    numlockx
    pavucontrol
    pulseaudio-ctl
    (redshift.override { withGeolocation = false; })
    zsh

    # Nix tools
    nix-prefetch-scripts

    # CLI tools
    comma
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
    zenith
  ];
}
