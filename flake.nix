# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      neovim-with-mini = pkgs.neovim.override {
        configure = {
          customRC = "";
          packages.plugins = with pkgs.vimPlugins; {
            start = [ mini-nvim ];
          };
        };
      };
    in
    {
      packages.${system} = {
        doc = pkgs.writeShellApplication {
          name = "texlab-tools-doc";
          runtimeInputs = [
            neovim-with-mini
          ];
          text = ''
            #!${pkgs.stdenv.shell}
            ${neovim-with-mini}/bin/nvim -u NONE -c "luafile scripts/docgen.lua" -c qa
            '';
          checkPhase = "${pkgs.stdenv.shellDryRun} $target";
        };
      };
    };
}
