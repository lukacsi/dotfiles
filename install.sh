#!/usr/bin/env bash
set -euo pipefail

# ========================================
# Dotfiles bootstrapper
# - Clones the repo (if not present)
# - Initializes submodules
# - Installs dependencies (git, stow, zsh)
# - Applies stow packages (default: 'local')
# - Optional: set default shell to zsh
# - Optional: install extras (fzf, eza, starship, neovim)
# ========================================

# ---- Defaults (override via flags) ----
REPO_URL="${REPO_URL:-https://github.com/lukacsi/dotfiles.git}"           # e.g. https://github.com/<you>/<repo>.git
BRANCH="${BRANCH:-master}"
DEST_DIR="${DEST_DIR:-$HOME/.dotfiles}"
STOW_PKGS="${STOW_PKGS:-local}"    # comma-separated if multiple, e.g. "local,work"
SET_SHELL="${SET_SHELL:-false}"
INSTALL_PACKAGES="${INSTALL_PACKAGES:-true}"
INSTALL_EXTRAS="${INSTALL_EXTRAS:-true}"
RUN_UPDATE="${RUN_UPDATE:-false}"
RUN_DESTOW="${RUN_DESTOW:-false}"
NO_SUBMODULES="${NO_SUBMODULES:-false}"
VERBOSE="${VERBOSE:-false}"

# ---- Helpers ----
log() { printf '%b\n' "[$(date +'%H:%M:%S')] $*"; }
die() { printf '%b\n' "ERROR: $*" >&2; exit 1; }

have() { command -v "$1" &>/dev/null; }

join_by() { local IFS="$1"; shift; echo "$*"; }

os_id=""
pkg_manager=""

detect_os_pm() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    os_id="macos"
    have brew || die "Homebrew not found. Install from https://brew.sh and re-run."
    pkg_manager="brew"
  else
    os_id="linux"
    if have apt-get; then pkg_manager="apt";
    elif have dnf; then pkg_manager="dnf";
    elif have pacman; then pkg_manager="pacman";
    elif have zypper; then pkg_manager="zypper";
    else die "Unsupported package manager. Install git, stow, zsh manually and re-run with INSTALL_PACKAGES=false, INSTALL_EXTRAS=false"
    fi
  fi
}

install_base_packages() {
  [[ "$INSTALL_PACKAGES" == "true" ]] || { log "Skipping package install"; return; }

  local base=(git stow zsh)
  log "Installing base packages: ${base[*]} (pm=$pkg_manager)"

  case "$pkg_manager" in
    brew)
      brew update
      brew install "${base[@]}" || true
      ;;
    apt)
      sudo apt-get update -y
      sudo apt-get install -y "${base[@]}"
      ;;
    dnf)
      sudo dnf install -y "${base[@]}"
      ;;
    pacman)
      sudo pacman -Sy --noconfirm --needed "${base[@]}"
      ;;
    zypper)
      sudo zypper --non-interactive install "${base[@]}"
      ;;
  esac
}

install_extras() {
  [[ "$INSTALL_EXTRAS" == "true" ]] || return 0

  local extras=(fzf)
  # Prefer 'eza' (successor of exa); fall back to 'exa' if needed.
  if [[ "$pkg_manager" == "brew" ]] || have eza || have exa; then
    extras+=()
  fi

  case "$pkg_manager" in
    brew)
      brew install fzf eza starship nvim || true
      ;;
    apt)
      sudo apt-get update -y
      sudo apt-get install -y fzf nvim || true
      # eza is available on newer Ubuntu/Debian; ignore if missing
      sudo apt-get install -y eza || true
      # Starship official script (no network restrictions assumed)
      curl -fsSL https://starship.rs/install.sh | sh -s -- -y || true
      ;;
    dnf)
      sudo dnf install -y fzf eza nvim || true
      curl -fsSL https://starship.rs/install.sh | sh -s -- -y || true
      ;;
    pacman)
      sudo pacman -Sy --noconfirm --needed fzf eza nvim || true
      curl -fsSL https://starship.rs/install.sh | sh -s -- -y || true
      ;;
    zypper)
      sudo zypper --non-interactive install fzf eza nvim || true
      curl -fsSL https://starship.rs/install.sh | sh -s -- -y || true
      ;;
  esac
}

