#! /bin/bash

# Copyright 2018-present Open Networking Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

kafkacat -u -C -b voltha-kafka.voltha -t voltha.events -D "" -o beginning -e | protoc --decode=voltha.Event /opt/voltha-kafka-dump/voltha-protos/protos/voltha_protos/events.proto -I /opt/voltha-kafka-dump/voltha-protos/protos
