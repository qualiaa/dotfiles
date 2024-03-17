{ pkgs, ... }:

{
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
}
