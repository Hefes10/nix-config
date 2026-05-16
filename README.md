# nix-config (seasmoke)

Configuración declarativa de mi Mac usando [Nix](https://nixos.org), [nix-darwin](https://github.com/nix-darwin/nix-darwin), [home-manager](https://github.com/nix-community/home-manager) y [nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew).

Toda la configuración del sistema, paquetes CLI, apps GUI (vía Homebrew), defaults de macOS, dock, y dotfiles de usuario están versionados en este repo. Reproducible en cualquier Mac Apple Silicon con tres comandos.

---

## ¿Qué hace esto?

- **Gestiona el sistema**: defaults de macOS (dock abajo, Finder en lista, etc.), TouchID para sudo, fuentes Nerd Font, keyboard
- **Instala apps GUI** vía Homebrew declarativo: Claude, Evernote, Notion, Obsidian, OBS, Docker, Orbstack, Tailscale, Surfshark, Raycast, Marta, Stats, etc.
- **Instala apps de la Mac App Store**: Telegram, Windows App (WhatsApp se instala manual, ver Troubleshooting)
- **Provee herramientas CLI** vía Nix: `uv`, `ripgrep`, `fd`, `bat`, `eza`, `fzf`, `jq`, `gh`, `mosh`, `nmap`, `skopeo`, etc.
- **Configura el shell**: zsh con autosuggestion + completion, starship, tmux, neovim, git, ssh, direnv+nix-direnv
- **Deploya configs de apps**: Ghostty (tema Nord, JetBrainsMono Nerd Font, teclado latam)

---

## Pre-requisitos

- macOS reciente (Sequoia 15+), Apple Silicon (M1/M2/M3/M4/M5...)
- Conexión a Internet
- Una cuenta de Apple ID logueada en la App Store (para apps MAS)

---

## Instalación desde cero (Mac nueva)

### Paso 1 — Configurar la Mac

1. **Idioma del sistema**: lo que prefieras. La config no depende del idioma. Los nombres de apps en disco (`Calendar.app`, `System Settings.app`, etc.) están en inglés siempre, macOS solo traduce el nombre visual.
2. **Layout de teclado**: Español - Latinoamericano (afecta `macos-option-as-alt = false` en Ghostty para que funcione `Option+Q = @`).
3. **Usuario**: `hefes`. Si querés otro nombre, hay que editar `lib/helpers.nix` (default `username = "hefes"`), `hosts/common/darwin-common.nix` (`users.users.hefes.home` y `system.primaryUser`), y renombrar `home/hefes.nix`.
4. **Hostname**: `seasmoke`. Si querés otro, editar `flake.nix` (key en `darwinConfigurations`) y usar ese nombre en los comandos de switch. Cambiar el hostname de macOS:
   ```bash
   sudo scutil --set LocalHostName seasmoke
   sudo scutil --set HostName seasmoke
   sudo scutil --set ComputerName seasmoke
   ```

### Paso 2 — Instalar Determinate Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Va a hacer dos preguntas:
- Primera (telemetría/Determinate cloud): **No**
- Segunda (instalar Nix): **Sí**

Al terminar, **cerrar y reabrir la terminal** para que se cargue el daemon.

### Paso 3 — Configurar SSH con GitHub (opcional pero recomendado)

Si vas a hacer `git push` desde esta Mac:

```bash
ssh-keygen -t ed25519 -C "tu-email@example.com"
cat ~/.ssh/id_ed25519.pub
```

Copiar la salida, ir a GitHub → Settings → SSH and GPG Keys → New SSH key, pegar.

Probar:
```bash
ssh -T git@github.com
```

Debería decir "Hi Hefes10! You've successfully authenticated..."

### Paso 4 — Clonar este repo

```bash
mkdir -p ~/Documents/nix-config-workspace
cd ~/Documents/nix-config-workspace
git clone git@github.com:Hefes10/nix-config.git
cd nix-config
```

> **Nota**: en la M1 actual este repo vive en `~/Documents/Documentos - MacBook Air de Jose/nix-config/` (path heredado de Migration Assistant). En la M5 conviene clonarlo a un path más limpio sin espacios.

Si no configuraste SSH (Paso 3), usar HTTPS:
```bash
git clone https://github.com/Hefes10/nix-config.git
```

### Paso 5 — Primera build (validación)

```bash
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.seasmoke.system" --no-link
echo "Exit: $?"
```

Si `Exit: 0`, el sistema compila correctamente. Si falla, **NO seguir al switch**, investigar el error primero.

### Paso 6 — Primer switch

```bash
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.seasmoke.system"
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#seasmoke"
```

Va a pedir contraseña. Después:
1. Instala paquetes Nix
2. Configura Homebrew si no está
3. Instala/desinstala casks (puede tardar **10-20 minutos** según conexión)
4. Aplica defaults de macOS
5. Configura el dock
6. Activa home-manager (zsh, git, neovim, etc.)

### Paso 7 — Reabrir terminal

Cerrar todas las terminales y abrir una nueva. Verificar que el PATH se cargó automáticamente:

```bash
which darwin-rebuild
which uv
```

Deberían imprimir paths a `/nix/var/nix/profiles/system/sw/bin/...`. Si no, ver Troubleshooting.

### Paso 8 — Loguearse en apps que requieren cuenta

Las apps GUI están instaladas pero vacías. Toca a mano (una sola vez):

- **App Store** → Updates → instalar manualmente **WhatsApp** (ver Troubleshooting para por qué)
- **Tailscale** → loguear
- **Surfshark** → loguear
- **Claude** → loguear con cuenta Anthropic
- **Evernote** → loguear
- **Notion** → loguear
- **Spotify**, **Discord**, etc.
- **Raycast** → configurar (no se versionan las settings)
- **Stats** → abrir y configurar qué módulos querés en la menubar

### Paso 9 — Migración manual (cosas que NO gestiona Nix)

Si venís de otra Mac:

| Qué | Cómo |
|---|---|
| Archivos personales (Documents, Downloads, Pictures) | Migration Assistant, Time Machine, o iCloud Drive |
| Llaves SSH (`~/.ssh/`) | Copiar manualmente con `scp` (NUNCA al repo) |
| Llaves GPG (`~/.gnupg/`) | Copiar manualmente |
| Settings de Raycast | Raycast Settings → Account → Cloud Sync (o exportar JSON manual) |
| Settings de Ghostty visuales | Ya están en este repo (`home/ghostty/config`) |
| Historial de zsh (`~/.zsh_history`) | Copiar manualmente si lo querés |
| Apps Adobe / paid apps | Login en cada una |
| iCloud, Calendar, Mail nativos | Login con tu Apple ID en System Settings |

---

## Comandos del día a día

### Aplicar cambios (después de editar la config)

**Workflow recomendado**:

```bash
cd ~/Documents/nix-config-workspace/nix-config

# 1. Validar que compila SIN aplicar
nix build ".#darwinConfigurations.seasmoke.system" --no-link
echo "Exit: $?"

# 2. Si Exit: 0, aplicar
sudo darwin-rebuild switch --flake ".#seasmoke"
```

Si querés saltar la validación previa, directamente:

```bash
sudo darwin-rebuild switch --flake ".#seasmoke"
```

Pero `nix build` antes te evita rollbacks innecesarios cuando hay un error de sintaxis.

### Agregar un paquete CLI

Editar `hosts/common/common-packages.nix` y agregar el paquete a `environment.systemPackages`. Después aplicar cambios.

Buscar el nombre exacto: https://search.nixos.org/packages

> **Diferencia entre `brews` y CLI Nix**: Si el paquete existe en Nix (search.nixos.org), preferí Nix. Si solo está en Homebrew y es CLI (no GUI), va a `homebrew.brews` en `darwin-common.nix`. Apps GUI siempre a `homebrew.casks`.

### Agregar una app GUI (cask)

Editar `hosts/common/darwin-common.nix`, sección `homebrew.casks`, agregar el cask. Después aplicar cambios.

Buscar casks: https://formulae.brew.sh/cask/

### Agregar una app de la Mac App Store

1. Instalar la app manualmente desde App Store
2. Obtener el ID:
   ```bash
   mas list
   ```
3. Editar `hosts/common/darwin-common.nix`, sección `homebrew.masApps`:
   ```nix
   "NombreApp" = 123456789;
   ```
4. Aplicar cambios

### Cambiar un default de macOS (dock, finder, keyboard, etc.)

Editar `hosts/common/darwin-common.nix`, sección `system.defaults` o `system.defaults.CustomUserPreferences`. Aplicar cambios. Algunos cambios requieren cerrar sesión y volver a entrar para verse.

Referencia: https://daiderd.com/nix-darwin/manual/index.html#opt-system.defaults

### Crear un entorno de desarrollo aislado (devShell)

En la carpeta del proyecto:

```bash
mkdir mi-proyecto && cd mi-proyecto
```

`flake.nix`:
```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { nixpkgs, ... }: let
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
  in {
    devShells.aarch64-darwin.default = pkgs.mkShell {
      packages = [ pkgs.python312 pkgs.uv pkgs.nodejs_22 ];
    };
  };
}
```

`.envrc`:
```bash
echo "use flake" > .envrc
direnv allow
```

Cada vez que entres a esa carpeta con `cd`, las herramientas aparecen en el PATH. Cuando salís, desaparecen. Cuando borrás la carpeta, no queda nada instalado en tu sistema.

### Investigar y solucionar problemas

```bash
# Ver generaciones del sistema (cada switch crea una nueva)
sudo darwin-rebuild --list-generations

# Hacer rollback a la generación anterior
sudo darwin-rebuild --rollback

# Ver qué generación está activa
readlink /nix/var/nix/profiles/system

# Ver el script de activación completo
sudo cat /nix/var/nix/profiles/system/activate | less

# Ver qué se está intentando hacer en el switch
sudo darwin-rebuild switch --flake ".#seasmoke" 2>&1 | grep -E "Installing|failed|Activating"

# Ver qué paquetes hay en el perfil del usuario
nix profile list
```

### Actualizar inputs del flake (versiones de paquetes)

```bash
cd ~/Documents/nix-config-workspace/nix-config
nix flake update
nix build ".#darwinConfigurations.seasmoke.system" --no-link
sudo darwin-rebuild switch --flake ".#seasmoke"
```

Si algo se rompe después: `git checkout flake.lock` y volver al lock viejo.

Para actualizar UN solo input:
```bash
nix flake update nixpkgs-darwin
```

### Limpiar el store de Nix (liberar espacio)

```bash
# Borra generaciones viejas del usuario
nix-collect-garbage -d

# Borra generaciones viejas del sistema (requiere sudo)
sudo nix-collect-garbage -d
```

Después de esto **no podés hacer rollback** a las generaciones eliminadas.

### Actualizar solo Homebrew (sin tocar Nix)

```bash
brew update
brew upgrade
```

Casi nunca necesario porque `darwin-rebuild switch` con `homebrew.onActivation.upgrade = true` ya lo hace.

---

## Estructura del repo

```
nix-config/
├── flake.nix                    # Entry point: declara inputs y darwinConfigurations
├── flake.lock                   # Versiones lockeadas de los inputs
├── lib/
│   ├── default.nix              # Helper imports
│   └── helpers.nix              # Función mkDarwin que arma el sistema
├── hosts/
│   ├── common/
│   │   ├── common-packages.nix  # Paquetes CLI (Nix)
│   │   └── darwin-common.nix    # Config compartida Darwin: brews, casks, fonts, defaults, MAS
│   └── darwin/
│       └── seasmoke/
│           ├── default.nix      # Importa common-* y custom-dock
│           └── custom-dock.nix  # Apps específicas del dock
├── home/
│   ├── hefes.nix                # Config home-manager: zsh, git, neovim, tmux, ghostty
│   ├── starship/
│   │   └── starship.toml        # Prompt del shell
│   ├── nvim/                    # Configs lua de neovim
│   └── ghostty/
│       └── config               # Config de Ghostty (tema, fuente, keyboard)
├── data/
│   └── mac-dot-zshrc            # Init zsh aplicado vía promptInit
└── README.md                    # Este archivo
```

### Qué edita qué

| Querés cambiar | Editar |
|---|---|
| Un paquete CLI (ripgrep, jq, uv...) | `hosts/common/common-packages.nix` |
| Una CLI de Homebrew (bitwarden-cli, mas...) | `hosts/common/darwin-common.nix` → `brews` |
| Una app GUI | `hosts/common/darwin-common.nix` → `casks` |
| Una app MAS | `hosts/common/darwin-common.nix` → `masApps` |
| Defaults macOS (dock, finder, keyboard) | `hosts/common/darwin-common.nix` → `system.defaults` |
| Fuentes | `hosts/common/darwin-common.nix` → `fonts.packages` |
| Apps del dock | `hosts/darwin/seasmoke/custom-dock.nix` |
| Config zsh, git, neovim, tmux, ssh | `home/hefes.nix` |
| Prompt starship | `home/starship/starship.toml` |
| Config Ghostty (tema, fuente, keyboard) | `home/ghostty/config` |
| Inputs del flake | `flake.nix` |

---

## Troubleshooting

### El switch corre, dice "exitoso", pero los archivos de home-manager no se aplican

**Síntoma**: nueva generación creada, pero `~/.zprofile`, `~/.gitconfig`, `~/Library/Application Support/com.mitchellh.ghostty/config`, etc. no son symlinks al store, o no se actualizaron.

**Causa**: el `activate` script tiene `set -e`. Si **algún cask de Homebrew falla** durante `brew bundle`, el script aborta antes de llegar a `Activating home-manager configuration for hefes` (que está al final).

**Diagnóstico**:
```bash
sudo darwin-rebuild switch --flake ".#seasmoke" 2>&1 | grep -E "Installing|failed|Activating home-manager"
```

Si ves `failed!` o `brew bundle\` failed!` ANTES de `Activating home-manager configuration` → ese es el problema.

**Solución**: comentar temporalmente el cask/MAS problemático en `darwin-common.nix`, aplicar el switch (ahora completa), y después podés volver a probarlo.

### WhatsApp da `mas.MASError error 5` y aborta el switch

WhatsApp en MAS suele fallar al actualizar (problema entre `mas` CLI y la API de App Store). Esto cae en el caso anterior: aborta el resto del activate.

**Por eso WhatsApp está COMENTADO en `masApps`**. Para instalarlo en una Mac nueva: abrir App Store manualmente, buscar WhatsApp, instalar. Una vez instalado, queda y no molesta más.

### `darwin-rebuild: command not found` en terminal nueva

Si después de la primera instalación, una terminal nueva no encuentra `darwin-rebuild`:

**Workaround inmediato**:
```bash
export PATH="/nix/var/nix/profiles/system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
```

**Fix permanente**: tu `~/.zprofile` debería ser un symlink al store de Nix. Verificá:
```bash
ls -la ~/.zprofile
```

Si dice `~/.zprofile -> /nix/store/...home-manager-files/.zprofile` → todo OK. Si es un archivo regular o no existe, hacer un `darwin-rebuild switch` (suponiendo que el problema anterior de "no se aplican archivos home-manager" no esté ocurriendo).

El `profileExtra` que carga el PATH está en `home/hefes.nix` → `programs.zsh.profileExtra`.

### `/run/current-system: No such file or directory`

En macOS Sequoia+, `/run` está reservado por el sistema y `synthetic.conf` no logra crearlo como symlink (cambio de Apple). **Es cosmético** — el sistema funciona usando `/nix/var/nix/profiles/system/` que sí existe. Por eso el PATH apunta ahí en `.zprofile`, no a `/run/current-system/sw/bin/`.

### Tailscale falla con "Binary already exists"

Si Tailscale fue instalado antes (manual o por una versión anterior del cask):
```bash
sudo rm -f /opt/homebrew/bin/tailscale
sudo darwin-rebuild switch --flake ".#seasmoke"
```

### Editar la config de Ghostty

El archivo en `~/Library/Application Support/com.mitchellh.ghostty/config` es un **symlink al Nix store** (read-only). Editar el archivo directamente no funciona.

Para cambiarlo:
1. Editar `home/ghostty/config` en este repo
2. `sudo darwin-rebuild switch --flake ".#seasmoke"`
3. Cerrar Ghostty con **Cmd+Q completo** (no solo cerrar ventana) y reabrir

Algunas opciones (como `macos-option-as-alt`) **requieren reiniciar la app entera**, no solo `reload config`.

### Archivos en `~/Library/Application Support/` no se crean

Aprendizaje: TCC (Transparency, Consent, Control) de macOS **NO bloquea** a root para escribir en `~/Library/Application Support/` durante `darwin-rebuild`. Verificable con `sudo touch`. Si un archivo no aparece ahí después de un switch, casi siempre es porque el `activate` script abortó antes de aplicarlo (ver primera entrada de Troubleshooting).

### nix-index warning sobre database

Si ves esto al abrir terminal:
```
error: reading from the database at '...nix-index/files' failed
```

Una sola vez:
```bash
nix-index
```

Tarda varios minutos. Después el warning desaparece y `nix-locate` empieza a funcionar (busca qué paquete provee un binario).

### Determinate Nix vs Nix oficial

Esta config usa **Determinate Nix** (de DeterminateSystems). Por eso `darwin-common.nix` tiene:
```nix
nix.enable = false;
```

Esto le dice a nix-darwin "no gestiones Nix, lo hace Determinate". Si en el futuro cambias a Nix oficial, hay que poner `nix.enable = true;` y reactivar las opciones `nix.settings`.

### Orden del activate script (avanzado)

Si necesitás entender qué corre cuándo, el orden del `activate` es:
1. Setup `/Applications/Nix Apps`, PAM, patches, `/etc`
2. system defaults, user defaults
3. restart Dock, launchd, networking, firewall, power, keyboard
4. Fonts, nvram
5. Homebrew prefixes
6. **Homebrew bundle** (`brew bundle --cleanup --zap`)
7. **Activate home-manager** (zsh, dotfiles, archivos de configuración)
8. Crear `/run/current-system` (falla en macOS reciente, ver arriba)

Si Homebrew falla en (6), nunca se llega a (7).

---

## Decisiones de diseño

- **Solo un host** (`seasmoke`) — versiones anteriores tenían varios hosts NixOS, fueron eliminados porque no se usaban
- **Determinate Nix en lugar de Nix oficial** — daemon auto-actualizable, mejor UX en macOS
- **Una sola rama de nixpkgs** (`nixpkgs-darwin` que sigue a unstable) — simplicidad antes que mezclar stable + unstable
- **Apps GUI vía Homebrew, no Nix** — los casks de Homebrew funcionan mejor que los paquetes Darwin de Nix en macOS, y se actualizan más rápido
- **`cleanup = "zap"`** en Homebrew — desinstala casks/brews que saqué de la lista (es declarativo: la lista es la verdad)
- **WhatsApp comentado en `masApps`** — la app MAS suele fallar al actualizar y aborta el resto del switch
- **Ghostty config vía `home.file`** — funciona porque el switch llega al `Activating home-manager` cuando Homebrew no falla
- **Bitwarden-CLI en `brews`, no `casks`** — `bitwarden-cli` NO existe como cask, solo como brew. La app GUI sería `bitwarden` (cask), pero no la uso
- **PATH manualmente en `profileExtra`** — porque `/run/current-system` no se crea en macOS reciente, apunto directo a `/nix/var/nix/profiles/system/sw/bin`

---

## Recursos

- [Buscador de paquetes Nix](https://search.nixos.org/packages)
- [Buscador de opciones nix-darwin](https://daiderd.com/nix-darwin/manual/index.html)
- [Buscador de opciones home-manager](https://mipmip.github.io/home-manager-option-search/)
- [Casks de Homebrew](https://formulae.brew.sh/cask/)
- [Documentación Ghostty](https://ghostty.org/docs/config)
- [Documentación Determinate Nix](https://docs.determinate.systems/)

---

## TODO / Mejoras futuras

- [ ] `nix flake update` — el lock tiene casi un año, hay versiones nuevas de inputs
- [ ] Templates de devShells para `nix flake init -t .#python` etc.
- [ ] Migrar config de zsh duplicada entre `darwin-common.nix` y `home/hefes.nix` a un solo lugar (home-manager)
- [ ] Limpiar `data/mac-dot-zshrc` si no se usa
- [ ] Configurar Stats al gusto (módulos, colores en la menubar)
- [ ] Migración a la M5 cuando llegue (apagar M1, configurar M5 con hostname `seasmoke`, instalar Determinate, clonar este repo, switch)
- [ ] Investigar si conviene mover `bitwarden-cli` a Nix (existe como `bitwarden-cli` en nixpkgs)
- [ ] Documentar workflow de SSH keys (no se versiona pero podrían generarse on-demand con sops-nix)
