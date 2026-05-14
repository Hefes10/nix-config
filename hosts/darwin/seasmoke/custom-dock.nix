{ config, ... }:
{
  system.defaults.dock = {
    persistent-apps = [
      "/System/Applications/Calendar.app"
      "/Applications/WhatsApp.app"
      "/Applications/Telegram.app"
      "/Applications/Safari.app"
      "/Applications/Ghostty.app"
      "/Applications/Warp.app"
      "/System/Applications/System Settings.app"
      "/Applications/Evernote.app"
      "/Applications/Notion.app"
      "/Applications/Claude.app"
    ];
  };
}
