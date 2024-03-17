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

  # Configure restic backups
  systemd.user.services.restic = {
    path = [ pkgs.openssh ];
    environment = {
      RESTIC_REPOSITORY = "sftp:backups:jamie";
      RESTIC_PASSWORD_FILE = "%h/.restic-password";
    };
    description = "Restic backup";
    requires = ["default.target"];
    serviceConfig = {
      ExecStart = ''${pkgs.restic}/bin/restic backup %h --exclude-file %h/.restic-exclude-file'';
      RestartSec = "30m";
      Restart = "on-failure";
    };
  };
  systemd.user.timers.restic = {
    description = "Restic backup timer";
    timerConfig = {
      OnCalendar = "Sat 02:00";
      Persistent = true;
    };
    wantedBy = ["timers.target"];
  };
}
