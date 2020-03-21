FROM golang:alpine as lastpass-provider
# need to build the provider for musl

# TODO: should version this ...

RUN apk add --no-cache git
RUN go get github.com/nrkno/terraform-provider-lastpass
RUN go build github.com/nrkno/terraform-provider-lastpass
# binary at /go/bin/terraform-provider-lastpass

FROM hashicorp/terraform:light

RUN apk add --no-cache lastpass-cli bash
# TODO: need to figure out how to make ththe plugins dir not be in the mounted volume...
COPY --from=lastpass-provider /go/bin/terraform-provider-lastpass terraform.d/plugins/linux_amd64/terraform-provider-lastpass_v0.4.2