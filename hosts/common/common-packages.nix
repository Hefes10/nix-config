{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    ## En uso
    btop          # monitor de procesos
    coreutils
    difftastic    # diff con syntax awareness
    drill         # DNS lookup
    du-dust       # du moderno
    duf           # df moderno
    entr          # ejecutar comando al cambiar archivos
    fastfetch     # info del sistema
    fd            # find moderno
    ffmpeg
    gh            # GitHub CLI
    gnused
    iperf3        # test de velocidad de red
    jq            # JSON CLI
    just          # task runner (make moderno)
    mosh          # SSH resistente a desconexiones
    nmap          # escaneo de red
    ripgrep       # grep moderno
    skopeo        # gestión de imágenes Docker/OCI
    smartmontools # salud de discos
    tree
    unzip
    uv            # Python package manager
    watch
    wget
    zoxide        # cd inteligente

    ## Comentados - activar si los necesito
    #act          # ejecutar GitHub Actions localmente
    #ansible      # automation
    #beszel       # monitor de servers
    #diffr        # otro diff coloreado (alternativa a difftastic)
    #dua          # otro analizador de espacio (alternativa a dust)
    #esptool      # programar memoria flash de dispositivos ESP
    #figurine     # ASCII art banners
    #git-crypt    # encriptar archivos en git
    #go           # compilador Go
    #hugo         # generador de sitios estáticos
    #ipmitool     # gestión de servers vía IPMI
    #jetbrains-mono   # fuente (ya está en fonts.packages)
    #kubectl      # CLI de Kubernetes
    #mc           # Midnight Commander (file manager TUI)
    #qemu         # virtualización
    #talosctl     # CLI de Talos (k8s)
    #television   # selector fuzzy
    #terraform    # IaC
    #wireguard-tools  # VPN
    #vscode-extensions.ms-vscode-remote.remote-ssh
  ];
}
