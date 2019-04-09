FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04
MAINTAINER Daniel Laguna <dani@dani.codes>

# get rid of tzdata user input need
ENV DEBIAN_FRONTEND=noninteractive

# install dependencies. Source scripts/ubuntu/install_deps.sh from openpose repo
RUN apt-get update && apt-get install -y \
	build-essential \
	libatlas-base-dev \
	libprotobuf-dev \
	libleveldb-dev \
	libsnappy-dev \
	libhdf5-serial-dev \
	protobuf-compiler \
	libboost-all-dev \
	libgflags-dev \
	libgoogle-glog-dev \
	liblmdb-dev \
	python-setuptools \
	python-dev \
	python-pip \
	python3-setuptools \
	python3-dev \
	python3-pip \
	opencl-headers \
	ocl-icd-opencl-dev \
	libviennacl-dev \
	libopencv-dev \
	freeglut3 \
	freeglut3-dev \
	libxmu-dev \
	libxi-dev \
	libsuitesparse-dev \
	wget \
	git

# cmake version in the official repo provokes some compiling errors. Versions
# higher than 3.12 are required
RUN wget https://github.com/Kitware/CMake/releases/download/v3.14.1/cmake-3.14.1.tar.gz 
RUN tar -xvzf cmake-3.14.1.tar.gz
RUN cd cmake-3.14.1 && ./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release && make -j8 && make install
RUN rm -rf cmake-3.14.1 cmake-3.14.1.tar.gz

# install python libraries
RUN pip install --upgrade numpy protobuf opencv-python
RUN pip3 install --upgrade numpy protobuf opencv-python

# clone openpose
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git

# first download the available models
RUN cd openpose/models/ && ./getModels.sh

# update eigen3 to newer version than the ubuntu repository has to solve cuda compat
RUN wget http://bitbucket.org/eigen/eigen/get/3.3.7.tar.gz && tar -xvzf 3.3.7.tar.gz && \
	cd eigen-eigen-323c052e1731 && mkdir build && cd build && cmake .. && make install

# install ceres solver
RUN wget http://ceres-solver.org/ceres-solver-1.14.0.tar.gz && tar -xvzf ceres-solver-1.14.0.tar.gz && \
	cd ceres-solver-1.14.0 && mkdir build && cd build && cmake .. && make -j8 && make install

# generate openpose binaries
RUN cd openpose && mkdir build && cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release \
	-DDOWNLOAD_BODY_COCO_MODEL=ON \
	-DDOWNLOAD_BODY_MPI_MODEL=ON \
	-DWITH_3D_RENDERER=ON \
	-DWITH_CERES=ON \
	-DWITH_EIGEN=APT_GET \
	.. && make -j8

WORKDIR /openpose
ENTRYPOINT ["./build/examples/openpose/openpose.bin"]
