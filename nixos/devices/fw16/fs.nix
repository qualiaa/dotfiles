{ ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-uuid/eb3ca2b8-f17b-4468-ae9c-33bd4114572c";
      preLVM = true;
    };
  };

  fileSystems."/".options = [ "compress=lzo" "noatime" ];
  fileSystems."/home".options = [ "compress=lzo" "noatime" ];
}
