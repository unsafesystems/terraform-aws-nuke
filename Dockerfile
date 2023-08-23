FROM alpine:3.18.3

ARG NUKE_VERSION=2.22.1

ARG TARGETARCH
RUN apk add --no-cache ca-certificates && \
	wget https://github.com/rebuy-de/aws-nuke/releases/download/v${NUKE_VERSION}/aws-nuke-v${NUKE_VERSION}-linux-$TARGETARCH.tar.gz && \
    tar -xvf aws-nuke-v${NUKE_VERSION}-linux-$TARGETARCH.tar.gz && \
	mv aws-nuke-v${NUKE_VERSION}-linux-$TARGETARCH /usr/local/bin/aws-nuke && \
	rm aws-nuke-v${NUKE_VERSION}-linux-$TARGETARCH.tar.gz

COPY scripts/bootstrap.sh /usr/local/bin/bootstrap
COPY scripts/nuke.sh /usr/local/bin/nuke
COPY scripts/prepare.sh /usr/local/bin/prepare

RUN adduser -D aws-nuke

USER aws-nuke
WORKDIR /home/aws-nuke

CMD ["bootstrap"]