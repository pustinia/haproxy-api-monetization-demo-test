FROM haproxytech/haproxy-ubuntu:2.3
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y git
RUN git clone https://github.com/haproxytech/haproxy-lua-jwt.git
RUN cd haproxy-lua-jwt && chmod +x ./install.sh && ./install.sh luajwt
CMD ["haproxy", "-d", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]