##
# User.restartLighttpd
# Restartet den Lighttpd Webserver
#
# Parameter:
#   keine
#
# R�ckgabewert: true

exec echo "restart-lighttpd" | socat - UNIX-CONNECT:/tmp/eq3-services.uds >/dev/null
#exec -- /usr/bin/nohup /etc/init.d/S50lighttpd restart >/dev/null
#exec /etc/init.d/S50lighttpd restart

jsonrpc_response true
