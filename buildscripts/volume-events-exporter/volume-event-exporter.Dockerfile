# Copyright 2021 The MayaData Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM golang:1.16.0 as build

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT=""
ARG RELEASE_TAG

ENV GO111MODULE=on \
  CGO_ENABLED=0 \
  GOOS=${TARGETOS} \
  GOARCH=${TARGETARCH} \
  GOARM=${TARGETVARIANT} \
  DEBIAN_FRONTEND=noninteractive \
  PATH="/root/go/bin:${PATH}" \
  RELEASE_TAG=${RELEASE_TAG}

WORKDIR /go/src/github.com/mayadata-io/volume-events-exporter/

RUN apt-get update && apt-get install -y make git

COPY go.mod go.sum ./
# Get dependancies - will also be cached if we won't change mod/sum
RUN go mod download

COPY . .

RUN make volume-events-exporter-bin

FROM alpine:3.12.0

ARG DBUILD_DATE
ARG DBUILD_REPO_URL
ARG DBUILD_SITE_URL
LABEL org.label-schema.name="volume-events-exporter"
LABEL org.label-schema.description="Volume Events Exporter for OpenEBS Persistent Volumes"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$DBUILD_DATE
LABEL org.label-schema.vcs-url=$DBUILD_REPO_URL
LABEL org.label-schema.url=$DBUILD_SITE_URL

COPY --from=build /go/src/github.com/mayadata-io/volume-events-exporter/bin/volume-events-exporter/volume-events-exporter /usr/local/bin/volume-events-exporter

ENTRYPOINT ["/usr/local/bin/volume-events-exporter"]
