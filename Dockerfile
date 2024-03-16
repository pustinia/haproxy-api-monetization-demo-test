FROM haproxytech/haproxy-ubuntu:2.9
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y git
RUN git clone https://github.com/haproxytech/haproxy-lua-oauth.git
RUN cd haproxy-lua-oauth && chmod +x ./install.sh && ./install.sh luaoauth
CMD ["haproxy", "-d", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
