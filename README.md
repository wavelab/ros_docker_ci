# ros_docker_ci

This repository contains the necessary scripts and docker files to set up a
docker container that allows for CI testing in a Ubuntu/ROS environment of
either:

* trusty/indigo
* xenial/kinetic

Currently, Travis-CI only natively supports up to trusty/indigo.

As many repositories depend on a CI environment that has ROS, this repository
aims to factor out the common elements of that requirement so that separate
docker setups do not need to be wholly maintained for every repository that uses
them.
