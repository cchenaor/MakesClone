{ __nixpkgs__
, __toModuleOutputs__
, deployTerraform
, projectPathMutable
, ...
}:
{ config
, lib
, ...
}:
let
  makeOutput = name: { setup, src, version }: {
    name = "/deployTerraform/${name}";
    value = deployTerraform {
      inherit setup;
      inherit name;
      src = projectPathMutable src;
      inherit version;
    };
  };
in
{
  options = {
    deployTerraform = {
      modules = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (lib.types.submodule (_: {
          options = {
            setup = lib.mkOption {
              default = [ ];
              type = lib.types.listOf lib.types.package;
            };
            src = lib.mkOption {
              type = lib.types.str;
            };
            version = lib.mkOption {
              type = lib.types.enum [
                "0.14"
                "0.15"
                "0.16"
              ];
            };
          };
        }));
      };
    };
  };
  config = {
    outputs = __toModuleOutputs__ makeOutput config.deployTerraform.modules;
  };
}
