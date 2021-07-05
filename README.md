# Makes

A SecDevOps framework
powered by [Nix][NIX].

Our primary goal is to help you setup
a powerful [CI/CD][CI_CD] system
in just a few steps, in any technology.

<!-- This is updated automatically by a GitHub action, don't worry about it -->
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
# Contents

- [Philosophy](#philosophy)
- [Getting started](#getting-started)
  - [Getting started as user](#getting-started-as-user)
  - [Getting started as developer](#getting-started-as-developer)
- [Configuring CI/CD](#configuring-cicd)
  - [Configuring on GitHub Actions](#configuring-on-github-actions)
  - [Configuring on GitLab CI/CD](#configuring-on-gitlab-cicd)
- [Makes.nix format](#makesnix-format)
  - [Formatters](#formatters)
    - [formatBash](#formatbash)
  - [Container Images](#container-images)
    - [deployContainerImage](#deploycontainerimage)
  - [Examples](#examples)
    - [helloWorld](#helloworld)
- [References](#references)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Philosophy

We strive for:
- :star2: Simplicity: Easy setup with:
  a laptop, or
  [Docker][DOCKER], or
  [GitHub Actions][GITHUB_ACTIONS], or
  [Gitlab CI][GITLAB_CI], or
  [Travis CI][TRAVIS_CI], or
  [Circle CI][CIRCLE_CI],
  and more!
- :beers: Sensible defaults: **Good for all** projects of any size, **out-of-the-box**.
- :dancers: Reproducibility: **Any member** of your team,
  day or night, yesterday and tomorrow, builds and get **exactly the same results**.
- :woman_technologist: Dev environments: **Any member** of your team with a Linux machine and
  the required secrets **can execute the entire CI/CD pipeline**.
- :horse_racing: Performance: A highly granular **caching** system so you only have to **build things once**.
- :shipit: Extendibility: You can add custom workflows, easily.

# Getting started

Makes is powered by [Nix][NIX].
Which means that Makes is able to run
on any of the [Nix's supported platforms][NIX_PLATFORMS].

We have **thoroughly** tested it in
[x86_64, AMD64 or Intel64][X86_64] Linux machines,
which are very easy to find on any cloud provider.

In order to use Makes you'll need to:

1.  Install Nix as explained
    in the [NixOS Download page][NIX_DOWNLOAD].

1.  Install Makes:
    `$ nix-env -if https://fluidattacks.com/makes/install`

Makes targets two kind of users:
- Final users: People that want to use projects built with Makes.
- Developers: People who develop projects with Makes.

## Getting started as user

1.  Download the Makes project of your choice.

1.  `$ cd /path/to/an/awesome/makes/project`

1.  Now run makes!

    - List all available commands: `$ m`

      ```
      Outputs list for project: ./
        .helloWorld
      ```

    - Run a command: `$ m .helloWorld 1 2 3`

      ```
      [INFO] Hello from Makes! Jane Doe.
      [INFO] You called us with CLI arguments: [ 1 2 3 ].
      ```


## Getting started as developer

1.  Locate in the root of your project:

    `$ cd /path/to/my/awesome/makes/project`
2.  Create a `makes` folder.

    `$ mkdir makes`

    We will place in this folder
    all the source code
    for the [CI/CD][CI_CD] system
    (build, test, deploy, release, etc).

1.  Create a configuration file named `makes.nix`
    with the following contents:

    ```nix
    # /path/to/my/awesome/project/makes.nix
    {
      helloWorld = {
        enable = true;
        name = "Jane Doe";
      };
    }
    ```

    We have tens of [CI/CD][CI_CD] actions
    that you can include in jour project as simple as this.

1.  Now run makes!

    - List all available commands: `$ m`

      ```
      Outputs list for project: ./
        .helloWorld
      ```

    - Run a command: `$ m .helloWorld 1 2 3`

      ```
      [INFO] Hello from Makes! Jane Doe.
      [INFO] You called us with CLI arguments: [ 1 2 3 ].
      ```

# Configuring CI/CD

## Configuring on GitHub Actions

[GitHub Actions][GITHUB_ACTIONS]
is configured through [workflow files][GITHUB_WORKFLOWS]
located in a `.github/workflows` folder in the root of the project.

The smallest possible [workflow file][GITHUB_WORKFLOWS]
looks like this:

```yaml
# .github/workflows/main.yml
name: Makes CI
on: [push, pull_request]
jobs:
  makes:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    # We offer this GitHub action in the following versions:
    #   main: latest release (example: /makes@main)
    #   action-vYY.MM: monthly release (example: /makes@action-v21.06)
    - uses: fluidattacks/makes@main
      # You can use any name you like here
      name: helloWorld
      # You can pass secrets (if required) as environment variables like this:
      env:
        SECRET_NAME: ${{ secrets.SECRET_IN_YOUR_GITHUB }}
      with:
        args: .helloWorld 1 2 3
```

## Configuring on GitLab CI/CD

[GitLab CI/CD][GITLAB_CI]
is configured through a [.gitlab-ci.yaml][GITLAB_CI_REF] file
located in the root of the project.

The smallest possible [.gitlab-ci.yaml][GITLAB_CI_REF]
looks like this:

```yaml
# /path/to/my/awesome/makes/project/.gitlab-ci.yaml
helloWorld:
  # We offer this Container Image in the following tags:
  #   head: latest release (example: /makes:head)
  #   yy.mm: monthly release (example: /makes:21.07)
  image: registry.gitlab.com/fluidattacks/product/makes:head
  script:
    - m .helloWorld 1 2 3
```

Secrets can be propagated to Makes through [GitLab Variables][GITLAB_VARS],
which are passed automatically to the running container
as environment variables.

# Makes.nix format

A Makes project is identified by a `makes.nix` file
in the top level directory.

Below we document all configuration options you can tweak with it.

## Formatters

### formatBash

Ensure that Bash code is formatted according to [shfmt][SHFMT].
It helps your code be consistent, beautiful and more maintainable.

Attributes:
- enable (`boolean`): Optional.
  Defaults to false.
- targets (`listOf str`): Optional.
  Files or directories (relative to the project) to format.
  Defaults to the entire project.

Example `makes.nix`:

```nix
{
  formatBash = {
    enable = true;
    targets = [
      "/" # Entire project
      "/file.sh" # A file
      "/folder" # A folder within the project
    ];
  };
}
```

Example invocation: `$ m .formatBash`

### formatPython

Ensure that Python code is formatted according to [Black][BLACK]
and [isort][ISORT].
It helps your code be consistent, beautiful and more maintainable.

Attributes:
- enable (`boolean`): Optional.
  Defaults to false.
- targets (`listOf str`): Optional.
  Files or directories (relative to the project) to format.
  Defaults to the entire project.

Example `makes.nix`:

```nix
{
  formatPython = {
    enable = true;
    targets = [
      "/" # Entire project
      "/file.py" # A file
      "/folder" # A folder within the project
    ];
  };
}
```

Example invocation: `$ m .formatPython`

## Container Images

### deployContainerImage

Deploy a set of container images in [OCI Format][OCI_FORMAT_REPO]
to the specified container registries.

Attributes:
- enable (`boolean`): Optional.
  Defaults to false.
- images (`attrsOf imageType`): Optional.
  Definitions of container images to deploy.
  Defaults to `{ }`.

Custom Types:
- imageType (`submodule`):
  - registry (`enum ["docker.io" "ghcr.io" "registry.gitlab.com"]`):
    Registry in which the image will be copied to.
  - src (`package`):
    Derivation that contains the container image in [OCI Format][OCI_FORMAT_REPO].
  - tag (`str`):
    The tag under which the image will be stored in the registry.

Required environment variables:
- CI_REGISTRY_USER and CI_REGISTRY_PASSWORD, when deploying to GitLab.
- DOCKER_HUB_USER and DOCKER_HUB_PASS, when deploying to Docker Hub.
- GITHUB_ACTOR and GITHUB_TOKEN, when deploying to Github Container Registry.

Example `makes.nix`:

```nix
{ config
, ...
}:
{
  inputs = {
    nixpkgs = import <nixpkgs> { };
  };

  deployContainerImage = {
    enable = true;
    images = {
      nginxDockerHub = {
        src = config.inputs.nixpkgs.dockerTools.examples.nginx;
        registry = "docker.io";
        tag = "fluidattacks/nginx:latest";
      };
      redisGitHub = {
        src = config.inputs.nixpkgs.dockerTools.examples.redis;
        registry = "ghcr.io";
        tag = "fluidattacks/redis:$(date +%Y.%m)"; # Tag from command
      };
      makesGitLab = {
        src = config.outputs."container-image";
        registry = "registry.gitlab.com";
        tag = "fluidattacks/product/makes:$MY_VAR"; # Tag from env var
      };
    };
  };
```

Example invocation: `$ DOCKER_HUB_USER=user DOCKER_HUB_PASS=123 m .deployContainerImage.nginxDockerHub`

Example invocation: `$ GITHUB_ACTOR=user GITHUB_TOKEN=123 m .deployContainerImage.makesGitHub`

Example invocation: `$ CI_REGISTRY_USER=user CI_REGISTRY_PASSWORD=123 m .deployContainerImage.makesGitLab`

## Examples

### helloWorld

Small command for demo purposes, it greets the specified user:

Attributes:
- enable (`boolean`): Optional.
  Defaults to false.
- name (`string`): Required.
  Name of the user to greet.

Example `makes.nix`:

```nix
{
  helloWorld = {
    enable = true;
    name = "Jane Doe";
  };
}
```

Example invocation: `$ m .helloWorld 1 2 3`

# References

- [BLACK]: https://github.com/psf/black
  [Black][BLACK]

- [CI_CD]: https://en.wikipedia.org/wiki/CI/CD
  [CI/CD][CI_CD]

- [CIRCLE_CI]: https://circleci.com/
  [Circle CI][CIRCLE_CI]

- [DOCKER]: https://www.docker.com/
  [Docker][DOCKER]

- [GITHUB_ACTIONS]: https://github.com/features/actions
  [Github Actions][GITHUB_ACTIONS]

- [GITHUB_WORKFLOWS]: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions
  [Github Workflows][GITHUB_WORKFLOWS]

- [GITLAB_CI]: https://docs.gitlab.com/ee/ci/
  [GitLab CI][GITLAB_CI]

- [GITLAB_CI_REF]: https://docs.gitlab.com/ee/ci/yaml/
  [GitLab CI configuration syntax][GITLAB_CI_REF]

- [GITLAB_VARS]: https://docs.gitlab.com/ee/ci/variables/
  [GitLab Variables][GITLAB_VARS]

- [ISORT]: https://github.com/PyCQA/isort
  [isort][ISORT]

- [NIX]: https://nixos.org
  [Nix][NIX]

- [NIX_DOWNLOAD]: https://nixos.org/download
  [Nix Download Page][NIX_DOWNLOAD]

- [NIX_PLATFORMS]: https://nixos.org/manual/nix/unstable/installation/supported-platforms.html
  [Nix Supported Platforms][NIX_PLATFORMS]

- [OCI_FORMAT_REPO]: https://github.com/opencontainers/image-spec
  [Open Container Image specification][OCI_FORMAT_REPO]

- [SHFMT]: https://github.com/mvdan/sh
  [SHFMT][SHFMT]

- [TRAVIS_CI]: https://travis-ci.org/
  [Travis CI][TRAVIS_CI]

- [X86_64]: https://en.wikipedia.org/wiki/X86-64
  [x86-64][X86_64]
