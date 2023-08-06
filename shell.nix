{ pkgs ? import <nixpkgs> { } }:
let
  tree-sitter-lua = pkgs.vimUtils.buildVimPlugin {
    name = "tree-sitter-lua";
    src = pkgs.fetchFromGitHub {
      owner = "tjdevries";
      repo = "tree-sitter-lua";
      rev = "a99b610";
      sha256 = "sha256-nG28Lz6b6d3VgDh/EkjFtrqrQpjQGMtxaK3yr4Np394=";
    };
    buildInputs = with pkgs; [ tree-sitter nodejs ];
  };

  neovim-docs = pkgs.neovim.override {
      configure = {
        customRC = ''
          " here your custom configuration goes!
        '';
        packages.myVimPackage = {
          start = [
            pkgs.vimPlugins.mini-nvim
          ];
        };
      };
    };
in
pkgs.mkShell {
  name = "build-doc-shell";
  buildInputs = [
    neovim-docs
  ];
}