clone_or_update_repo() {
  if [[ -d "$DEST_DIR/.git" ]]; then
    log "Repo exists at $DEST_DIR. Fetching updates (branch=$BRANCH)..."
    git -C "$DEST_DIR" fetch --all --tags
    git -C "$DEST_DIR" checkout "$BRANCH"
    git -C "$DEST_DIR" pull --ff-only origin "$BRANCH" || true
  else
    [[ -n "$REPO_URL" ]] || die "REPO_URL is required to clone (e.g., --repo https://github.com/<you>/<repo>.git)"
    log "Cloning $REPO_URL into $DEST_DIR (branch=$BRANCH)"
    git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$DEST_DIR"
  fi
}

submodules() {
  [[ "$NO_SUBMODULES" == "true" ]] && { log "Skipping submodules"; return; }

  log "Initializing submodules"
  git -C "$DEST_DIR" submodule update --init --recursive

  if [[ "$RUN_UPDATE" == "true" ]]; then
    log "Updating submodules to latest remote"
    git -C "$DEST_DIR" submodule update --remote --merge --recursive
  fi
}

do_stow() {
  IFS=',' read -r -a pkgs <<<"$STOW_PKGS"
  local joined; joined="$(join_by ', ' "${pkgs[@]}")"
  log "Applying stow packages: $joined"
  for p in "${pkgs[@]}"; do
    if [[ ! -d "$DEST_DIR/$p" ]]; then
      die "Stow package '$p' not found in $DEST_DIR. Adjust --packages or repository layout."
    fi
    stow -d "$DEST_DIR" -t "$HOME" --no-folding -S "$p" ${VERBOSE:+-v}
  done
}

do_destow() {
  IFS=',' read -r -a pkgs <<<"$STOW_PKGS"
  local joined; joined="$(join_by ', ' "${pkgs[@]}")"
  log "Removing stow packages: $joined"
  for p in "${pkgs[@]}"; do
    if [[ -d "$DEST_DIR/$p" ]]; then
      stow -d "$DEST_DIR" -t "$HOME" -D "$p" ${VERBOSE:+-v} || true
    fi
  done
}

set_default_shell() {
  [[ "$SET_SHELL" == "true" ]] || return 0
  local zsh_bin
  zsh_bin="$(command -v zsh || true)"
  [[ -x "$zsh_bin" ]] || die "zsh not found in PATH."

  # Ensure zsh is listed in /etc/shells
  if ! grep -q "^$zsh_bin$" /etc/shells 2>/dev/null; then
    log "Adding $zsh_bin to /etc/shells (sudo)"
    echo "$zsh_bin" | sudo tee -a /etc/shells >/dev/null
  fi

  if [[ "$SHELL" != "$zsh_bin" ]]; then
    log "Changing default shell to $zsh_bin"
    chsh -s "$zsh_bin"
  else
    log "Default shell already set to zsh"
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --repo URL            Git repo URL (required if cloning)
  --branch NAME         Git branch (default: $BRANCH)
  --dest DIR            Destination dir (default: $DEST_DIR)
  --packages LIST       Comma-separated stow packages (default: $STOW_PKGS)
  --set-shell           Set zsh as default shell
  --no-submodules       Skip submodule init/update
  --update              Update submodules to latest remote
  --install-packages    Install base packages (default: $INSTALL_PACKAGES)
  --install-extras      Install extras: fzf, eza, starship, neovim
  --destow              Remove symlinks for the given packages
  --verbose             Verbose stow
  -h, --help            Show this help

Environment overrides are also supported (e.g., REPO_URL=... BRANCH=... SET_SHELL=true ...).
EOF
}

# ---- Parse flags ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO_URL="$2"; shift 2;;
    --branch) BRANCH="$2"; shift 2;;
    --dest) DEST_DIR="$2"; shift 2;;
    --packages) STOW_PKGS="$2"; shift 2;;
    --set-shell) SET_SHELL=true; shift;;
    --no-submodules) NO_SUBMODULES=true; shift;;
    --update) RUN_UPDATE=true; shift;;
    --install-packages) INSTALL_PACKAGES=true; shift;;
    --install-extras) INSTALL_EXTRAS=true; shift;;
    --destow) RUN_DESTOW=true; shift;;
    --verbose) VERBOSE=true; shift;;
    -h|--help) usage; exit 0;;
    *) die "Unknown option: $1 (use -h|--help)";;
  esac
done

# ---- Main ----
detect_os_pm
install_base_packages

# If running from a cloned repo, allow in-place ops
if [[ -d ".git" && -f "$(basename "$0")" ]]; then
  DEST_DIR="$(pwd)"
  log "Operating in-place at $DEST_DIR"
else
  clone_or_update_repo
fi

submodules

if [[ "$RUN_DESTOW" == "true" ]]; then
  do_destow
  exit 0
fi

do_stow
set_default_shell
install_extras


