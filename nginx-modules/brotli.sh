yum -y install gcc pcre-devel openssl openssl-devel
RUN cd /root && git clone https://github.com/google/ngx_brotli && \
    cd ngx_brotli && git submodule update --init
RUN cd /root

