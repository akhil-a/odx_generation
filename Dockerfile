# Set the base image to Ubuntu
FROM ubuntu

RUN apt-get update && apt-get install -y build-essential vim libarchive-zip-perl
RUN mkdir ODX_AUTOMATION 
WORKDIR ODX_AUTOMATION
copy . .
#Install Libsodium.s0.23.1.0
WORKDIR /ODX_AUTOMATION/
RUN tar -xvzf libsodium-stable-2018-12-03.tar.gz
WORKDIR /ODX_AUTOMATION/libsodium-stable
RUN ./configure \
	&& make && make check \
	&& make install 

RUN ln -s /usr/local/lib/libsodium.so /usr/lib/libsodium.so \
	&& ln -s /usr/local/lib/libsodium.so.23 /usr/lib/libsodium.so.23 \
	&& ln -s /usr/local/lib/libsodium.so.23.1.0 /usr/lib/libsodium.so.23.1.0
#Install libboost
WORKDIR /ODX_AUTOMATION/
RUN dpkg -i libboost-system1.58.0_1.58.0+dfsg-5ubuntu3_amd64.deb 
RUN dpkg -i libboost-filesystem1.58.0_1.58.0+dfsg-5ubuntu3_amd64.deb

RUN rm -rf /ODX_AUTOMATION/* && mkdir /ODX_AUTOMATION/Inputs
COPY Inputs/* /ODX_AUTOMATION/Inputs/
COPY odx_generation_script.sh /ODX_AUTOMATION/
