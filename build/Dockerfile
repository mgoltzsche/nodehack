FROM alpine:3.11 AS nodehack
RUN apk add --update --no-cache ca-certificates
COPY nodehack /usr/local/bin/nodehack
ENV CERT_FILE=/ca-cert/ca.crt
ENTRYPOINT ["/usr/local/bin/nodehack", "/host"]

# Test
FROM nodehack
ENV HOST_PATH=/mockhost \
	CERT_NAME=fakecert \
	NAMESERVER=8.8.8.8 \
	DEBUG=x
RUN set -ex; \
	mkdir -p /ca-cert $HOST_PATH/usr/bin $HOST_PATH/etc; \
	echo fakecertcontents > /ca-cert/ca.crt; \
	echo 'nameserver 1.1.1.1' > $HOST_PATH/etc/resolv.conf; \
	cp -r /bin /lib $HOST_PATH/; \
	printf '#!/bin/sh\nsleep 20' > /bin/crio; \
	chmod +x /bin/crio; \
	crio & \
	nodehack $HOST_PATH setca setdns reloadcrio; \
	ls -la $HOST_PATH/etc/ssl/certs | \
		grep -Eq ' ca-cert-nodehack-ca-fakecert-[0-9a-f]+\.pem -> /usr/local/share/ca-certificates/nodehack-ca-fakecert-'; \
	ls $HOST_PATH/usr/local/share/ca-certificates | grep -q nodehack-ca-fakecert-; \
	[ "$(printf 'nameserver %s\nnameserver 1.1.1.1' $NAMESERVER)" = "$(cat $HOST_PATH/etc/resolv.conf)" ]; \
	[ "$(ls -a $HOST_PATH/usr/local/share/ca-certificates | wc -l)" -eq 3 ] || (ls -la $HOST_PATH/usr/local/share/ca-certificates;false); \
	[ ! -d "$HOST_PATH/etc/pki/ca-trust/source/anchors" ]; \
	\
	mkdir -p $HOST_PATH/etc/pki/ca-trust/source/anchors; \
	echo '#!/bin/sh' > $HOST_PATH/usr/bin/update-ca-trust; \
	chmod +x $HOST_PATH/usr/bin/update-ca-trust; \
	nodehack $HOST_PATH setca setdns reloadcrio; \
	[ "$(printf 'nameserver %s\nnameserver 1.1.1.1' $NAMESERVER)" = "$(cat $HOST_PATH/etc/resolv.conf)" ]; \
	[ "$(ls -a $HOST_PATH/etc/pki/ca-trust/source/anchors | wc -l)" -eq 3 ] || (ls -la $HOST_PATH/etc/pki/ca-trust/source/anchors;false); \
	[ "$(ls -a $HOST_PATH/usr/local/share/ca-certificates | wc -l)" -eq 3 ] || (ls -la $HOST_PATH/usr/local/share/ca-certificates;false)

FROM nodehack
