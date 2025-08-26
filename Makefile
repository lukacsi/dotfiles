SHELL := /usr/bin/env bash
STOW_PKGS := local

.PHONY: help bootstrap stow destow update

help:
	@echo "Available targets:"
	@echo "  make bootstrap  - Initialize all git submodules"
	@echo "  make stow       - Apply symlinks for dotfiles using stow"
	@echo "  make destow     - Remove symlinks (undo stow)"
	@echo "  make update     - Update all submodules to latest remote"

bootstrap:
	git submodule update --init --recursive

stow:
	stow -v -t $$HOME --no-folding $(STOW_PKGS)

destow:
	stow -Dv -t $$HOME $(STOW_PKGS)

update:
	git submodule update --remote --merge --recursive
