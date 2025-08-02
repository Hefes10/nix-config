{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/Applications/Safari.app"
      "/Applications/Mensajes.app"
      "/Applications/Telegram.app"
      "/Applications/Calendario.app"
      "/Applications/Visual Studio Code.app"
      "/Applications/Ghostty.app"
    ];
  };
}
