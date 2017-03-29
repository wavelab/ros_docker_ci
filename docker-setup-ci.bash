#!/bin/bash
set -e

build_container()
{
    echo "Building ROS-Docker container for ${DOCKER_DISTRO}..."
    bash ros_docker_ci/docker-build.sh ${DOCKER_DISTRO}
}

if [[ -d ${DOCKER_CACHE_DIR} ]]; then
    echo "Docker cache dir found."

    if [[ -f ${DOCKER_CACHE_DIR}/${DOCKER_DISTRO}_container.tar.gz ]]; then

        echo "Loading ${DOCKER_CACHE_DIR}/${DOCKER_DISTRO}_container.tar.gz..."
        docker load -i ${DOCKER_CACHE_DIR}/${DOCKER_DISTRO}_container.tar.gz

        if docker inspect "wavelab/ubuntu:${DOCKER_DISTRO}" > /dev/null 2>&1; then
            echo "wavelab/ubuntu:${DOCKER_DISTRO} docker image found."
        else
            echo "wavelab/ubuntu:${DOCKER_DISTRO} not found - was not in the tar.gz?"

            echo "Deleting the tar.gz file."
            rm ${DOCKER_CACHE_DIR}/${DOCKER_DISTRO}_container.tar.gz

            build_container
        fi
    else
        echo "Docker container for ${DOCKER_DISTRO} not found in ${DOCKER_CACHE_DIR}/."

        build_container
    fi
else
    echo "Docker cache dir not found."

    build_container
fi
