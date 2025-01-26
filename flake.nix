{
    description = "NixOS configuration with home-manager and Android SDK license acceptance";
    
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        
        ags.url = "github:aylur/ags";
    };
    
    outputs = { self, nixpkgs, home-manager, ags, ... }@inputs: 
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
            inherit system;
            config = {
                allowUnfree = true;
                android_sdk.accept_license = true;
            };
        };
        
    in {
        nixosConfigurations = {
            nixos = nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = { inherit inputs pkgs; };
                modules = [
                    ./configuration.nix
                    home-manager.nixosModules.home-manager
                    {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.extraSpecialArgs = { inherit inputs; };
                        home-manager.users.zacmagee = { pkgs, config, ... }: {
                            imports = [
                                ./home.nix
                            ];
                        };
                    }
                    {
                        nixpkgs.config = {
                            android_sdk.accept_license = true;
                        };
                    }
                ];
            };
        };
    };
}
