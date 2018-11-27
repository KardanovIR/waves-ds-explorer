FROM ubuntu:18.04

ENV NETWORK_BYTE = 'C'
ENV NODE_API_URI = 'http://localhost:6816'
ENV BLOCKCHAIN_NAME = 'Devnet'
ENV NODES_LIST = ''
ENV DATA_SERVICES_PORT = '8080'
ENV BLOCKCHAIN_HEIGHT = 1000

COPY ./generateExplorerConfig.py /var/src/generateExplorerConfig.py
COPY ./generateDataServiceConfig.py /var/src/generateDataServiceConfig.py
COPY ./entrypoint.sh /

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
        wget \
        curl \
        openssh-server \
        software-properties-common \
        nano \
        git \
        sudo \
        tzdata


RUN apt-get update && \
        apt-get -qy upgrade && \
        apt-get install -qy language-pack-en-base && \
        locale-gen en_US.UTF-8 && \
        locale-gen ru_RU.UTF-8


ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install python
RUN apt-get update -y && apt-get install -y python3 \
    python3-pip \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip
RUN pip3 install requests pyhocon pyyaml

# add nodejs
RUN apt-get install curl
RUN curl -o node_installer.sh  https://deb.nodesource.com/setup_10.x
RUN sh node_installer.sh
RUN apt-get install -y nodejs
RUN npm install -g forever
RUN npm install -g gulp-cli
RUN npm install -g pm2
RUN npm install -g yarn
RUN npm install -g bower --allow-root

# add postgresql repo
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/PostgreSQL.list'

# install postgresql
RUN apt-get update && DEBIAN_FRONTEND=noninteractive sudo apt-get -y -q install postgresql-10

# create db
USER postgres
RUN service postgresql start && psql --command "ALTER USER postgres PASSWORD 'APASSWORD';"
RUN service postgresql start && psql --command "CREATE DATABASE dataservices WITH OWNER = postgres ENCODING = 'UTF8' TABLESPACE = pg_default TEMPLATE=template0 LC_COLLATE = 'ru_RU.UTF-8' LC_CTYPE = 'ru_RU.UTF-8' CONNECTION LIMIT = -1;"
USER root

RUN mkdir -p /var/src
WORKDIR /var/src


# Run Explorer
RUN git clone https://github.com/wavesplatform/WavesExplorerLite
WORKDIR WavesExplorerLite
RUN echo '{ "allow_root": true }' > /root/.bowerrc
RUN sudo npm install --allow-root


# Run Data Services
WORKDIR /var/src
RUN git clone https://github.com/wavesplatform/blockchain-postgres-sync
WORKDIR blockchain-postgres-sync
RUN npm install


# upload schema
USER postgres
RUN service postgresql start && psql -f schema.sql dataservices
USER root

# run blockchain-postgres-sync
# install data-service
WORKDIR /var/src
RUN git clone https://github.com/wavesplatform/data-service
WORKDIR data-service
RUN ls
RUN yarn install

RUN echo 'PGHOST=localhost \n\
PGDATABASE=dataservices \n\
PGUSER=postgres \n\
PGPASSWORD=APASSWORD' > variables.env

RUN chmod 777 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
