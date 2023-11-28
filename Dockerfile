FROM ubuntu:18.04
COPY environment.yml .

#  Install miniconda
RUN  apt-get update && apt-get install -y wget
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_23.9.0-0-Linux-x86_64.sh -O ~/miniconda.sh && \
  /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=/opt/conda/bin:${PATH}

RUN conda update -y conda
RUN conda env update -n root -f environment.yml

# Install software
RUN apt-get update && \
    apt-get install -y build-essential && \
    apt-get install -y procps && \
    apt-get install -y libgsl-dev && \
    apt-get install -y tabix && \
    apt-get install -y zlib1g-dev liblzma-dev libbz2-dev libxau-dev
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install jbang (not as conda package available)
WORKDIR "/opt"
RUN wget https://github.com/jbangdev/jbang/releases/download/v0.91.0/jbang-0.91.0.zip && \
    unzip -q jbang-*.zip && \
    mv jbang-0.91.0 jbang  && \
    rm jbang*.zip
ENV PATH="/opt/jbang/bin:${PATH}"

# Install imputation bot
RUN wget https://github.com/lukfor/imputationbot/releases/download/v0.9.4/imputationbot-0.9.4-linux.zip && \
    unzip -q imputationbot-0.9.4-linux.zip && \
    rm imputationbot-0.9.4-linux.zip && \
    ./imputationbot version
ENV PATH="/opt:${PATH}"

# Install imputation
WORKDIR "/opt/imputationserver"
RUN wget https://github.com/genepi/imputationserver/releases/download/v1.6.7/imputationserver.zip && \
    unzip -q imputationserver.zip  && \
    rm imputationserver.zip
ENV PATH="/opt/imputationserver:${PATH}"

# Install bcftools
ENV BCFTOOLS_VERSION=1.13
WORKDIR "/opt"
RUN wget https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2  && \
    tar xvfj bcftools-${BCFTOOLS_VERSION}.tar.bz2 && \
    cd  bcftools-${BCFTOOLS_VERSION}  && \
    ./configure  && \
    make && \
    make install
