# Example for PHP 7.3 FPM infrastructure

See https://github.com/acgrid/docker-multi-stage-builder if you need to know the compiler used.

## Try me
```bash
git clone https://github.com/acgrid/n-php-docker.git
cd n-php-docker
docker build -t n-php-docker .
```
## Show configuration
After built successfully, run:
```bash
docker run --rm n-php-docker php -m # Show extension
docker run --rm n-php-docker php -i # Show phpinfo
```

## PHP Extensions bundled
```
[PHP Modules]
apcu
bcmath
bz2
calendar
cg_bcode
Core
ctype
curl
date
dom
fileinfo
filter
gd
gettext
gmp
hash
iconv
json
libxml
maxminddb
mbstring
mysqli
mysqlnd
openssl
pcntl
pcre
PDO
pdo_mysql
pdo_sqlite
Phar
posix
readline
redis
Reflection
session
shmop
SimpleXML
soap
sockets
sodium
SPL
sqlite3
standard
sysvsem
sysvshm
tokenizer
xml
xmlreader
xmlrpc
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```