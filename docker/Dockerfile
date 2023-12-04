# To build the Docker container, run the following lines from your proteus root directory:
# cd docker
# docker build --rm -t proteus:latest .

# Get ubuntu base image
FROM ubuntu:22.04

# This is needed or it mpiexec complains because docker runs as root
# Discussion on this issue https://github.com/open-mpi/ompi/issues/4451
ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

# By default, four cores are used to compile
ARG compile_cores=4

# Install apt dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
    gcc \
    g++ \
    gfortran \
    cmake \
    bison \
    flex \
    git \
    python3 \
    python3-dev \
    python-is-python3 \
    python3-packaging \
    openmpi-bin \
    libopenmpi-dev \
    libboost-all-dev

# Build Proteus
RUN cd /$WORKDIR && \
    git clone https://github.com/aurora-multiphysics/proteus.git && \
    cd proteus && \
    ./scripts/install_ubuntu.sh && \
    source ~/.moose_profile

# Run tests
RUN cd /proteus && \
    ./run_tests
