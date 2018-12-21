{{- /*
Copyright 2017-present Open Networking Foundation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/ -}}

{{- define "voltha-vcore.cmd" }}
- "voltha/voltha/main.py"
- "--etcd={{ .Values.etcdReleaseName }}.default.svc.cluster.local:2379"
- "--kafka={{ .Values.kafkaReleaseName }}.default.svc.cluster.local"
- "--rest-port=8880"
- "--grpc-port=50556"
- "--interface=eth1"
- "--backend=etcd"
- "--pon-subnet=10.38.0.0/12"
- "--ponsim-comm=grpc"
- "--core-number-extractor=^.*-([0-9]+)_.*$"
{{- end }}

{{- define "logconfig.yml" }}
version: 1

formatters:
  default:
    format: '%(asctime)s.%(msecs)03d %(levelname)-8s %(threadName)s %(module)s.%(funcName)s %(message)s'
    datefmt: '%Y%m%dT%H%M%S'

handlers:
  console:
    class : logging.StreamHandler
    formatter: default
    stream: ext://sys.stdout
  localRotatingFile:
    class: logging.handlers.RotatingFileHandler
    filename: voltha.log
    formatter: default
    maxBytes: 2097152
    backupCount: 10
  kafka:
    class: kafkaloghandler.KafkaLogHandler
    bootstrap_servers:
      - "{{ .KafkaServer }}"
    topic: "voltha.log.{{ .KafkaTopic }}"

loggers:
  '':
    handlers: [console, localRotatingFile, kafka]
    level: {{ .loglevel }}
    propagate: False
{{- end }}
