{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/Launchpad.app"
      "/Applications/Calendar.app"
      "/Applications/WhatsApp.app"
      "/Applications/Telegram.app"
      "/Applications/Safari.app"
      "/Applications/Visual Studio Code.app"
      "/Applications/Ghostty.app"
      "/Applications/Warp.app"
      "/Applications/System Settings.app.app"
    ];
  };
}
