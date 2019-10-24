FROM alpine:latest
MAINTAINER RedOracle

# Metadata params
ARG BUILD_DATE
ARG VERSION
ARG VCS_URL
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION \
      org.label-schema.name='OpenVpn' \
      org.label-schema.description='Alpine Linux + OpenVpn.latest docker image' \
      org.label-schema.usage='https://www.redoracle.com' \
      org.label-schema.url='https://alpinelinux.org' \
      org.label-schema.vendor='Alpine' \
      org.label-schema.schema-version='1.0' \
      org.label-schema.docker.cmd='docker run --rm redoracle/openvpn:latest' \
      org.label-schema.docker.cmd.devel='docker run -i --rm --name OpenVpn -t redoracle/openvpn:latest' \
      org.label-schema.docker.debug='docker logs $CONTAINER' \
      io.github.offensive-security.docker.dockerfile="Dockerfile" \
      io.github.offensive-security.license="MIT" \
      MAINTAINER="RedOracle <info@redoracle.com>"

WORKDIR /root/

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
      && apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester \
      && ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin \
      && rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN /etc/openvpn \
EASYRSA /usr/share/easy-rsa \
EASYRSA_PKI $OPENVPN/pki \
EASYRSA_CRL_DAYS 3650 \
EASYRSA_VARS_FILE $OPENVPN/vars

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
