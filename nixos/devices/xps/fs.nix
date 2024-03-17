{ ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-24dc2aad-a0de-4412-bd1e-3ccf96550e8b".device = "/dev/disk/by-uuid/24dc2aad-a0de-4412-bd1e-3ccf96550e8b";
}
