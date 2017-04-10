# ros_docker_ci

This repository encapsulates the necessary scripts and docker files to set up a
docker container for use in Travis-CI that supports testing in a Ubuntu/ROS
environment of either:

* trusty/indigo
* xenial/kinetic

An example illustrating its usage can be found at the
[ros_docker_ci_demo](https://github.com/wavelab/ros_docker_ci_demo) repo.

## Authors

* Michael Smart (Maintainer)
* Alex Tomala

## Quick Start Instructions

1) Submodule this repository into the user repo:

```bash
git submodule add https://github.com/wavelab/ros_docker_ci.git REPO/RELATIVE/PATH
```

2) Create two scripts in the user repo that do CI tasks. The first is 
`scripts/install_deps_for_docker_ci.bash` which needs to install all of the user
repo's dependencies. The second is a script that performs the desired CI tasks
on a container where the dependencies have been installed and the repo is
located at root. You can specify this CI-scripts location in (3)

3) Copy the `.travis.yml` file from the
[ros_docker_ci_demo](https://github.com/wavelab/ros_docker_ci_demo) repo. Change
all of the items in it marked as 'MODIFY_ME'.

Done!

## Verbose Usage Instructions

An example illustrating the use of this repository can be found at
the [ros_docker_ci_demo](https://github.com/wavelab/ros_docker_ci_demo) repo.

The following instructions will replicate creating the setup used in the demo
repo.

### Submoduling

If using this repo as a submodule, use the `git submodule add` command within
your repository's root folder to add this repo as a submodule:

```bash
git submodule add https://github.com/wavelab/ros_docker_ci.git REPO/RELATIVE/PATH
```

For example:
```bash
git submodule add https://github.com/wavelab/ros_docker_ci.git dependencies/ros_docker_ci
```

to place the submodule at `dependencies/ros_docker_ci`

### Required CI scripts

`ros_docker_ci` has two requirements of your project structure for its use:

1) `scripts/install_deps_for_docker_ci.bash`

The project must contain a `scripts/install_deps_for_docker_ci.bash` script to
direct the installation of repository dependencies inside the docker container.
Other than the barebones items indicated in the
[dockerfile](https://github.com/wavelab/ros_docker_ci/blob/master/trusty/Dockerfile),
this script is the only installation script that will be run. Ideally your
repository XYZ will already contain an `install_all_XYZ_dependencies.bash` style
script that installs everything (including ros), and then the version of 
`scripts/install_deps_for_docker_ci.bash` that you provide only needs to wrap a
call to such a dependency install script.

2) A CI test script

In addition to (1), your repository must provide a singular script that can be
called to run the entire CI process for an environment that already has all
dependencies installed.

For example, the demo repo has the script `scripts/run-ci-tests.bash` which
sources the relevant ros `setup.bash` script, runs the utility script to
identify relevant environment variables, and then simply runs `catkin build` to
confirm compilation without tests.

```bash
#!/bin/bash
set -e  # exit on first error

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source /opt/ros/${ROS_DISTRO}/setup.bash
# get UBUNTU_CODENAME, ROS_DISTRO, REPO_DIR, CATKIN_DIR
source $SCRIPT_DIR/identify_environment.bash

sudo apt-get update

cd ${CATKIN_DIR}

catkin build --no-status
```

The CI test script does not require a specific name or location. You will
provide them in the `.travis.yml` file as parameters to `ros_docker_ci`'s docker
scripts.

NOTE: The docker scripts will be mounted to the same location in the docker
container as they appear in the Travis-CI build. Accordingly, scripts should not
rely on a specific absolute location and should determine paths automatically
where required.

### The `.travis.yml` file

A minimal example `travis.yml` file  where `ros_docker_ci` is located at
`dependencies/ros_docker_ci` is shown below:

```bash
# Use ubuntu trusty (14.04) with sudo privileges.
dist: trusty
sudo: required

# Set build matrix and global CI env variables
env:
  global:
  - DOCKER_CACHE_DIR=$HOME/docker_cache
  - DOCKER_CI_REL_DIR=dependencies/ros_docker_ci
  matrix:
    - DOCKER_DISTRO=trusty
    - DOCKER_DISTRO=xenial

before_install:
  - git submodule init
  - git submodule -q update

install:
  - travis_wait 45 bash ${DOCKER_CI_REL_DIR}/docker-setup-ci.bash

script:
  - bash ${DOCKER_CI_REL_DIR}/docker-run-ci.bash scripts/run-ci-tests.bash

before_cache:
  - bash ${DOCKER_CI_REL_DIR}/save-docker-cache-ci.bash

cache:
  directories:
    - $HOME/docker_cache
  timeout: 1200
```

#### Environment Setup

The snippet

```bash
# Use ubuntu trusty (14.04) with sudo privileges.
dist: trusty
sudo: required

# Set build matrix and global CI env variables
env:
  global:
  - DOCKER_CACHE_DIR=$HOME/docker_cache
  - DOCKER_CI_REL_DIR=dependencies/ros_docker_ci
  matrix:
    - DOCKER_DISTRO=trusty
    - DOCKER_DISTRO=xenial
```

configures the baseline travis-ci environment. Specific to `ros_docker_ci` are
the following variables:

* `DOCKER_CACHE_DIR`: this sets where the docker container will be cached
between builds. Depending on the dependencies required, caching the docker
container can save a significant amount of time on the travis-CI builds.
* `DOCKER_CI_REL_DIR`: this sets where the `ros_docker_ci` container is located.
It is a relative path that is based from the user repo's root.
* `DOCKER_DISTRO`: this variable is set in a build matrix to dictate what set of
distribution confugrations to be built for CI testing. In this example, both
trusty and xenial will be built as separate travis-CI jobs.

#### Install

The snippet

```bash
before_install:
  - git submodule init
  - git submodule -q update

install:
  - travis_wait 45 bash ${DOCKER_CI_REL_DIR}/docker-setup-ci.bash
```

handles the `before_install` and `install` phases of the travis build. The git
submodule commands make sure that `ros_docker_ci` as well as any other required
submodules are ready for the build.

The command:

```bash
  - travis_wait 45 bash ${DOCKER_CI_REL_DIR}/docker-setup-ci.bash
```

Locates `ros_docker_ci` and executes its `docker-setup-ci.bash` script. The
script first checks the cache for a docker container, and loads it if a valid
one is found. Otherwise the script runs the
`scripts/install_deps_for_docker_ci.bash` script provided by the user repo to
install dependencies in a newly created docker container.

#### Script

The snippet

```bash
script:
  - bash ${DOCKER_CI_REL_DIR}/docker-run-ci.bash scripts/run-ci-tests.bash
```

handles the `script` phase of the travis build. The `docker-run-ci.bash` script
takes 1 argument that must be specified here: the user repo's CI script that is
used to perform the CI tasks and is given as a repo-relative path.

#### Caching

The snippet

```bash
before_cache:
  - bash ${DOCKER_CI_REL_DIR}/save-docker-cache-ci.bash

cache:
  directories:
    - $HOME/docker_cache
  timeout: 1200
```

handles Travis-CI's cache usage. If the docker container was rebuilt by the
`docker-setup-ci.bash` script, then the updated container will be added to the
cache directory. The cache directory set in the `cache:` segment must contain
the directory specified by `DOCKER_CACHE_DIR`.
