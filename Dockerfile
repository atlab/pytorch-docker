FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
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
                       python3-dev \
                       python3-pip \
                       python3-tk \
                       python3-wheel \
                       graphviz \
                       libhdf5-dev \
                       swig &&\
    ln -s /usr/bin/python3 /usr/local/bin/python &&\
    ln -s /usr/bin/pip3 /usr/local/bin/pip &&\
    pip install --upgrade pip &&\
    apt-get clean &&\
    # best practice to keep the Docker image lean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

WORKDIR /src

# install miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh &&\
    bash ~/miniconda.sh -b -p /root/miniconda &&\
    eval "$(/root/miniconda/bin/conda shell.bash hook)" &&\
    conda init &&\
    conda install xeus-python notebook -c conda-forge &&\
    conda install pip

# Install essential Python packages
RUN pip --no-cache-dir install \
         pytest \
         numpy \
         matplotlib \
         scipy \
         pandas \
         scikit-learn \
         seaborn \
         graphviz \
         gpustat \
         h5py \
         https://download.pytorch.org/whl/cu100/torch-1.1.0-cp36-cp36m-linux_x86_64.whl \
         https://download.pytorch.org/whl/cu100/torchvision-0.3.0-cp36-cp36m-linux_x86_64.whl \
         jupyter \
         jupyterlab \
         ipympl
RUN pip --no-cache-dir install --upgrade datajoint~=0.11.0
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash - &&\
    apt-get install -y nodejs &&\
    curl -L https://npmjs.org/install.sh | sh

# install jupyterlab extensions
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager &&\
    jupyter labextension install jupyter-matplotlib &&\
    jupyter labextension install @jupyterlab/debugger &&\
    jupyter nbextension enable --py widgetsnbextension


# Add profiling library support
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:${LD_LIBRARY_PATH}

# Export port for Jupyter Notebook
EXPOSE 8888
RUN jupyter serverextension enable --py jupyterlab --sys-prefix
WORKDIR /notebooks

# By default start bash
ENTRYPOINT ["/bin/bash"]
