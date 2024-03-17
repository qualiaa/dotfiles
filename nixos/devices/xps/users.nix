{ pkgs, ... }:

{
  imports = [ ../../common/users.nix ];

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
}
