FROM golang:1.13.7-alpine3.11 as build

RUN \
  echo -e "\e[32madd build dependency packages\e[0m" \
  && apk --no-cache add \
    ca-certificates \
    git

WORKDIR /go/src/atlassian_upm_exporter

COPY atlassian_upm_exporter.go .

RUN \
  echo -e "\e[32m'go get' all build dependencies\e[0m" \
  && go get -v -d ./... \
  \
  && echo -e "\e[32mBuild the binary\e[0m" \
  && env GOOS=linux GOARCH=386 go build -v

FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /go/src/atlassian_upm_exporter/atlassian_upm_exporter /bin/

EXPOSE 9997

ENTRYPOINT ["/bin/atlassian_upm_exporter"]
