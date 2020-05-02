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
                       graphviz \
                       libhdf5-dev \
                       swig &&\
    apt-get clean &&\
    # best practice to keep the Docker image lean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

WORKDIR /src

# install miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

ENV PATH=/opt/conda/bin:$PATH

RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate base && \
    conda install -y pip numpy pyyaml scipy matplotlib pandas scikit-learn seaborn pytest graphviz h5py jupyter jupyterlab ipympl ipython mkl mkl-include ninja cython typing && \
    conda install -y pytorch==1.1.0 torchvision==0.3.0 cudatoolkit=10.0 -c pytorch && \
    conda install -y xeus-python notebook -c conda-forge && \
    conda clean -ya
# Install essential Python packages
RUN pip --no-cache-dir install \
         gpustat

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
