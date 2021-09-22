{ inputs
, makesExecutionId
, outputs
, projectIdentifier
, globalStateDir
, projectStateDir
, projectSrc
, system
, ...
}:
let
  agnostic = import ./agnostic.nix {
    inherit system;
    __globalStateDir__ = globalStateDir;
    __projectStateDir__ = projectStateDir;
  };

  args = agnostic // {
    inherit inputs;
    inherit makesExecutionId;
    inherit outputs;
    inherit projectIdentifier;
    inherit projectSrc;
    projectPath = import ./project-path/default.nix args;
    projectPathLsDirs = import ./project-path-ls-dirs/default.nix args;
    projectPathsMatching = import ./project-paths-matching/default.nix args;
    projectSrcInStore = builtins.path { name = "head"; path = projectSrc; };
  };
in
args
