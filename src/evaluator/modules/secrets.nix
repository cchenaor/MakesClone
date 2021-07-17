{ __toModuleOutputs__
, makeSecretForAwsFromEnv
, ...
}:
{ config
, lib
, ...
}:
let
  awsFromEnvType = lib.types.submodule (_: {
    options = {
      accessKeyId = lib.mkOption {
        default = "AWS_ACCESS_KEY_ID";
        type = lib.types.str;
      };
      defaultRegion = lib.mkOption {
        default = "AWS_DEFAULT_REGION";
        type = lib.types.str;
      };
      secretAccessKey = lib.mkOption {
        default = "AWS_SECRET_ACCESS_KEY";
        type = lib.types.str;
      };
      sessionToken = lib.mkOption {
        default = "AWS_SESSION_TOKEN";
        type = lib.types.str;
      };
    };
  });
  makeAwsFromEnvOutput = name:
    { accessKeyId
    , defaultRegion
    , secretAccessKey
    , sessionToken
    }: {
      name = "/secretsForAwsFromEnv/${name}";
      value = makeSecretForAwsFromEnv {
        inherit accessKeyId;
        inherit defaultRegion;
        inherit name;
        inherit secretAccessKey;
        inherit sessionToken;
      };
    };
in
{
  options = {
    secretsForAwsFromEnv = lib.mkOption {
      default = { };
      type = lib.types.attrsOf awsFromEnvType;
    };
  };
  config = {
    outputs =
      (__toModuleOutputs__ makeAwsFromEnvOutput config.secretsForAwsFromEnv) //
      (__toModuleOutputs__ makeAwsFromEnvOutput {
        __default__ = {
          accessKeyId = "AWS_ACCESS_KEY_ID";
          defaultRegion = "AWS_DEFAULT_REGION";
          secretAccessKey = "AWS_SECRET_ACCESS_KEY";
          sessionToken = "AWS_SESSION_TOKEN";
        };
      });
  };
}
