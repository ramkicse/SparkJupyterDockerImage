FROM avikdatta/basejupyterdockerimage
LABEL MAINTAINER 'reach4avik@yahoo.com'
ENV NB_USER vmuser
ENV NB_UID 1000
USER root
WORKDIR /root/
RUN mkdir -p /home/$NB_USER/tmp && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
    openjdk-8-jre-headless \
    ca-certificates-java \
    screen \
    netcat \
    unzip \
    libatlas-base-dev \
    gfortran               \
    sqlite3                \
    libhdf5-serial-dev     \
    g++ \
    liblz4-dev \
    libigraph0-dev  && \
    apt-get purge -y --auto-remove  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /home/$NB_USER/tmp
ENV TINI_VERSION v0.18.0
RUN wget --quiet  https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini && \
    mv tini /usr/local/bin/tini && \ 
    chmod +x /usr/local/bin/tini
COPY entrypoint.sh /home/$NB_USER/entrypoint.sh
COPY environment.yml /home/$NB_USER/environment.yml
RUN chown -R ${NB_UID} /home/$NB_USER && \
    chmod a+x /home/$NB_USER/entrypoint.sh && \
    chmod a+r /home/$NB_USER/environment.yml && \
     rm -rf /tmp/*
USER $NB_USER
WORKDIR /home/$NB_USER
ENV PATH $PATH:/home/$NB_USER/miniconda3/bin/
ENV NODE_OPTIONS --max-old-space-size=4096
RUN . /home/vmuser/miniconda3/etc/profile.d/conda.sh && \
    conda config --set safety_checks disabled && \
    conda update -n base -c defaults conda && \
    conda env create -q --file /home/$NB_USER/environment.yml && \
    echo ". /home/$NB_USER/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "source activate pipeline-env" >> ~/.bashrc && \
    conda clean -a -y && \
    conda activate pipeline-env && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@1.1 --no-build && \
    jupyter labextension install jupyterlab-plotly@4.6.0 --no-build && \
    jupyter labextension install plotlywidget@4.6.0 --no-build && \
    jupyter lab build && \
    rm -rf /home/$NB_USER/.cache && \
    rm -rf /home/$NB_USER/tmp && \
    mkdir -p /home/$NB_USER/tmp && \
    mkdir -p /home/$NB_USER/.cache
ENV NODE_OPTIONS ''
EXPOSE 8887
EXPOSE 8787
EXPOSE 4040
ENTRYPOINT [ "/usr/local/bin/tini","--","/home/vmuser/entrypoint.sh" ]
CMD ["notebook"]
