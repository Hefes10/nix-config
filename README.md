# nix-config (seasmoke)

Configuración declarativa de mi Mac usando [Nix](https://nixos.org), [nix-darwin](https://github.com/nix-darwin/nix-darwin), [home-manager](https://github.com/nix-community/home-manager) y [nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew).

Toda la configuración del sistema, paquetes CLI, apps GUI (vía Homebrew), defaults de macOS, dock, y dotfiles de usuario están versionados en este repo. Reproducible en cualquier Mac Apple Silicon con tres comandos.

---

## ¿Qué hace esto?

- **Gestiona el sistema**: defaults de macOS (dock abajo, Finder en lista, etc.), TouchID para sudo, fuentes Nerd Font, keyboard
- **Instala apps GUI**: Claude, Evernote, Notion, Obsidian, OBS, Docker, Orbstack, Tailscale, Surfshark, Raycast, Marta, etc. (vía Homebrew declarativo)
- **Instala apps de la Mac App Store**: Telegram, Windows App (WhatsApp se instala manualmente, ver Troubleshooting)
- **Provee herramientas CLI**: `uv`, `ripgrep`, `fd`, `bat`, `eza`, `fzf`, `jq`, `gh`, `mosh`, `nmap`, `skopeo`, etc.
- **Configura el shell**: zsh con autosuggestion + completion, starship, tmux, neovim, git, ssh, direnv+nix-direnv
- **Deploya configs de apps**: Ghostty (tema Nord, JetBrainsMono Nerd Font, teclado latam)

---

## Pre-requisitos

- macOS reciente, Apple Silicon (M1/M2/M3/M4/M5...)
- Conexión a Internet
- Una cuenta de Apple ID logueada en la App Store (para apps MAS)

---

## Instalación desde cero (Mac nueva)

### Paso 1 — Configurar la Mac

1. Idioma del sistema: **inglés** (algunos defaults asumen esto)
2. Layout de teclado: **Español - Latinoamericano**
3. Usuario: **`hefes`** (tiene que coincidir con la config)
4. Hostname: **`seasmoke`** (`scutil --set LocalHostName seasmoke && scutil --set HostName seasmoke && scutil --set ComputerName seasmoke`)

### Paso 2 — Instalar Determinate Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

- Primera pregunta (acerca de telemetría/algo de Determinate): **No**
- Segunda pregunta (instalar Nix): **Sí**

Al terminar, **cerrar y reabrir la terminal** (o `source` el nix-daemon).

### Paso 3 — Clonar este repo

```bash
mkdir -p ~/Documents
cd ~/Documents
git clone git@github.com:Hefes10/nix-config.git
cd nix-config
```

Si no tenés SSH configurado con GitHub todavía:

```bash
git clone https://github.com/Hefes10/nix-config.git
```

(Después podés cambiar el remoto a SSH con `git remote set-url origin git@github.com:Hefes10/nix-config.git`)

### Paso 4 — Primera build y switch

```bash
nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.seasmoke.system"
```

Esto va a tardar varios minutos (descarga todo el sistema desde el cache de Nix). Cuando termine:

```bash
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#seasmoke"
```

Va a pedir contraseña. Después instala/desinstala casks vía Homebrew (puede tardar 10-20 minutos), aplica los defaults de macOS, configura el dock, etc.

### Paso 5 — Reabrir terminal

Cerrar y abrir una terminal nueva. `darwin-rebuild`, `uv`, y los demás binarios deberían estar en PATH automáticamente:

```bash
which darwin-rebuild
which uv
```

### Paso 6 — Loguearse en apps que requieren cuenta

Las apps GUI están instaladas pero no logueadas. Toca a mano:

- App Store → ver "actualizaciones" → descargar **WhatsApp** (no se instala automáticamente, ver Troubleshooting)
- Tailscale → loguear con tu cuenta
- Surfshark → loguear
- Claude → loguear
- Evernote → loguear
- Notion → loguear
- Spotify, Discord, etc.

### Paso 7 — Cosas que NO gestiona Nix (migración manual)

Si venís de otra Mac:

- Archivos personales (Documents, Downloads, Pictures): Migration Assistant, Time Machine o iCloud Drive
- Llaves SSH (`~/.ssh/`): copiar manualmente (nunca al repo)
- Llaves GPG (`~/.gnupg/`): copiar manualmente
- Configs de apps en `~/Library/` que tengan datos importantes (Raycast settings, Obsidian vault local, etc.)

---

## Comandos del día a día

### Aplicar cambios después de editar la config

```bash
cd ~/Documents/nix-config
sudo darwin-rebuild switch --flake ".#seasmoke"
```

Hay un alias en zsh: `rebuild` (definido en `home/hefes.nix`).

### Agregar un paquete CLI

Editar `hosts/common/common-packages.nix`, agregar el paquete a la lista, hacer `darwin-rebuild switch`.

Para encontrar el nombre exacto del paquete: https://search.nixos.org/packages

### Agregar una app GUI (cask de Homebrew)

Editar `hosts/common/darwin-common.nix`, sección `homebrew.casks`, agregar el cask, hacer `darwin-rebuild switch`.

Para buscar casks: https://formulae.brew.sh/cask/

### Agregar una app de la Mac App Store

1. Buscar el ID de la app: instalarla manualmente desde App Store, luego correr:

   ```bash
   mas list
   ```

   Eso te da el ID numérico.

2. Editar `hosts/common/darwin-common.nix`, sección `homebrew.masApps`, agregar la entrada:

   ```nix
   "NombreApp" = 123456789;
   ```

3. `darwin-rebuild switch`.

### Crear un entorno de desarrollo aislado (devShell)

Ir a la carpeta del proyecto:

```bash
mkdir mi-proyecto && cd mi-proyecto
```

Crear `flake.nix`:

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

Crear `.envrc`:

```bash
echo "use flake" > .envrc
direnv allow
```

Cada vez que entres a esa carpeta con `cd`, las herramientas van a aparecer en tu PATH. Cuando salgas, desaparecen.

### Ver generaciones del sistema y hacer rollback

```bash
sudo darwin-rebuild --list-generations
```

Para volver a una generación anterior:

```bash
sudo darwin-rebuild --rollback
```

### Actualizar inputs del flake (versiones de paquetes)

```bash
cd ~/Documents/nix-config
nix flake update
nix build ".#darwinConfigurations.seasmoke.system"
sudo darwin-rebuild switch --flake ".#seasmoke"
```

Si después de actualizar algo se rompe, `git checkout flake.lock` te devuelve al lock viejo.

### Limpiar el store de Nix (liberar espacio)

```bash
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

El segundo borra generaciones viejas del sistema. Después de esto **no podés hacer rollback** a las generaciones borradas.

### Actualizar Homebrew sin tocar Nix

Casi nunca necesario, pero por si acaso:

```bash
brew update
brew upgrade
```

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
│   │   ├── common-packages.nix  # Paquetes CLI (Nix store)
│   │   └── darwin-common.nix    # Config compartida Darwin: casks, fonts, defaults, MAS
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
│   └── mac-dot-zshrc            # Init de zsh que aplica nix-darwin
└── README.md                    # Este archivo
```

### Qué edita qué

| Querés cambiar | Editar |
|---|---|
| Un paquete CLI (ripgrep, jq, etc.) | `hosts/common/common-packages.nix` |
| Una app GUI (Claude, OBS, etc.) | `hosts/common/darwin-common.nix` → `casks` |
| Una app de la Mac App Store | `hosts/common/darwin-common.nix` → `masApps` |
| Defaults de macOS (dock, finder, etc.) | `hosts/common/darwin-common.nix` → `system.defaults` |
| Fuentes del sistema | `hosts/common/darwin-common.nix` → `fonts.packages` |
| Apps del dock | `hosts/darwin/seasmoke/custom-dock.nix` |
| Config de zsh, git, neovim, etc. | `home/hefes.nix` |
| Config de Ghostty (tema, fuente) | `home/ghostty/config` |
| Inputs del flake (nixpkgs, nix-darwin) | `flake.nix` |

---

## Troubleshooting

### WhatsApp falla a instalar en cada switch (`mas.MASError error 5`)

WhatsApp está **comentado** en `masApps` por este motivo: la API de MAS suele fallar al actualizar WhatsApp, lo cual hace que `brew bundle` devuelva exit code != 0, lo cual aborta el resto del `activate` (incluyendo la activación de home-manager) por el `set -e` del script.

**Solución**: instalar WhatsApp manualmente desde la App Store después de la primera vez. Una vez instalado, ahí queda.

Si en algún momento querés volver a probarlo declarativo: descomentar en `darwin-common.nix`:

```nix
"WhatsApp" = 310633997;
```

### `darwin-rebuild: command not found` en terminal nueva

Si después de la primera instalación, una terminal nueva no encuentra `darwin-rebuild`:

```bash
export PATH="/nix/var/nix/profiles/system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
```

Esto debería estar en `~/.zprofile` (gestionado por home-manager vía `programs.zsh.profileExtra` en `home/hefes.nix`). Si no está:

```bash
ls -la ~/.zprofile
```

Tiene que ser un symlink al `/nix/store/...`. Si no, hacer un `darwin-rebuild switch` para que home-manager lo cree.

### `/run/current-system: No such file or directory`

En macOS reciente (Sequoia+), `/run` no se crea vía `synthetic.conf` como antes. Esto es **cosmético** — el sistema usa `/nix/var/nix/profiles/system` que sí existe siempre. Por eso el PATH apunta a ese path en `.zprofile`, no a `/run/current-system`.

### El switch corre pero los archivos de home-manager (.zprofile, configs, ghostty) no se aplican

Síntoma: el switch termina exitoso, genera nueva generación, pero los archivos en `~/` o `~/.config/` no aparecen.

Causa típica: **algún cask de Homebrew falló** y por el `set -e` el resto del activate se aborta antes de llegar a `Activating home-manager configuration for hefes`.

Diagnóstico:

```bash
sudo /nix/var/nix/profiles/system/sw/bin/darwin-rebuild switch --flake ".#seasmoke" 2>&1 | grep -E "Installing|failed|Activating home-manager"
```

Si ves `failed!` antes de `Activating home-manager configuration` → ese es el problema. Comentar el cask/app problemático en `darwin-common.nix` temporalmente, hacer switch, y después podés volver a intentar.

### Tailscale falla con "binary already exists"

Después del primer switch, si Tailscale falla con `It seems there is already a Binary at '/opt/homebrew/bin/tailscale'`:

```bash
sudo rm -f /opt/homebrew/bin/tailscale
sudo darwin-rebuild switch --flake ".#seasmoke"
```

### Editar la config de Ghostty

El archivo en `~/Library/Application Support/com.mitchellh.ghostty/config` es un **symlink al Nix store** (read-only). Para cambiarlo:

1. Editar `home/ghostty/config` en este repo
2. `darwin-rebuild switch`
3. Cerrar Ghostty con Cmd+Q y reabrir

### nix-index warning sobre database

Si ves esto al abrir terminal:

```
error: reading from the database at '...nix-index/files' failed
```

Una sola vez:

```bash
nix-index
```

Eso genera la DB (tarda varios minutos). Después el warning desaparece.

### Determinate Nix vs nix-darwin

Esta config usa **Determinate Nix** (la variante de DeterminateSystems). Por eso `darwin-common.nix` tiene:

```nix
nix.enable = false;
```

Esto le dice a nix-darwin que NO gestione Nix (lo gestiona Determinate). Si en algún momento cambias a Nix oficial, hay que cambiar esto a `true`.

---

## Decisiones de diseño

- **Solo un host** (`seasmoke`) — versiones anteriores tenían varios hosts NixOS, fueron eliminados
- **Determinate Nix en lugar de Nix oficial** — para tener daemon auto-actualizable
- **Una sola rama de nixpkgs** (`nixpkgs-darwin` que sigue a unstable) — simplicidad antes que mezclar stable + unstable
- **Apps GUI vía Homebrew, no Nix** — los casks de Homebrew funcionan mejor que los paquetes Darwin de Nix en macOS
- **`cleanup = "zap"`** en Homebrew — desinstala casks que saqué de la lista
- **WhatsApp comentado** — ver Troubleshooting
- **Ghostty config vía `home.file`** — funciona porque root puede escribir en `~/Library/Application Support/` (no es bloqueado por TCC como se creyó al inicio)

---

## Recursos

- [Buscador de paquetes Nix](https://search.nixos.org/packages)
- [Buscador de opciones nix-darwin](https://daiderd.com/nix-darwin/manual/index.html)
- [Buscador de opciones home-manager](https://mipmip.github.io/home-manager-option-search/)
- [Casks de Homebrew](https://formulae.brew.sh/cask/)
- [Documentación Ghostty](https://ghostty.org/docs/config)

---

## TODO / Mejoras futuras

- [ ] `nix flake update` (el lock tiene casi un año, hay versiones nuevas de inputs)
- [ ] Templates de devShells para `nix flake init -t .#python` etc.
- [ ] Migrar config zsh duplicada de `darwin-common.nix` a `home/hefes.nix` solamente
- [ ] Limpiar `data/mac-dot-zshrc` (no se sabe cuánto se usa)