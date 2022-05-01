{
  description = "Pure Emacs apps";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    twist.url = "github:emacs-twist/twist.nix";
    twist.inputs.nixpkgs.follows = "nixpkgs";

    org-babel.url = "github:emacs-twist/org-babel";
    org-babel.inputs.nixpkgs.follows = "nixpkgs";

    melpa.url = "github:melpa/melpa";
    melpa.flake = false;

    gnu-elpa = {
      url = "git+https://git.savannah.gnu.org/git/emacs/elpa.git?ref=main";
      flake = false;
    };
    nongnu = {
      url = "git+https://git.savannah.gnu.org/git/emacs/nongnu.git?ref=main";
      flake = false;
    };
    epkgs = {
      url = "github:emacsmirror/epkgs";
      flake = false;
    };

    emacs.url = "github:emacs-mirror/emacs";
    emacs.flake = false;

    emacs-unstable.url = "github:nix-community/emacs-overlay";
    emacs-unstable.inputs.nixpkgs.follows = "nixpkgs";

    # Configuration repositories
    centaur.url = "github:seagle0128/.emacs.d";
    centaur.flake = false;

    terlar.url = "github:terlar/emacs-config";
    terlar.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    twist,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem
    (system: let
      inherit (nixpkgs) lib;

      pkgs = nixpkgs.legacyPackages.${system}.appendOverlays [
        inputs.emacs-unstable.overlay
        inputs.org-babel.overlay
        inputs.twist.overlay
      ];

      inventories = import ./lib/inventories.nix inputs;

      profiles = {
        terlar = import ./profiles/terlar {
          inherit pkgs;
          inherit (inputs) terlar;
        };

        guangtao = import ./profiles/guangtao {
          inherit pkgs;
          inherit (inputs) centaur;
        };
      };

      packages =
        lib.mapAttrs (
          _: attrs:
            pkgs.callPackage ./lib/profile.nix ({
                inherit inventories;
                withSandbox = pkgs.callPackage ./lib/sandbox.nix {};
              }
              // attrs)
        )
        profiles;
    in {
      inherit packages;
      apps = lib.pipe packages [
        (lib.mapAttrsToList (
          name: package: let
            apps = package.makeApps {
              lockDirName = "profiles/${name}/lock";
            };
          in
            lib.mapAttrsToList (appName: app: {
              name = "${appName}-${name}";
              value = app;
            })
            apps
        ))
        lib.concatLists
        lib.listToAttrs
      ];
    });
}
