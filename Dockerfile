FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04
MAINTAINER Daniel Laguna <dani@dani.codes>

# install dependencies. Source ubuntu/install_cmake.sh from openpose repo
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
	libopencv-dev \
	libeigen3-dev \
	python-numpy \
	python-protobuf \
	wget \
	git \
	cmake 

# compile openpose
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git
RUN cd openpose && mkdir build && cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release \
	-DDOWNLOAD_BODY_COCO_MODEL=ON \
	-DDOWNLOAD_BODY_MPI_MODEL=ON \
	-DUSE_3D_RENDERER=ON \
	-DWITH_EIGEN=APT_GET \
	.. && make -j8

WORKDIR /openpose
ENTRYPOINT ["./build/examples/openpose/openpose.bin"]
