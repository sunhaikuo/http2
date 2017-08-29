#！/bin/bash
echo "安装依赖库和编译要用到的工具"
sudo apt-get install build-essential libpcre3 libpcre3-dev zlib1g-dev unzip git

echo "安装nginx-ct"
wget -O nginx-ct.zip -c https://github.com/grahamedgecombe/nginx-ct/archive/v1.3.2.zip
unzip nginx-ct.zip

echo "安装ngx_brotli"
sudo apt-get install autoconf libtool automake
git clone https://github.com/bagder/libbrotli
cd libbrotli
# 如果提示 error: C source seen but 'CC' is undefined，可以在 configure.ac 最后加上 AC_PROG_CC
./autogen.sh
./configure
make
sudo make install
cd  ../

echo "获取 ngx_brotli 源码"
git clone https://github.com/google/ngx_brotli.git
cd ngx_brotli
git submodule update --init
cd ../

echo "Cloudflare 补丁"
git clone https://github.com/cloudflare/sslconfig.git

echo "获取OpenSSL1.0.2"
wget -O openssl.tar.gz -c https://github.com/openssl/openssl/archive/OpenSSL_1_0_2k.tar.gz
tar zxf openssl.tar.gz
mv openssl-OpenSSL_1_0_2k/ openssl
cd openssl
patch -p1 < ../sslconfig/patches/openssl__chacha20_poly1305_draft_and_rfc_ossl102j.patch 
cd ../

echo "获取nginx"
wget -c https://nginx.org/download/nginx-1.11.13.tar.gz
tar zxf nginx-1.11.13.tar.gz
cd nginx-1.11.13/
patch -p1 < ../sslconfig/patches/nginx__1.11.5_dynamic_tls_records.patch
cd ../

echo "编译和安装nginx"
cd nginx-1.11.13/
./configure --add-module=../ngx_brotli --add-module=../nginx-ct-1.3.2 --with-openssl=../openssl --with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module
make
sudo make install













