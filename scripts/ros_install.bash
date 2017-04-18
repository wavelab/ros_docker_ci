#!/bin/bash
set -e  # exit on first error
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# get UBUNTU_CODENAME, ROS_DISTRO, REPO_DIR, CATKIN_DIR
source $SCRIPT_DIR/identify_environment.bash

ROSPACKAGES_DIR="$REPO_DIR/rospackages"

sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu $UBUNTU_CODENAME main\" > /etc/apt/sources.list.d/ros-latest.list"
wget -qO - http://packages.ros.org/ros.key | sudo apt-key add -

echo "Updating package lists ..."
sudo apt-get -qq update
echo "Installing ROS $ROS_DISTRO ..."
sudo apt-get -qq install python-catkin-pkg python-rosdep python-wstool ros-$ROS_DISTRO-catkin ros-$ROS_DISTRO-desktop > /dev/null
sudo apt-get -qq install ros-$ROS_DISTRO-pcl-ros ros-$ROS_DISTRO-image-transport ros-$ROS_DISTRO-image-transport-plugins ros-$ROS_DISTRO-libg2o > /dev/null

source /opt/ros/$ROS_DISTRO/setup.bash

# Prepare rosdep to install dependencies.
echo "Updating rosdep ..."
if [ ! -d /etc/ros/rosdep ]; then
    sudo rosdep init > /dev/null
fi

# Add Dataspeed packages
echo "Setting up Dataspeed apt and rosdep repositories"
bash <(wget -q -O - https://bitbucket.org/DataspeedInc/ros_binaries/raw/default/scripts/setup.bash)

rosdep update
sudo apt-get -qq install python-rosinstall

# Install system dependencies listed in ROS packages' package.xml
# Note: dependencies needed on embedded systems must still be included
# separately in the repo or cross-compiled stage.
if [ -d "$ROSPACKAGES_DIR" ]; then
    rosdep -q -y install --from-paths "$ROSPACKAGES_DIR" --ignore-src
else
    echo "Repository not detected: rosdep did not run"
fi
