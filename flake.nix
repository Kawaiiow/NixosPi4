{
  desccription = "Rasberry Pi4 Nix";

  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:Nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    }
    flake-utils.url = "github:numtide/flake-utils";
  };

  # outputs = { self, nixpkgs, home-manager, ... }: rec { 
  #   nixosConfigurations.rpi4 = nixpkgs.lib.nixosSystem {
  #     modules = [
  #       "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-rasberrypi.nix"
  #       {
  #         nixpkgs.config.allowUnsupportedSystem = true;
  #         nixpkgs.hostPlatform.system = "arm7l-linux";
  #         nixpkgs.buildPlatform.system = "x86_64-linux"; # FIXME: If I wil change
  #       }
  #     ];
  #   };
  #   images.rpi4 = nixosConfigurations.rpi4.config.system.build.sdImage;
  # };
  outputs = { self, nixpkgs, home-manager, ... } @ inputs: let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-linux"
    ];
    forAllSystem = nixpkgs.lib.getAttrs systems;
  in {
    packages = forAllSystem (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystem (system: nixpkgs.legacyPackages.${system}.alejandra);

    overlays = import ./overlays {inherit inputs;};
    
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nixos/configuration.nix # TODO: Require file
        ];
      };
    };

    homeConfigurations = {
      "kawaii@nixos" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home-manager/home/home.nix # TODO: Follow the name
        ];
      };
    };
  }
  
}
