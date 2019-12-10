FROM confluentinc/cp-kafkacat:4.1.2

RUN apt-get update && apt-get install -y unzip curl git libatomic1

# Install protoc
RUN PROTOC_VERSION="3.7.0" && \
    PROTOC_SHA256SUM="a1b8ed22d6dc53c5b8680a6f1760a305b33ef471bece482e92728f00ba2a2969" && \
    curl -L -o /tmp/protoc-$PROTOC_VERSION-linux-x86_64.zip https://github.com/google/protobuf/releases/download/v$PROTOC_VERSION/protoc-$PROTOC_VERSION-linux-x86_64.zip && \
    echo "$PROTOC_SHA256SUM  /tmp/protoc-$PROTOC_VERSION-linux-x86_64.zip" | sha256sum -c - && \
    unzip /tmp/protoc-$PROTOC_VERSION-linux-x86_64.zip -d /tmp/protoc3 && \
    mv /tmp/protoc3/bin/* /usr/local/bin/ && \
    mv /tmp/protoc3/include/* /usr/local/include/ && \
    chmod -R a+rx /usr/local/bin/* && \
    chmod -R a+rX /usr/local/include/

WORKDIR /opt/voltha-kafka-dump

COPY voltha-dump-events.sh ./

# Install voltha-protos
RUN git clone https://github.com/opencord/voltha-protos.git
