WD = $(readlink -f "$0")
SPATH = $(dirname "$WD")
CONFIGDIR = "/usr/local/openresty/nginx/config/"
rm -f "${CONFIGDIR}/nginx.conf"
cp "${SPATH}/config/nginx.conf" $CONFIGDIR
