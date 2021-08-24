with import ./src/args/agnostic.nix { };

makeScript {
  aliases = [
    "m-v21.09"
    "makes"
    "makes-v21.09"
  ];
  replace = {
    __argMakesSrc__ = ./.;
  };
  entrypoint = ''
    __MAKES_SRC__=__argMakesSrc__ \
    python __argMakesSrc__/src/cli/main/__main__.py "$@"
  '';
  searchPaths = {
    bin = [
      __nixpkgs__.cachix
      __nixpkgs__.git
      __nixpkgs__.gnutar
      __nixpkgs__.gzip
      __nixpkgs__.nix
      __nixpkgs__.python38
    ];
  };
  name = "m";
}
