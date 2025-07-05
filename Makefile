NIX_FLAGS. = --extra-experimental-features "nix-comamand flakes"
NIXOS_FLAGS = -j 4 --cores 4
HOME_FLAGS = -j 4 --cores 4

all: flake.lock switch home

lock: flake.lock

flake.lock:
	nix ${NIX_FLAGS} flake lock

update:
	nix ${NIX_FLAGS} flake update

test:
	sudo nixos-rebuild ${NIXOS_FLAGS} test --flake .

switch:
	sudo nixos-rebuild ${NIXOS_FLAGS} switch --flake .

upgrade: update
	sudo nixos-rebuild ${NIXOS_FLAGS} switch --upgrade --flake .

rescue:
	nixos-rebuild --option sandbox false ${NIXOS_FLAGS} boot --install-bootloader --flake .

boot:
	sudo nixos-rebuild ${NIXOS_FLAGS} boot --install-bootloader --flake .

home:
	home-manager ${HOME_FLAGS} --flake .

PHONY: all lock update test switch rescue boot home
