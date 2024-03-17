{ ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure console keymap
  console.keyMap = "uk";

  # Configure keymap in X11
  services.xserver = {
    layout = "gb";
    xkbVariant = "";
    xkb.options = "caps:escape";
  };

  # Configure touchpad
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad = {
    naturalScrolling = true;
    disableWhileTyping = true;
  };
}
