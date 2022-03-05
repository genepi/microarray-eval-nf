FROM continuumio/miniconda3:4.9.2


#RUN apt-get update && apt-get install -y \
#  libopenblas-dev \
#  && rm -rf /var/lib/apt/lists/*

COPY environment.yml .
RUN conda env update -n root -f environment.yml && conda clean -a

# Install jbang (not as conda package available)
WORKDIR "/opt"
RUN wget https://github.com/jbangdev/jbang/releases/download/v0.59.0/jbang.zip && \
    unzip -q jbang.zip && \
    rm jbang.zip
ENV PATH="/opt/jbang/bin:${PATH}"

# Install imputation bot
RUN wget https://github.com/lukfor/imputationbot/releases/download/v0.9.4/imputationbot-0.9.4-linux.zip && \
    unzip -q imputationbot-0.9.4-linux.zip && \
    rm imputationbot-0.9.4-linux.zip && \
    ./imputationbot version
ENV PATH="/opt:${PATH}"
