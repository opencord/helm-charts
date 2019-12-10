#! /bin/bash
kafkacat -u -C -b voltha-kafka.voltha -t voltha.events -D "===VOLTHA-DELIM===" -o beginning -e | python -u ./callprotoc.py voltha.Event /opt/voltha-kafka-dump/voltha-protos/protos/voltha_protos/events.proto /opt/voltha-kafka-dump/voltha-protos/protos
