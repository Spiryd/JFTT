FROM alpine

WORKDIR /usr/calculator

RUN apk update && apk upgrade && apk add --update alpine-sdk && \
    apk add --no-cache bash git make cmake 
RUN apk add flex && apk add bison

COPY . .

RUN make
RUN make clean
