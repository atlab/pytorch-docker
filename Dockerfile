FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04
LABEL maintainer="Zhuokun Ding <zkding@outlook.com>"

# Deal with pesky Python 3 encoding issue
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Install essential Ubuntu packages
# and upgrade pip
RUN apt-get update &&\
    apt-get install -y software-properties-common \
                       build-essential \
                       git \
                       wget \
                       vim \
                       curl \
                       zip \
                       zlib1g-dev \
                       unzip \
                       pkg-config \
                       libblas-dev \
                       liblapack-dev \
                       python3-tk \
                       python3-wheel \
                       graphviz \
                       libhdf5-dev \
                       python3.8 \
                       python3.8-dev \
                       python3.8-distutils \
                       swig &&\
    apt-get clean &&\
    ln -s /usr/bin/python3.8 /usr/local/bin/python &&\
    ln -s /usr/bin/python3.8 /usr/local/bin/python3 &&\
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py &&\
    python3 get-pip.py &&\
    rm get-pip.py &&\
    # best practice to keep the Docker image lean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /src

# Install essential Python packages
RUN python3 -m pip --no-cache-dir install \
         blackcellmagic\
         pytest \
         pytest-cov \
         numpy \
         matplotlib \
         scipy \
         pandas \
         jupyterlab \
         ipywidgets \
         ipympl \
         scikit-learn \
         scikit-image \
         seaborn \
         graphviz \
         gpustat \
         h5py \
         gitpython \
         Pillow==6.1.0 \
         jupyter-dash
         
RUN python3 -m pip --no-cache-dir install \
        torch===1.7.0+cu110 \
        torchvision===0.8.1+cu110 \
        torchaudio===0.7.0 -f https://download.pytorch.org/whl/torch_stable.html

RUN python3 -m pip --no-cache-dir install datajoint~=0.12.0

# Install Node.js for rebuilding jupyter lab
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
RUN apt-get install -y nodejs

# Rebuilt jupyer lab
RUN jupyter lab build

# Add profiling library support
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:${LD_LIBRARY_PATH}

# Export port for Jupyter Notebook
EXPOSE 8888

WORKDIR /notebooks

# By default start bash
ENTRYPOINT ["/bin/bash"]