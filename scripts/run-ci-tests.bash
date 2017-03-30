#!/bin/bash

set -e  # exit on first error

source /opt/ros/${ROS_DISTRO}/setup.bash
source /ros_docker_ci/scripts/identify_environment.bash

sudo apt-get update

cd ${CATKIN_DIR}

catkin build --no-status
