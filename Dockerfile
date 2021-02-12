ARG TERRAFORMTAG

FROM golang:alpine as lastpass-provider
# need to build the provider for musl

RUN apk add --no-cache git
WORKDIR /src
# TODO: should version this ...

RUN git clone https://github.com/nrkno/terraform-provider-lastpass
WORKDIR /src/terraform-provider-lastpass
RUN go build .
# binary at /src/terraform-provider-lastpass/terraform-provider-lastpass

FROM hashicorp/terraform:${TERRAFORMTAG}

RUN apk add --no-cache lastpass-cli bash \
    && mkdir -p /terraform.d/plugins/linux_amd64
# TODO: need to figure out how to make the plugins dir not be in the mounted volume...
COPY --from=lastpass-provider /src/terraform-provider-lastpass/terraform-provider-lastpass /terraform.d/plugins/linux_amd64/terraform-provider-lastpass_v0.4.2

RUN adduser -u 1000 -D terraform