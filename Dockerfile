# docker build -t lfpy:latest .
FROM ubuntu:20.10

LABEL maintainer "An-Cheng Yang<acyang0903@gmail.com>"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Asia/Taipei

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY lfpy.yml /root

RUN apt-get update --fix-missing && \
    apt-get install --no-install-recommends -y wget unzip bzip2 ca-certificates curl git apt-utils gnupg pkg-config vim && \
    curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > /tmp/conda.gpg && \
    install -o root -g root -m 644 /tmp/conda.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" > /etc/apt/sources.list.d/conda.list && \
    apt-get update --fix-missing && \
    apt-get install --no-install-recommends -y conda && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

ENV PATH /opt/conda/bin:$PATH

RUN conda config --add channels conda-forge && \
    conda env create -f /root/lfpy.yml && \
    conda clean -a -y && \
    /opt/conda/envs/lfpy/bin/jupyter-lab --generate-config && \
    sed -i "s/# c.NotebookApp.tornado_settings = {}/c.NotebookApp.tornado_settings = {'headers':{'Content-Security-Policy':\"frame-ancestors http:\/\/*.*.*.* 'self'\"}}/g" /root/.jupyter/jupyter_lab_config.py

RUN conda run -n lfpy pip install MEArec csa parameters NeuroTools elephant

RUN conda run -n lfpy jupyter labextension install jupyterlab-plotly @jupyter-widgets/jupyterlab-manager plotlywidget

ENV PATH /opt/conda/envs/lfpy/bin:$PATH

RUN mkdir -p /src && cd /src && \
    git clone https://github.com/alejoe91/MEArec.git
