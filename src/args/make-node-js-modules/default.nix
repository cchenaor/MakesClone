{
  __nixpkgs__,
  attrsGet,
  fromJsonFile,
  makeDerivation,
  makeNodeJsVersion,
  makeSearchPaths,
  patchShebangs,
  toFileJson,
  ...
}: {
  name,
  nodeJsVersion,
  packageJson,
  packageLockJson,
  registryTokens ? {},
  searchPaths ? {},
  shouldIgnoreScripts ? false,
}: let
  nodeJs = makeNodeJsVersion nodeJsVersion;
  packageLock = fromJsonFile packageLockJson;

  collectDependencies = deps:
    builtins.foldl'
    (all: name: let
      url =
        # If `resolved` exists it is a tarball
        if builtins.hasAttr "resolved" depAttrs
        then depAttrs.resolved
        # Otherwise `version` likely points to a tarball
        else if builtins.hasAttr "version" depAttrs
        then depAttrs.version
        # Something pending to implement?
        else abort "Unable to fetch: ${name}";
      registryHost = builtins.elemAt (__nixpkgs__.lib.strings.splitString "/" url) 2;
      registryToken =
        if builtins.hasAttr registryHost registryTokens
        then registryTokens.${registryHost}
        else null;
      tarball = __nixpkgs__.fetchurl {
        hash = depAttrs.integrity;
        url = url;
        curlOptsList =
          if registryToken == null
          then []
          else ["-v" "--header" "Authorization: Bearer ${registryToken}"];
      };
      dep =
        depAttrs
        // {
          inherit name;
          resolved = tarball;
          resolvedName = "${name}/-/${tarball.name}";
        };
      depAttrs = deps.${name};
      depsOfdep =
        if builtins.hasAttr "dependencies" dep
        then collectDependencies dep.dependencies
        else [];
    in
      all ++ depsOfdep ++ [dep])
    []
    (builtins.attrNames deps);

  dependenciesFlat = collectDependencies (
    (attrsGet packageLock "dependencies" {})
    // (attrsGet packageLock "devDependencies" {})
  );
  dependenciesGrouped =
    builtins.groupBy
    (dep: dep.name)
    dependenciesFlat;

  registryIndexes =
    builtins.map
    (name: {
      name = "${name}/index.html";
      path = toFileJson "${name}.json" {
        inherit name;
        versions =
          builtins.listToAttrs
          (builtins.map
            (versionAttrs: {
              name = versionAttrs.version;
              value = {
                dist.integrity = versionAttrs.integrity;
                dist.tarball = versionAttrs.resolvedName;
              };
            })
            dependenciesGrouped.${name});
      };
    })
    (builtins.attrNames dependenciesGrouped);

  registryTarballs = __nixpkgs__.lib.lists.unique (builtins.map
    (dep: {
      name = dep.resolvedName;
      path = dep.resolved;
    })
    dependenciesFlat);

  registry =
    __nixpkgs__.linkFarm "make-node-js-modules-registry-for-${name}"
    (registryIndexes ++ registryTarballs);
in
  makeDerivation {
    builder = ./builder.sh;
    env = {
      envRegistry = registry;
      envPackageJson = packageJson;
      envPackageLockJson = packageLockJson;
      envShouldIgnoreScripts = shouldIgnoreScripts;
    };
    name = "make-node-js-modules-for-${name}";
    searchPaths = {
      bin = [
        __nixpkgs__.bash
        __nixpkgs__.findutils
        __nixpkgs__.gnused
        __nixpkgs__.jq
        __nixpkgs__.python39
        __nixpkgs__.which
        nodeJs
      ];
      source = [
        (makeSearchPaths searchPaths)
        patchShebangs
      ];
    };
  }
