{ makeDerivation
, makePythonPypiEnvironment
, ...
}:
{ config
, name
, src
}:
makeDerivation {
  builder = ./builder.sh;
  env = {
    envConfig = config;
    envSrc = src;
  };
  name = "lint-python-imports-for-${name}";
  searchPaths.source = [
    (makePythonPypiEnvironment {
      name = "lint-python-imports";
      sourcesYaml = ./pypi-sources.yaml;
      withSetuptools_57_4_0 = true;
      withSetuptoolsScm_6_0_1 = true;
      withWheel_0_37_0 = true;
    })
  ];
}
