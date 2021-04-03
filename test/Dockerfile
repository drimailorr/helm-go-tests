FROM golang:1.16.2-alpine

RUN apk add --no-cache git curl openssl bash
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod +x get_helm.sh && ./get_helm.sh

WORKDIR /app/test/
COPY test/go.mod .
COPY test/go.sum .
RUN go mod download
COPY test/ .

WORKDIR /app/examples/
COPY ./examples/ .

WORKDIR /app/test/
ENTRYPOINT ["sh", "-c", "CGO_ENABLED=0 go test -v -tags helm"]
