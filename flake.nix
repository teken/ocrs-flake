{
  description = "ocrs with clipboard support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ocrs-src = {
      url = "github:robertknight/ocrs";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ocrs-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };

        # Use official stable Rust toolchain
        rustToolchain = pkgs.rust-bin.stable.latest.default;
        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustToolchain;
          rustc = rustToolchain;
        };
      in
      {
        packages.default = rustPlatform.buildRustPackage {
          pname = "ocrs";
          version = "unstable";

          src = ocrs-src;

          # If the hash differs, replace with the hash reported on failure
          cargoHash = "sha256-oFjEy5UEPgZ320IdNb7vmTmKvLMLTo60x5o2BrczFbQ=";

          buildFeatures = [ "clipboard" ];

          meta = with pkgs.lib; {
            description = "Library and tool for OCR with clipboard support";
            homepage = "https://github.com/robertknight/ocrs";
            mainProgram = "ocrs";
            license = with licenses; [ asl20 mit ];
          };
        };

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
        };
      }
    ) // {
      overlays.default = final: prev: {
        ocrs = self.packages.${final.system}.default;
      };
    };
}
