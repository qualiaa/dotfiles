{ pkgs, ... }:

{
  programs.nm-applet.enable = true;
  programs.nm-applet.indicator = false;

  services.redshift = {
    enable = true;
    temperature.day = 6700;
    temperature.night = 3000;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [pkgs.cups-brother-hll2350dw];
}
