FROM alpine:latest
MAINTAINER Ludovic MAILLET <ludovic.maillet@gmail.com>

EXPOSE 8118/tcp 9050/tcp

# Install tor and privoxy
RUN apk --no-cache --no-progress -U add privoxy tor runit tini							\
	&& mkdir -p /etc/service/privoxy/supervise /etc/service/tor/supervise				\
	&& echo "listen-address 0.0.0.0:8118"			>     /etc/service/privoxy/config   \
	&& echo "forward-socks5 / localhost:9050 ."		>>     /etc/service/privoxy/config	\
	&& echo "#!/bin/sh"								>     /etc/service/privoxy/run		\
	&& echo "privoxy --no-daemon"					>>     /etc/service/privoxy/run		\
	&& echo "SOCKSPort 0.0.0.0:9050"		                           >     /etc/service/tor/torrc	\
	&& echo "ExitNodes {ca},{us},{de},{nl} StrictNodes 0"              >>  /etc/service/tor/torrc   \
	&& echo "CircuitStreamTimeout 300"                                 >>  /etc/service/tor/torrc   \
	&& echo "ExitPolicy reject *:* #Pour ne pas être noeud de sortie"  >>  /etc/service/tor/torrc   \
	&& echo "#!/bin/sh"						>     /etc/service/tor/run					\
	&& echo "tor -f ./torrc"				>>     /etc/service/tor/run                 \
	&& echo "#!/bin/sh"								>     /usr/local/bin/entrypoint.sh	\
	&& echo "tini -- runsvdir /etc/service"        >>      /usr/local/bin/entrypoint.sh \
	&& chmod +x /usr/local/bin/entrypoint.sh                                            \
	&& chmod +x /etc/service/privoxy/run                                                \
	&& chmod +x /etc/service/tor/run

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
